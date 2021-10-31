# objc4 的源码

<h2>目录</h2>

- [objc4 的源码](#objc4-的源码)
  - [相关资源](#相关资源)
    - [1. Apple 官网源码下载](#1-apple-官网源码下载)
    - [2. GitHub 社区的可编译版本](#2-github-社区的可编译版本)
  - [FAQ](#faq)
    - [调用 `objc_msgSend()` 函数报错的原因](#调用-objc_msgsend-函数报错的原因)

## 相关资源

### 1. Apple 官网源码下载

- 在线源码：<https://opensource.apple.com/source/objc4/>
- `.tar.gz` ：<https://opensource.apple.com/tarballs/objc4/>

### 2. GitHub 社区的可编译版本

- <https://github.com/GhostClock/objc4-818.2> ，这是 2021 年比较新的版本，在 *Xcode 13* 上亲测可用。

## FAQ

### 调用 `objc_msgSend()` 函数报错的原因

> 参考：<https://stackoverflow.com/questions/24922913/too-many-arguments-to-function-call-expected-0-have-3>

If you think having to do this is annoying and pointless you can disable the check in the **build settings** by setting '**Enable strict checking of objc_msgSend Calls**' to **no** 。
