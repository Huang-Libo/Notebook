# Mach-O

## 查看 Mach-O 的工具

### 1. MachOView

- **【推荐使用此版本 🌟 】** GitHub 上的一个比较新的 [Fork](https://github.com/fangshufeng/MachOView) ，最后更新日期是 `Aug 28, 2019` ，而且还添加了有几个比较好用的新功能，比如：在 *Symbol Table* 和 *Dynamic Symbol Table* 和 *String Table* 中**添加索引值**（非常方便 👍 ）以及十进制表示值，方便查找内容。
- 【原始版本】：在 [sourceforge](https://sourceforge.net/projects/machoview/) 下载，最后更新时间是 `2019-07-27` ，在 *macOS 11.5* 可用。
- 【不推荐使用】GitHub 上知名度最高的一个 [Fork](https://github.com/gdbinit/MachOView)，代码的最后更新时间是 `Apr 23, 2015` ，作者 `Jun 25, 2020` 在 `README.md` 中说不再维护了，推荐大家使用另外几个 Fork 。虽然他有更好版本的代码，但受 `NDAs` 的限制。他也没有精力去重新再制造一个轮子。最后他说，安全地解析可执行二进制需要大量的 `C/C++` 工作。这是可能的，但很累人。🧱 😅

### 2. MachO-Explorer

- [MachO-Explorer](https://github.com/DeVaukz/MachO-Explorer) 是用 `Swift 5` 实现的版本，功能大致和 MachOView 相同，UI 略简陋，是个潜力股。它对 Mach-O 解析是用的作者写的另一个名为 [MachO-Kit](https://github.com/DeVaukz/MachO-Kit) 的工具完成的。

## 符号表 Hook

**注意**：下面引用的内容写的有点问题。hook 的不是符号表，而是 lazy/non-lazy symbol pointer 中（里面存储的是指针数组）中相应指针中存储的地址值。

> 《macOS 软件安全与逆向》，9.4.2 SymbolTable Hook ，P/355

SymbolTable Hook 即符号表 Hook ，通过对目标程序的符号表做手脚来达到Hook的目的。

Mach-O 程序中的符号分为两种：

- 一种是直接在动态链接程序时就需要绑定的符号 **non-lazily symbol** ，即**非延迟绑定的符号**，它保存在 `＿DATA` 段中的 `＿nl_symbol_ptr` 节区中；
- 另一种是在程序运行后第一次调用才会绑定的符号 **lazily symbol** ，即**延迟绑定的符号**，它保存在 `＿DATA` 段中的 `＿la_symbol_ptr` 节区中。

延迟绑定符号的绑定操作是 dyld 在加载程序时，通过例程 `dyld_stub_binder` 成的。**这两张表都保存了符号的名称与内存中的地址，符号表 Hook 的原理就是在镜像加载绑定符号时，修改符号表指向的内存地址**，通过这种“移花接木”的方式来完成 Hook 。

基于这种 Hook 思想，网上有 Facebook 公司发布的开源符号表 Hook 工具 [fishhook](https://github.com/facebook/fishhook) ，虽然介绍中说是针对 iOS 平台的，但实际上对 macOS 系统上的 Mach-O 文件的符号表 Hook 也是可用的。

fishhook 提供了 `rebind_symbols()` 与 `rebind_symbols_image()` ，来实现对当前镜像与指定镜像的符号重绑定工作，这两个方法都是调用 `rebind_symbols_for_image()` 来完成工作的。

## 源码

- [xnu/mach-o](https://opensource.apple.com/source/xnu/xnu-7195.141.2/EXTERNAL_HEADERS/mach-o/)
  - [xnu/mach-o/loader.h](https://opensource.apple.com/source/xnu/xnu-7195.141.2/EXTERNAL_HEADERS/mach-o/loader.h.auto.html)
  - [xnu/mach-o/nlist.h](https://opensource.apple.com/source/xnu/xnu-7195.141.2/EXTERNAL_HEADERS/mach-o/nlist.h.auto.html)
  - [xnu/mach-o/reloc.h](https://opensource.apple.com/source/xnu/xnu-7195.141.2/EXTERNAL_HEADERS/mach-o/reloc.h.auto.html)

## 参考

- [OS X ABI Mach-O File Format Reference](https://github.com/Huang-Libo/osx-abi-macho-file-format-reference)
- [戴铭：Apple 操作系统可执行文件 Mach-O](https://ming1016.github.io/2020/03/29/apple-system-executable-file-macho/)
- [张不坏 - Mach-O 简单分析](https://zhangbuhuai.com/post/macho-structure.html)
- [Position-Independent Code](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/MachOTopics/1-Articles/dynamic_code.html#//apple_ref/doc/uid/TP40002528)
