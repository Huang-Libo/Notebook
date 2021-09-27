# Mach-O

## 查看 Mach-O 的工具

### 1. MachOView

- **【推荐使用此版本 🌟 】** GitHub 上的一个比较新的 [Fork](https://github.com/fangshufeng/MachOView) ，最后更新日期是 `Aug 28, 2019` ，而且还添加了有几个比较好用的新功能，比如：在 *Symbol Table* 和 *Dynamic Symbol Table* 和 *String Table* 中**添加索引值**（非常方便 👍 ）以及十进制表示值，方便查找内容。
- 【原始版本】：在 [sourceforge](https://sourceforge.net/projects/machoview/) 下载，最后更新时间是 `2019-07-27` ，在 *macOS 11.5* 可用。
- 【不推荐使用】GitHub 上知名度最高的一个 [Fork](https://github.com/gdbinit/MachOView)，代码的最后更新时间是 `Apr 23, 2015` ，作者 `Jun 25, 2020` 在 `README.md` 中说不再维护了，推荐大家使用另外几个 Fork 。虽然他有更好版本的代码，但受 `NDAs` 的限制。他也没有精力去重新再制造一个轮子。最后他说，安全地解析可执行二进制需要大量的 `C/C++` 工作。这是可能的，但很累人。🧱 😅

### 2. MachO-Explorer

- [MachO-Explorer](https://github.com/DeVaukz/MachO-Explorer) 是用 `Swift 5` 实现的版本，功能大致和 MachOView 相同，UI 略简陋，是个潜力股。它对 Mach-O 解析是用的作者写的另一个名为 [MachO-Kit](https://github.com/DeVaukz/MachO-Kit) 的工具完成的。
