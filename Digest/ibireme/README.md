# YY 系列简介

> 文摘来源：[ibireme 的博客：《最近一段时间的工作整理》](https://blog.ibireme.com/2015/10/23/daily/)，有增删。

正式转为全职 iOS 工程师已经有**一年多**了，这一年里工作并不忙，使得我有更多的时间和精力来研究些有意思的东西。最近整理了下这一年攒下来的代码，拆分成了几个库，在接下来的一段时间内会陆续开源：

- [YYModel](https://github.com/ibireme/YYModel) 类似 Mantle / JSONModel 的工具，性能比 Mantle 高一个数量级，有更好的容错性，更简洁的 API。
- [YYWebImage](https://github.com/ibireme/YYWebImage) 类似 SDWebImage 的工具，基于 YYImage 和 YYCache ，有更好的性能、更丰富的功能。
  - [YYImage](https://github.com/ibireme/YYImage) iOS 图像库，支持高性能的 APNG / WebP / GIF 动图播放、编码和解码，支持帧动画等。
  - [YYCache](https://github.com/ibireme/YYCache) 类似 TMCache 那样的工具，有着更好的性能，支持 **LRU** ，磁盘缓存支持 **SQLite** 。
- [YYText](https://github.com/ibireme/YYText) `UILabel` 和 `UITextView` 的开源实现，支持**异步排版渲染**、**图文混排**、更多文字特效/点击效果、动画/表情输入、竖排版等。
  - [YYKeyboardManager](https://github.com/ibireme/YYKeyboardManager) 从 YYText 分离出来的一个键盘监听工具，能实时监听和获取键盘视图、位置、动画。
  - [YYDispatchQueuePool](https://github.com/ibireme/YYDispatchQueuePool) 从 YYText 分离出来的一个很简单的队列管理工具，用于管理全局并发任务。
  - [YYAsyncLayer](https://github.com/ibireme/YYAsyncLayer) 从 YYText 分离出来的一个很简单的 `CALayer` 的子类，用于进行异步绘制和显示。
- [YYCategories](https://github.com/ibireme/YYCategories) Category 类型的工具库。
- [YYKit](https://github.com/ibireme/YYKit) 上面所有工具的打包工具集，全部工具都兼容 *iOS 6~9* 。
- [YYKitDemo](https://github.com/ibireme/YYKit) YYKit 的功能/性能演示，实现有 Twitter 和 Weibo 的 Feed 列表、发布视图，有着和官方 App 完全一致的 UI 和更流畅的交互体验。

每个库都会配有几篇博客来介绍相关技术、性能评测，这也算是我最近一年工作的总结吧。
