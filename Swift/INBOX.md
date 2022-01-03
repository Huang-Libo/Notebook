# Swfit Inbox

[Swift 中含关联值的枚举](https://github.com/Huang-Libo/Notebook/blob/master/code/EnumAssociatedValues.swift)

- `static` 可以修饰存储属性，而 `class` 不能；
- `class` 修饰的方法可以继承，而 `static` 不能。
- 在协议中需用 `static` 来修饰。

## pending

- `associatedtype`
- `AnyObject`
- `some` , Swift 5.1
- `@frozen`, Combine
- 泛型，`where`
- 逃逸闭包 `@escaping`
- Combine
  - `Self.Output`
- SwiftUI
  - `@State`
  - bind : A binding controls the storage for a value, so you can pass data around to different views that need to read or write it.

### `@EnvironmentObject` & `environmentObject(_:)`

- The `@EnvironmentObject` attribute.
  - You use this attribute in views that are lower down in the view hierarchy to receive data from views that are higher up.
- The `environmentObject(_:)` modifier.
  - You apply this modifier so that views further down in the view hierarchy can read data objects passed down through the environment.
