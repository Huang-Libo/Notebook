# React Native：配置开发环境

文档：[React Native - environment setup](https://reactnative.dev/docs/environment-setup)

## 简介

- **如果你是移动开发的新手**，最简单的开始方式是使用 `Expo CLI` （功能有限，适合玩具项目或小型项目）。如果想直接在浏览器上试试，可使用 [Snack](https://snack.expo.dev/)（高峰期使用要排队）。
- **如果你熟悉移动开发**，推荐使用 *React Native CLI* ，这需要搭配 Xcode 或 Android Studio 来使用。

## 使用 Expo CLI

> 说明：Expo 只适合玩一玩，不感兴趣可以跳过本节内容。

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

修改并保存 `App.js` 文件，应用就会自动更新。

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

说明：使用 `n` 命令可以快速安装不同的 `node` 版本，非常方便，比如执行 `n 14.17.5` 即可安装 *14.17.5* 版本的 `node` 。

```console
brew install node
brew install watchman
```

安装 CocoaPods ：

> 说明：若使用 macOS 系统自带的 ruby 需要 sudo 权限；使用 rvm 管理的 ruby 则不需要 sudo 权限。

```console
gem install cocoapods
```

*React Native command line interface* 是随 *Node.js* 发布的，执行方式：

```console
npx react-native <command>
```

### 创建应用

使用 RN 内建的 `npx` 创建一个名为 AwesomeProject 的新应用：

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
    • cd "RNDemo" && npx react-native run-android

Run instructions for iOS:
  • cd "RNDemo" && npx react-native run-ios
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

或者打开 ios 目录下的 `.xcworkspace`（也可执行 `xed -b ios` ），然后在 Xcode 中运行项目。

**其他方案**：

- [在已有的 APP 中集成 RN](https://reactnative.dev/docs/integration-with-existing-apps)

## 运行项目

### 启动 Metro

> - Metro, the JavaScript bundler that ships with React Native.  
> - Metro "takes in an entry file and various options, and returns a single JavaScript file that includes all your code and its dependencies." —Metro Docs  
> - If you're familiar with web development, Metro is a lot like webpack—for React Native apps. Unlike Kotlin or Java, JavaScript isn't compiled—and neither is React Native. Bundling isn't the same as compiling, but it can help improve startup performance and translate some platform-specific JavaScript into more widely supported JavaScript.  

在项目的目录下执行以下命令即可启动 Metro ：

```console
npx react-native start
```

### 在 iOS 模拟器中启动应用

让 *Metro Bundler* 在单独的终端中运行，再开启一个终端来启动应用：

```console
npx react-native run-ios
```

项目编译完成后，就会在模拟器中运行。

也可以直接在 Xcode 中运行 ios 目录下的 `.xcworkspace` 工程。

### 在真机上运行项目

略。

### 修改代码

在 `App.js` 中修改代码，在 iOS 模拟器中执行 <kbd>⌘</kbd> + <kbd>R</kbd> 来刷新页面。

## FAQ

### watchman 导致的 RN 项目运行失败

执行 `npx react-native run-ios` 运行 RN 项目，终端内提示 `/usr/local/var/run/watchman/` 这个目录不存在，这个目录本应该是 `watchman` 安装时产生的，但使用 `brew` 重新安装 `watchman` 也未能修复这个问题。

执行 `watchman version` ，也是提示上述目录不存在。

根据 watchman 项目中[这个 issue 的回答](https://github.com/facebook/watchman/issues/640#issuecomment-416983649)，可以自行创建相关目录，设置合适的目录权限即可。

先在 `/usr/local/var` 目录下创建 **run** 目录（如果没有此目录才需执行）：

```console
sudo mkdir run
```

执行 `ll` 查看 **run** 目录的文件权限：

```plaintext
total 0
drwxr-xr-x   4 huanglibo  admin   128B Jan 12  2018 homebrew
drwxr-xr-x   3 huanglibo  admin    96B Oct 27  2017 log
drwxr-xr-x   2 huanglibo  admin    64B Oct 27  2017 mongodb
drwxr-xr-x  59 huanglibo  admin   1.8K May  1  2020 mysql
drwx------  24 huanglibo  admin   768B Jan 12  2018 postgres
drwxr-xr-x   2 root       wheel    64B Aug 28 00:49 run
```

可以看到使用 `sudo` 命令创建的目录默认拥有者是 `root` ，默认组是 `wheel` 。

修改 **run** 目录的 owner ：

```console
sudo chown huanglibo run
```

修改 **run** 目录的 group ：

```console
chgrp admin run
```

执行 `cd run` 后，在 **run** 目录下创建 **watchman** 目录：

```console
mkdir watchman
```

执行 `ll` 查看 **watchman** 目录的权限，是正常的，无需修改：

```console
total 0
drwxr-xr-x  2 huanglibo  admin    64B Aug 28 00:50 watchman
```

再次运行 `watchman version` ，可正常输出版本信息了：

```console
{
    "version": "2021.08.23.00"
}
```

最后，执行 `npx react-native run-ios` ，项目能正常运行了。
