# ibireme :《深入理解 RunLoop》

> 文摘来源：[ibireme 的博客：《深入理解 RunLoop 》](https://blog.ibireme.com/2015/05/18/runloop/)，有增删。

<h2>目录</h2>

- [ibireme :《深入理解 RunLoop》](#ibireme-深入理解-runloop)
  - [源码](#源码)
  - [RunLoop 的概念](#runloop-的概念)

## 源码

`CFRunLoopRef` 的代码 `CFRunLoop.c` 是开源的，可以在这里 <http://opensource.apple.com/tarballs/CF/> 下载到整个 `CoreFoundation` 的源码。

Swift 开源后，苹果又维护了一个跨平台的 `CoreFoundation` 版本：<https://github.com/apple/swift-corelibs-foundation/> ，这个版本的源码可能和现有 iOS 系统中的实现略不一样，但更容易编译，而且已经适配了 Linux / Windows 。

## RunLoop 的概念

一般来讲，一个**线程**一次只能执行一个任务，执行完成后线程就会退出。如果我们需要一个机制，**让线程能随时处理事件但并不退出**，这种模型通常被称作 Event Loop ， 在 macOS / iOS 里被称作 RunLoop ，它的主要功能是管理事件/消息，让线程在没有处理消息时休眠以避免资源占用、在有消息到来时立刻被唤醒。

RunLoop 提供了一个入口函数来执行事件循环的逻辑。线程执行了这个函数后，就会一直处于这个函数内部 “接受消息->等待->处理” 的循环中，直到这个循环结束（比如传入 quit 的消息），函数返回。

macOS/iOS 系统中，提供了两个这样的对象：`NSRunLoop` 和 `CFRunLoopRef` 。

- `CFRunLoopRef` 是在 `CoreFoundation` 框架内的，它提供了纯 C 函数的 API ，所有这些 API 都是**线程安全**的。
- `NSRunLoop` 是基于 `CFRunLoopRef` 的封装，提供了面向对象的 API ，但是这些 API **不是线程安全**的。
