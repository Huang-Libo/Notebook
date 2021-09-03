# React Native：Native Modules

`NativeModule system` 将 `Java / Objective-C / C++` (原生)类的实例作为 `JS` 对象暴露给 `JS` ，因此允许你在 `JS` 中执行任意的原生代码。

有两种方法可以为 React Native 应用编写原生模块：

1. 直接在 React Native 应用的 iOS / Android 项目中；
2. 作为一个 NPM 包，依赖安装在 React Native 应用中。
