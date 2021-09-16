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

首先要明确：

- 项目依赖的动态库**不会**编译到 mach-o 文件中，系统中所有的进程共享动态库；
- **本地 C 函数**指**项目源码中实现的 C 函数**和**项目引入的静态库中的 C 函数**，它们的共同特点是都被编译到了 mach-o 文件中，位在于 `__TEXT` 代码段。

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

