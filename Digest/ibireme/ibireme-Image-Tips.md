# iOS 处理图片的 Tips

> 文摘来源：[ibireme 的博客：《iOS 处理图片的一些小 Tip 》](https://blog.ibireme.com/2015/11/02/ios_image_tips/)，有增删。

<h2>目录</h2>

- [iOS 处理图片的 Tips](#ios-处理图片的-tips)
  - [如何把 GIF 动图保存到相册？](#如何把-gif-动图保存到相册)
  - [将 UIImage 保存到磁盘，用什么方式最好？](#将-uiimage-保存到磁盘用什么方式最好)
  - [UIImage 缓存是怎么回事？](#uiimage-缓存是怎么回事)
  - [我要是用 imageWithData 能不能避免缓存呢？](#我要是用-imagewithdata-能不能避免缓存呢)
  - [怎么能避免缓存呢？](#怎么能避免缓存呢)
  - [我能直接取到图片解码后的数据，而不是通过画布取到吗？](#我能直接取到图片解码后的数据而不是通过画布取到吗)
  - [如何判断一个文件的图片类型？](#如何判断一个文件的图片类型)
  - [怎样像浏览器那样边下载边显示图片？](#怎样像浏览器那样边下载边显示图片)

## 如何把 GIF 动图保存到相册？

iOS 的相册是支持保存 GIF 和 APNG 动图的，~~只是不能直接播放~~（现在已经可以播放了）。

- ~~用 `[ALAssetsLibrary writeImageDataToSavedPhotosAlbum:metadata:completionBlock]`~~（从 *iOS 10* 开始已过期，请改用 `PhotoKit` 中的方法）可以直接把 APNG 、GIF 的数据写入相册；
- 如果图省事直接用 `UIImageWriteToSavedPhotosAlbum()` 写相册，那么图像会被强制转码为 PNG 。（变成静态图了）

## 将 UIImage 保存到磁盘，用什么方式最好？

目前来说，保存 `UIImage` 有三种方式：

1. 直接用 `NSKeyedArchiver` 把 `UIImage` 序列化保存；
2. 用 `UIImagePNGRepresentation()` 先把图片转为 PNG 保存；
3. 用 `UIImageJPEGRepresentation()` 把图片压缩成 JPEG 保存。

实际上，`NSKeyedArchiver` 是调用了 `UIImagePNGRepresentation()` 进行序列化的，用它来保存图片是消耗最大的。

**苹果对 JPEG 有硬编码和硬解码，保存成 JPEG 会大大缩减编码解码时间，也能减小文件体积**。所以如果图片不包含透明像素时，`UIImageJPEGRepresentation(0.9)` 是最佳的图片保存方式，其次是 `UIImagePNGRepresentation()` 。

## UIImage 缓存是怎么回事？

通过 `imageNamed` 创建 `UIImage` 时，系统**实际上只是在 Bundle 内查找到文件名**，然后把这个文件名放到 `UIImage` 里返回，**并没有进行实际的文件读取和解码**。

当 `UIImage` **第一次显示到屏幕上时，其内部的解码方法才会被调用，同时解码结果会保存到一个全局缓存去**。据我观察，**在图片解码后，App 第一次退到后台和收到内存警告时，该图片的缓存才会被清空**，其他情况下缓存会一直存在。

## 我要是用 imageWithData 能不能避免缓存呢？

不能。通过数据创建 `UIImage` 时，`UIImage` 底层是调用 `ImageIO` 的 `CGImageSourceCreateWithData()` 方法。该方法有个参数叫 `ShouldCache` ，**在 64 位的设备上，这个参数是默认开启的**。

- **这个图片也是同样在第一次显示到屏幕时才会被解码**，随后解码数据被缓存到 `CGImage` 内部。
- 与 `imageNamed` 创建的图片不同，**如果这个图片被释放掉，其内部的解码数据也会被立刻释放**。

## 怎么能避免缓存呢？

1. 手动调用 `CGImageSourceCreateWithData()` 来创建图片，并把 `ShouldCache` 和 `ShouldCacheImmediately` 关掉。**这么做会导致每次图片显示到屏幕时，解码方法都会被调用，造成很大的 CPU 占用**。
2. 把图片用 `CGContextDrawImage()` 绘制到画布上，然后**把画布的数据取出来当作图片。这也是常见的网络图片库的做法**。

## 我能直接取到图片解码后的数据，而不是通过画布取到吗？

1. `CGImageSourceCreateWithData(data)` 创建 `ImageSource`。
2. `CGImageSourceCreateImageAtIndex(source)` 创建一个未解码的 `CGImage` 。
3. `CGImageGetDataProvider(image)` 获取这个图片的**数据源**。
4. `CGDataProviderCopyData(provider)` 从数据源获取直接解码的数据。

`ImageIO` 解码发生在最后一步，**这样获得的数据是没有经过颜色类型转换的原生数据（比如灰度图像）**。

## 如何判断一个文件的图片类型？

通过**读取文件或数据的头几个字节然后和对应图片格式标准进行比对**。我在 [YYImage](https://github.com/ibireme/YYImage/blob/master/YYImage/YYImageCoder.m#L1066-L1141) 内写了一个简单的函数，能很快速的判断图片格式。

## 怎样像浏览器那样边下载边显示图片？

首先，图片本身有 3 种常见的编码方式：

<p>
<img src="https://raw.githubusercontent.com/Huang-Libo/image-hosting/master/Default/image-baseline.gif" width="160"/>
<img src="https://raw.githubusercontent.com/Huang-Libo/image-hosting/master/Default/image-interlaced.gif" width="160"/>
<img src="https://raw.githubusercontent.com/Huang-Libo/image-hosting/master/Default/image-progressive.gif" width="160"/>
</p>

- `baseline` ，即**逐行扫描。默认情况**下，JPEG 、PNG 、GIF 都是这种保存方式；
- `interlaced` ，即隔行扫描。PNG 和 GIF 在保存时可以选择这种格式；
- `progressive` ，即**渐进式。JPEG 在保存时可以选择这种方式**。

**边下载边显示图片的步骤**：

- 首先用 `CGImageSourceCreateIncremental(NULL)` 创建一个空的图片源；
- 随后在获得新数据时调用 `CGImageSourceUpdateData(src, data, false)` 来更新图片源：
  - 第二个参数 `data` 是包含到目前为止积累的所有图像文件的数据；
  - 第三个 `bool` 值参数代表这次传入的是否是最终的数据；
- 最后在用 `CGImageSourceCreateImageAtIndex()` 创建图片来显示。

你可以用 [PINRemoteImage](https://github.com/pinterest/PINRemoteImage) 或者我写的 [YYWebImage](https://github.com/ibireme/YYWebImage) 来实现这个效果。~~`SDWebImage` 并没有用 Incremental 方式解码，所以显示效果很差。~~（后来已经实现了）
