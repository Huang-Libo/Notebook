# Protocols

> Version: *Swift 5.5*  
> Source: [*swift-book: Protocols*](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)  
> Digest Date: *February 3, 2022*  

A *protocol* defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a *class*, *structure*, or *enumeration* to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to *conform* to that protocol.

In addition to specifying requirements that conforming types must implement, you can *extend* a protocol to implement some of these requirements or to implement additional functionality that conforming types can take advantage of.

- [Protocols](#protocols)
  - [Protocol Syntax](#protocol-syntax)
  - [Property Requirements](#property-requirements)
  - [Method Requirements](#method-requirements)

## Protocol Syntax

You define protocols in a very similar way to *classes*, *structures*, and *enumerations*:

```swift
protocol SomeProtocol {
    // protocol definition goes here
}
```

Custom types state that they adopt a particular protocol by placing the protocol’s name after the type’s name, separated by a *colon*, as part of their definition. Multiple protocols can be listed, and are separated by *commas*:

```swift
struct SomeStructure: FirstProtocol, AnotherProtocol {
    // structure definition goes here
}
```

If a class has a superclass, list the superclass name before any protocols it adopts, followed by a comma:

```swift
class SomeClass: SomeSuperclass, FirstProtocol, AnotherProtocol {
    // class definition goes here
}
```

## Property Requirements

A protocol can require any conforming type to provide an instance property or type property with a particular name and type. The protocol doesn’t specify whether the property should be a *stored property* or a *computed property*, it only specifies the required property *name* and *type*. The protocol also specifies whether each property must be *gettable* or *gettable and settable*.

- If a protocol requires a property to be *gettable and settable*, that property requirement can’t be fulfilled by a constant stored property or a read-only computed property.
- If the protocol only requires a property to be *gettable*, the requirement can be satisfied by any kind of property, *and it’s valid for the property to be also settable if this is useful for your own code*.

Property requirements are always declared as *variable properties*, prefixed with the `var` keyword. Gettable and settable properties are indicated by writing `{ get set }` after their type declaration, and gettable properties are indicated by writing `{ get }`.

```swift
protocol SomeProtocol {
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
}
```

*Always* prefix *type property* requirements with the `static` keyword when you define them in a protocol. This rule pertains even though type property requirements can be prefixed with the `class` or `static` keyword when implemented by a class:

```swift
protocol AnotherProtocol {
    static var someTypeProperty: Int { get set }
}
```

Here’s an example of a protocol with a single instance property requirement:

```swift
protocol FullyNamed {
    var fullName: String { get }
}
```

Here’s an example of a simple structure that adopts and conforms to the `FullyNamed` protocol:

```swift
struct Person: FullyNamed {
    var fullName: String
}
let john = Person(fullName: "John Appleseed")
// john.fullName is "John Appleseed"
```

Here’s a more complex class, which also adopts and conforms to the `FullyNamed` protocol:

```swift
class Starship: FullyNamed {
    var prefix: String?
    var name: String
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    var fullName: String {
        return (prefix != nil ? prefix! + " " : "") + name
    }
}
var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
// ncc1701.fullName is "USS Enterprise"
```

This class implements the `fullName` property requirement as a *computed read-only property* for a starship. Each `Starship` class instance stores a mandatory `name` and an optional `prefix`. The `fullName` property uses the `prefix` value if it exists, and prepends it to the beginning of `name` to create a full name for the starship.

## Method Requirements


