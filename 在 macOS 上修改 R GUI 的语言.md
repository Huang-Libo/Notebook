# 在 macOS 上修改 R.app(R GUI) 的默认 Language

最近需要用 R 语言, 所以在 `macOS 10.13.2` 上安装了 R. 安装好之后发现 R GUI 居然是日语的, 这让我蒙圈了, 我用的又不是日文系统, 为什么会显示日文, 难道这个二进制包是一个日本人打出来的? 

![让人蒙圈的日语](media/15194702029143.jpg)


**紧接着我发现, R GUI 的默认 Language 有点不好改.**

## 修改默认 Language 的痛点

在 Windows 操作系统上还是很好修改默认 Language 的, 直接在安装目录的 etc 目录下的 RConsole 文件中添加 `language = en` 即可. 参考[这里](https://www.zhihu.com/question/21127155/answer/58369102
).

然而, 在 macOS 上修改其默认 Language 就没有这么简单了, 主要是我没有找到和 RConsole 对标的配置文件.

## 安装的过程

> 从安装过程可以找到我们关心的相关信息.

安装时, 从[清华大学的镜像站](https://mirrors.tuna.tsinghua.edu.cn/CRAN/) 直接下二进制的 `.pkg` 安装包:    

![](media/15194668205163.jpg)    

从安装说明里面可以看出:

1. 这个安装包包含 `R Framework` 和 `R.app GUI`;
2. R Framework 的安装路径是 `/Library/Framework`, 经过一番探索可发现其配置文件在 `/Library/Frameworks/R.framework/Resources/etc/` 目录下(需要 root 权限), 但没发现可配置 Language 的地方. 另外, 这里是终端中的 R 的配置文件, 应该也不能改 R.app 的默认 Language.

![](media/15194722689558.jpg)

#### R Framework

R Framework 是可在命令行中使用的 R 环境, 直接在终端输入 `R` 即可:

![](media/15194714101547.jpg)

在终端里面默认的 Language 是英文的, 如果不是, 则在 R 环境中输入(参考[这里](https://cran.r-project.org/bin/macosx/RMacOSX-FAQ.html#Internationalization-of-the-R_002eapp)):  

```
> system("defaults write org.R-project.R force.LANG en_US.UTF-8")
```

或在终端中输入:  

```
$ defaults write org.R-project.R force.LANG en_US.UTF-8
```

最后重启一下 shell 就可以了.

#### R.app GUI

R.app 是 R 的一个可视化环境. 目前最关键的问题是 R.app 是日文的, 并且不知道有没有对应的配置文件可以修改默认 Language, 反正我找了好久都没有找到.  

## 修改 R.app GUI 的默认 Language

> 虽然没有找到相关配置文件, 但是我摸索到一个替代方案.

右键 `R.app`, 点击`显示包内容`, 进入 `Resources` 目录, 把除了 `English.lproj` 以外的其他以 `.lproj` 结尾的目录移动到新建的 `lproj-bak` 目录中, 最后重启 `R.app`.

![](media/15194730111137.jpg)

最后我们会发现默认 Language 恢复成英语了, 菜单栏和提示信息都是英文: 

![](media/15194731892943.jpg)

## 后记

1. `Resources` 目录下的 `ReadMe.txt` 包含 `Localization` 相关的信息, 但目前痛点已解决, 等以后有新需求的时候再看它吧.
2. 如果直接从源码安装, 应该也能自行指定 Language, 不过我没试, 有兴趣的同学可以试试.

## 资源

在折腾的过程中, 也有人推荐了开源的 [RStudio](https://www.rstudio.com/products/rstudio/download/#download), 看起来智能一点, 喜欢折腾的同学也可以试试:  

![](media/15194735419551.jpg)
 

