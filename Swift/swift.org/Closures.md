# Closures

> Version: *Swift 5.5*  
> Source: [*swift-book: Closures*](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)  
> Digest Date: *January 16, 2022*  

*Closures* in Swift are similar to *blocks* in C and Objective-C and to *lambdas* in other programming languages.

- [Closures](#closures)
  - [Introduction](#introduction)
  - [Closure Expressions](#closure-expressions)
    - [The Sorted Method](#the-sorted-method)
    - [Closure Expression Syntax](#closure-expression-syntax)

## Introduction

Closures can *capture* and *store* references to any constants and variables from the *context* in which they’re defined. This is known as *closing over* those constants and variables. Swift handles all of the memory management of capturing for you.

**Global and nested functions, actually special cases of closures**. Closures take one of three forms:

- *Global functions* are closures that have a name and don’t capture any values.
- *Nested functions* are closures that have a name and can capture values from their enclosing function.
- *Closure expressions* are *unnamed* closures written in a lightweight syntax that can capture values from their surrounding context.

Swift’s closure expressions have a clean, clear style, with optimizations that encourage brief, clutter-free syntax in common scenarios. These optimizations include:

- Inferring parameter and return value types from context
- Implicit returns from single-expression closures
- Shorthand argument names
- Trailing closure syntax

## Closure Expressions

*Closure expressions* are a way to write inline closures in a brief, focused syntax.

### The Sorted Method

Swift’s standard library provides a method called *sorted(by:)*, which sorts an array of values of a known type, based on the output of a sorting closure that you provide. Once it completes the sorting process, the *sorted(by:)* method returns a *new* array of the same type and size as the old one, with its elements in the correct sorted order. The original array *isn’t* modified by the *sorted(by:)* method.

The closure expression examples below use the `sorted(by:)` method to sort an array of String values in reverse alphabetical order. Here’s the initial array to be sorted:

```swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
```

The `sorted(by:)` method accepts a closure that takes two arguments of the same type as the array’s contents, and returns a `Bool` value to say whether the first value should appear before or after the second value once the values are sorted. **The sorting closure needs to return true if the first value should appear before the second value**, and false otherwise.

This example is sorting an array of `String` values, and so the sorting closure needs to be a function of type `(String, String) -> Bool`.

One way to provide the sorting closure is to write a normal function of the correct type, and to pass it in as an argument to the `sorted(by:)` method:

```swift
func backward(_ s1: String, _ s2: String) -> Bool {
    return s1 > s2
}
var reversedNames = names.sorted(by: backward)
// reversedNames is equal to ["Ewa", "Daniella", "Chris", "Barry", "Alex"]
```

If the first string (`s1`) is greater than the second string (`s2`), the `backward(_:_:)` function will return `true`, indicating that `s1` should appear before `s2` in the sorted array.

### Closure Expression Syntax

Closure expression syntax has the following general form:

<img src="../../media/Swift/swift.org/closureExpressionSyntax.jpg" width="40%"/>

- The *parameters* in closure expression syntax can be `in-out` parameters, but they can’t have a default value.
- *Variadic parameters*（可变参数）can be used if you name the variadic parameter.
- *Tuples* can also be used as parameter types and return types.

The example below shows a closure expression version of the `backward(_:_:)` function from above:

```swift
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})
```

The start of the closure’s body is introduced by the `in` keyword. This keyword indicates that the definition of the closure’s *parameters* and *return type* has finished, and the *body* of the closure is about to begin.

Because the body of the closure is so short, it can even be written on a single line:

```swift
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in return s1 > s2 } )
```


