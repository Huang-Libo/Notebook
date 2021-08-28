# React Native 101

文档：[React Native - getting started](https://reactnative.dev/docs/getting-started)

## 前置课程：JavaScript

想快速熟悉 `JavaScript` ，推荐阅读 [MDN Web Docs](https://developer.mozilla.org/) 的这两份文档：

- [A re-introduction to JavaScript (JS tutorial)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/A_re-introduction_to_JavaScript)
- [JavaScript Docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

## Function Components 和 Class Components

组件有两种写法，classes 或 functions 。

*Function Components*（推荐写法）：

```javascript
import React from 'react';
import { Text, View } from 'react-native';

const HelloWorldApp = () => {
  return (
    <View style={{
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
      }}>
      <Text>Hello, world!</Text>
    </View>
  );
}

export default HelloWorldApp;
```

*Class Components* ：

```javascript
import React, { Component } from 'react';
import { Text, View } from 'react-native';

class HelloWorldApp extends Component {
  render() {
    return (
      <View style={{
          flex: 1,
          justifyContent: "center",
          alignItems: "center"
        }}>
        <Text>Hello, world!</Text>
      </View>
    );
  }
}

export default HelloWorldApp;
```

## Native Components & Core Components

React Native 在 **runtime** 期间为这些组件创建相应的原生的控件。

React Native 内置了一些常用的 *Native Components* ，它们被称为 React Native 的 *Core Components* 。开发者也可以根据实际需求构建自己的组件。

> 相关链接🔗 ：[所有 Core Components 的文档](https://reactnative.dev/docs/components-and-apis)。

最常用的 *Core Components*（[截图来源](https://reactnative.dev/docs/intro-react-native-components#core-components)）：

![Core-Components.jpg](media/React-Native-Docs/Core-Components.jpg)

示例：

```javascript
import React from 'react';
import { View, Text, Image, ScrollView, TextInput } from 'react-native';

const App = () => {
  return (
    <ScrollView>
      <Text>Some text</Text>
      <View>
        <Text>Some more text</Text>
        <Image
          source={{
            uri: 'https://reactnative.dev/docs/assets/p_cat2.png',
          }}
          style={{ width: 200, height: 200 }}
        />
      </View>
      <TextInput
        style={{
          height: 40,
          borderColor: 'gray',
          borderWidth: 1
        }}
        defaultValue="You can type in me"
      />
    </ScrollView>
  );
}

export default App;
```

各类组件的关系图：

![diagram_react-native-components.svg](media/React-Native-Docs/diagram_react-native-components.svg)

## React 基础

> [React 的官方文档](https://reactjs.org/docs/getting-started.html)

React 的核心概念：

- components
- JSX
- props
- state

### 你的第一个组件

示例代码：

```javascript
import React from 'react';
import { Text } from 'react-native';

const Cat = () => {
  return (
    <Text>Hello, I am your cat!</Text>
  );
}

export default Cat;
```

这个组件以 function 开头：

```javascript
const Cat = () => {};
```

*Function Components* 返回的内容会被渲染成 **React element** 。这个 Cat 组件将被渲染成 `<Text>` 元素。

最后，使用 JavaScript 的 [export default](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export) 导出这个组件。

**说明**：其他导出组件方式可参考这个 [handy cheatsheet on JavaScript imports and exports](https://medium.com/dailyjs/javascript-module-cheatsheet-7bd474f1d829) 。

## JSX

> React 的官方文档中关于 JSX 的介绍：[a comprehensive guide to JSX](https://reactjs.org/docs/jsx-in-depth.html) 。

React 和 React Native 都可使用 JSX ，这种 JavaScript 语法使 React 元素的编写更便利。由于 JSX 是 JavaScript ，因此可以在 JSX 内使用变量，如下面 `<Text>` 组件使用中的 `name` 变量（在 JSX 中使用花括号 `{}` 包裹）：

```javascript
import React from 'react';
import { Text } from 'react-native';

const Cat = () => {
  const name = "Maru";
  return (
    <Text>Hello, I am {name}!</Text>
  );
}

export default Cat;
```

任何 JavaScript 表达式都可放在花括号中执行，如下面代码中的 `{getFullName("Rum", "Tum", "Tugger")}` 方法调用：

```javascript
import React from 'react';
import { Text } from 'react-native';

const getFullName = (firstName, secondName, thirdName) => {
  return firstName + " " + secondName + " " + thirdName;
}

const Cat = () => {
  return (
    <Text>
      Hello, I am {getFullName("Rum", "Tum", "Tugger")}!
    </Text>
  );
}

export default Cat;
```

**说明**：由于 JSX 是包含在 React 库中的，因此需要在文件的开头导入：`import React from 'react'` 。

### 自定义组件

可以在自定义的组件中将不同的 *Core Components* 组合起来，形成一个新的组件，React Native 会一起渲染它们：

```javascript
import React from 'react';
import { Text, TextInput, View } from 'react-native';

const Cat = () => {
  return (
    <View>
      <Text>Hello, I am...</Text>
      <TextInput
        style={{
          height: 40,
          borderColor: 'gray',
          borderWidth: 1
        }}
        defaultValue="Name me!"
      />
    </View>
  );
}

export default Cat;
```

在其他组件中可以使用封装好的组件。在下面的 `Cafe` 组件中，通过 `<Cat />` 使用封装好的 `Cat` 组件：

```javascript
import React from 'react';
import { Text, View } from 'react-native';

const Cat = () => {
  return (
    <View>
      <Text>I am also a cat!</Text>
    </View>
  );
}

const Cafe = () => {
  return (
    <View>
      <Text>Welcome!</Text>
      <Cat />
      <Cat />
      <Cat />
    </View>
  );
}

export default Cafe;
```

包含其他组件的称为 parent component 。在上述例子中，`Cafe` 是 parent component ，`Cat` 是 child component 。

在 `Cafe` 组件中可以添加任意多的 `Cat` 组件。每个 `<Cat>` 渲染为一个独立的 element ，可以使用 `props` 来分别定制它们。
