# React Native：Native Modules

`NativeModules` system 将 Java / Objective-C / C++ （原生）类的实例作为 JS 对象暴露给 JS ，因此允许你在 JS 中执行任意的原生代码。

有两种方法可以为 React Native 应用编写原生模块：

1. 直接在 React Native 应用的 iOS / Android 项目中；
2. 作为一个 NPM 包，依赖安装在 React Native 应用中。

## iOS 原生模块

在下面的指南中，你将创建一个本地模块 `CalendarModule` ，它将允许你通过 JavaScript 访问 iOS 的日历 API 。最终你可以通过在 JavaScript 中调用 `CalendarModule.createCalendarEvent('Dinner Party', 'My House');` 来调用原生的方法创建一个日历事项。

### 在 Xcode 中创建 Objective-C 类

首先在 Xcode 中创建 `RCTCalendarModule` 类。由于 Objective-C 没有类似 Java 或 C++ 那样的语言层级的命名空间，因此通过添加前缀来避免重名。在这个例子中，前缀用的是 `RCT` ，代表 `React` 。

`RCTCalendarModule.h`

```Objective-C
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCTCalendarModule : NSObject <RCTBridgeModule>

@end

```

`RCTCalendarModule.m`

```Objective-C
#import "RCTCalendarModule.h"
#import <React/RCTLog.h>

@implementation RCTCalendarModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)name location:(NSString *)location)
{
    RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
    NSLog(@"This is NSLog!");
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getName)
{
    return [[UIDevice currentDevice] name];
}

@end
```

### 模块的名称

`RCTCalendarModule` 类遵守了 `RCTBridgeModule` 协议。*原生模块 (native module)* 的本质就是实现了 `RCTBridgeModule` 协议的 Objective-C 类。

使用 `RCT_EXPORT_MODULE` 宏来导出和注册原生模块，它有个可选参数，用来指定在 JavaScript 代码中访问该模块时使用的名称。请注意**这个参数不是字符串字面量**，使用 `RCT_EXPORT_MODULE(CalendarModuleFoo)` 而**不是** `RCT_EXPORT_MODULE("CalendarModuleFoo")` 。

如果未指定该参数，则在 JavaScript 中默认使用不带前缀的 Objective-C 的类名。比如，`RCTCalendarModule` 在 JavaScript 中使用 `CalendarModule` 来访问。

在 JS 中访问上述原生模块，需要先导入 `NativeModules` ：

```jsx
import { NativeModules } from 'react-native';
```

使用 `CalendarModule` ：

```jsx
const { CalendarModule } = ReactNative.NativeModules;
```

### 导出原生方法给 JavaScript

#### 异步方法：RCT_EXPORT_METHOD

使用 `RCT_EXPORT_METHOD` 宏导出的方法是异步的，因此其返回值类型总是 `void` 。为了将 `RCT_EXPORT_METHOD` 导出的方法的结果传递给 JavaScript ，你可以使用 callback 或发送通知。

在上面的例子中创建了一个名为 `createCalendarEvent` 的方法，带有两个名为 `name` 和 `location` 的 `NSString` 参数。在这个方法中调用了 `RCTLog` ，稍后在 JS 代码中调用 `createCalendarEvent` 方法，就可以在 Xcode 或 Chrome Debugger 或 Flipper (for Mac) 中查看的 log 。

> Please note that the `RCT_EXPORT_METHOD` macro will not be necessary with **TurboModules** unless your method relies on *RCT argument conversion* (see argument types below). Ultimately, React Native will remove `RCT_EXPORT_MACRO`, so we discourage people from using `RCTConvert`. Instead, you can do the argument conversion within the method body.

#### 同步方法：RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD

你可以使用 `RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD` 来创建一个原生的同步方法：

```objc
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getName)
{
    return [[UIDevice currentDevice] name];
}
```

这个方法的返回值类型必须是对象类型 `id` 并且可被序列化为 JSON 。这意味着只能返回 `nil` 或可转成 JSON 的值（如 `NSNumber`, `NSString`, `NSArray`, `NSDictionary` ）。

目前，我们不推荐使用同步方法，因为同步调用方法可能会有很大的性能损失，并且会给本地模块带来线程相关的 bug 。另外，请注意，如果选择使用 `RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD` ，App 将不能使用 *Chrome debugger* 。这是因为同步方法需要 `JS VM` 与 App 共享内存。对于 *Chrome debugger* ，React Native 运行在 Chrome 的 `JS VM` 中，并通过 **WebSocket** 与移动设备**异步通信**。

### React Native 调用原生模块的示例

```jsx
import React from 'react';
import { NativeModules, Button, SafeAreaView } from 'react-native';

const { CalendarModule } = NativeModules;

const NewModuleButton = () => {
  const onPress = () => {
    CalendarModule.createCalendarEvent('testName', 'testLocation');
  };

  return (
    <SafeAreaView>
      <Button
        title="Click to invoke your native module!"
        color="#841584"
        onPress={onPress}
      />
    </SafeAreaView>
    
  );
};

export default NewModuleButton;
```
