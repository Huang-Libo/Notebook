# 漫谈 iOS Crash 收集框架

- 文章归档：[Intenet Archive: 《漫谈 iOS Crash 收集框架》](https://web.archive.org/web/20170302231915/https://nianxi.net/ios/ios-crash-reporter.html)

为了能够第一时间发现程序问题，应用程序需要实现自己的崩溃日志收集服务，成熟的开源项目很多，如 KSCrash，plcrashreporter，CrashKit 等。追求方便省心，对于保密性要求不高的程序来说，也可以选择各种一条龙Crash统计产品，如 Crashlytics，Hockeyapp ，友盟，Bugly 等等。

是否集成越多的Crash日志收集服务就越保险？
自己收集的Crash日志和系统生成的Crash日志有分歧，应该相信谁？
为什么有大量Crash日志显示崩在main函数里,但函数栈中却没有一行自己的代码？
野指针类的Crash难定位，有何妙招来应对？
想解释清这些问题，必须从Mach异常说起

- [漫谈 iOS Crash 收集框架](#漫谈-ios-crash-收集框架)
  - [Mach 异常与 Unix 信号](#mach-异常与-unix-信号)

## Mach 异常与 Unix 信号

iOS 系统自带的 *Apple’s Crash Reporter* 记录设备中的 Crash 日志，Exception Type 项通常会包含两个元素：**Mach 异常** 和 **Unix 信号**。

```plaintext
Exception Type:         EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype:      KERN_INVALID_ADDRESS at 0x041a6f3
```

Mach异常是什么？它又是如何与Unix信号建立联系的？ Mach是一个XNU的微内核核心，Mach异常是指最底层的内核级异常，被定义在 <mach/exception_types.h>下 。每个thread，task，host都有一个异常端口数组，Mach的部分API暴露给了用户态，用户态的开发者可以直接通过Mach API设置thread，task，host的异常端口，来捕获Mach异常，抓取Crash事件。

所有Mach异常都在host层被ux_exception转换为相应的Unix信号，并通过threadsignal将信号投递到出错的线程。iOS中的 POSIX API 就是通过 Mach 之上的 BSD 层实现的。

因此，EXC_BAD_ACCESS (SIGSEGV)表示的意思是：Mach层的EXC_BAD_ACCESS异常，在host层被转换成SIGSEGV信号投递到出错的线程。既然最终以信号的方式投递到出错的线程，那么就可以通过注册signalHandler来捕获信号:

```objectivec
signal(SIGSEGV,signalHandler);
```

捕获Mach异常或者Unix信号都可以抓到crash事件，这两种方式哪个更好呢？ 优选Mach异常，因为Mach异常处理会先于Unix信号处理发生，如果Mach异常的handler让程序exit了，那么Unix信号就永远不会到达这个进程了。转换Unix信号是为了兼容更为流行的POSIX标准(SUS规范)，这样不必了解Mach内核也可以通过Unix信号的方式来兼容开发。

> 因为硬件产生的信号(通过CPU陷阱)被Mach层捕获，然后才转换为对应的Unix信号；苹果为了统一机制，于是操作系统和用户产生的信号(通过调用kill和pthread_kill)也首先沉下来被转换为Mach异常，再转换为Unix信号。
