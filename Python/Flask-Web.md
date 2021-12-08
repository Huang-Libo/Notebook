# Flask Web 开发

> 《 Flask Web 开发：基于 Python 的 Web 应用开发实战（第2版）》

<h2>目录</h2>

- [Flask Web 开发](#flask-web-开发)
  - [前言](#前言)
    - [资源](#资源)
    - [关于示例代码](#关于示例代码)
    - [Flask 简介](#flask-简介)
  - [安装](#安装)
    - [创建虚拟环境](#创建虚拟环境)
    - [激活虚拟环境](#激活虚拟环境)
    - [使用 pip 安装 Python 包](#使用-pip-安装-python-包)

## 前言

### 资源

- [图灵社区：在线阅读](https://www.ituring.com.cn/book/2463)
- [GitHub：随书源码](https://github.com/miguelgrinberg/flasky)
- [Flask 官网](https://flask.palletsprojects.com/)

### 关于示例代码

本书使用的示例代码可从 GitHub 上下载：<https://github.com/miguelgrinberg/flasky> 。

可以按章节 checkout 对应的标签，比如：

```console
git checkout 1a
```

如果改动了文件，想撤销本地修改、把文件还原到初始状态：

```console
git reset --hard
```

另一个有用的操作是查看应用两个版本之间的差异，以便了解改动详情。比如执行下述命令可以查看 `2a` 和 `2b` 两个 tag 之间的差异：

```console
git diff 2a 2b
```

也可以在 GitHub 上查看 diff ，如： <https://github.com/miguelgrinberg/flasky/compare/2a...2b> 。

### Flask 简介

在大多数标准中，Flask 都算是小型框架，小到可以称为“微框架”。Flask 非常小，因此你一旦能够熟练使用它，很可能就能读懂它所有的源码。

但是，小并不意味着它比其他框架的功能少。Flask 自开发伊始就被设计为可扩展的框架，它具有一个包含基本服务的强健核心，其他功能则可通过扩展实现。

Flask 有 **3** 个主要依赖（这些依赖全都是 Flask 的开发者 Armin Ronacher 开发的）：

- 路由、调试和 Web 服务器网关接口（WSGI，Web server gateway interface）子系统由 `Werkzeug` 提供；
- 模板系统由 `Jinja2` 提供；
- 命令行集成由 `Click` 提供。

Flask 原生不支持*数据库访问*、*Web 表单验证*和*用户身份验证*等高级功能。这些功能以及其他大多数 Web 应用需要的核心服务都以扩展的形式实现，然后再与核心包集成。开发者可以任意挑选符合项目需求的扩展，甚至可以自行开发。这和大型框架的做法相反，大型框架往往已经替你做出了大多数决定，难以（有时甚至不允许）使用替代方案。

## 安装

先把项目 clone 到本地：

```console
git clone https://github.com/miguelgrinberg/flasky.git
cd flasky
git checkout 1a
```

### 创建虚拟环境

安装 Flask 最便捷的方法是使用虚拟环境。

**虚拟环境是 Python 解释器的一个私有副本**，在这个环境中你可以安装私有包，而且不会影响系统中安装的全局 Python 解释器。

虚拟环境非常有用，可以避免你安装的 Python 版本和包与系统预装的发生冲突。为每个项目单独创建虚拟环境，可以保证应用只能访问所在虚拟环境中的包，从而保持全局解释器的干净整洁，使其只作为创建更多虚拟环境的源。与直接使用系统全局的 Python 解释器相比，使用虚拟环境还有个好处，那就是不需要管理员权限。

创建虚拟环境的命令格式如下：

```console
python3 -m venv <virtual-environment-name>
```

下面我们在 flasky 目录中创建一个虚拟环境。通常，虚拟环境的名称为 `venv` ，不过你也可以使用其他名称。确保当前目录是 flasky ，然后执行这个命令：

```console
python3 -m venv venv
```

这个命令执行完毕后，flasky 目录中会出现一个名为 `venv` 的子目录，这里就是一个全新的虚拟环境，包含这个项目专用的 Python 解释器。

### 激活虚拟环境

若想使用虚拟环境，要先将其“激活”：

```console
source venv/bin/activate
```

虚拟环境被激活后，里面的 Python 解释器的路径会添加到当前命令会话的 `PATH` 环境变量中，指明在什么位置寻找一众可执行文件。为了提醒你已经激活了虚拟环境，激活虚拟环境的命令会修改命令提示符，加入环境名：

```console
(venv) $
```

注意：

- 激活虚拟环境后，在命令提示符中输入 `python` ，将调用虚拟环境中的解释器，而不是系统全局解释器。
- 如果你打开了多个命令提示符窗口，在每个窗口中都要激活虚拟环境。

虚拟环境中的工作结束后，在命令提示符中输入 `deactivate`，还原当前终端会话的 `PATH` 环境变量，把命令提示符重置为最初的状态。

### 使用 pip 安装 Python 包

若想在虚拟环境中安装 Flask，要确保 `venv` 虚拟环境已经激活，然后执行下述命令：

```console
(venv) $ pip install flask
```

执行这个命令后，pip 不仅安装 Flask 自身，还会安装它的所有依赖。任何时候都可以使用 `pip freeze` 命令查看虚拟环境中安装了哪些包：

```console
flasky ❯ pip freeze
click==8.0.3
Flask==2.0.2
itsdangerous==2.0.1
Jinja2==3.0.3
MarkupSafe==2.0.1
Werkzeug==2.0.2

```

要想验证 Flask 是否正确安装，可以启动 Python 解释器，尝试导入 Flask：

```console
(venv) $ python
>>> import flask
>>>
```
