# iOS 保持界面流畅的技巧

> 文摘来源：[ibireme 的博客：《iOS 保持界面流畅的技巧》](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)，有增删。

这篇文章会非常详细的分析 iOS 界面构建中的各种性能问题以及对应的解决思路，同时给出一个开源的微博列表实现，通过实际的代码展示如何构建流畅的交互。

- [iOS 保持界面流畅的技巧](#ios-保持界面流畅的技巧)
  - [演示项目](#演示项目)
  - [屏幕显示图像的原理](#屏幕显示图像的原理)
  - [卡顿产生的原因](#卡顿产生的原因)
  - [CPU 资源消耗原因和解决方案](#cpu-资源消耗原因和解决方案)
    - [1. 对象创建](#1-对象创建)
    - [2. 对象调整](#2-对象调整)
    - [3. 对象销毁](#3-对象销毁)
    - [4. 布局计算](#4-布局计算)
    - [5. Autolayout](#5-autolayout)
    - [6. 文本计算](#6-文本计算)
    - [7. 文本渲染](#7-文本渲染)
    - [8. 图片的解码](#8-图片的解码)
    - [9. 图像的绘制](#9-图像的绘制)
  - [GPU 资源消耗原因和解决方案](#gpu-资源消耗原因和解决方案)
    - [1. 纹理的渲染](#1-纹理的渲染)
    - [2. 视图的混合 (Composing)](#2-视图的混合-composing)
    - [3. 图形的生成](#3-图形的生成)
  - [AsyncDisplayKit](#asyncdisplaykit)
    - [ASDK 的由来](#asdk-的由来)
    - [ASDK 的基本原理](#asdk-的基本原理)

## 演示项目

在开始技术讨论前，你可以先下载我写的 Demo 跑到真机上体验一下：<https://github.com/ibireme/YYKit> 。 Demo 里包含一个微博的 Feed 列表、发布视图，还包含一个 Twitter 的 Feed 列表。为了公平起见，所有界面和交互我都从官方应用原封不动的抄了过来，数据也都是从官方应用抓取的。你也可以自己抓取数据替换掉 Demo 中的数据，方便进行对比。尽管官方应用背后的功能更多更为复杂，但不至于会带来太大的交互性能差异。

![YYKitDemo.jpg](../media/Digest/ibireme/smooth-user-interface/YYKitDemo.jpg)

这个 Demo 最低可以运行在 iOS 6 上，所以你可以把它跑到老设备上体验一下。在我的测试中，即使在 iPhone 4S 或者 iPad 3 上，Demo 列表在快速滑动时仍然能保持 50~60 FPS 的流畅交互，而其他诸如微博、朋友圈等 App 的列表视图在滑动时已经有很严重的卡顿了。

微博的 Demo 有大约四千行代码，Twitter 的只有两千行左右代码，第三方库只用到了 YYKit ，文件数量比较少，方便查看。好了，下面是正文。

## 屏幕显示图像的原理

<img src="../media/Digest/ibireme/smooth-user-interface/ios_screen_scan.png" width="400"/>

> CRT 显示器是一种使用阴极射线管 (Cathode Ray Tube) 的显示器

首先从过去的 CRT 显示器原理说起。CRT 的电子枪按照上面方式，从上到下一行行扫描，扫描完成后显示器就呈现一帧画面，随后电子枪回到初始位置继续下一次扫描。为了把显示器的显示过程和系统的`视频控制器`进行同步，显示器（或者其他硬件）会用硬件时钟产生一系列的定时信号。

- 当电子枪换到新的一行，准备进行扫描时，显示器会发出一个**水平同步信号（horizonal synchronization），简称 HSync**；
- 而当一帧画面绘制完成后，电子枪回复到原位，准备画下一帧前，显示器会发出一个**垂直同步信号（vertical synchronization），简称 VSync** 。

**显示器通常以固定频率进行刷新，这个刷新率就是 VSync 信号产生的频率**。尽管现在的设备大都是液晶显示屏了，但原理仍然没有变。

![ios_screen_display.png](../media/Digest/ibireme/smooth-user-interface/ios_screen_display.png)

通常来说，计算机系统中 CPU 、GPU 、显示器是以上面这种方式协同工作的。CPU 计算好显示内容提交到 GPU ，GPU 渲染完成后将渲染结果放入 **FrameBuffer（帧缓冲区）**，随后`视频控制器`会按照 `VSync` 信号逐行读取 `FrameBuffer` 的数据，经过可能的*数模转换*传递给显示器显示。

在最简单的情况下， `FrameBuffer` 只有一个，这时 `FrameBuffer` 的读取和刷新都都会有比较大的效率问题。为了解决效率问题，显示系统通常会引入两个缓冲区，即**双缓冲机制**。在这种情况下，GPU 会预先渲染好一帧放入一个缓冲区内，让`视频控制器`读取，当下一帧渲染好后，GPU 会直接把`视频控制器`的指针指向第二个缓冲器。如此一来效率会有很大的提升。

双缓冲虽然能解决效率问题，但会引入一个新的问题。当`视频控制器`还未读取完成时，即屏幕内容刚显示一半时，GPU 将新的一帧内容提交到 `FrameBuffer` 并把两个缓冲区进行交换后，`视频控制器`就会把新的一帧数据的下半段显示到屏幕上，造成画面撕裂现象，如下图：

![ios_vsync_off.jpg](../media/Digest/ibireme/smooth-user-interface/ios_vsync_off.jpg)

为了解决这个问题，**GPU 通常有一个机制叫做垂直同步（简写也是 V-Sync）**，当开启垂直同步后，GPU 会等待显示器的 VSync 信号发出后，才进行新的一帧的渲染和缓冲区更新。这样能解决画面撕裂的现象，也增加了画面的流畅度，但需要消耗更多的计算资源，也会带来部分延迟。

那么目前主流的移动设备是什么情况呢？从网上查到的资料可以知道，

- **iOS 设备会始终使用双缓冲，并开启垂直同步**；
- 而安卓设备直到 4.1 版本，Google 才开始引入这种机制，目前安卓系统是三缓冲+垂直同步。

## 卡顿产生的原因

![ios_frame_drop.png](../media/Digest/ibireme/smooth-user-interface/ios_frame_drop.png)

在 `VSync` 信号到来后，系统图形服务会通过 `CADisplayLink` 等机制通知 App ，App 主线程开始在 CPU 中计算显示内容，比如视图的创建、布局计算、图片解码、文本绘制等。随后 CPU 会将计算好的内容提交到 GPU 去，由 GPU 进行变换、合成、渲染。随后 GPU 会把渲染结果提交到 `FrameBuffer` 去，等待下一次 VSync 信号到来时显示到屏幕上。

依据垂直同步的机制，如果在一个 VSync 时间内，CPU 或者 GPU 没有完成内容提交，则那一帧就会被丢弃，等待下一次收到 VSync 信号时再显示，而这时显示屏会保留之前的内容不变。这就是界面卡顿的原因。

从上面的图中可以看到，CPU 和 GPU 不论哪个阻碍了显示流程，都会造成掉帧的现象。所以开发时，也需要分别对 CPU 和 GPU 压力进行评估和优化。

## CPU 资源消耗原因和解决方案

### 1. 对象创建

对象的创建会分配内存、调整属性、甚至还有读取文件等操作，比较消耗 CPU 资源。**尽量用轻量的对象代替重量的对象**，可以对性能有所优化。比如 `CALayer` 比 `UIView` 要轻量许多，那么**不需要响应触摸事件的控件，用 CALayer 显示会更加合适**。如果对象不涉及 UI 操作，则尽量放到子线程去创建，但可惜的是包含有 CALayer 的控件，都只能在主线程创建和操作。**通过 Storyboard 创建视图对象时，其资源消耗会比直接通过代码创建对象要大非常多**，在性能敏感的界面里，Storyboard 并不是一个好的技术选择。

尽量推迟对象创建的时间，并把对象的创建分散到多个任务中去。尽管这实现起来比较麻烦，并且带来的优势并不多，但如果有能力做，还是要尽量尝试一下。如果对象可以复用，并且复用的代价比释放、创建新对象要小，那么这类对象应当尽量放到一个缓存池里复用。

### 2. 对象调整

对象的调整也经常是消耗 CPU 资源的地方。这里特别说一下 `CALayer` ：`CALayer` 内部并没有属性，当调用属性方法时，它内部是通过运行时 `resolveInstanceMethod` 为对象临时添加一个方法，并把对应属性值保存到内部的一个 `Dictionary` 里，同时还会通知 `delegate` 、创建动画等等，非常消耗资源。`UIView` 的关于显示相关的属性（比如 `frame` / `bounds` / `transform`）等实际上都是 `CALayer` 属性映射来的，所以对 `UIView` 的这些属性进行调整时，消耗的资源要远大于一般的属性。对此你在应用中，应该尽量减少不必要的属性修改。

当视图层次调整时，`UIView` 、`CALayer` 之间会出现很多方法调用与通知，所以在优化性能时，应该**尽量避免调整视图层次、添加和移除视图**。

### 3. 对象销毁

对象的销毁虽然消耗资源不多，但累积起来也是不容忽视的。通常当容器类持有大量对象时，其销毁时的资源消耗就非常明显。同样的，如果对象可以放到子线程去释放，那就挪到子线程去。这里有个小 Tip ：把对象捕获到 block 中，然后扔到后台队列去随便发送个消息以避免编译器警告，就可以让对象在子线程销毁了。

```objectivec
NSArray *tmp = self.array;
self.array = nil;
dispatch_async(queue, ^{
    [tmp class];
});
```

### 4. 布局计算

**视图布局的计算是 App 中最为常见的消耗 CPU 资源的地方。如果能在子线程提前计算好视图布局、并且对视图布局进行缓存，那么这个地方基本就不会产生性能问题了**。

不论使用何种技术对视图进行布局，其最终都会落到对 `UIView` 的 `frame` / `bounds` / `center` 等属性的调整上。上面也说过，对这些属性的调整非常消耗资源，所以尽量提前计算好布局，在需要时一次性调整好对应属性，而不要多次、频繁的计算和调整这些属性。

### 5. Autolayout

`Autolayout` 是苹果本身提倡的技术，在大部分情况下也能很好的提升开发效率，但是 `Autolayout` 对于复杂视图来说常常会产生严重的性能问题。随着视图数量的增长，`Autolayout` 带来的 CPU 消耗会呈指数级上升。如果你不想手动调整 `frame` 等属性，你可以用一些工具方法替代（比如常见的 `left` / `right` / `top` / `bottom` / `width` / `height` 快捷属性），或者使用 `ComponentKit`、`AsyncDisplayKit` 等框架。

### 6. 文本计算

如果一个界面中包含大量文本（比如微博、微信朋友圈等），文本的宽高计算会占用很大一部分资源，并且不可避免。如果对文本的显示没有特殊要求，可以参考下 `UILabel` 内部的实现方式：

- 用 `-[NSAttributedString boundingRectWithSize:options:context:]` 来计算文本宽高；
- 用 `-[NSAttributedString drawWithRect:options:context:]` 来绘制文本。

尽管这两个方法性能不错，但仍旧需要放到子线程进行以避免阻塞主线程。

如果你用 `CoreText` 绘制文本，那就可以先生成 `CoreText` 排版对象，然后自己计算了，并且 `CoreText` 对象还能保留以供稍后绘制使用。

### 7. 文本渲染

屏幕上能看到的所有文本内容控件，包括 `UIWebView` ，在底层都是通过 `CoreText` 排版、绘制为 `Bitmap` 显示的。常见的文本控件（ `UILabel` 、`UITextView` 等），其**排版和绘制都是在主线程进行的，当显示大量文本时，CPU 的压力会非常大**。

`对此解决方案只有一个`，那就是自定义文本控件，用 `TextKit` 或最底层的 `CoreText` 对文本异步绘制。尽管这实现起来非常麻烦，但其带来的优势也非常大，`CoreText` 对象创建好后，能直接获取文本的宽高等信息，避免了多次计算（调整 `UILabel` 大小时算一遍、`UILabel` 绘制时内部再算一遍）；`CoreText` 对象占用内存较少，可以缓存下来以备稍后多次渲染。

### 8. 图片的解码

当你用 `UIImage` 或 `CGImageSource` 的那几个方法创建图片时，图片数据并不会立刻解码。图片设置到 `UIImageView` 或者 `CALayer.contents` 中去，并且 `CALayer` 被提交到 GPU 前，CGImage 中的数据才会得到解码。这一步是发生在**主线程**的，并且不可避免。

如果想要绕开这个机制，常见的做法是在**子线程**先把图片绘制到 `CGBitmapContext` 中，然后从 `Bitmap` 直接创建图片。目前常见的网络图片库都自带这个功能。

### 9. 图像的绘制

图像的绘制通常是指用那些以 `CG` 开头的方法把图像绘制到画布中，然后从画布创建图片并显示这样一个过程。这个最常见的地方就是 `[UIView drawRect:]` 里面了。**由于 `CoreGraphic` 方法通常都是线程安全的，所以图像的绘制可以很容易的放到子线程进行**。一个简单**异步绘制**的过程大致如下（实际情况会比这个复杂得多，但原理基本一致）：

```objectivec
- (void)display {
    dispatch_async(backgroundQueue, ^{
        CGContextRef ctx = CGBitmapContextCreate(...);
        // draw in context...
        CGImageRef img = CGBitmapContextCreateImage(ctx);
        CFRelease(ctx);
        dispatch_async(mainQueue, ^{
            layer.contents = img;
        });
    });
}
```

## GPU 资源消耗原因和解决方案

相对于 CPU 来说，GPU 能干的事情比较单一：接收提交的纹理（Texture）和顶点描述（三角形），应用变换（transform）、混合并渲染，然后输出到屏幕上。通常我们所能看到的内容，主要也就是纹理（图片）和形状（三角模拟的矢量图形）两类。

### 1. 纹理的渲染

所有的 `Bitmap` ，包括图片、文本、栅格化的内容，最终都要由内存提交到显存，绑定为 *GPU Texture* 。不论是提交到显存的过程，还是 GPU 调整和渲染 Texture 的过程，都要消耗不少 GPU 资源。当在较短时间显示大量图片时（比如 `UITableView` 存在非常多的图片并且快速滑动时），CPU 占用率很低，GPU 占用非常高，界面仍然会掉帧。避免这种情况的方法只能是尽量减少在短时间内大量图片的显示，尽可能**将多张图片合成为一张进行显示**。

当图片过大，超过 GPU 的最大纹理尺寸时，图片需要先由 CPU 进行预处理，这对 CPU 和 GPU 都会带来额外的资源消耗。目前来说，iPhone 4S 以上机型，**纹理尺寸上限都是 4096 × 4096** ，更详细的资料可以看[这里](http://iosres.com/)。所以，尽量不要让图片和视图的大小超过这个值。

### 2. 视图的混合 (Composing)

当多个视图（或者说 `CALayer` ）重叠在一起显示时，GPU 会首先把他们混合到一起。如果视图结构过于复杂，混合的过程也会消耗很多 GPU 资源。为了减轻这种情况的 GPU 消耗，App 应当**尽量减少视图数量和层次，并在不透明的视图里标明 `opaque` 属性以避免无用的 `alpha` 通道合成**。

当然，这也可以用上面的方法，**把多个视图预先渲染为一张图片来显示**。

### 3. 图形的生成

`CALayer` 的 `border` 、圆角、阴影、遮罩（mask），`CASharpLayer` 的矢量图形显示，通常会触发**离屏渲染（offscreen rendering）**，而离屏渲染通常发生在 GPU 中。当一个列表视图中出现大量圆角的 `CALayer` ，并且快速滑动时，可以观察到 GPU 资源已经占满，而 CPU 资源消耗很少。这时界面仍然能正常滑动，但平均帧数会降到很低。

为了避免这种情况，可以尝试开启 `CALayer.shouldRasterize` 属性，但这会把原本离屏渲染的操作转嫁到 CPU 上去。对于只需要圆角的某些场合，也可以用一张已经绘制好的圆角图片覆盖到原本视图上面来模拟相同的视觉效果。

**最彻底的解决办法，就是把需要显示的图形在子线程绘制为图片，避免使用圆角、阴影、遮罩等属性。**

## AsyncDisplayKit

### ASDK 的由来

ASDK 的作者是 Scott Goodson ，他曾经在苹果工作，负责 iOS 的一些内置应用的开发，比如股票、计算器、地图、钟表、设置、Safari 等，当然他也参与了 `UIKit` framework 的开发。

后来他加入 Facebook 后，负责 Paper 的开发，创建并开源了 `AsyncDisplayKit` 。目前他在 Pinterest 和 Instagram 负责 iOS 开发和用户体验的提升等工作。

### ASDK 的基本原理

<img src="../media/Digest/ibireme/smooth-user-interface/ASDK-design.png" width="70%"/>

ASDK 认为，阻塞主线程的任务，主要分为上面这三大类（布局、渲染、操作 UI 对象）。文本和布局的计算、渲染、解码、绘制都可以通过各种方式异步执行，但 `UIKit` 和 `Core Animation` 相关操作必需在主线程进行。ASDK 的目标，就是尽量把这些任务从主线程挪走，而挪不走的，就尽量优化性能。

先看 `UIView` 和 `CALayer` 的关系：

<img src="../media/Digest/ibireme/smooth-user-interface/ASDK-layer-backed-view.png" width="60%"/>

可看出：

- `view` 持有 `layer` 用于显示，`view` 中大部分显示属性实际是从 `layer` 映射而来；
- `layer` 的 `delegate` 在这里是 `view` ，当其属性改变、动画产生时，`view` 能够得到通知。

`UIView` 和 `CALayer` 不是线程安全的，并且只能在**主线程**创建、访问和销毁。

ASDK 尝试对 `UIKit` 组件进行封装：

**1. view backed node：**

![ASDK-view-backed-node.png](../media/Digest/ibireme/smooth-user-interface/ASDK-view-backed-node.png)

ASDK 为此创建了 `ASDisplayNode` 类，包装了常见的视图属性（比如 `frame` / `bounds` / `alpha` / `transform` / `backgroundColor` / `superNode` / `subNodes` 等），然后它用 `UIView` -> `CALayer` 相同的方式，实现了 `ASNode` -> `UIView` 这样一个关系。

**2. view backed node：**

<img src="../media/Digest/ibireme/smooth-user-interface/ASDK-layer-backed-node.png" width="60%"/>

当不需要响应触摸事件时，`ASDisplayNode` 可以被设置为 *layer backed* ，即 `ASDisplayNode` 充当了原来 `UIView` 的功能，节省了更多资源。

**`ASDisplayNode` 的特点**：

- 与 `UIView` 和 `CALayer` 不同，`ASDisplayNode` 是线程安全的，它可以在子线程创建和修改。
- `Node` 刚创建时，并不会在内部新建 `UIView` 和 `CALayer` ，直到第一次在主线程访问 `view` 或 `layer` 属性时，它才会在内部生成对应的对象。
- 当它的属性（比如 `frame` / `transform` ）改变后，它并不会立刻同步到其持有的 `view` 或 `layer` 去，而是把被改变的属性保存到内部的一个中间变量，稍后在需要时，再通过某个机制一次性设置到内部的 `view` 或 `layer` 。

通过模拟和封装 `UIView` / `CALayer`，开发者可以把代码中的 `UIView` 替换为 `ASNode` ，很大的降低了开发和学习成本，同时能获得 ASDK 底层大量的性能优化。

为了方便使用， ASDK 把大量常用控件都封装成了 `ASNode` 的子类，比如 `Button` 、`Control` 、`Cell` 、`Image` 、`ImageView` 、`Text` 、`TableView` 、`CollectionView` 等。利用这些控件，开发者可以尽量避免直接使用 `UIKit` 相关控件，以获得更完整的性能提升。