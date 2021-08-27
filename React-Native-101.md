# React Native 101

## 开发环境配置

文档：[开发环境配置](https://reactnative.dev/docs/environment-setup)

- 如果你是移动开发的新手，最简单的开始方式是使用 `Expo CLI` （有一些限制，适合玩具项目）。需要指定版本的 *Node.js* 和一个手机或模拟器。
  - 如果想直接在浏览器上试试，可使用 [Snack](https://snack.expo.dev/) 。
- 如果你熟悉移动开发，推荐使用 *React Native CLI* ，这需要搭配 Xcode 或 Android Studio 来使用。

## 使用 Expo CLI

> 说明：Expo 只适合玩一玩，可以跳过。

依赖：需要 *Node 12 LTS* 及以上的版本。

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

## 使用 React Native CLI

> 环境选择：macOS + iOS

依赖：

- Node (不低于 *Node 12 LTS* )
- Watchman（用于监控文件的变化）
- React Native command line interface
- Xcode（不低于 *Xcode 10* ）
- CocoaPods

### 安装依赖软件

使用 Homebrew 安装 Node 和 Watchman ：

```console
brew install node
brew install watchman
```

安装 CocoaPods ：

> 说明：若使用 macOS 系统自带的 ruby 需要 sudo 权限；使用 rvm 管理的 ruby 则不需要 sudo 权限。

```console
gem install cocoapods
```

*React Native command line interface* 是随 *Node.js* 发布的，执行方式：`npx react-native <command>` 。

### 创建应用

使用 RN 内建的 npx 创建一个名为 AwesomeProject 的新应用：

```console
npx react-native init AwesomeProject
```

可选参数：

- `--version X.XX.X` ：指定 RN 的版本。
- `--template react-native-template-typescript` ：指定使用 typescript 的模板。

项目生成后，终端会给出运行提示：

```plaintext
Run instructions for Android:
    • Have an Android emulator running (quickest way to get started), or a device connected.
    • cd "/Users/huanglibo/RNDemo" && npx react-native run-android

Run instructions for iOS:
  • cd "/Users/huanglibo/RNDemo" && npx react-native run-ios
  - or -
  • Open RNDemo/ios/RNDemo.xcworkspace in Xcode or run "xed -b ios"
  • Hit the Run button

Run instructions for macOS:
  • See https://aka.ms/ReactNativeGuideMacOS for the latest up-to-date instructions.
```

简要概况一下在 iOS 上运行项目的流程。进入到项目主目录后，执行：

```console
npx react-native run-ios
```

或者打开 ios 目录下的 .xcworkspace（也可执行 `xed -b ios` ），然后在 Xcode 中运行项目。

**其他方案**：

- [在已有的 APP 中集成 RN](https://reactnative.dev/docs/integration-with-existing-apps)

## 运行项目

### 启动 Metro

> Metro, the JavaScript bundler that ships with React Native.
>  
> Metro "takes in an entry file and various options, and returns a single JavaScript file that includes all your code and its dependencies."—Metro Docs
>  
> If you're familiar with web development, Metro is a lot like webpack—for React Native apps. Unlike Kotlin or Java, JavaScript isn't compiled—and neither is React Native. Bundling isn't the same as compiling, but it can help improve startup performance and translate some platform-specific JavaScript into more widely supported JavaScript.

在项目的目录下执行以下命令即可启动 Metro ：

```console
npx react-native start
```

### 在 iOS 模拟器中启动应用

让 Metro Bundler 在单独的终端中运行，再开启一个终端来启动应用：

```console
npx react-native run-ios
```

项目编译完成后，就会在模拟器中运行。

也可以直接在 Xcode 中运行 ios 目录下的 `.xcworkspace` 工程。
