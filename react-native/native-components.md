# 原生组件

## iOS 原生 UI 组件

> 本指南以 core React Native library 中已存在的 `MapView` 为例来介绍如何构建一个原生 UI 组件。

接下来对原生的 `MKMapView` 进行封装，使它可以在 JavaScript 中使用。

*原生视图 (native view)* 由 `RCTViewManager` 的子类创建和操作。这些子类在功能上与 `UIViewController` 相似，但本质上是单例的，每个类只有一个由 `bridge` 创建的实例。它们把原生视图暴露给 `RCTUIManager` ，`RCTUIManager` 委托它们在必要时设置和更新视图的属性。`RCTViewManager` 通常也是视图的 delegate ，通过 `bridge` 将事件发送回 JavaScript 。

导出原生 UI 组件的步骤：

- 子类化 `RCTViewManager` ，为你的组件创建一个 manager；
- 添加 `RCT_EXPORT_MODULE()` 宏；
- 实现 `- (UIView *)view` 方法。

**在 Xcode 中添加**：

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

不要在 `- (UIView *)view` 导出的 view 实例上设置 `frame` 或 `backgroundColor` 等属性，因为 React Native 会覆盖你设置的值，最终生效的是 JavaScript 组件设置的 layout props 。如果你需要更细的控制粒度，最好将你想样式化的 `UIView` 实例包装在另一个 `UIView` 中，并返回这个 *wrapper* `UIView` 。参考 [React Native issue 2948](https://github.com/facebook/react-native/issues/2948#issuecomment-259145135) 。

**在 VS Code 中添加**：

`MapView.js`

> 注意：不可在 `MapView.js` 中执行 `⌘S` ，否则会报错：“There are two approaches to error handling with callbacks” 。原因是 `requireNativeComponent` 被执行了两次。如果报错了，可在其他文件（比如 `APP.js` ）执行 `⌘S` 或在 Metro 终端任务中输入 `r` 来刷新项目。

```jsx
import { requireNativeComponent } from 'react-native';

// requireNativeComponent automatically resolves 'RNTMap' to 'RNTMapManager'
module.exports = requireNativeComponent('RNTMap');
```

`APP.js`

```jsx
import React, { Component } from 'react';
import MapView from './MapView.js';

class App extends Component {
  render() {
    return <MapView style={{flex: 1}} />;
  }
}

export default App;
```

这现在是 JavaScript 中的一个功能齐全的原生地图视图组件，包含缩放和其他本地手势支持。但我们还不能从 JavaScript 控制它 :(

### 导出属性

要使该组件更可用，我们可以做的第一件事是在一些原生属性上进行桥接。比如我们想*禁用缩放手势*和*指定可视区域*。

#### 示例一：导出 zoomEnabled 属性

缩放手势通过 `zoomEnabled` 属性控制，这是一个布尔值，在 `RNTMapManager.m` 中添加：

```objectivec
RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
```

其中 `RCT_EXPORT_VIEW_PROPERTY(name, type)` 宏的本质是一个方法：

```objectivec
/**
 * This handles the simple case, where JS and native property names match.
 */
#define RCT_EXPORT_VIEW_PROPERTY(name, type)            \
+(NSArray<NSString *> *)propConfig_##name RCT_DYNAMIC \
{                                                     \
  return @[ @ #type ];                                \
}
```

在 JS 中使用 `MapView` 时，就能设置 `zoomEnabled` 属性了。在 JS 中禁用缩放：

```jsx
<MapView zoomEnabled={false} style={{flex: 1}} />;
```

为了记录 `MapView` 组件的属性（以及它们接受的值），我们将添加一个 wrapper 组件，并使用 React `PropTypes` 记录接口：

```jsx
// MapView.js
import PropTypes from 'prop-types';
import React from 'react';
import { requireNativeComponent } from 'react-native';

class MapView extends React.Component {
  render() {
    return <RNTMap {...this.props} />;
  }
}

MapView.propTypes = {
  /**
   * A Boolean value that determines whether the user may use pinch
   * gestures to zoom in and out of the map.
   */
  zoomEnabled: PropTypes.bool
};

var RNTMap = requireNativeComponent('RNTMap');

module.exports = MapView;
```

#### 示例二：导出 region 属性

接下来，我们再添加一个更复杂的 `region` prop ，在 `RNTMapManager.m` 中添加：

```objectivec
RCT_CUSTOM_VIEW_PROPERTY(region, MKCoordinateRegion, MKMapView)
{
    MKCoordinateRegion myRegion = json ? [RCTConvert MKCoordinateRegion:json] : defaultView.region;
    [view setRegion:myRegion animated:YES];
}
```

在上述代码中，`json` 是从 JS 传入的原始值。还有一个 `view` 变量，它允许我们访问 manager 的 view 实例，最后是 `defaultView` 变量，如果 JS 给我们发送一个空值，我们使用它将属性重置为默认值。

其中 `RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass)` 宏的本质是包装了一个方法头，提供了 `json`、`view`、`defaultView` 三个属性给后面的方法体使用：

```objectivec
/**
 * This macro maps a named property to an arbitrary key path in the view.
 */
#define RCT_REMAP_VIEW_PROPERTY(name, keyPath, type)    \
  +(NSArray<NSString *> *)propConfig_##name RCT_DYNAMIC \
  {                                                     \
    return @[ @ #type, @ #keyPath ];                    \
  }

/**
 * This macro can be used when you need to provide custom logic for setting
 * view properties. The macro should be followed by a method body, which can
 * refer to "json", "view" and "defaultView" to implement the required logic.
 */
#define RCT_CUSTOM_VIEW_PROPERTY(name, type, viewClass) \
  RCT_REMAP_VIEW_PROPERTY(name, __custom__, type)       \
  -(void)set_##name : (id)json forView : (viewClass *)view withDefaultView : (viewClass *)defaultView RCT_DYNAMIC
```

在 `RNTMapManager.m` 中添加一个 `RCTConvert (Mapkit)` 分类，提供一个 `+ MKCoordinateRegion:` 方法来把 JS 传入的 `json` 转成 `MKCoordinateRegion` ，在这个分类中使用了 React Native 库中已有的 `RCTConvert+CoreLocation` 分类中的方法：

```objectivec
#import "RNTMapManager.h"
#import <React/RCTConvert.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <React/RCTConvert+CoreLocation.h>

@interface RCTConvert (Mapkit)

+ (MKCoordinateSpan)MKCoordinateSpan:(id)json;
+ (MKCoordinateRegion)MKCoordinateRegion:(id)json;

@end

@implementation RCTConvert(MapKit)

+ (MKCoordinateSpan)MKCoordinateSpan:(id)json
{
    json = [self NSDictionary:json];
    return (MKCoordinateSpan){
        [self CLLocationDegrees:json[@"latitudeDelta"]],
        [self CLLocationDegrees:json[@"longitudeDelta"]]
    };
}

+ (MKCoordinateRegion)MKCoordinateRegion:(id)json
{
    return (MKCoordinateRegion){
        [self CLLocationCoordinate2D:json],
        [self MKCoordinateSpan:json]
    };
}

@end

@implementation RNTMapManager

RCT_EXPORT_MODULE(RNTMap)

RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(region, MKCoordinateRegion, MKMapView)
{
    MKCoordinateRegion myRegion = json ? [RCTConvert MKCoordinateRegion:json] : defaultView.region;
    [view setRegion:myRegion animated:YES];
}

- (UIView *)view
{
    return [[MKMapView alloc] init];
}

@end
```

在 `MapView.js` 的 `propTypes` 中添加 `region` ：

```jsx
// MapView.js
import PropTypes from 'prop-types';
import React from 'react';
import { requireNativeComponent } from 'react-native';

class MapView extends React.Component {
  render() {
    return <RNTMap {...this.props} />;
  }
}

MapView.propTypes = {
    /**
     * A Boolean value that determines whether the user may use pinch
     * gestures to zoom in and out of the map.
     */
    zoomEnabled: PropTypes.bool,
  
    /**
     * The region to be displayed by the map.
     *
     * The region is defined by the center coordinates and the span of
     * coordinates to display.
     */
    region: PropTypes.shape({
      /**
       * Coordinates for the center of the map.
       */
      latitude: PropTypes.number.isRequired,
      longitude: PropTypes.number.isRequired,
  
      /**
       * Distance between the minimum and the maximum latitude/longitude
       * to be displayed.
       */
      latitudeDelta: PropTypes.number.isRequired,
      longitudeDelta: PropTypes.number.isRequired,
    }),
  };
  

var RNTMap = requireNativeComponent('RNTMap');

module.exports = MapView;
```

在 `APP.js` 中为 `MapView` 设置 `region` 属性：

```jsx
import React, { Component } from 'react';
import MapView from './MapView.js';

class App extends Component {
  render() {
    var region = {
      latitude: 39.95,
      longitude: 116.31,
      latitudeDelta: 0.02,
      longitudeDelta: 0.02,
    };
    return (
      <MapView
        region={region}
        zoomEnabled={false}
        style={{ flex: 1 }}
      />
    );
  }
}

export default App;
```
