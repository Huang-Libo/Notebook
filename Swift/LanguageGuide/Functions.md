# Functions

> Version: *Swift 5.6*  
> Source: [*swift-book: Functions*](https://docs.swift.org/swift-book/LanguageGuide/Functions.html)  
> Digest Date: *March 2, 2022*  

*Functions* are self-contained chunks of code that perform a specific task.

- [Functions](#functions)
  - [Introduction](#introduction)
  - [Defining and Calling Functions](#defining-and-calling-functions)
  - [Function Parameters and Return Values](#function-parameters-and-return-values)

## Introduction

Swift’s unified function syntax is flexible enough to express anything from a simple C-style function with no parameter names to a complex Objective-C-style method with *names* and *argument labels* for each parameter.

Parameters can provide default values to simplify function calls and can be passed as `in-out` parameters, which modify a passed variable once the function has completed its execution.

Every function in Swift has a type, consisting of the function’s *parameter types* and *return type*. You can use this type like any other type in Swift, which makes it easy to pass functions as parameters to other functions, and to return functions from functions.

Functions can also be written within other functions to encapsulate useful functionality within a *nested function* scope.

## Defining and Calling Functions

The function in the example below is called `greet(person:)`:

```swift
func greet(person: String) -> String {
    let greeting = "Hello, " + person + "!"
    return greeting
}

print(greet(person: "Anna"))
// Prints "Hello, Anna!"
print(greet(person: "Brian"))
// Prints "Hello, Brian!"
```

You call the `greet(person:)` function by passing it a `String` value after the `person` *argument label*, such as greet(person: "Anna"). Because the function returns a `String` value, `greet(person:)` can be wrapped in a call to the `print(_:separator:terminator:)` function to print that string and see its return value, as shown above.

> **NOTE**: The `print(_:separator:terminator:)` function doesn’t have a label for its first argument, and its other arguments are optional because they have a default value. These variations on function syntax are discussed below in [Function Argument Labels and Parameter Names](#function-argument-labels-and-parameter-names) and [Default Parameter Values](#default-parameter-values).

To make the body of this function shorter, you can combine the message creation and the return statement into one line:

```swift
func greetAgain(person: String) -> String {
    return "Hello again, " + person + "!"
}
print(greetAgain(person: "Anna"))
// Prints "Hello again, Anna!"
```

## Function Parameters and Return Values


