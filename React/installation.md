# 安装

## Try React

### React 在线试用

- [CodePen](https://reactjs.org/redirect-to-codepen/hello-world)
- [CodeSandbox](https://codesandbox.io/s/new)
- [Stackblitz](https://stackblitz.com/fork/react)

### Babel 在线解释器

- [Babel REPL](https://babeljs.io/repl/#?presets=react&code_lz=MYewdgzgLgBApgGzgWzmWBeGAeAFgRgD4AJRBEAGhgHcQAnBAEwEJsB6AwgbgChRJY_KAEMAlmDh0YWRiGABXVOgB0AczhQAokiVQAQgE8AkowAUAcjogQUcwEpeAJTjDgUACIB5ALLK6aRklTRBQ0KCohMQk6Bx4gA)

### 代码资源

- 示例 HTML 下载：<https://raw.githubusercontent.com/reactjs/reactjs.org/main/static/html/single-file-example.html>
- React JavaScript
  - <https://unpkg.com/react@17/umd/react.development.js>
  - <https://unpkg.com/react-dom@17/umd/react-dom.development.js>
  - <https://unpkg.com/@babel/standalone/babel.min.js>

### 推荐的教程

- 官网推荐的一个教程：[this overview of React by Tania Rascia](https://www.taniarascia.com/getting-started-with-react/)

#### JavaScript 资源

- [this JavaScript overview](https://developer.mozilla.org/en-US/docs/Web/JavaScript/A_re-introduction_to_JavaScript)
- [MDN - JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- <https://javascript.info/>

## 在网站中添加 React

> 示例源码：<https://gist.github.com/gaearon/6668a1f6986742109c00a581ce704605>

### 步骤 1： 添加一个 DOM 容器到 HTML

打开 HTML 页面，添加一个空的 `<div>` 标签作为标记你想要用 React 显示内容的位置。例如：

```html
<!-- ... 其它 HTML ... -->

<div id="like_button_container"></div>

<!-- ... 其它 HTML ... -->
```

我们给这个 `<div>` 加上唯一的 `id` HTML 属性。这将允许我们稍后用 JavaScript 代码找到它，并在其中显示一个 React 组件。

### 步骤 2：添加 Script 标签

接下来，在 `</body>` 结束标签之前，向 HTML 页面中添加三个 `<script>` 标签：

```html
  <!-- ... 其它 HTML ... -->

  <!-- 加载 React。-->
  <!-- 注意: 部署时，将 "development.js" 替换为 "production.min.js"。-->
  <script src="https://unpkg.com/react@17/umd/react.development.js" crossorigin></script>
  <script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js" crossorigin></script>

  <!-- 加载我们的 React 组件。-->
  <script src="like_button.js"></script>

</body>
```

前两个标签加载 React。第三个将加载你的组件代码。

**HTML 的完整示例**：

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Add React in One Minute</title>
  </head>
  <body>

    <h2>Add React in One Minute</h2>
    <p>This page demonstrates using React with no build tooling.</p>
    <p>React is loaded as a script tag.</p>

    <!-- We will put our React component inside this div. -->
    <div id="like_button_container"></div>

    <!-- Load React. -->
    <!-- Note: when deploying, replace "development.js" with "production.min.js". -->
    <script src="https://unpkg.com/react@16/umd/react.development.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@16/umd/react-dom.development.js" crossorigin></script>

    <!-- Load our React component. -->
    <script src="like_button.js"></script>

  </body>
</html>
```

### 步骤 3：创建一个 React 组件

在 HTML 页面文件的同级目录下创建一个名为 `like_button.js` 的文件：

```javascript
'use strict';

const e = React.createElement;

class LikeButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = { liked: false };
  }

  render() {
    if (this.state.liked) {
      return 'You liked this.';
    }

    return e(
      'button',
      { onClick: () => this.setState({ liked: true }) },
      'Like'
    );
  }
}

const domContainer = document.querySelector('#like_button_container');
ReactDOM.render(e(LikeButton), domContainer);
```

这段代码会找到我们在步骤 1 中添加到 HTML 里的 `<div>`，然后在它内部显示我们的 React 组件 “Like” 按钮。

## 复用组件的示例

> 示例源码：<https://gist.github.com/gaearon/faa67b76a6c47adbab04f739cba7ceda>

HTML：

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Add React in One Minute</title>
  </head>
  <body>

    <h2>Add React in One Minute</h2>
    <p>This page demonstrates using React with no build tooling.</p>
    <p>React is loaded as a script tag.</p>

    <p>
      This is the first comment.
      <!-- We will put our React component inside this div. -->
      <div class="like_button_container" data-commentid="1"></div>
    </p>

    <p>
      This is the second comment.
      <!-- We will put our React component inside this div. -->
      <div class="like_button_container" data-commentid="2"></div>
    </p>

    <p>
      This is the third comment.
      <!-- We will put our React component inside this div. -->
      <div class="like_button_container" data-commentid="3"></div>
    </p>

    <!-- Load React. -->
    <!-- Note: when deploying, replace "development.js" with "production.min.js". -->
    <script src="https://unpkg.com/react@17/umd/react.development.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js" crossorigin></script>

    <!-- Load our React component. -->
    <script src="like_button.js"></script>

  </body>
</html>
```

JavaScript ：

```javascript
'use strict';

const e = React.createElement;

class LikeButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = { liked: false };
  }

  render() {
    if (this.state.liked) {
      return 'You liked comment number ' + this.props.commentID;
    }

    return e(
      'button',
      { onClick: () => this.setState({ liked: true }) },
      'Like'
    );
  }
}

// Find all DOM containers, and render Like buttons into them.
document.querySelectorAll('.like_button_container')
  .forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    const commentID = parseInt(domContainer.dataset.commentid, 10);
    ReactDOM.render(
      e(LikeButton, { commentID: commentID }),
      domContainer
    );
  });
```

## 为生产环境压缩 JavaScript 代码

在将你的网站部署到生产环境之前，要注意未经压缩的 JavaScript 可能会显著降低用户的访问速度。

如果你已经压缩了应用代码，如果你确保已部署的 HTML 加载了以 `production.min.js` 结尾的 React 版本，那么**你的网站是生产就绪（production-ready）**的：

```javascript
<script src="https://unpkg.com/react@17/umd/react.production.min.js" crossorigin></script>
<script src="https://unpkg.com/react-dom@17/umd/react-dom.production.min.js" crossorigin></script>
```

压缩代码的步骤可参考[这个 gist](https://gist.github.com/gaearon/42a2ffa41b8319948f9be4076286e1f3) 。

## 可选：使用 React 和 JSX

在上面的示例中，我们只依赖了浏览器原生支持的特性。这就是为什么我们使用了 JavaScript 函数调用来告诉 React 要显示什么：

```javascript
const e = React.createElement;

// 显示一个 "Like" <button>
return e(
  'button',
  { onClick: () => this.setState({ liked: true }) },
  'Like'
);
```

然而，React 还提供了一种使用 JSX 编写界面的方式：

```jsx
// 显示一个 "Like" <button>
return (
  <button onClick={() => this.setState({ liked: true })}>
    Like
  </button>
);
```

### 快速尝试 JSX

在项目中尝试 JSX 最快的方法是在页面中添加这个 `<script>` 标签：

```html
<script src="https://unpkg.com/babel-standalone@6/babel.min.js"></script>
```

现在，你可以在任何 `<script>` 标签内使用 JSX，方法是在为其添加 `type="text/babel"` 属性。

一个使用了 JSX 的 HTML 文件的[例子](https://raw.githubusercontent.com/reactjs/reactjs.org/main/static/html/single-file-example.html)：

```jsx
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Hello World</title>
    <script src="https://unpkg.com/react@17/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js"></script>

    <!-- Don't use this in production: -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
  </head>
  <body>
    <div id="root"></div>
    <script type="text/babel">

      ReactDOM.render(
        <h1>Hello, world!</h1>,
        document.getElementById('root')
      );

    </script>
    <!--
      Note: this page is a great way to try React but it's not suitable for production.
      It slowly compiles JSX with Babel in the browser and uses a large development build of React.

      Read this section for a production-ready setup with JSX:
      https://reactjs.org/docs/add-react-to-a-website.html#add-jsx-to-a-project

      In a larger project, you can use an integrated toolchain that includes JSX instead:
      https://reactjs.org/docs/create-a-new-react-app.html

      You can also use React without JSX, in which case you can remove Babel:
      https://reactjs.org/docs/react-without-jsx.html
    -->
  </body>
</html>
```

这种方式适合于学习和创建简单的示例。然而，它会使你的网站变慢，并且**不适用于生产环境**。当你准备好更进一步时，删除你添加的这个新的 `<script>` 标签以及 `type="text/babel"` 属性。取而代之的，在下一小节中，你将设置一个 **JSX 预处理器**来自动转换所有 `<script>` 标签的内容。

### 将 JSX 添加到项目

<https://zh-hans.reactjs.org/docs/add-react-to-a-website.html#add-jsx-to-a-project>

### 运行 JSX 预处理器

<https://zh-hans.reactjs.org/docs/add-react-to-a-website.html#run-jsx-preprocessor>

## 创建新的 React 应用

### Create React App

[Create React App](https://github.com/facebookincubator/create-react-app) 是一个用于学习 React 的舒适环境，也是用 React 创建新的单页应用的最佳方式。
