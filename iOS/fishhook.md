# fishhook

## 资料说明

### 原仓库

地址： <https://github.com/facebook/fishhook>

目前 `main` 分支的代码（最后更新时间是 2020.04.21）在 iOS 14.7 真机上运行会 crash（在模拟器上能正常运行）

### 我 fork 的仓库

地址：<https://github.com/Huang-Libo/fishhook>

改动点：

- 合入了 [pull/87](https://github.com/facebook/fishhook/pull/87)，解决了在 iOS 14.7 真机上 crash 的问题；
- 添加了 [Example](https://github.com/Huang-Libo/fishhook/tree/main/Example) 工程，包含 hook `open()` ，`close()` ，`printf()` ， `NSLog()` 的示例；
- 整理了 [README.md](https://github.com/Huang-Libo/fishhook/blob/main/README.md) 的格式，方便阅读。

## 简介

fishhook 是一个非常简单的库，支持对 iOS 模拟器和真机上（实际上 macOS 平台也支持）运行的 Mach-O 二进制文件进行*动态地重绑定符号 (dynamically rebinding symbols)* 。这个功能和 macOS 中的 [`DYLD_INTERPOSE`][interpose] 类似。

在 Facebook ，开发者使用 fishhook 来 hook `libSystem` 中的调用以进行调试、追踪（比如对文件描述符被关闭两次的问题进行审计）。

[interpose]: https://opensource.apple.com/source/dyld/dyld-852.2/include/mach-o/dyld-interposing.h.auto.html "<mach-o/dyld-interposing.h>"

## DYLD_INTERPOSE 使用示例

> 源码：<https://opensource.apple.com/source/dyld/dyld-852.2/include/mach-o/dyld-interposing.h.auto.html>

上文提到的 `DYLD_INTERPOSE` 实际上是 `dyld` 中的一个宏（宏的结尾包含了分号，调用的时候不用再加分号了）：

```c
#define DYLD_INTERPOSE(_replacement,_replacee) \
   __attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
            __attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };
```

 源码中给出的示例是使用自定义的 `my_open()` 替换 `open()` 函数 ：

```c
static
int
my_open(const char* path, int flags, mode_t mode)
{
  int value;
  // do stuff before open (including changing the arguments)
  value = open(path, flags, mode);
  // do stuff after open (including changing the return value(s))
  return value;
}
DYLD_INTERPOSE(my_open, open)
```

## fishhook 使用示例

### 示例一：重绑定 `open` 和 `close`

```objectivec
#import <dlfcn.h>
#import <UIKit/UIKit.h>
#import <fishhook/fishhook.h>
#import "AppDelegate.h"
 
static int (*orig_close)(int);
static int (*orig_open)(const char *, int, ...);
 
int my_close(int fd) {
  printf("Calling real close(%d)\n", fd);
  return orig_close(fd);
}
 
int my_open(const char *path, int oflag, ...) {
  va_list ap = {0};
  mode_t mode = 0;
 
  if ((oflag & O_CREAT) != 0) {
    // mode only applies to O_CREAT
    va_start(ap, oflag);
    mode = va_arg(ap, int);
    va_end(ap);
    printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
    return orig_open(path, oflag, mode);
  } else {
    printf("Calling real open('%s', %d)\n", path, oflag);
    return orig_open(path, oflag, mode);
  }
}

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        struct rebinding rebindings[2] = {
            {"close", my_close, (void *)&orig_close},
            {"open", my_open, (void *)&orig_open}
        };
        // Use fishhook to rebind symbols
        rebind_symbols(rebindings, 2);
     
        // Open our own binary and print out first 4 bytes
        // (which is the same for all Mach-O binaries on a given architecture)
        int fd = open(argv[0], O_RDONLY);
        uint32_t magic_number = 0;
        read(fd, &magic_number, 4);
        printf("Mach-O Magic Number: %x \n", magic_number);
        close(fd);

        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```

**输出示例**：

使用 *iPhone 12 (iOS 14.5)* **模拟器**的输出：

```plaintext
Calling real open('$HOME/Library/Developer/CoreSimulator/Devices/BEC0C655-BA6E-433C-A6A6-2D55CC2DEC61/data/Containers/Bundle/Application/F309C60B-EF06-4F9F-8287-3C738F0FE4F6/fishhook-demo.app/fishhook-demo', 0)
Mach-O Magic Number: feedfacf 
Calling real close(3)
...
```

使用 *iPhone 12 (iOS 14.7.1)* **真机**的输出：：

```plaintext
Calling real open('/var/containers/Bundle/Application/8250D7D8-4893-486C-B5FC-FB55AA110116/Example.app/Example', 0)
Mach-O Magic Number: feedfacf 
Calling real close(3)
...
```

### 示例二：重绑定 `printf`

```objectivec
#import <fishhook/fishhook.h>

static int (*orig_printf)(const char * __restrict, ...);

int my_printf(const char *format, ...)
{
    // 打印额外的前缀
    orig_printf("🤯 ");
    int retVal = 0;
    // 取出变长参数
    va_list args;
    va_start(args, format);
    retVal = vprintf(format, args);
    va_end(args);

    return retVal;
}

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        printf("Before hook printf\n");
        // Use fishhook to rebind symbols
        struct rebinding rebindings[1] = {
            {"printf", my_printf, (void *)&orig_printf}
        };
        rebind_symbols(rebindings, 1);
        int a = 666;
        printf("After hook printf, %d\n", a);
        
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```

示例输出：

```plaintext
Before hook printf
🤯 After hook printf, 666
```

**注意**：在实现 `my_printf` 时，需要使用 `va_start` 和 `va_end` 取出 `printf` 的第二个参数、这是个“*变长参数*”，然后存入到 `va_list` 类型的变量中，最后传递给 `vprintf` 函数的第二个参数。可参考：

- GNU `glibc` 的 `printf.c` <https://code.woboq.org/userspace/glibc/stdio-common/printf.c.html>
- Apple `libc` 的 `printf.c` ：<https://opensource.apple.com/source/Libc/Libc-1439.100.3/stdio/FreeBSD/printf.c.auto.html>

### 示例三：重绑定 `NSLog`

```objectivec
#import <fishhook/fishhook.h>

// 用于记录原 NSLog 的函数指针
static void (*orig_NSLog)(NSString *format, ...);

@implementation ViewController

// 自定义的 NSLog
void my_NSLog(NSString *format, ...) {
    if(!format) {
        return;
    }
    // 在原始输出中添加额外的信息
    NSString *extra = @"🤯 ";
    format = [extra stringByAppendingString:format];
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    // 调用原 NSLog
    orig_NSLog(@"%@", message);
    va_end(args);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Before hook NSLog\n");
    // 调用 fishhook 来重新绑定 NSLog 对应的符号
    struct rebinding rebindings[1] = {
        {"NSLog", my_NSLog, (void *)&orig_NSLog}
    };
    rebind_symbols(rebindings, 1);
    NSLog(@"After hook NSLog\n");
}

@end
```

示例输出：

```plaintext
2021-09-14 21:58:24.319771+0800 Example[8722:6392547] Before hook NSLog
2021-09-14 21:58:24.329150+0800 Example[8722:6392547] 🤯 After hook NSLog
```

## 调用 C 语言动态库函数和本地函数的不同之处

先看两个重要的结论，后面讲会对它们进行详细地讲解：

- 项目依赖的动态库**不会**编译到 mach-o 文件中，系统中所有的进程共享动态库；
- 这里说的**本地 C 函数**指**项目源码中实现的 C 函数**和**项目引入的静态库中的 C 函数**，它们的共同特点是都被编译到了 mach-o 文件中，位于 `__TEXT` 代码段。

### 示例一：调用动态库中的 C 函数

> 源码：<https://github.com/Huang-Libo/fishhook/blob/main/Symbol-Example-1/HelloWorld.c>

这里以 C 标准库中的 `printf` 函数的调用为例，演示源码中引用的动态库中的函数的调用方式。

先看一段简单的 C 代码，在 `main` 函数中只调用了 `printf` 函数：

```c
#include <stdio.h>

int main(int argc, const char * argv[]) {
    printf("Hello, World!\n");
    return 0;
}

```

使用 clang 编译，生成可执行文件 `a.out` ：

```console
clang HelloWorld.c
```

`nm -n a.out` 输出：

```plaintext
                 U _printf
                 U dyld_stub_binder
0000000100000000 T __mh_execute_header
0000000100003f50 T _main
0000000100008008 d __dyld_private
```

可以看出 `_printf` 符号类型是 `undefined` ；此外，还有一个名为 `dyld_stub_binder` 的符号也是 `undefined` 类型，这个符号稍后介绍。

**关于 `nm` 命令**：

`nm` 命令可*列出 mach-o 文件中的符号 (list symbols from object files)* 。可以在终端中使用 `man nm` 查看其文档。

`nm` 的输出包含 3 列：

- 第 1 列是 **The symbol value** ，即符号的地址，默认使用 16 进制；
- 第 2 列是 **The symbol type** ，即符号的类型；
  - `U` ：表示 `undefined` ，即未定义，因此没有对应的地址；
  - `T` ：表示符号位于 `__TEXT` 段，即代码所在区域；
  - `d` ：表示符号在已初始化的数据区；
- 第 3 列是 **The symbol name** ，即符号的名称。

### 示例二：调用本地的 C 函数

> 源码：<https://github.com/Huang-Libo/fishhook/blob/main/Symbol-Example-2/Symbol-Example/main.c>

接下来在上述源码中添加一个 `my_hello` 函数：

```c
#include <stdio.h>

void my_hello() {
    printf("My Hello!\n");
}

int main(int argc, const char * argv[]) {
    printf("Hello, World!\n");
    return 0;
}
```

调用 `clang HelloWorld.c` 重新编译后，再输入 `nm -n a.out` 查看 `a.out` 中的符号列表：

```plaintext
                 U _printf
                 U dyld_stub_binder
0000000100000000 T __mh_execute_header
0000000100003f20 T _my_hello
0000000100003f40 T _main
0000000100008008 d __dyld_private
```

> C 函数对应的符号名，是在函数名前加一个下划线。

可以看到我们自定义的 `my_hello` 函数对应的符号 `_my_hello` 是有地址的，且在 `__TEXT` 段中。

## 探索 printf 的调用流程 1 : Hopper 汇编

> 源码：<https://github.com/Huang-Libo/fishhook/blob/main/Symbol-Example-2/Symbol-Example/main.c>

接下来对上述源码生成的 Mach-O 进行详细分析。

### _main

使用 Hopper 打开 [Symbol-Example](https://github.com/Huang-Libo/fishhook/tree/main/Symbol-Example-2) 项目生成的可执行文件。入口是位于 `(__TEXT,__text)` 的 `_main` ：

![hopper-_main.jpg](../media/iOS/fishhook/hopper-_main.jpg)

在 `_main` 中可以看到在 `0x100003f5f` 地址上执行了 `call` ，对应的符号是 `imp___stubs__printf` ，注释是 `printf` ，说明这一行汇编对应的就是 `main()` 函数内的 `printf()` 函数调用 ：

```c
0000000100003f5f call imp___stubs__printf
```

### `imp___stubs__printf`

双击 `imp___stubs__printf` 跳入其定义中：

![hopper-imp___stubs__printf.jpg](../media/iOS/fishhook/hopper-imp___stubs__printf.jpg)

可看到它位于 `(__TEXT,__stubs)` ，入口地址是 `0x100003f72` ，在其内出现了新的符号 `_printf_ptr` ：

```c
              imp___stubs__printf:
0000000100003f72 jmp qword [_printf_ptr]
```

### _printf_ptr

双击 `_printf_ptr` ，跳入其定义中：

![hopper-_printf_ptr.jpg](../media/iOS/fishhook/hopper-_printf_ptr.jpg)

可看到它位于 `(__DATA,__la_symbol_ptr)` 中，它的内部存储的是 *Lazy Symbol Pointer* ，也就是说这里面存储的符号在第一次被调用时才执行绑定。

可看到其内有一个 `extern` 的 `_printf` 符号：

```c
              _printf_ptr:
0000000100008000 extern _printf
```

**编者注**：感觉 **Hopper** 生成的汇编中的 `(__DATA,__la_symbol_ptr)` 内少了一些数据，导致 `_printf` 的调用链路断在后面将讲到的外部符号所在区域了。实际上，用 **MachOView** 查看 `(__DATA,__la_symbol_ptr)` ，可以看到 `_printf` 符号还有个属性是 **Data** ，其值是 **0x100003F88** ，这个地址位于 `(__TEXT,__stub_helper)` 内，这个地址值很重要，通过这个地址值，就能把 `_printf` 和 `dyld_stub_binder` 关联起来了，稍后将详细介绍。

![Mach-O-__DATA__la_symbol_ptr.jpg](../media/iOS/fishhook/Mach-O-__DATA__la_symbol_ptr.jpg)

### _printf

双击 `_printf` ，会跳入到其定义：

![hopper-external-symbols-1.jpg](../media/iOS/fishhook/hopper-external-symbols-1.jpg)

这里显示的是*外部符号 (External Symbols)* ， 在 **Hopper** 生成的汇编中，`printf()` 函数的调用链路就断在这里了，如之前所述，应该是因为 `(__DATA,__la_symbol_ptr)` 内有些信息没有显示。

从地址值上看，外部符号位于所有符号的最后面（在 **MachOView** 中没有这个专门展示外部符号的地方，这两个地址值 `0x100014000` 和 `0x100014008` 也较大，在 **MachOView** 中没有显示相应的区域）：

![hopper-external-symbols-2.jpg](../media/iOS/fishhook/hopper-external-symbols-2.jpg)

这两个外部符号对应的汇编是：

```c
             _printf:
0000000100014000 extern function code 
             dyld_stub_binder:
0000000100014008 extern function code 
```

`_printf` 和 `dyld_stub_binder` 的注释分别是：

```c
; in /usr/lib/libSystem.B.dylib, CODE XREF=imp___stubs__printf, DATA XREF=_printf_ptr
; in /usr/lib/libSystem.B.dylib, CODE XREF=0x100003f81, DATA XREF=dyld_stub_binder_100004000
```

从注释中可看出：

1）这两个符号都来自 `/usr/lib/libSystem.B.dylib` 。

2）`printf` 的调用流程是：

```c
imp___stubs__printf   // (__TEXT,__stubs)
  -> _printf_ptr      // (__DATA,__la_symbol_ptr)
    -> _printf        // 外部符号
```

3）`dyld_stub_binder` 的调用流程是：

```c
0x100003f81                      // (__TEXT,__stub_helper)
  -> dyld_stub_binder_100004000  // (__DATA,__got)
    -> dyld_stub_binder          // 外部符号
```

`_printf` 和 `dyld_stub_binder` 是强相关的，但根据目前的线索还看不出来它俩的联系。

接下来先详细查看 `dyld_stub_binder` 这个外部符号的调用流程。

### `(__TEXT,__stub_helper)`

顺着上面的外部符号 `dyld_stub_binder` 的注释给出的地址 `0x100003f81` ，可在 `(__TEXT,__stub_helper)` 中可以看到这一行出现了新符号 `dyld_stub_binder_100004000` ：

![hopper-__stub_helper.jpg](../media/iOS/fishhook/hopper-__stub_helper.jpg)

在 `0x100003f81` 左侧有一个蓝色箭头指向下方，实际上就是指向的 `dyld_stub_binder_100004000` 。

另外，在左侧可以看到一个红色箭头。在上图的地址中，我们再次看到了上文提到的 **0x100003f88** ，这个地址也就是 `_printf` 符号中的 **Data** 字段存储的值。在 **0x100003f88** 执行了 `push` 指令后，接着执行了 `jmp` 指令跳转到开头处 `0x100003f78`。

在 `0x100003f78` 出现了新符号 `__dyld_private` ，暂不讨论。**最后**会执行 `0x100003f81` 中的指令，跳转到 `dyld_stub_binder_100004000` 符号所在地址。

上图中的汇编：

```c
0000000100003f78 lea r11, qword [__dyld_private]
0000000100003f7f push r11
0000000100003f81 jmp qword [dyld_stub_binder_100004000]
0000000100003f87 nop
0000000100003f88 push 0x0
0000000100003f8d jmp 0x100003f78
```

### dyld_stub_binder_100004000

> `dyld_stub_binder_100004000` 后面的 `100004000` 实际上是 `dyld_stub_binder` 在当前 Mach-O 中的地址值，在别的 Mach-O 中会是其它值。

双击 `dyld_stub_binder_100004000` 跳入到其定义中，可看到它位于 `(__DATA,__got)` 中，它的内部存的是 *Non-Lazy symbol pointer* ，也就是应用在启动的 **pre-main** 阶段就会被绑定的符号：

![hopper-dyld_stub_binder.jpg](../media/iOS/fishhook/hopper-dyld_stub_binder.jpg)

### dyld_stub_binder

双击 `dyld_stub_binder` 跳入其定义中，就来到了老地方，External Symbols ：

![hopper-external-symbols-1.jpg](../media/iOS/fishhook/hopper-external-symbols-1.jpg)

### 小结

综上所述，我们可以得出**一个重要结论：在 Mach-O 中，`_printf` 符号指向的是 `__stub_helper` 区域，在执行完一系列指令后，最终指向了 `dyld_stub_binder` 符号。**

`printf()` 函数**第 1 次**调用时的流程：

```c
imp___stubs__printf   // (__TEXT,__stubs)
  -> _printf_ptr      // (__DATA,__la_symbol_ptr)
    -> _printf        // 外部符号
      -> 0x100003f88 -> 0x100003f81    // (__TEXT,__stub_helper)
        -> dyld_stub_binder_100004000  // (__DATA,__got)
          -> dyld_stub_binder          // 外部符号
```

`dyld_stub_binder` 是 `dyld` 中的一个辅助函数，职责是绑定外部符号。比如，外部符号 `_printf` 在 `(__DATA,__la_symbol_ptr)` 中的 **Data** 初始值是 `0x100003f88` ，也就是说 `_printf` 最初指向的是 `(__TEXT,__stub_helper)` 内的 `0x100003f88`，在调用一系列指令后，最终调用了 `dyld_stub_binder` 。

`dyld_stub_binder` 会去内存中查找 `_printf` 符号的实际地址，找到后将 `(__DATA,__la_symbol_ptr)` 中 `_printf` 的 **Data** 值由 `0x100003f88` 替换为 `_printf` 的实际地址，下次调用 `_printf` 时，就能直接调用其函数的实现，而无需再调用 `dyld_stub_binder` 。

`printf()` 函数**第 n 次 (n >= 2)** 调用时的流程：

```c
imp___stubs__printf   // (__TEXT,__stubs)
  -> _printf_ptr      // (__DATA,__la_symbol_ptr)
    -> _printf        // 外部符号
      -> 0x????????   // _printf 符号的实际地址
```
