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


