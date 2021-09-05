# React Native：原生模块

- 文档：<https://reactnative.dev/docs/native-modules-ios>

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

```objectivec
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getName)
{
    return [[UIDevice currentDevice] name];
}
```

这个方法的返回值类型必须是对象类型 `id` 并且可被序列化为 JSON 。这意味着只能返回 `nil` 或可转成 JSON 的值（如 `NSNumber`, `NSString`, `NSArray`, `NSDictionary` ）。

目前，我们不推荐使用同步方法，因为同步调用方法可能会有很大的性能损失，并且会给本地模块带来线程相关的 bug 。另外，请注意，如果选择使用 `RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD` ，App 将不能使用 *Chrome debugger* 。这是因为同步方法需要 `JS VM` 与 App 共享内存。对于 *Chrome debugger* ，React Native 运行在 Chrome 的 `JS VM` 中，并通过 **WebSocket** 与移动设备**异步通信**。

### 调用原生模块的示例

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

### 更好地导出原生模块

像上面那样导出 `NativeModules` 模块有一点笨重。为了避免每次在 RN 中使用原生模块时做重复的事情，可以为原生模块创建一个 JavaScript 包装器。

创建一个名为 `NativeCalendarModule.js` 的 JavaScript 文件，添加下述内容：

```jsx
import { NativeModules } from 'react-native';
const { CalendarModule } = NativeModules;
export default CalendarModule;
```

如果你使用 TypeScript ，在这个文件中也可以很方便地为这个原生模块添加 *type annotations* ：

```jsx
import { NativeModules } from 'react-native';
const { CalendarModule } = NativeModules
interface CalendarInterface {
   createCalendarEvent(name: string, location: string): void;
}
export default CalendarModule as CalendarInterface;
```

在其他 JavaScript 文件中，只需要导入上述模块即可调用其包装的原生模块：

```jsx
import NativeCalendarModule from './NativeCalendarModule';
NativeCalendarModule.createCalendarEvent('foo', 'bar');
```

### 参数类型

<https://reactnative.dev/docs/next/native-modules-ios#argument-types>

### 导出常量

原生模块可以通过重写原生方法 `-constantsToExport` 来导出常量。如：

```objectivec
- (NSDictionary *)constantsToExport
{
    return @{ @"DEFAULT_EVENT_NAME": @"New Event" };
}
```

在 JS 中可通过在原生模块上调用 `getConstants()` 来访问上面导出的常量：

```jsx
const { DEFAULT_EVENT_NAME } = CalendarModule.getConstants();
console.log(DEFAULT_EVENT_NAME);
```

Technically, it is possible to access constants exported in `-constantsToExport` directly off the `NativeModule` object. This will no longer be supported with **TurboModules**, so we encourage the community to switch to the above approach to avoid necessary migration down the line.

注意：常量是在初始化的时候导出的，如果你在运行时修改了 `-constantsToExport` 方法中的值，对 JavaScript 环境是不生效的。

对于 iOS 项目，如果重写了 `-constantsToExport` ，则还需要重写 `+requiresMainQueueSetup:` 方法来让 React Native 知道你的模块是否需要在主线程上初始化（在任何 JavaScript 代码执行之前）。否则，你会看到一个警告：在未来，你的模块可能会在后台线程上初始化，除非你明确选择使用 `+requiresMainQueueSetup:` 来指定在主线程执行。如果你的模块不需要访问 `UIKit` ，那么你应该在 `+ requiresMainQueueSetup:` 中返回 `NO` 。

### Callbacks

`callback` 在异步方法中用于把数据从 Objective-C 传递到 JavaScript 。**它们还可以用于在原生代码中异步执行 JS 。**

对于 iOS ，`callback` 是使用 `RCTResponseSenderBlock` 类型实现的。注意，`RCTResponseSenderBlock` 只接受一个数组类型的参数。如：

```objectivec
RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)title
                  location:(NSString *)location
                  callback:(RCTResponseSenderBlock)callback)
{
    NSInteger eventId = 101;
    callback(@[@(eventId)]);

    RCTLogInfo(@"[Xcode]Pretending to create an event %@ at %@", title, location);
}
```

在 JavaScript 中调用上述方法，第三个参数就是回调：

```jsx
const onPress = () => {
  NativeCalendarModule.createCalendarEvent(
    'Party',
    '04-12-2020',
    (eventId) => {
      console.log(`Created a new event with id ${eventId}`);
    }
  );
```

原生模块应该只调用一次它的回调函数。但是，它可以存储回调，并在稍后调用它。这个模式通常用于包装需要委托的 iOS API — 参见 [RCTAlertManager](https://github.com/facebook/react-native/blob/main/React/CoreModules/RCTAlertManager.mm) 的示例。**如果回调从未调用，则会泄漏一些内存。**

有两种方法处理包含错误信息的回调。第一种方法是遵循 Node 的约定，将传递给**回调数组**（即 callback 唯一的数组类型的参数）的第一个参数视为错误对象：

```objectivec
RCT_EXPORT_METHOD(createCalendarEventCallback:(NSString *)title
                  location:(NSString *)location
                  callback:(RCTResponseSenderBlock)callback)
{
    NSNumber *eventId = [NSNumber numberWithInt:123];
    callback(@[[NSNull null], eventId]);
}
```

在 JavaScript 中，你可以检查第一个参数来判断是否有 error ：

```jsx
const onPress = () => {
  NativeCalendarModule.createCalendarEventCallback(
    'testName',
    'testLocation',
    (error, eventId) => {
      if (error) {
        console.error(`Error found! ${error}`);
      }
      console.log(`event id ${eventId} returned`);
    }
  );
};
```

第二种可选的方法是使用两个独立的 callback ，`onFailure` 和 `onSuccess` ：

```objectivec
RCT_EXPORT_METHOD(createCalendarEventCallback:(NSString *)title
                  location:(NSString *)location
                  errorCallback:(RCTResponseSenderBlock)errorCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
  @try {
    NSNumber *eventId = [NSNumber numberWithInt:456];
    successCallback(@[eventId]);
  }

  @catch ( NSException *e ) {
    errorCallback(@[e]);
  }
}
```

然后在 JavaScript 中，你可以为错误和成功的响应分别添加一个的回调:

```jsx
const onPress = () => {
  NativeCalendarModule.createCalendarEventCallback(
    'testName',
    'testLocation',
    (error) => {
      console.error(`Error found! ${error}`);
    },
    (eventId) => {
      console.log(`event id ${eventId} returned`);
    }
  );
};
```

If you want to pass error-like objects to JavaScript, use `RCTMakeError` from [RCTUtils.h](https://github.com/facebook/react-native/blob/main/React/Base/RCTUtils.h). Right now this only passes an Error-shaped dictionary to JavaScript, but React Native aims to automatically generate real JavaScript Error objects in the future. You can also provide a `RCTResponseErrorBlock` argument, which is used for error callbacks and accepts an `NSError \* object`. Please note that this argument type will not be supported with **TurboModules**.

### Promise

原生模块也可以实现一个 `Promise` ，这可以简化你的 JavaScript ，特别是当你使用 `ES2016` 的 `async`/`await` 语法时。当一个原生模块方法的最后一个参数是 `RCTPromiseResolveBlock` 和 `RCTPromiseRejectBlock` 时，它对应的 JS 方法将返回一个 JS `Promise` 对象。如：

```objectivec
RCT_EXPORT_METHOD(createCalendarEvent:(NSString *)title
                 location:(NSString *)location
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
//    NSInteger eventId = createCalendarEvent();
    NSInteger eventId = 789;
    if (eventId) {
        resolve(@(eventId));
    } else {
        reject(@"event_failure", @"no event id returned", nil);
    }
}
```

这个方法对应的 JavaScript 返回一个 `Promise` 。这意味着你可以在 `async` 函数中使用 `await` 关键字来调用它并等待它的结果：

```jsx
const onPress = async () => {
  try {
    const eventId = await NativeCalendarModule.createCalendarEvent(
      'Party',
      'my house'
    );
    console.log(`Created a new event with id ${eventId}`);
  } catch (e) {
    console.error(e);
  }
};
```