# Methods

> Version: *Swift 5.6*  
> Source: [*swift-book: Methods*](https://docs.swift.org/swift-book/LanguageGuide/Methods.html)  
> Digest Date: *March 1, 2022*  

- [Methods](#methods)
  - [Introduction](#introduction)
  - [Instance Methods](#instance-methods)
    - [The self Property](#the-self-property)

## Introduction

*Methods* are functions that are associated with a particular type.

- *Classes*, *structures*, and *enumerations* can all define *instance methods*, which encapsulate specific tasks and functionality for working with an instance of a given type.
- *Classes*, *structures*, and *enumerations* can also define *type methods*, which are associated with the type itself. Type methods are similar to *class methods* in Objective-C.

The fact that *structures* and *enumerations* can define methods in Swift is a major difference from C and Objective-C.

- In Objective-C, *classes* are the only types that can define methods.
- In Swift, you can choose whether to define a *class*, *structure*, or *enumeration*, and still have the flexibility to define methods on the type you create.

## Instance Methods

*Instance methods* are functions that belong to instances of a particular *class*, *structure*, or *enumeration*. They support the functionality of those instances, either by providing ways to access and modify *instance properties*, or by providing functionality related to the instance’s purpose. Instance methods have exactly the same syntax as functions, as described in [Functions](https://docs.swift.org/swift-book/LanguageGuide/Functions.html).

- An instance method has implicit access to all other instance methods and properties of that type.
- An instance method can be called only on a specific instance of the type it belongs to. It can’t be called in isolation without an existing instance.

Here’s an example that defines a simple `Counter` class, which can be used to count the number of times an action occurs:

```swift
class Counter {
    var count = 0
    func increment() {
        count += 1
    }
    func increment(by amount: Int) {
        count += amount
    }
    func reset() {
        count = 0
    }
}
```

You call instance methods with the same *dot syntax* as properties:

```swift
let counter = Counter()
// the initial counter value is 0
counter.increment()
// the counter's value is now 1
counter.increment(by: 5)
// the counter's value is now 6
counter.reset()
// the counter's value is now 0
```

*Function parameters* can have both

- a *name* (for use within the function’s body) and
- an *argument label* (for use when calling the function),

as described in [Function Argument Labels and Parameter Names](https://docs.swift.org/swift-book/LanguageGuide/Functions.html#ID166). The same is true for *method parameters*, because **methods are just functions that are associated with a type**.

### The self Property


