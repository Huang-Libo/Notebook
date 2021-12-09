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
  - [应用的基本结构](#应用的基本结构)
    - [初始化](#初始化)
    - [路由和视图函数](#路由和视图函数)
    - [一个完整的应用](#一个完整的应用)
    - [Web 开发服务器](#web-开发服务器)
    - [动态路由](#动态路由)
    - [调试模式](#调试模式)
    - [命令行选项](#命令行选项)

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

- 路由、调试和 *Web 服务器网关接口 (WSGI，Web server gateway interface)* 子系统由 `Werkzeug` 提供；
- *模板系统*由 `Jinja2` 提供；
- *命令行集成*由 `Click` 提供。

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

虚拟环境非常有用，可以避免你安装的 Python 版本和包与系统预装的发生冲突。为每个项目单独创建虚拟环境，可以保证应用只能访问所在虚拟环境中的包，从而保持全局解释器的干净整洁，使其只作为创建更多虚拟环境的源。

与直接使用系统全局的 Python 解释器相比，使用虚拟环境还有个好处，那就是**不需要管理员权限**。创建虚拟环境的命令格式如下：

```console
python3 -m venv <virtual-environment-name>
```

下面我们在 flasky 目录中创建一个虚拟环境。通常，虚拟环境的名称为 `venv` ，不过你也可以使用其他名称。确保当前目录是 flasky ，然后执行这个命令：

```console
python3 -m venv venv
```

这个命令执行完毕后，flasky 目录中会出现一个名为 `venv` 的子目录，这里就是一个全新的虚拟环境，包含这个项目专用的 Python 解释器。

### 激活虚拟环境

若想使用虚拟环境，要先将其**激活**：

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
(venv) $ python3 -m pip install flask
```

> 在 pip 前面添加 python -m 的原因（[参考](https://stackoverflow.com/a/51373253)）：This guarantees that you're absolutely positively running the pip that goes with whatever python3 means, while pip3 just means you're running the pip that goes with some Python 3.x , which may be any of the various ones you've installed.

执行这个命令后，pip 不仅安装 Flask 自身，还会安装它的所有依赖。任何时候都可以使用 `pip freeze` 命令查看虚拟环境中安装了哪些包：

```console
(venv) $ pip freeze
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

## 应用的基本结构

### 初始化

所有 Flask 应用都必须创建一个**应用实例**。Web 服务器使用一种名为 *Web 服务器网关接口 (WSGI，Web server gateway interface，读作 “wiz-ghee” )* 的协议，把接收自客户端的所有请求都转交给这个对象处理。应用实例是 `Flask` 类的对象，通常由下述代码创建：

```python
from flask import Flask
app = Flask(__name__)
```

Flask 类的*构造函数*只有一个必须指定的参数，即应用主模块或包的名称。在大多数应用中，Python 的 `__name__` 变量就是所需的值，Flask 用这个参数确定应用的位置，进而找到应用中其他文件的位置，例如图片和模板。

### 路由和视图函数

客户端（例如 Web 浏览器）把**请求**发送给 Web 服务器，Web 服务器再把请求发送给 Flask 应用实例。应用实例需要知道对每个 URL 的请求要运行哪些代码，所以保存了一个 URL 到 Python 函数的映射关系。**处理 URL 和函数之间关系的程序称为路由**。

在 Flask 应用中定义路由的最简便方式，是使用应用实例提供的 `app.route` 装饰器。下面的例子说明了如何使用这个装饰器声明路由：

```python
@app.route('/')
def index():
    return '<h1>Hello World!</h1>'
```

> **装饰器**：是 Python 语言的标准特性。惯常用法是**把函数注册为事件处理程序，在特定事件发生时调用**。

前例把 `index()` 函数注册为应用根地址 `/` 的处理程序。使用 `app.route` 装饰器注册视图函数是首选方法，但不是唯一的方法。

Flask 还支持一种更传统的方式：使用 `app.add_url_rule()` 方法。这个方法最简单的形式接受 3 个参数：*URL* 、*端点名*和*视图函数*。

下述示例使用 `app.add_url_rule()` 方法注册 index() 函数，其作用与前例相同：

```python
def index():
    return '<h1>Hello World!</h1>'

app.add_url_rule('/', 'index', index)
```

`index()` 这样处理入站请求的函数称为**视图函数**。如果应用部署在域名为 `www.example.com` 的服务器上，在浏览器中访问 `http://www.example.com` 后，会触发服务器执行 `index()` 函数。

这个函数的返回值称为**响应**，是客户端接收到的内容。如果客户端是 Web 浏览器，响应就是显示给用户查看的内容。视图函数返回的响应可以是包含 HTML 的简单字符串，也可以是后文将介绍的复杂表单。

如果仔细观察日常所用服务的某些 URL ，你会发现很多地址中都包含可变部分。例如，你的 Facebook 资料页面的地址是 `http://www.facebook.com/<your-name>` ，用户名 `<your-name>` 是地址的一部分。Flask 支持这种形式的 URL ，只需在 `app.route` 装饰器中使用特殊的句法即可。下例定义的路由中就有一部分是可变的：

```python
@app.route('/user/<name>')
def user(name):
    return '<h1>Hello, {}!</h1>'.format(name)
```

### 一个完整的应用

示例 2-1　`hello.py` ：

> 可以执行 `git checkout 2a` 检出应用的这个版本。

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>Hello World!</h1>'
```

### Web 开发服务器

> Flask 提供的 Web 服务器只适用于开发和测试。

Flask 应用自带 Web 开发服务器，通过 `flask run` 命令启动。这个命令在 `FLASK_APP` 环境变量指定的 Python 脚本中寻找应用实例。

若想启动前一节编写的 `hello.py` 应用，首先确保之前创建的虚拟环境已经激活，而且里面安装了 Flask 。

```console
(venv) $ export FLASK_APP=hello.py
(venv) $ flask run
 * Serving Flask app 'hello.py' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```

服务器启动后便开始~~轮询~~，处理请求。直到按 `Ctrl+C` 键停止服务器，~~轮询~~才会停止。服务器运行时，在 Web 浏览器的地址栏中输入 <http://localhost:5000/> 。

Flask Web 开发服务器也可以在代码中调用 `app.run()` 方法来启动。在没有 flask 命令的旧版 Flask 中，若想启动应用，要运行应用的主脚本。主脚本的尾部包含下述代码片段：

> 要在启动时打开调试器，则需要将 `debug` 参数设置为 `True` ：`app.run(debug=True)`

```python
if __name__ == '__main__':
    app.run()
```

现在有了 `flask run` 命令，我们就无须再这么做了。不过，`app.run()` 方法依然有其用处，例如在单元测试中。

### 动态路由

这个应用的第 2 版将添加一个动态路由。在浏览器中访问这个动态 URL 时，你会看到一条个性化的消息，包含你在 URL 中提供的名字。比如，访问 <http://localhost:5000/user/Dave> 。

> 可以执行 `git checkout 2b` 检出应用的这个版本。

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>Hello World!</h1>'

@app.route('/user/<name>')
def user(name):
    return '<h1>Hello, {}!</h1>'.format(name)
```

### 调试模式

Flask 应用可以在**调试模式**中运行。在这个模式下，开发服务器默认会加载两个便利的工具：**重载器**和**调试器**。

- 启用**重载器 (reloader)** 后，Flask 会监视项目中的所有源码文件，发现变动时自动重启服务器。在开发过程中运行启动重载器的服务器特别方便，因为**每次修改并保存源码文件后，服务器都会自动重启，让改动生效**。
- **调试器 (debugger)** 是一个基于 Web 的工具，当应用抛出未处理的异常时，它会出现在浏览器中。此时，Web 浏览器变成一个交互式栈跟踪，你可以在里面审查源码，在调用栈的任何位置计算表达式。

调试模式默认禁用。若想启用，在执行 `flask run` 命令之前设定 `FLASK_DEBUG=1` 环境变量：

```console
(venv) $ export FLASK_APP=hello.py
(venv) $ export FLASK_DEBUG=1
(venv) $ flask run
 * Serving Flask app 'hello.py' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 635-855-495
```

说明：使用 `app.run()` 方法启动服务器时，不会用到 `FLASK_APP` 和 `FLASK_DEBUG` 环境变量。若想以编程的方式启动调试模式，就使用 `app.run(debug=True)` 。

注意：千万不要在生产服务器中启用调试模式。客户端通过调试器能请求执行远程代码，因此可能导致生产服务器遭到攻击。作为一种简单的保护措施，启动调试模式时可以要求输入 `PIN` 码，执行 `flask run` 命令时会打印在控制台中。

### 命令行选项

执行 `flask --help` ：

```console
(venv) $ flask --help
Usage: flask [OPTIONS] COMMAND [ARGS]...

  A general utility script for Flask applications.

  Provides commands from Flask, extensions, and the application. Loads the
  application defined in the FLASK_APP environment variable, or from a wsgi.py
  file. Setting the FLASK_ENV environment variable to 'development' will
  enable debug mode.

    $ export FLASK_APP=hello.py
    $ export FLASK_ENV=development
    $ flask run

Options:
  --version  Show the flask version
  --help     Show this message and exit.

Commands:
  routes  Show the routes for the app.
  run     Run a development server.
  shell   Run a shell in the app context.
```

`flask routes` 用于显示应用所有的路由：

```console
(venv) $ flask routes
Endpoint  Methods  Rule
--------  -------  -----------------------
index     GET      /
static    GET      /static/<path:filename>
user      GET      /user/<name>
```

`flask shell` 命令在**应用的上下文中**打开一个 Python shell 会话。在这个会话中可以运行维护任务或测试，也可以调试问题。可以看到提示中包含应用相关的信息 `App: hello [production]` ：

```console
(venv) $ flask shell
Python 3.9.6 (default, Jun 29 2021, 05:25:02) 
[Clang 12.0.5 (clang-1205.0.22.9)] on darwin
App: hello [production]
Instance: /Users/huanglibo/Dropbox/Repo-D/Python/flasky/instance
>>> 
```

`flask run` 命令的作用是在 Web 开发服务器中运行应用。这个命令有多个参数：

```console
(venv) $ flask run --help
Usage: flask run [OPTIONS]

  Run a local development server.

  This server is for development purposes only. It does not provide the
  stability, security, or performance of production WSGI servers.

  The reloader and debugger are enabled by default if FLASK_ENV=development or
  FLASK_DEBUG=1.

Options:
  -h, --host TEXT                 The interface to bind to.
  -p, --port INTEGER              The port to bind to.
  --cert PATH                     Specify a certificate file to use HTTPS.
  --key FILE                      The key file to use when specifying a
                                  certificate.
  --reload / --no-reload          Enable or disable the reloader. By default
                                  the reloader is active if debug is enabled.
  --debugger / --no-debugger      Enable or disable the debugger. By default
                                  the debugger is active if debug is enabled.
  --eager-loading / --lazy-loading
                                  Enable or disable eager loading. By default
                                  eager loading is enabled if the reloader is
                                  disabled.
  --with-threads / --without-threads
                                  Enable or disable multithreading.
  --extra-files PATH              Extra files that trigger a reload on change.
                                  Multiple paths are separated by ':'.
  --help                          Show this message and exit.
```

`--host` 参数特别有用，它告诉 Web 服务器在哪个网络接口上监听客户端发来的连接。默认情况下，Flask 的 Web 开发服务器监听 `localhost` 上的连接，因此服务器只接受运行服务器的计算机发送的连接。

`flask run --host 0.0.0.0` 命令让 Web 服务器监听公共网络接口上的连接，因此同一网络中的其他计算机发送的连接也能接收到：

```console
(venv) $ flask run --host 0.0.0.0
 * Serving Flask app 'hello.py' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://192.168.50.91:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 635-855-495

```

`--reload` 、`--no-reload` 、`--debugger` 和 `--no-debugger` 参数对调试模式进行细致的设置。例如，启动调试模式后可以使用 `--no-debugger` 关闭调试器，但是应用还在调试模式中运行，而且重载器也启用了。

