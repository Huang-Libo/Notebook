# 原生组件

## iOS 原生 UI 组件

> 本指南以 core React Native library 中已存在的 `MapView` 为例来介绍如何构建一个原生 UI 组件。

接下来对原生的 `MKMapView` 进行封装，使它可以在 JavaScript 中使用。

*原生视图 (native view)* 由 `RCTViewManager` 的子类创建和操作。这些子类在功能上与 `UIViewController` 相似，但本质上是单例的，每个类只有一个由 `bridge` 创建的实例。它们把原生视图暴露给 `RCTUIManager` ，`RCTUIManager` 委托它们在必要时设置和更新视图的属性。`RCTViewManager` 通常也是视图的 delegate ，通过 `bridge` 将事件发送回 JavaScript 。

导出原生 UI 组件的步骤：

- 子类化 `RCTViewManager` ，为你的组件创建一个 manager；
- 添加 `RCT_EXPORT_MODULE()` 宏；
- 实现 `- (UIView *)view` 方法。

在 Xcode 中添加：

`RNTMapManager.h`

```objectivec
#import <MapKit/MapKit.h>
#import <React/RCTViewManager.h>

@interface RNTMapManager : RCTViewManager

@end
```

`RNTMapManager.m`

```objectivec
#import "RNTMapManager.h"

@implementation RNTMapManager

RCT_EXPORT_MODULE(RNTMap)

- (UIView *)view
{
    return [[MKMapView alloc] init];
}

@end
```

不要对 `- (UIView *)view` 导出的 view 实例上设置 `frame` 或 `backgroundColor` 等属性，

React Native 会覆盖你设置的值，最终生效的是 JavaScript 组件设置的 layout props 。如果你需要更细的控制粒度，最好将你想样式化的 UIView 实例包装在另一个 UIView 中，并返回包装器 UIView 。参考 [React Native issue 2948](https://github.com/facebook/react-native/issues/2948#issuecomment-259145135) 。

在 VS Code 中添加：

`MapView.js`

```jsx
import { requireNativeComponent } from 'react-native';

// requireNativeComponent automatically resolves 'RNTMap' to 'RNTMapManager'
module.exports = requireNativeComponent('RNTMap');
```

`APP.js`

```jsx
return (
  <MapView style={{flex: 1}} />
);
```

这现在是 JavaScript 中的一个功能齐全的原生地图视图组件，包含缩放和其他本地手势支持。但我们还不能从 JavaScript 控制它 :(
