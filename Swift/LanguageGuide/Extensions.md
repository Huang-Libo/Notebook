# Extensions

*Extensions* add new functionality to an existing *class*, *structure*, *enumeration*, or *protocol* type. This includes the ability to extend types for which you don’t have access to the original source code (known as *retroactive modeling*). Extensions are similar to *categories* in Objective-C. (Unlike Objective-C categories, Swift extensions don’t have names.)

Extensions in Swift can:

- Add *computed instance properties* and *computed type properties*
- Define *instance methods* and *type methods*
- Provide new initializers
- Define subscripts
- Define and use new nested types
- Make an existing type conform to a protocol

In Swift, you can even extend a protocol to provide implementations of its requirements or add additional functionality that conforming types can take advantage of. For more details, see [Protocol Extensions](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html#ID521).

> **NOTE**: Extensions can add new functionality to a type, but they can’t override existing functionality.

- [Extensions](#extensions)
  - [Extension Syntax](#extension-syntax)
  - [Computed Properties](#computed-properties)
  - [Initializers](#initializers)

## Extension Syntax

Declare extensions with the `extension` keyword:

```swift
extension SomeType {
    // new functionality to add to SomeType goes here
}
```

An extension can extend an existing type to make it adopt one or more protocols. To add protocol conformance, you write the protocol names the same way as you write them for a class or structure:

```swift
extension SomeType: SomeProtocol, AnotherProtocol {
    // implementation of protocol requirements goes here
}
```

## Computed Properties

Extensions can add *computed instance properties* and *computed type properties* to existing types. This example adds five computed instance properties to Swift’s built-in `Double` type, to provide basic support for working with distance units:

```swift
extension Double {
    var km: Double { return self * 1_000.0 }
    var m: Double { return self }
    var cm: Double { return self / 100.0 }
    var mm: Double { return self / 1_000.0 }
    var ft: Double { return self / 3.28084 }
}
let oneInch = 25.4.mm
print("One inch is \(oneInch) meters")
// Prints "One inch is 0.0254 meters"
let threeFeet = 3.ft
print("Three feet is \(threeFeet) meters")
// Prints "Three feet is 0.914399970739201 meters"
```

Although they’re implemented as computed properties, the names of these properties can be appended to a floating-point literal value with *dot syntax*, as a way to use that literal value to perform distance conversions.

These properties are read-only computed properties, and so they’re expressed without the `get` keyword, for brevity. Their return value is of type `Double`, and can be used within mathematical calculations wherever a Double is accepted:

```swift
let aMarathon = 42.km + 195.m
print("A marathon is \(aMarathon) meters long")
// Prints "A marathon is 42195.0 meters long"
```

> **NOTE**: Extensions can add new computed properties, **but they can’t add stored properties, or add property observers to existing properties**.

## Initializers


