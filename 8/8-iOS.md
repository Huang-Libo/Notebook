# 8-iOS

## UIView 和 CALayer 的区别

- `UIView` 属于 `UIKit` 框架，仅用于 iOS 系统，它可以响应交互事件；而 `CALayer` 属于 `Core Animation` 框架，是 iOS 和 macOS 通用的，它只负责页面的绘制，无法响应交互事件。
- 每个 `UIView` 都有一个相应的 `CALayer` 属性；
- `CALayer` 有一个 `CALayerDelegate` 类型的 `delegate` 属性，而 `UIView` 通常就是 `CALayer` 的 `delegate` ；
- 这样的设计遵守了单一职责的原则，使得 `CALayer` 在不同平台上可以被复用。
  - 在不同类型的设备上，交互逻辑也是不一样的。比如在 iOS 系统上是触摸操作，负责交互的是 `UIKit` 中的 `UIView` ；在 macOS 系统上是键鼠操作，负责交互的是 `AppKit` 中的 `NSView` 。
  - 但它们的图形绘制的方式是一样的，`UIView` 和 `NSView` 的底层都是使用 `CALayer` 进行绘制的。

## iOS 系统响应触摸事件的机制

1）手指触碰屏幕，屏幕感应到触碰后，将事件交由 `IOKit` 处理。

2）`IOKit` 将触摸事件封装成一个 `IOHIDEvent` 对象，并通过 `mach port` 传递给 `SpringBoad` 进程。

- `mach port` ：进程端口，各进程之间通过它进行通信。
- `SpringBoad` ：是一个系统进程，可以理解为桌面系统，可以**统一管理和分发系统接收到的触摸事件**。

3）`SpringBoard` 进程因接收到触摸事件，触发了主线程 `RunLoop` 的 `source1` 事件源的回调。此时 `SpringBoard` 会根据当前桌面的状态，判断应该由谁处理此次触摸事件。因为事件发生时，你可能正在桌面上翻页，也可能正在刷微博。

- 若是前者（即前台无 APP 运行），则触发 `SpringBoard` 本身主线程 `RunLoop` 的 `source0` 事件源的回调，将事件交由桌面系统去消耗；
- 若是后者（即有 APP 正在前台运行），则将触摸事件通过 `IPC`（进程间通信）传递给前台 APP 进程。

## fishhook 的原理 & 位置无关代码

> 参考：[fishhook & PIC](../iOS/fishhook.md)

fishhook 的功能：对**外部符号**进行*符号重绑定 (symbol rebind)* 。要说清楚它的实现原理，需要先说*位置无关代码 (Position Independent Code, PIC)*。

**位置无关代码**：

*自己源码中实现的 C 函数*和*静态库中的 C 函数*对应的符号属于**内部符号**，它们的**地址偏移量**在编译时就确定了，存储在 Mach-O 文件的 `__TEXT` 段。由于 `__TEXT` 段是只读的，且会进行代码签名验证，因此是不能修改的。

如果代码中有**外部符号**，比如系统动态库的 C 函数，由于编译器在生成 Mach-O 文件时无法知道该函数的实际地址，因此会插入一个 **stub（符号桩）**。

外部符号的地址值存储在 Mach-O 文件的 `(__DATA,__la_symbol_ptr)` 或 `(__DATA_CONST,__got)` 中。其中， `__la_symbol_ptr` 中的符号是惰性绑定的，它的初始值是指向 Mach-O 的 `(__TEXT,__stub_helper)` 区域，经过调用一系列汇编指令之后，最终指向了 `dyld_stub_binder` 。

在第一次调用惰性绑定的符号时，会通过 `dyld_stub_binder` 去查找符号的真实地址、填入到 `__la_symbol_ptr` 对应的符号的 **Data** 中，这样就完成了*符号绑定 (symbol bind)*。之后再调用这个符号时，就能直接调用它的实现了。

**fishhook 的适用范围**：

据此我们我们可以得知， fishhook 的适用范围是

- 可以 hook 外部符号
- 但无法 hook 内部符号

**fishhook 的原理**：

修改 `__la_symbol_ptr` 中外部符号存储的地址值，将它改为我们自己实现的函数的地址值。同时用一个函数指针存储外部符号的原始实现，这样就还能调用到该符号的原始实现。

