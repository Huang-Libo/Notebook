# React Native：基础

文档：[React Native - Basics](https://reactnative.dev/docs/getting-started)

## 前置课程：JavaScript

想快速熟悉 `JavaScript` ，推荐阅读 [MDN Web Docs](https://developer.mozilla.org/) 的这两份文档：

- [A re-introduction to JavaScript (JS tutorial)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/A_re-introduction_to_JavaScript)
- [JavaScript Docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

## Function Components & Class Components

组件有两种写法，classes 或 functions 。

*Function Components*（推荐写法）：

```jsx
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

```jsx
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

![Core-Components.jpg](media/React-Native-Docs-Image/Core-Components.jpg)

示例：

```jsx
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

![diagram_react-native-components.svg](media/React-Native-Docs-Image/diagram_react-native-components.svg)

## React 基础

> [React 的官方文档](https://reactjs.org/docs/getting-started.html)

React 的核心概念：

- components
- JSX
- props
- state

### 你的第一个组件

示例代码：

```jsx
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

```jsx
const Cat = () => {};
```

*Function Components* 返回的内容会被渲染成 **React element** 。这个 Cat 组件将被渲染成 `<Text>` 元素。

最后，使用 JavaScript 的 [export default](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export) 导出这个组件。

**说明**：其他导出组件方式可参考这个 [handy cheatsheet on JavaScript imports and exports](https://medium.com/dailyjs/javascript-module-cheatsheet-7bd474f1d829) 。

### JSX

> React 的官方文档中关于 JSX 的介绍：[a comprehensive guide to JSX](https://reactjs.org/docs/jsx-in-depth.html) 。

React 和 React Native 都可使用 JSX ，这种 JavaScript 语法使 React 元素的编写更便利。由于 JSX 是 JavaScript ，因此可以在 JSX 内使用变量，如下面 `<Text>` 组件使用中的 `name` 变量（在 JSX 中使用花括号 `{}` 包裹）：

```jsx
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

```jsx
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

```jsx
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

```jsx
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

## Props

`Props` 是 Properties 的简写。可以使用 `Props` 自定义 React 组件。例如，在下面的代码中，为每个 `<Cat>` 组件传入了不同的 `name` 变量：

```jsx
import React from 'react';
import { Text, View } from 'react-native';

const Cat = (props) => {
  return (
    <View>
      <Text>Hello, I am {props.name}!</Text>
    </View>
  );
}

const Cafe = () => {
  return (
    <View>
      <Cat name="Maru" />
      <Cat name="Jellylorum" />
      <Cat name="Spot" />
    </View>
  );
}

export default Cafe;
```

React Native 的大部分 *Core Components* 可以使用 `props` 来自定义，比如，在使用 [Image](https://reactnative.dev/docs/image) 组件时，可以传递一个名为 `source` 的 prop 来指定 image 的来源：

```jsx
import React from 'react';
import { Text, View, Image } from 'react-native';

const CatApp = () => {
  return (
    <View>
      <Image
        source={{uri: "https://reactnative.dev/docs/assets/p_cat1.png"}}
        style={{width: 200, height: 200}}
      />
      <Text>Hello, I am your cat!</Text>
    </View>
  );
}

export default CatApp;
```

`Image` 组件有许多不同的 `props` ，比如 `style` ，它接受*设计*和*布局*相关的`属性-值`对的 JS 对象 。详情可参考 [Image 组件的文档](https://reactnative.dev/docs/image#props)。

**说明**：

> Notice the double curly braces `{{ }}` surrounding `style`‘s width and height.  
>  
> In JSX, JavaScript values are referenced with `{}`. This is handy if you are passing something other than a string as props, like an array or number: `<Cat food={["fish", "kibble"]} age={2} />`.
>  
> However, JS objects are also denoted with curly braces: `{width: 200, height: 200}`. **Therefore, to pass a JS object in JSX, you must wrap the object in another pair of curly braces**: `{{width: 200, height: 200}}`

## State

`props` 是用来配置组件的渲染方式的参数，而 `state` 是组件的 personal data storage 。`state` 用于*数据随时间变化*或*根据用户的交互而变化*的场景。State gives your components memory!

> As a general rule, use props to configure a component when it renders. Use state to keep track of any component data that you expect to change over time.

在下面的例子中，猫咖啡馆中的两只猫等着被投喂。它们的饥饿状态以 state 的方式存储，且会在点击“投喂”按钮后发生变化（不同于它们的名字，名字是固定不变的）。

开发者可以调用 [React’s useState Hook](https://reactjs.org/docs/hooks-state.html) 来给组件添加 `state` 。

> A Hook is a kind of function that lets you “hook into” React features. For example, `useState` is a Hook that lets you add state to function components.
>  
> You can learn more about [other kinds of Hooks in the React documentation](https://reactjs.org/docs/hooks-intro.html).

示例：

```jsx
import React, { useState } from "react";
import { Button, Text, View } from "react-native";

const Cat = (props) => {
  const [isHungry, setIsHungry] = useState(true);

  return (
    <View>
      <Text>
        I am {props.name}, and I am {isHungry ? "hungry" : "full"}!
      </Text>
      <Button
        onPress={() => {
          setIsHungry(false);
        }}
        disabled={!isHungry}
        title={isHungry ? "Pour me some milk, please!" : "Thank you!"}
      />
    </View>
  );
}

const Cafe = () => {
  return (
    <>
      <Cat name="Munkustrap" />
      <Cat name="Spot" />
    </>
  );
}

export default Cafe;
```

接下来对上述代码进行解读。

首先，需要从 React 中导入 `useState` ：

```jsx
import React, { useState } from 'react';
```

然后，通过在组件的函数中调用 `useState` 来声明组件的*状态*，在这个例子中，`useState` 创建了一个 `isHungry` *状态*变量：

```jsx
const Cat = (props) => {
  const [isHungry, setIsHungry] = useState(true);
  // ...
};
```

> You can use `useState` to track any kind of data: `strings`, `numbers`, `Booleans`, `arrays`, `objects`. For example, you can track the number of times a cat has been petted with `const [timesPetted, setTimesPetted] = useState(0)`!

调用 `useState` 做了两件事情：

- 创建一个含初值的 `state` 变量；
- 创建一个函数来设置 `state` 变量的值。

命名规则建议：`[<getter>, <setter>] = useState(<initialValue>)` 。

接下来，添加了 [Button](https://reactnative.dev/docs/button) *Core Component* ，并设置了 `onPress` prop ：

```jsx
<Button
  onPress={() => {
    setIsHungry(false);
  }}
  //..
/>
```

当用户点击按钮时，会触发 `onPress` ，然后调用 `setIsHungry(false)` ，将 `isHungry` state 变量设置为 `false` 。当 `isHungry` 为 `false` 时，`Button` 组件的 `disable` prop 会被设置成 `true` ，且 `title` 也会改变：

```jsx
<Button
  //..
  disabled={!isHungry}
  title={isHungry ? 'Pour me some milk, please!' : 'Thank you!'}
/>
```

> You might’ve noticed that although `isHungry` is a `const`, it is seemingly reassignable! What is happening is when a state-setting function like `setIsHungry` is called, its **component will re-render**. In this case the `Cat` function will run again—and this time, `useState` will give us the next value of `isHungry`.

最后，把 `Cat` 组件添加到 `Cafe` 组件中：

```jsx
const Cafe = () => {
  return (
    <>
      <Cat name="Munkustrap" />
      <Cat name="Spot" />
    </>
  );
};
```

>See the `<>` and `</>` above? These bits of JSX are [fragments](https://reactjs.org/docs/fragments.html). Adjacent JSX elements must be wrapped in an enclosing tag. Fragments let you do that without nesting an extra, unnecessary wrapping element like `View`.

## TextInput

[TextInput](https://reactnative.dev/docs/textinput#content) 是一个 *Core Component* ，它允许用户输入文本。

- `TextInput` 有一个 `onChangeText` prop ，这个 prop 可设置一个函数，这个函数会在 text 发生变化时被调用。
- `TextInput` 还有一个 `onSubmitEditing` prop ，它携带的函数会在 text 被提交的时候被调用。

示例：

```jsx
import React, { useState } from 'react';
import { Text, TextInput, View } from 'react-native';

const PizzaTranslator = () => {
  const [text, setText] = useState('');
  return (
    <View style={{padding: 10}}>
      <TextInput
        style={{height: 40}}
        placeholder="Type here to translate!"
        onChangeText={text => setText(text)}
        defaultValue={text}
      />
      <Text style={{padding: 10, fontSize: 42}}>
        {text.split(' ').map((word) => word && '🍕').join(' ')}
      </Text>
    </View>
  );
}

export default PizzaTranslator;
```

在这个例子中，我们把 `text` 存储在 state 中，因为它会被用户更改。

**相关文档**：

- [React docs on controlled components](https://reactjs.org/docs/forms.html#controlled-components)
- [reference docs for TextInput](https://reactnative.dev/docs/textinput)

## ScrollView

下面是一个创建 vertical `ScrollView` 的示例：

```jsx
import React from 'react';
import { SafeAreaView, Image, ScrollView, Text } from 'react-native';

const logo = {
  uri: 'https://reactnative.dev/img/tiny_logo.png',
  width: 64,
  height: 64
};

const App = () => (
  <SafeAreaView>
    <ScrollView>
      <Text style={{ fontSize: 96 }}>Scroll me plz</Text>
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Text style={{ fontSize: 96 }}>If you like</Text>
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Text style={{ fontSize: 96 }}>Scrolling down</Text>
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Text style={{ fontSize: 96 }}>What's the best</Text>
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Text style={{ fontSize: 96 }}>Framework around?</Text>
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Image source={logo} />
      <Text style={{ fontSize: 80 }}>React Native</Text>
    </ScrollView>
  </SafeAreaView>
);

export default App;
```

`ScrollView` 适合用于展示内容有限的页面，因为 `ScrollView` 中所有的元素都会被渲染，即使它们还没有出现在屏幕上。因此，如果你有一个很长的 list 要展示，你应该使用 `FlatList` 。

## List Views

React Native 提供了一套用于展示列表数据的组件，较常用的是 [FlatList](https://reactnative.dev/docs/flatlist) 和 [SectionList](https://reactnative.dev/docs/sectionlist) 。

和 `ScrollView` 组件不同的是，`FlatList` 组件只会渲染当前展示在屏幕上的元素，而不是一次性渲染所有元素。

`FlatList` 组件需要两个 prop ：`data` 和 `renderItem` 。`data` 是列表的数据源；`renderItem` 从数据源中取出一项然后返回一个 *formatted component* 来渲染。

下面的示例使用硬编码数据创建了一个 `FlatList` 。`data` 中的每一项被渲染成了一个 `Text` 组件：

```jsx
import React from 'react';
import { FlatList, StyleSheet, Text, SafeAreaView } from 'react-native';

const styles = StyleSheet.create({
  container: {
   flex: 1,
   paddingTop: 22
  },
  item: {
    padding: 10,
    fontSize: 18,
    height: 44,
  },
});

const FlatListBasics = () => {
  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={[
          {key: 'Devin'},
          {key: 'Dan'},
          {key: 'Dominic'},
          {key: 'Jackson'},
          {key: 'James'},
          {key: 'Joel'},
          {key: 'John'},
          {key: 'Jillian'},
          {key: 'Jimmy'},
          {key: 'Julie'},
        ]}
        renderItem={({item}) => <Text style={styles.item}>{item.key}</Text>}
      />
    </SafeAreaView>
  );
}

export default FlatListBasics;
```

如果想把页面分成多个 section ，类似 iOS 中的 `UITableView` ，则可以使用 `SectionList` ：

```jsx
import React from 'react';
import { SectionList, StyleSheet, Text, SafeAreaView } from 'react-native';

const styles = StyleSheet.create({
  container: {
   flex: 1,
   paddingTop: 22
  },
  sectionHeader: {
    paddingTop: 2,
    paddingLeft: 10,
    paddingRight: 10,
    paddingBottom: 2,
    fontSize: 14,
    fontWeight: 'bold',
    backgroundColor: 'rgba(247,247,247,1.0)',
  },
  item: {
    padding: 10,
    fontSize: 18,
    height: 44,
  },
})

const SectionListBasics = () => {
    return (
      <SafeAreaView style={styles.container}>
        <SectionList
          sections={[
            {title: 'D', data: ['Devin', 'Dan', 'Dominic']},
            {title: 'J', data: ['Jackson', 'James', 'Jillian', 'Jimmy', 'Joel', 'John', 'Julie']},
          ]}
          renderItem={({item}) => <Text style={styles.item}>{item}</Text>}
          renderSectionHeader={({section}) => <Text style={styles.sectionHeader}>{section.title}</Text>}
          keyExtractor={(item, index) => index}
        />
      </SafeAreaView>
    );
}

export default SectionListBasics;
```

## FAQ

- [Troubleshooting](https://reactnative.dev/docs/troubleshooting)
- [Platform Specific Code](https://reactnative.dev/docs/platform-specific-code)
- [More Resources](https://reactnative.dev/docs/more-resources)
