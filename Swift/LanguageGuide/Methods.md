# Methods

> Version: *Swift 5.6*  
> Source: [*swift-book: Methods*](https://docs.swift.org/swift-book/LanguageGuide/Methods.html)  
> Digest Date: *March 1, 2022*  

- [Methods](#methods)
  - [Introduction](#introduction)
  - [Instance Methods](#instance-methods)
    - [The self Property](#the-self-property)
    - [Modifying Value Types from Within Instance Methods](#modifying-value-types-from-within-instance-methods)

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

Every instance of a type has an *implicit property* called `self`, which is exactly equivalent to the instance itself. You use the `self` property to refer to the current instance within its own instance methods.

The `increment()` method in the example above could have been written like this:

```swift
func increment() {
    self.count += 1
}
```

In practice, you don’t need to write `self` in your code very often. If you don’t explicitly write `self`, Swift assumes that you are referring to a *property* or *method* of the current instance whenever you use a known property or method name within a method. This assumption is demonstrated by the use of count (rather than `self.count`) inside the three instance methods for `Counter`.

The main exception to this rule occurs when a parameter name for an instance method has the *same name* as a property of that instance. In this situation, **the parameter name takes precedence**, and it becomes necessary to refer to the property in a more qualified way. You use the `self` property to distinguish between the parameter name and the property name.

Here, `self` disambiguates between a method parameter called `x` and an instance property that’s also called `x`:

```swift
struct Point {
    var x = 0.0, y = 0.0
    func isToTheRightOf(x: Double) -> Bool {
        return self.x > x
    }
}
let somePoint = Point(x: 4.0, y: 5.0)
if somePoint.isToTheRightOf(x: 1.0) {
    print("This point is to the right of the line where x == 1.0")
}
// Prints "This point is to the right of the line where x == 1.0"
```

Without the `self` prefix, Swift would assume that both uses of `x` referred to the *method parameter* called `x`.

### Modifying Value Types from Within Instance Methods


