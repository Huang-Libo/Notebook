# Protocols

> Version: *Swift 5.5*  
> Source: [*swift-book: Protocols*](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)  
> Digest Date: *February 3, 2022*  

A *protocol* defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a *class*, *structure*, or *enumeration* to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to *conform* to that protocol.

In addition to specifying requirements that conforming types must implement, you can *extend* a protocol to implement some of these requirements or to implement additional functionality that conforming types can take advantage of.

- [Protocols](#protocols)
  - [Protocol Syntax](#protocol-syntax)
  - [Property Requirements](#property-requirements)

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


