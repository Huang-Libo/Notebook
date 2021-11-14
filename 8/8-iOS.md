# 8-iOS

- [8-iOS](#8-ios)
  - [基础](#基础)
    - [UIView 和 CALayer 的区别](#uiview-和-calayer-的区别)
    - [寻找两个 UIView 的最近的公共 View](#寻找两个-uiview-的最近的公共-view)
  - [事件的传递和响应](#事件的传递和响应)
    - [iOS 系统响应触摸事件的机制](#ios-系统响应触摸事件的机制)
  - [Runtime](#runtime)
    - [「从历年 weak 看 iOS 面试】」](#从历年-weak-看-ios-面试)
    - [消息转发流程](#消息转发流程)
    - [dealloc 的流程](#dealloc-的流程)
    - [添加 weak 变量](#添加-weak-变量)
    - [weak 指针置为 nil 的过程](#weak-指针置为-nil-的过程)
    - [Objective-C 方法调用的本质](#objective-c-方法调用的本质)
  - [RunLoop](#runloop)
    - [source0 和 source1 有什么区别](#source0-和-source1-有什么区别)
  - [App 启动优化](#app-启动优化)
    - [删除未使用的类和方法](#删除未使用的类和方法)
    - [统计启动时间](#统计启动时间)
  - [开源库](#开源库)
    - [fishhook 的原理 & 位置无关代码](#fishhook-的原理--位置无关代码)

## 基础

### UIView 和 CALayer 的区别

`UIView` 和 `CALayer` 的关系：

- `view` 持有 `layer` 用于显示，`view` 中大部分显示属性实际是从 `layer` 映射而来；
- `layer` 的 `delegate` 在这里是 `view` ，当其属性改变、动画产生时，`view` 能够得到通知。

`UIView` 和 `CALayer` 不是线程安全的，并且只能在主线程创建、访问和销毁。

补充：

- `UIView` 属于 `UIKit` 框架，用于 iOS 系统，它可以响应交互事件；而 `CALayer` 属于 `Core Animation` 框架，是 iOS 和 macOS 通用的，它只负责页面的绘制，无法响应交互事件。
- 这样的设计遵守了单一职责的原则，使得 `CALayer` 在不同平台上可以被复用。
  - 在不同类型的设备上，交互逻辑是不一样的：
    - 在 iOS 系统上是**触摸操作**，负责交互的是 `UIKit` 中的 `UIView` ；
    - 在 macOS 系统上是**键鼠操作**，负责交互的是 `AppKit` 中的 `NSView` 。
  - 但它们的图形绘制的方式是一样的，`UIView` 和 `NSView` 的底层都是使用 `CALayer` 进行绘制的。
- 每个 `UIView` 都有一个相应的 `layer` 属性，在 `layer` 中有一个 `delegate` 属性，而 `UIView` 通常就是 `CALayer` 的 `delegate` 。

### 寻找两个 UIView 的最近的公共 View

来源：[唐巧的公众号](https://mp.weixin.qq.com/s?__biz=MjM5NTIyNTUyMQ==&mid=562061601&idx=1&sn=a409387dbbbd77282237b7d91dc18884&scene=19#wechat_redirect)，有改动。

一个 `UIViewController` 中的所有 `view` 之间的关系其实可以看成一颗树，`UIViewController` 的 `view` 变量是这颗树的根节点，其它的 `view` 都是根节点的直接或间接子节点。

所以我们可以通过 `view` 的 `superview` 属性一直找到根节点。（需要注意的是，在代码中，我们还需要考虑各种非法输入，如果输入了 `nil` ，则也需要处理，避免异常。）

以下是找到指定 `view` 到根 `view` 的路径代码：

```objectivec
+ (NSArray *)superViews:(UIView *)view {
    if (view == nil) {
        return @[];
    }
    NSMutableArray *result = [NSMutableArray array];
    while (view != nil) {
        [result addObject:view];
        view = view.superview;
    }
    return [result copy];
}
```

然后对于两个 view A 和 view B，我们可以得到两个路径。将一个路径中的所有点先放进 `NSSet` 中，然后遍历另一个数组，检查当前的 `view` 是否在 `NSSet` 中：

```objectivec
+ (UIView *)commonView_2:(UIView *)viewA andView:(UIView *)viewB {
    NSArray *arr1 = [self superViews:viewA];
    NSArray *arr2 = [self superViews:viewB];
    NSSet *set = [NSSet setWithArray:arr2];
    for (NSUInteger i = 0; i < arr1.count; ++i) {
        UIView *targetView = arr1[i];
        if ([set containsObject:targetView]) {
            return targetView;
        }
    }
    return nil;
}
```

## 事件的传递和响应

### iOS 系统响应触摸事件的机制

1）手指触碰屏幕，屏幕感应到触碰后，将事件交由 `IOKit` 处理。

2）`IOKit` 将触摸事件封装成一个 `IOHIDEvent` 对象，并通过 `mach port` 传递给 `SpringBoad` 进程。

- `mach port` ：进程端口，各进程之间通过它进行通信。
- `SpringBoad` ：是一个系统进程，可以理解为桌面系统，可以**统一管理和分发系统接收到的触摸事件**。

3）`SpringBoard` 进程因接收到触摸事件，触发了主线程 `RunLoop` 的 `source1` 事件源的回调。此时 `SpringBoard` 会根据当前桌面的状态，判断应该由谁处理此次触摸事件。因为事件发生时，你可能正在桌面上翻页，也可能正在刷微博。

- 若是前者（即前台无 APP 运行），则触发 `SpringBoard` 本身主线程 `RunLoop` 的 `source0` 事件源的回调，将事件交由桌面系统去消耗；
- 若是后者（即有 APP 正在前台运行），则将触摸事件通过 `IPC`（进程间通信）传递给前台 APP 进程。

## Runtime

### 「从历年 weak 看 iOS 面试】」

> 来源：孙源老铁的微博[我就叫Sunny怎么了](https://weibo.com/u/1364395395)，有改动。

**2013年**

面试官：代理用 `weak` 还是 `strong` ?

我 ：`weak` 。

面试官：明天来上班吧

**2014年**

面试官：代理为什么用 `weak` 不用 `strong` ?

我 ： 用 `strong` 会造成循环引用。

面试官：明天来上班吧

**2015年**

面试官：`weak` 是怎么实现的？

我 ：`weak` 是系统通过一个 `hash` 表来实现对象的弱引用。

面试官：明天来上班吧

**⭐️ 2016年**

面试官：`weak` 是怎么实现的？

我 ：runtime 维护了一个 `weak` 表，用于存储指向某个对象的所有 `weak` 指针。`weak` 表其实是一个 `hash`（哈希）表，`key` 是所指对象的地址，`value` 是 `weak` 指针的**地址数组**（地址数组中的元素是**对象指针的地址**）。

面试官：明天来上班吧

**⭐️ 2017年**

面试官：`weak` 是怎么实现的？

我 ：

1. **初始化时**：runtime 会调用 `objc_initWeak()` 函数，初始化一个新的 `weak` 指针指向对象的地址；
2. **添加引用时**：`objc_initWeak()` 函数会调用 `storeWeak()` 函数，它的作用是更新指针指向，创建对应的弱引用表。
3. **释放时**，调用 `clearDeallocating()` 函数，它首先根据*对象地址*获取所有 `weak` 指针地址的数组，然后遍历这个数组把其中的数据设为 `nil` ，最后把这个 `entry` 从 `weak` 表中删除，清理对象的记录。

面试官：明天来上班吧

**2018年**

面试官：`weak` 是怎么实现的？

我 ：跟2017年说的一样，还详细补充了 `objc_initWeak()` ，`storeWeak()` ，`clearDeallocating()` 的实现细节。

面试官：小伙子基础不错。13k ，996干不干？干就明天来上班。。下一个

**2019年**

面试官：`weak` 是怎么实现的？

我 ： 别说了，拿纸来，我动手实现一个。

面试官：等写完后，面试官慢悠悠的说，小伙子不错，我考虑考虑，你先回去吧

### 消息转发流程

![Runtime-message-forward.jpg](../media/iOS/Runtime/Runtime-message-forward.jpg)

### dealloc 的流程

> 参考：[iOS - 老生常谈内存管理（四）：内存管理方法源码分析](https://juejin.cn/post/6844904131719593998#heading-63)

- 判断销毁对象前有没有需要处理的东西（如弱引用、关联对象、C++ 的析构函数、`SideTable` 的引用计数表等等）；
  - 如果没有就直接调用 `free` 函数销毁对象；
  - 如果有就先调用 `object_dispose` 做一些释放对象前的处理（把弱引用指针置为 `nil` 、移除关联对象、调用 `object_cxxDestruct` 、在 `SideTable` 的引用计数表中查出引用计数等等），最后用 `free` 函数销毁对象。

### 添加 weak 变量

经过一系列的函数调用栈，最终在 `weak_register_no_lock()` 函数当中，进行弱引用变量的添加，具体添加的位置是通过哈希算法来查找的。

- 如果不存在的话，就创建一个弱引用表，然后将弱引用变量添加进去。
- 如果对应位置已经存在当前对象的弱引用表（数组），那就把弱引用变量添加进去；

### weak 指针置为 nil 的过程

当一个对象被销毁时，在 `dealloc` 方法内部经过一系列的函数调用栈，通过两次哈希查找，第一次根据对象的地址找到它所在的 `SideTable` ，第二次根据对象的地址在 `SideTable` 的 `weak_table` 中找到它的弱引用表。

最后遍历弱引用数组，将指向对象的 `weak` 变量全都置为 `nil` 。

### Objective-C 方法调用的本质

Objective-C 的方法调用在编译时会被转换成 `objc_msgSend` 函数调用，比如：

```objectivec
NSObject *obj = [[NSObject alloc] init];
```

在终端中使用 clang 转成对应的 cpp 代码：

```console
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m
```

cpp 代码：

```cpp
NSObject *obj = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"));
```

将类型转换去掉，可以看到基本结构是：

```cpp
NSObject *obj = objc_msgSend(objc_msgSend(objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init"));
```

实际上是调用了两次 `objc_msgSend` ，相当于：

```cpp
id obj1 = objc_msgSend(objc_getClass("NSObject"), sel_registerName("alloc"));
id obj2 = objc_msgSend(obj1, sel_registerName("init"));
```

两个 Runtime 函数的功能：

- `objc_getClass` ：通过给定的 `C 字符串`查找相应名称的`类`。
- `sel_registerName` ：向 Objective-C 运行时系统注册一个方法，将方法名映射到一个 `SEL` ，并返回 `SEL` 的值。在将方法添加到类定义之前，必须向 Objective-C 运行时系统注册方法名以获取方法的 `SEL` 。如果方法名已经注册，该函数将简单地返回 `SEL` 。

可以看出 `objc_getClass` 和 `sel_registerName` 的参数都是 C 字符串，因此，它们都是在**运行时**通过给定的字符串去查找对应的类和 `SEL` 。

因此，在编译时只是将 Objective-C 的方法调用转成了 `objc_msgSend` ，在运行时再通过 `objc_getClass` 和 `sel_registerName` 来查找对应的`类`和`方法`。

## RunLoop

### source0 和 source1 有什么区别

> 参考：[iOS 从源码解析 RunLoop (九)](https://juejin.cn/post/6913094534037504014#heading-0)

先说结论：

进入休眠的 RunLoop 仅能通过 `mach port` 和 `mach_msg` 来唤醒。

- `source1` ：是基于 `mach port` 的，可接收来自系统内核或者其他进程或线程的事件，可以**主动唤醒**休眠中的 RunLoop 。（ `mach port` 是进程间通信的一种方式。）
- `source0` ：不是基于 port 的，无法主动唤醒 RunLoop 。

再看源码：

`__CFRunLoopSource` 的定义：

```c
struct __CFRunLoopSource {
    CFRuntimeBase _base;
    uint32_t _bits;
    pthread_mutex_t _lock;
    CFIndex _order;			/* immutable */
    CFMutableBagRef _runLoops;
    union {
        CFRunLoopSourceContext version0;	/* immutable, except invalidation */
        CFRunLoopSourceContext1 version1;	/* immutable, except invalidation */
    } _context;
};
```

其中的 `version0` 、`version1` 分别对应 `source0` 和 `source1` 。

上述 `CFRunLoopSourceContext` 的定义：

```c
typedef struct {
    CFIndex	version;
    void *	info;
    const void *(*retain)(const void *info);
    void	(*release)(const void *info);
    CFStringRef	(*copyDescription)(const void *info);
    Boolean	(*equal)(const void *info1, const void *info2);
    CFHashCode	(*hash)(const void *info);
    void	(*schedule)(void *info, CFRunLoopRef rl, CFStringRef mode);
    void	(*cancel)(void *info, CFRunLoopRef rl, CFStringRef mode);
    void	(*perform)(void *info);
} CFRunLoopSourceContext;
```

参数：

- `info` ：作为 `perform` 函数的参数；
- `schedule` ：当 `source0` 加入到 RunLoop 时触发的回调函数（在 `CFRunLoopAddSource` 函数中可看到其被调用）；
- `cancel` ：当 `source0` 从 RunLoop 中移除时触发的回调函数；
- `perform` ：`source0` 要执行的任务块，当 `source0` 事件被触发时的回调, 调用 `__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__` 函数来执行 `perform(info)` 。

上述 `CFRunLoopSourceContext1` 的定义为：

```c
typedef struct {
    CFIndex	version;
    void *	info;
    const void *(*retain)(const void *info);
    void	(*release)(const void *info);
    CFStringRef	(*copyDescription)(const void *info);
    Boolean	(*equal)(const void *info1, const void *info2);
    CFHashCode	(*hash)(const void *info);
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)) || (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    mach_port_t	(*getPort)(void *info);
    void *	(*perform)(void *msg, CFIndex size, CFAllocatorRef allocator, void *info);
#else
    void *	(*getPort)(void *info);
    void	(*perform)(void *info);
#endif
} CFRunLoopSourceContext1;
```

参数：

- `info` ：作为 `perform` 函数的参数；
- `getPort` ：函数指针，用于当 `source1` 被添加到 RunLoop 中的时候，从该函数中获取具体的 `mach_port_t` 对象，用来唤醒 RunLoop 。
- `perform` ：函数指针，即指向 RunLoop 被唤醒后 `source1` 要执行的回调函数，调用 `__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__` 函数来执行。

解读：

`source0` 仅包含一个 `perform` 函数指针，它并不能主动唤醒 RunLoop（**进入休眠的 RunLoop 仅能通过 mach port 和 mach_msg 来唤醒**）。

使用 `source0` 时，需要先调用 `CFRunLoopSourceSignal(rls)` 将这个 `source0` 标记为待处理，然后手动调用 `CFRunLoopWakeUp(rl)` 来唤醒 RunLoop ( `CFRunLoopWakeUp` 函数内部是通过 RunLoop 实例的 `_wakeUpPort` 成员变量来唤醒 RunLoop 的），唤醒后的 RunLoop 继续执行 `__CFRunLoopRun` 函数内部的外层 `do...while` 循环来执行 timer 、 source 以及 observer 。

通过调用 `__CFRunLoopDoSources0` 函数来执行 `source0` 事件，执行过后的 `source0` 会被 `__CFRunLoopSourceUnsetSignaled(rls)` 标记为已处理，后续 RunLoop 循环中不会再执行标记为已处理的 `source0` 。

`source0` 不同于不重复执行的 timer 和 RunLoop 的 block 链表中的 block 节点，`source0` 执行过后不会自己主动移除，不重复执行的 timer 和 block 执行过后会自己主动移除，执行过后的 `source0` 可手动调用 `CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode)` 来移除。

`source0` 具体执行时的函数如下，`info` 做参数执行 `perform` 函数：

```c
// perform(info)
__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__(rls->_context.version0.perform, rls->_context.version0.info); 
```

## App 启动优化

> 参考：[美团外卖 iOS App 冷启动治理](https://tech.meituan.com/2018/12/06/waimai-ios-optimizing-startup.html)

### 删除未使用的类和方法

随着业务的迭代，不断有新的代码加入，同时也会废弃掉无用的代码和资源文件，但是工程中经常有无用的代码和文件被遗弃在角落里，没有及时被清理掉。这些无用的部分一方面增大了 App 的包体积，另一方便也拖慢了 App 的冷启动速度，所以及时清理掉这些无用的代码和资源十分有必要。

通过对 Mach-O 文件的了解，可以知道：

- `__TEXT` 段的 `__objc_methname` 节中包含了代码中的所有方法，
- `__DATA` 段的 `__objc_selrefs` 节中则包含了所有被使用的方法的引用。

通过取两个集合的**差集**就可以得到所有未被使用的代码。核心方法如下（参考：[objc_cover](https://github.com/nst/objc_cover) ）：

```python
def referenced_selectors(path):
    re_sel = re.compile("__TEXT:__objc_methname:(.+)") //获取所有方法
    refs = set()
    lines = os.popen("/usr/bin/otool -v -s __DATA __objc_selrefs %s" % path).readlines() ## ios & mac //真正被使用的方法
    for line in lines:
        results = re_sel.findall(line)
        if results:
            refs.add(results[0])
    return refs
}
```

### 统计启动时间

启动时间需要包含 `pre-main` 所花费的时间，因此开始时间点要尽可能早。

- 开始时间点：以 `exec()` 系统调用的时间作为冷启动的起始时间。因为系统允许我们通过 `sysctl()` 函数获得进程的有关信息，其中就包括进程创建的时间戳。
- 结束时间点：结束时间比较好确定，我们可以将首页某些视图元素的展示作为首页加载完成的标志。

```objectivec
#import <sys/sysctl.h>
#import <mach/mach.h>

+ (BOOL)processInfoForPID:(int)pid procInfo:(struct kinfo_proc*)procInfo
{
    int cmd[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    size_t size = sizeof(*procInfo);
    return sysctl(cmd, sizeof(cmd)/sizeof(*cmd), procInfo, &size, NULL, 0) == 0;
}

+ (NSTimeInterval)processStartTime
{
    struct kinfo_proc kProcInfo;
    if ([self processInfoForPID:[[NSProcessInfo processInfo] processIdentifier] procInfo:&kProcInfo]) {
        return kProcInfo.kp_proc.p_un.__p_starttime.tv_sec * 1000.0 + kProcInfo.kp_proc.p_un.__p_starttime.tv_usec / 1000.0;
    } else {
        NSAssert(NO, @"无法取得进程的信息");
        return 0;
    }
}
```

## 开源库

### fishhook 的原理 & 位置无关代码

> 参考：[fishhook & PIC](../iOS/fishhook.md)

fishhook 的功能：对**外部符号**进行*符号重绑定 (symbol rebind)* 。它本质上是利用了*位置无关代码 (Position Independent Code， PIC)* 相关的特性。

**位置无关代码**：

*自己源码中实现的 C 函数*和*静态库中的 C 函数*对应的符号属于**内部符号**，它们的**地址偏移量**在编译时就确定了，存储在 Mach-O 文件的 `__TEXT` 段。由于 `__TEXT` 段是只读的，且会进行代码签名验证，因此是不能修改的。

如果代码中有**外部符号**，比如系统动态库的 C 函数，由于编译器在生成 Mach-O 文件时无法知道该函数的实际地址，因此会插入一个 **stub（符号桩）**。

外部符号的地址值存储在 Mach-O 文件的 `(__DATA，__la_symbol_ptr)` 或 `(__DATA_CONST，__got)` 中。其中， `__la_symbol_ptr` 中的符号是惰性绑定的，它的初始值是指向 Mach-O 的 `(__TEXT，__stub_helper)` 区域，经过调用一系列汇编指令之后，最终指向了 `dyld_stub_binder()` 方法。

在第一次调用惰性绑定的符号时，会通过 `dyld_stub_binder()` 方法去查找符号的真实地址、填入到 `__la_symbol_ptr` 对应的符号的 **Data** 中，这样就完成了*符号绑定 (symbol bind)*。之后再调用这个符号时，就能直接调用它的实现了。

**fishhook 的适用范围**：

据此我们我们可以得知， fishhook 的适用范围是

- 可以 hook 外部符号
- 但无法 hook 内部符号

**fishhook 的原理**：

修改 `__la_symbol_ptr` 中外部符号存储的地址值，将它改为我们自己实现的函数的地址值。同时用一个函数指针存储外部符号的原始实现，这样就还能调用到该符号的原始实现。
