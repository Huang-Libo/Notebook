# React Native：设计

文档：[React Native - Design](https://reactnative.dev/docs/style)

## Style

所有的 *core components* 都接受一个名为 `style` 的 prop 。`style` 的 name 和 value 与 web 上使用的 CSS 类似，不同的是 name 使用了驼峰命名法，比如 `backgroundColor` ，而不是 CSS 上的 `background-color` 。

`style` prop 可以是一个 `plain old JavaScript object` ，这是我们的示例代码中经常使用的。你也可以传递一个 `style` 数组，数组中的最后一个样式具有*优先权 (precedence)* ，因此可以使用它来继承样式。

当组件的样式变得复杂时，通常会使用 `StyleSheet.create` 在一个地方定义所有的 `style` 。

示例：

```javascript
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

const LotsOfStyles = () => {
    return (
      <View style={styles.container}>
        <Text style={styles.red}>just red</Text>
        <Text style={styles.bigBlue}>just bigBlue</Text>
        <Text style={[styles.bigBlue, styles.red]}>bigBlue, then red</Text>
        <Text style={[styles.red, styles.bigBlue]}>red, then bigBlue</Text>
      </View>
    );
};

const styles = StyleSheet.create({
  container: {
    marginTop: 50,
  },
  bigBlue: {
    color: 'blue',
    fontWeight: 'bold',
    fontSize: 30,
  },
  red: {
    color: 'red',
  },
});

export default LotsOfStyles;
```

一种常见的模式是让你的组件接受一个 `style` prop ，然后此 `style` 会作用于这个组件的子组件。通过这种方式来实现类似 CSS 中的样式*级联 (cascade)* 。
