# 黑幕背后的 Autorelease

> 文摘来源：[sunnyxx 的博客：《黑幕背后的 Autorelease》](http://blog.sunnyxx.com/2014/10/15/behind-autorelease/)，有增删。
>  
> 说明：该博客的图片外链已失效（用的微博图床，第三方图床果然靠不住。。），不过可在 [Internet Archive](https://web.archive.org/web/20180727060528/http://blog.sunnyxx.com/2014/10/15/behind-autorelease/) 中找到原图。

Autorelease 机制是 iOS 开发者管理对象内存的好伙伴，

- 在 MRC 中，调用 `[obj autorelease]` 来延迟内存的释放是一件简单自然的事；
- 在 ARC 中，我们甚至可以完全不知道 Autorelease 就能管理好内存。

而在这背后，objc 和编译器都帮我们做了哪些事呢，它们是如何协作来正确管理内存的呢？刨根问底，一起来探究下黑幕背后的 Autorelease 机制。

<h2>目录</h2>

- [黑幕背后的 Autorelease](#黑幕背后的-autorelease)
  - [Autorelease 对象什么时候释放？](#autorelease-对象什么时候释放)
    - [小实验](#小实验)
  - [Autorelease 原理](#autorelease-原理)
    - [AutoreleasePoolPage](#autoreleasepoolpage)
    - [释放时刻](#释放时刻)
    - [嵌套的AutoreleasePool](#嵌套的autoreleasepool)

## Autorelease 对象什么时候释放？

这个问题拿来做面试题，问过很多人，没有几个能答对的。很多答案都是“~~当前作用域大括号结束时释放~~”，显然没有正确理解 Autorelease 的机制。

**在没有手动添加 Autorelease Pool 的情况下，Autorelease 对象是在当前 RunLoop 迭代结束时释放的**。原理请看 [ibireme 的博客：《深入理解 RunLoop 》](https://huanglibo.gitbook.io/notebook/digest/ibireme-runloop#1.-autoreleasepool) 。

### 小实验

```objectivec
__weak id reference = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str = [NSString stringWithFormat:@"避免 tagged Pointer"];
    // str 是一个 autorelease 对象，设置一个 weak 的引用来观察它
    reference = str;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@", reference); // Console: 避免 tagged Pointer
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@", reference); // Console: (null)
}
```

~~这个实验同时也证明了 `viewDidLoad` 和 `viewWillAppear` 是在同一个 RunLoop 调用的，`而 viewDidAppear 是在之后的某个` RunLoop 调用的。~~ （由于这个 vc 在 `loadView` 之后便 add 到了 `window` 层级上，所以 `viewDidLoad` 和 `viewWillAppear` 是在同一个 RunLoop 调用的，因此在 `viewWillAppear` 中，这个 autorelease 的变量依然有值。）

当然，我们也可以手动干预 Autorelease 对象的释放时机：

```objectivec
- (void)viewDidLoad {
    [super viewDidLoad];
    @autoreleasepool {
        NSString *str = [NSString stringWithFormat:@"避免 tagged Pointer"];
    }
    NSLog(@"%@", str); // Console: (null)
}
```

## Autorelease 原理

### AutoreleasePoolPage

在 ARC 中，我们使用 `@autoreleasepool{}` 来使用一个 `AutoreleasePool` ，随后编译器将其改写成下面的样子：

```objectivec
void *context = objc_autoreleasePoolPush();
/* 👇 */
// {}中的代码
/* 👆 */
objc_autoreleasePoolPop(context);
```

而这两个函数都是对 `AutoreleasePoolPage` 的简单封装，所以自动释放机制的核心就在于这个类。

`AutoreleasePoolPage` 是一个 C++ 实现的类，它有这些属性（这些属性继承自私有的 `AutoreleasePoolPageData` ）：

![AutoreleasePoolPage-1](../media/Digest/sunnyxx/AutoreleasePoolPage-1.jpg)

`AutoreleasePoolPage` 的特性：

- AutoreleasePool 并没有单独的结构，而是由若干个 `AutoreleasePoolPage` 以**双向链表**的形式组合而成，其中 `parent` 指针指向上一个 page ，`child` 指针指向下一个 page ）；
- **AutoreleasePool 与线程是一一对应的**（结构中的 `thread` 指针指向其对应的线程）
- `AutoreleasePoolPage` 每个对象会开辟 4096 字节内存（也就是**虚拟内存一页的大小**）【编者疑问：ARM64 架构上是 16KB ，其他架构上是 4KB ？】，除了自身实例变量所占的空间，剩下的空间全部用来储存 autorelease 对象的地址；
- 上面的 `next` 指针作为**游标**指向栈顶最后 push 进来的 autorelease 对象的下一个位置；
- 一个 `AutoreleasePoolPage` 的空间被占满时，会新建一个 `AutoreleasePoolPage` 对象，通过 `parent` 和 `child` 指针连接链表，之后的 autorelease 对象在新的 page 加入。

所以，若当前线程中只有一个 `AutoreleasePoolPage` 对象，并记录了很多 autorelease 对象地址时，内存如下图：

![AutoreleasePoolPage-2](../media/Digest/sunnyxx/AutoreleasePoolPage-2.jpg)

图中的情况，这一页再加入一个 autorelease 对象就要满了（也就是 `next` 指针马上指向栈顶），这时就要执行上面说的操作，建立下一页 page 对象，与这一页链表连接完成后，新 page 的 `next` 指针被初始化在栈底（ `begin` 的位置），然后继续向栈顶添加新对象。

所以，向一个对象发送 `-autorelease` 消息，就是将这个对象加入到当前 `AutoreleasePoolPage` 的 `next` 指针指向的位置。

### 释放时刻

每当进行一次 `objc_autoreleasePoolPush` 调用时，Runtime 向当前的 `AutoreleasePoolPage` 中添加一个**哨兵对象**（值为 `nil` ），那么这一个 page 就变成了下面的样子：

![AutoreleasePoolPage-3](../media/Digest/sunnyxx/AutoreleasePoolPage-3.jpg)

`objc_autoreleasePoolPush` 的返回值正是这个哨兵对象的地址，被 `objc_autoreleasePoolPop(哨兵对象)` 作为入参，于是：

- 根据传入的哨兵对象的地址找到哨兵对象所处的 page ；
- 在当前的 page 中，向所有的晚于哨兵对象插入的 autorelease 对象发送 `-release` 消息，并向回移动 `next` 指针到正确位置；从最新加入的对象一直向前清理，可能会向前跨越若干个 page ，直到哨兵所在的 page 。

刚才的 `objc_autoreleasePoolPop` 执行后，最终变成了下面的样子：

![AutoreleasePoolPage-4](../media/Digest/sunnyxx/AutoreleasePoolPage-4.jpg)

### 嵌套的AutoreleasePool

知道了上面的原理，嵌套的 AutoreleasePool 就非常简单了，`pop` 的时候总会释放到上次 `push` 的位置为止，多层的 pool 就是多个哨兵对象而已，就像剥洋葱一样，每次一层，互不影响。
