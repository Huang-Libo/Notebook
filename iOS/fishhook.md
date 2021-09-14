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

 源码中给出的示例：

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

```objectivec
#import <dlfcn.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "fishhook.h"
 
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
        // Use fishhook to rebind symbols
        rebind_symbols((struct rebinding[2]){
            {"close", my_close, (void *)&orig_close},
            {"open", my_open, (void *)&orig_open}
        }, 2);
     
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
