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

> 示例压缩包[下载](https://gist.github.com/gaearon/6668a1f6986742109c00a581ce704605/archive/f6c882b6ae18bde42dcf6fdb751aae93495a2275.zip)。

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


