# Flask Web 开发

> 《 Flask Web 开发：基于 Python 的 Web 应用开发实战（第2版）》

<h2>目录</h2>

- [Flask Web 开发](#flask-web-开发)
  - [资源](#资源)
  - [关于示例代码](#关于示例代码)

## 资源

- [图灵社区：在线阅读](https://www.ituring.com.cn/book/2463)
- [Flask 官网](https://flask.palletsprojects.com/)

## 关于示例代码

本书使用的示例代码可从 GitHub 上下载：<https://github.com/miguelgrinberg/flasky> 。

可以按章节 checkout 对应的标签，比如：

```console
git checkout 1a
```

如果改动了文件，想撤销本地修改、把文件还原到初始状态：

```console
git reset --hard
```

你可能经常需要从 GitHub 上下载修正和改进后的源码，更新本地仓库。完成这个操作的命令如下所示：

```console
git fetch --all
git fetch --tags
git reset --hard origin/master
```

另一个有用的操作是查看应用两个版本之间的差异，以便了解改动详情。比如执行下述命令可以查看 `2a` 和 `2b` 两个 tag 之间的差异：

```console
git diff 2a 2b
```

也可以在 GitHub 上查看 diff ，如： <https://github.com/miguelgrinberg/flasky/compare/2a...2b> 。
