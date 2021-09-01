# React Native：设计

文档：[React Native - Design](https://reactnative.dev/docs/style)

## Style

所有的 *core components* 都接受一个名为 `style` 的 prop 。`style` 的 `name` 和 `value` 与 web 上使用的 CSS 类似，不同的是 `name` 使用了驼峰命名法，比如 `backgroundColor` ，而不是 CSS 上的 `background-color` 。

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

## Height and Width

### Fixed Dimensions

设置组件尺寸的的一般方式是在 `style` 中添加固定的 `width` 和 `height` 。**React Native 中的所有维度都是无单位的，表示与密度无关的像素。**

示例：

```javascript
import React from 'react';
import { View } from 'react-native';

const FixedDimensionsBasics = () => {
  return (
    <View>
      <View style={{
        width: 50, height: 50, backgroundColor: 'powderblue'
      }} />
      <View style={{
        width: 100, height: 100, backgroundColor: 'skyblue'
      }} />
      <View style={{
        width: 150, height: 150, backgroundColor: 'steelblue'
      }} />
    </View>
  );
};

export default FixedDimensionsBasics;
```

### Flex Dimensions

在组件的 `style` 中使用 `flex` 以根据可用空间的大小来动态地展开和收缩组件。通常你会使用 `flex: 1` ，它告诉组件填满所有可用空间，并在具有相同父组件的其他组件之间平均共享。给定的 `flex` 值越大，组件所占的空间比就越高。

```javascript
import React from 'react';
import { View } from 'react-native';

const FlexDimensionsBasics = () => {
  return (
    // Try removing the `flex: 1` on the parent View.
    // The parent will not have dimensions, so the children can't expand.
    // What if you add `height: 300` instead of `flex: 1`?
    <View style={{ flex: 1 }}>
      <View style={{ flex: 1, backgroundColor: 'powderblue' }} />
      <View style={{ flex: 2, backgroundColor: 'skyblue' }} />
      <View style={{ flex: 3, backgroundColor: 'steelblue' }} />
    </View>
  );
};

export default FlexDimensionsBasics;
```

> A component can only expand to fill available space if its parent has dimensions greater than 0. If a parent does not have either a fixed width and height or flex, the parent will have dimensions of 0 and the flex children will not be visible.

在这个例子中，如果把父组件的 `style={{ flex: 1 }` 去掉，由于父组件没有了任何 dimension ，因此所有的子组件就都无法展开了；如果把父组件的 `flex: 1` 改成 `height: 300` ，能正常显示，父组件的高度变成了 `300px` ，子组件也相应缩小了。

### Percentage Dimensions

文档中说：

> Similar to flex dimensions, percentage dimensions require parent with a defined size.

但我把父组件的 `style={{ height: '100%' }}` 去掉后，子组件还是能正常展示，为什么呢？

```javascript
import React from 'react';
import { View } from 'react-native';

const PercentageDimensionsBasics = () => {
  // Try removing the `height: '100%'` on the parent View.
  // The parent will not have dimensions, so the children can't expand.
  return (
    <View style={{ height: '100%' }}>
      <View style={{
        height: '15%', backgroundColor: 'powderblue'
      }} />
      <View style={{
        width: '66%', height: '35%', backgroundColor: 'skyblue'
      }} />
      <View style={{
        width: '33%', height: '50%', backgroundColor: 'steelblue'
      }} />
    </View>
  );
};

export default PercentageDimensionsBasics;
```

## Layout with Flexbox

> Flexbox works the same way in React Native as it does in CSS on the web, with a few exceptions. The defaults are different, with `flexDirection` defaulting to `column` instead of `row`, `alignContent` defaulting to `flex-start` instead of `stretch`, `flexShrink` defaulting to `0` instead of `1`, the `flex` parameter only supporting a single number.

一个组件可以使用 *Flexbox algorithm* 来指定它的子组件的布局。Flexbox 的设计宗旨是在不同的屏幕尺寸上提供一致的布局。常用的有 `flexDirection`, `alignItems`, `justifyContent` 。

### Flex

[flex](https://reactnative.dev/docs/layout-props#flex) 定义了组件的填充方式。

示例：

```javascript
import React from "react";
import { StyleSheet, Text, View } from "react-native";

const Flex = () => {
  return (
    <View style={[styles.container, {
      // Try setting `flexDirection` to `"row"`.
      flexDirection: "column"
    }]}>
      <View style={{ flex: 1, backgroundColor: "red" }} />
      <View style={{ flex: 2, backgroundColor: "darkorange" }} />
      <View style={{ flex: 3, backgroundColor: "green" }} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
});

export default Flex;
```

### Flex Direction

[flexDirection](https://reactnative.dev/docs/layout-props#flexdirection) 用于控制子组件的布局方向。

- column（默认值）
- row
- column-reverse
- row-reverse

示例：

```javascript
import React, { useState } from "react";
import { StyleSheet, Text, TouchableOpacity, View, SafeAreaView } from "react-native";

const FlexDirectionBasics = () => {
  const [flexDirection, setflexDirection] = useState("column");

  return (
    <PreviewLayout
      label="flexDirection"
      values={["column", "row", "row-reverse", "column-reverse"]}
      selectedValue={flexDirection}
      setSelectedValue={setflexDirection}
    >
      <View
        style={[styles.box, { backgroundColor: "powderblue" }]}
      />
      <View
        style={[styles.box, { backgroundColor: "skyblue" }]}
      />
      <View
        style={[styles.box, { backgroundColor: "steelblue" }]}
      />
    </PreviewLayout>
  );
};

const PreviewLayout = ({
  label,
  children,
  values,
  selectedValue,
  setSelectedValue,
}) => (
  <SafeAreaView style={{ padding: 10, flex: 1 }}>
    <Text style={styles.label}>{label}</Text>
    <View style={styles.row}>
      {values.map((value) => (
        <TouchableOpacity
          key={value}
          onPress={() => setSelectedValue(value)}
          style={[
            styles.button,
            selectedValue === value && styles.selected,
          ]}
        >
          <Text
            style={[
              styles.buttonLabel,
              selectedValue === value && styles.selectedLabel,
            ]}
          >
            {value}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
    <View style={[styles.container, { [label]: selectedValue }]}>
      {children}
    </View>
  </SafeAreaView>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 8,
    backgroundColor: "aliceblue",
  },
  box: {
    width: 50,
    height: 50,
  },
  row: {
    flexDirection: "row",
    flexWrap: "wrap",
  },
  button: {
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderRadius: 4,
    backgroundColor: "oldlace",
    alignSelf: "flex-start",
    marginHorizontal: "1%",
    marginBottom: 6,
    minWidth: "48%",
    textAlign: "center",
  },
  selected: {
    backgroundColor: "coral",
    borderWidth: 0,
  },
  buttonLabel: {
    fontSize: 12,
    fontWeight: "500",
    color: "coral",
  },
  selectedLabel: {
    color: "white",
  },
  label: {
    textAlign: "center",
    marginBottom: 10,
    fontSize: 24,
  },
});

export default FlexDirectionBasics;
```

### Layout Direction

Layout [direction](https://reactnative.dev/docs/layout-props#direction) 指定层次结构中的子元素和文本的布局方向。

- LTR（默认值）：从左向右布局。
- RtL：从右向左布局。

示例：

```javascript
import React, { useState } from "react";
import { View, TouchableOpacity, Text, StyleSheet, SafeAreaView } from "react-native";

const DirectionLayout = () => {
  const [direction, setDirection] = useState("ltr");

  return (
    <PreviewLayout
      label="direction"
      selectedValue={direction}
      values={["ltr", "rtl"]}
      setSelectedValue={setDirection}>
      <View
        style={[styles.box, { backgroundColor: "powderblue" }]}
      />
      <View
        style={[styles.box, { backgroundColor: "skyblue" }]}
      />
      <View
        style={[styles.box, { backgroundColor: "steelblue" }]}
      />
    </PreviewLayout>
  );
};

const PreviewLayout = ({
  label,
  children,
  values,
  selectedValue,
  setSelectedValue,
}) => (
  <SafeAreaView style={{ padding: 10, flex: 1 }}>
    <Text style={styles.label}>{label}</Text>
    <View style={styles.row}>
      {values.map((value) => (
        <TouchableOpacity
          key={value}
          onPress={() => setSelectedValue(value)}
          style={[
            styles.button,
            selectedValue === value && styles.selected,
          ]}
        >
          <Text
            style={[
              styles.buttonLabel,
              selectedValue === value && styles.selectedLabel,
            ]}
          >
            {value}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
    <View style={[styles.container, { [label]: selectedValue }]}>
      {children}
    </View>
  </SafeAreaView>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 8,
    backgroundColor: "aliceblue",
  },
  box: {
    width: 50,
    height: 50,
  },
  row: {
    flexDirection: "row",
    flexWrap: "wrap",
  },
  button: {
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderRadius: 4,
    backgroundColor: "oldlace",
    alignSelf: "flex-start",
    marginHorizontal: "1%",
    marginBottom: 6,
    minWidth: "48%",
    textAlign: "center",
  },
  selected: {
    backgroundColor: "coral",
    borderWidth: 0,
  },
  buttonLabel: {
    fontSize: 12,
    fontWeight: "500",
    color: "coral",
  },
  selectedLabel: {
    color: "white",
  },
  label: {
    textAlign: "center",
    marginBottom: 10,
    fontSize: 24,
  },
});

export default DirectionLayout;
```
