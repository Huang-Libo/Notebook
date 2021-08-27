# React Native 101

## 开发环境配置

文档：[开发环境配置](https://reactnative.dev/docs/environment-setup)

- 如果你是移动开发的新手，最简单的开始方式是使用 `Expo CLI` （有一些限制，适合玩具项目）。需要指定版本的 *Node.js* 和一个手机或模拟器。
  - 如果想直接在浏览器上试试，可使用 [Snack](https://snack.expo.dev/) 。
- 如果你熟悉移动开发，推荐使用 *React Native CLI* ，这需要搭配 Xcode 或 Android Studio 来使用。

### Expo CLI

> 依赖：需要 *Node 12 LTS* 及以上的版本。

使用 npm 安装 `Expo CLI` 命令行工具：

```console
npm install -g expo-cli
```

然后使用 `expo` 命令创建一个名为 AwesomeProject 的 RN 项目：

```console
expo init AwesomeProject
```

执行 `cd AwesomeProject` 后，启动项目：

```console
npm start # 或使用 expo start
```

这将为你启动一个 development server 。

在手机上安装 [Expo Go](https://expo.dev/client) 应用，并将手机和电脑连接到同一个网络下。

在 iOS 设备上，用自带的相机扫描终端中生成的二维码，就会跳转到 *Expo Go* 应用内。

修改并保存 App.js 文件，应用就会自动更新。

**注意**：

使用 Expo 提供的 managed workflow 有一些限制，比如有些 iOS 和 Android 的 API 不能使用；SDK 不是所有的后台代码执行都支持；免费版的 build 有时候要排队；等等。

详情请看 Expo 的文档：[Expo 的限制](https://docs.expo.dev/introduction/why-not-expo/)
