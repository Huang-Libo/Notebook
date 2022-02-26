# Swfit Inbox

- [Swfit Inbox](#swfit-inbox)
  - [pending](#pending)
    - [`@EnvironmentObject` & `environmentObject(_:)`](#environmentobject--environmentobject_)
  - [Swift 中含关联值的枚举](#swift-中含关联值的枚举)
  - [Error](#error)
    - [Overview](#overview)
    - [Using Enumerations as Errors](#using-enumerations-as-errors)
    - [Including More Data in Errors](#including-more-data-in-errors)

## pending

- `some` , Swift 5.1
- `@frozen`
- Combine
  - `Self.Output`
- SwiftUI

### `@EnvironmentObject` & `environmentObject(_:)`

- The `@EnvironmentObject` attribute.
  - You use this attribute in views that are lower down in the view hierarchy to receive data from views that are higher up.
- The `environmentObject(_:)` modifier.
  - You apply this modifier so that views further down in the view hierarchy can read data objects passed down through the environment.

## Swift 中含关联值的枚举

[Swift 中含关联值的枚举](https://github.com/Huang-Libo/Notebook/blob/master/code/EnumAssociatedValues.swift)

- `static` 可以修饰存储属性，而 `class` 不能；
- `class` 修饰的方法可以继承，而 `static` 不能。
- 在协议中需用 `static` 来修饰。

## Error

> [Swift Docs: Protocol-Error](https://developer.apple.com/documentation/swift/error#)

Declaration：

```swift
public protocol Error : Sendable {
}
```

### Overview

Any type that declares conformance to the `Error` protocol can be used to represent an error in Swift’s error handling system. Because the Error protocol has *no* requirements of its own, you can declare conformance on any custom type you create.

### Using Enumerations as Errors

Swift’s enumerations are well suited to represent simple errors.

```swift
enum IntParsingError: Error {
    case overflow
    case invalidInput(Character)
}
```

```swift
extension Int {
    init(validating input: String) throws {
        // ...
        let c = _nextCharacter(from: input)
        if !_isValid(c) {
            throw IntParsingError.invalidInput(c)
        }
        // ...
    }
}
```

```swift
do {
    let price = try Int(validating: "$100")
} catch IntParsingError.invalidInput(let invalid) {
    print("Invalid character: '\(invalid)'")
} catch IntParsingError.overflow {
    print("Overflow error")
} catch {
    print("Other error")
}
// Prints "Invalid character: '$'"
```

### Including More Data in Errors

Sometimes you may want different error states to include the same common data, such as the position in a file or some of your application’s state. When you do, use a structure to represent errors. The following example uses a structure to represent an error when parsing an XML document, including the line and column numbers where the error occurred:

```swift
struct XMLParsingError: Error {
    enum ErrorKind {
        case invalidCharacter
        case mismatchedTag
        case internalError
    }

    let line: Int
    let column: Int
    let kind: ErrorKind
}

func parse(_ source: String) throws -> XMLDoc {
    // ...
    throw XMLParsingError(line: 19, column: 5, kind: .mismatchedTag)
    // ...
}
```

```swift
do {
    let xmlDoc = try parse(myXMLData)
} catch let e as XMLParsingError {
    print("Parsing error: \(e.kind) [\(e.line):\(e.column)]")
} catch {
    print("Other error: \(error)")
}
// Prints "Parsing error: mismatchedTag [19:5]"
```
