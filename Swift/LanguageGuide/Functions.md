# Functions

> Version: *Swift 5.6*  
> Source: [*swift-book: Functions*](https://docs.swift.org/swift-book/LanguageGuide/Functions.html)  
> Digest Date: *March 2, 2022*  

- [Functions](#functions)
  - [Introduction](#introduction)
  - [Defining and Calling Functions](#defining-and-calling-functions)
  - [Function Parameters and Return Values](#function-parameters-and-return-values)
    - [Functions Without Parameters](#functions-without-parameters)
    - [Functions With Multiple Parameters](#functions-with-multiple-parameters)
    - [Functions Without Return Values](#functions-without-return-values)
    - [Functions with Multiple Return Values](#functions-with-multiple-return-values)
    - [Optional Tuple Return Types](#optional-tuple-return-types)
    - [Functions With an Implicit Return](#functions-with-an-implicit-return)
  - [Function Argument Labels and Parameter Names](#function-argument-labels-and-parameter-names)

## Introduction

*Functions* are self-contained chunks of code that perform a specific task.

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

Function parameters and return values are extremely flexible in Swift. You can define anything from a simple utility function with a single unnamed parameter to a complex function with expressive parameter names and different parameter options.

### Functions Without Parameters

Here’s a function with no input parameters, which always returns the same `String` message whenever it’s called:

```swift
func sayHelloWorld() -> String {
    return "hello, world"
}
print(sayHelloWorld())
// Prints "hello, world"
```

### Functions With Multiple Parameters

Functions can have multiple input parameters, which are written within the function’s parentheses, separated by commas.

This function takes a person’s name and whether they have already been greeted as input, and returns an appropriate greeting for that person:

```swift
func greet(person: String, alreadyGreeted: Bool) -> String {
    if alreadyGreeted {
        return greetAgain(person: person)
    } else {
        return greet(person: person)
    }
}
print(greet(person: "Tim", alreadyGreeted: true))
// Prints "Hello again, Tim!"
```

Note that this function is distinct from the `greet(person:)` function shown in an earlier section. Although both functions have names that begin with greet, the `greet(person:alreadyGreeted:)` function takes two arguments but the `greet(person:)` function takes only one.

### Functions Without Return Values

Functions aren’t required to define a return type. Here’s a version of the `greet(person:)` function, which prints its own `String` value rather than returning it:

```swift
func greet(person: String) {
    print("Hello, \(person)!")
}
greet(person: "Dave")
// Prints "Hello, Dave!"
```

> **NOTE**: Strictly speaking, this version of the `greet(person:)` function does still return a value, even though no return value is defined. Functions without a defined return type return a special value of type `Void`. This is simply an empty tuple, which is written as `()`.

The return value of a function can be ignored when it’s called:

```swift
func printAndCount(string: String) -> Int {
    print(string)
    return string.count
}
func printWithoutCounting(string: String) {
    let _ = printAndCount(string: string)
}
printAndCount(string: "hello, world")
// prints "hello, world" and returns a value of 12
printWithoutCounting(string: "hello, world")
// prints "hello, world" but doesn't return a value
```

The second function, `printWithoutCounting(string:)`, calls the first function, but ignores its return value. When the second function is called, the message is still printed by the first function, but the returned value isn’t used.

### Functions with Multiple Return Values

You can use a *tuple type* as the return type for a function to return multiple values as part of one compound return value.

The example below defines a function called `minMax(array:)`, which finds the smallest and largest numbers in an array of `Int` values:

```swift
func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}
```

Because the tuple’s member values are named as part of the function’s return type, they can be accessed with dot syntax to retrieve the minimum and maximum found values:

```swift
let bounds = minMax(array: [8, -6, 2, 109, 3, 71])
print("min is \(bounds.min) and max is \(bounds.max)")
// Prints "min is -6 and max is 109"
```

Note that the tuple’s members don’t need to be named at the point that the tuple is returned from the function, because their names are already specified as part of the function’s return type.

### Optional Tuple Return Types

If the tuple type to be returned from a function has the potential to have “no value” for the entire tuple, you can use an *optional* tuple return type to reflect the fact that the entire tuple can be `nil`. You write an optional tuple return type by placing a *question mark* after the tuple type’s closing parenthesis, such as `(Int, Int)?` or `(String, Int, Bool)?`.

> **NOTE**: An optional tuple type such as `(Int, Int)?` is different from a tuple that contains optional types such as `(Int?, Int?)`. With an optional tuple type, the entire tuple is optional, not just each individual value within the tuple.

To handle an empty array safely, write the `minMax(array:)` function with an *optional* tuple return type and return a value of `nil` when the array is empty:

```swift
func minMax(array: [Int]) -> (min: Int, max: Int)? {
    if array.isEmpty { return nil }
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}
```

You can use optional binding to check whether this version of the `minMax(array:)` function returns an actual tuple value or `nil`:

```swift
if let bounds = minMax(array: [8, -6, 2, 109, 3, 71]) {
    print("min is \(bounds.min) and max is \(bounds.max)")
}
// Prints "min is -6 and max is 109"
```

### Functions With an Implicit Return

If the entire body of the function is a single expression, the function implicitly returns that expression. For example, both functions below have the same behavior:

```swift
func greeting(for person: String) -> String {
    "Hello, " + person + "!"
}
print(greeting(for: "Dave"))
// Prints "Hello, Dave!"

func anotherGreeting(for person: String) -> String {
    return "Hello, " + person + "!"
}
print(anotherGreeting(for: "Dave"))
// Prints "Hello, Dave!"
```

- The entire definition of the `greeting(for:)` function is the greeting message that it returns, which means it can use this shorter form.
- The `anotherGreeting(for:)` function returns the same greeting message, using the `return` keyword like a longer function.

Any function that you write as just one return line can omit the `return`.

As you’ll see in [Shorthand Getter Declaration](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID608), property getters can also use an implicit return.

> **NOTE**: The code you write as an implicit return value needs to return some value. For example, you can’t use `print(13)` as an implicit return value. However, you can use a function that never returns like `fatalError("Oh no!")` as an implicit return value, because Swift knows that the implicit return doesn’t happen.

## Function Argument Labels and Parameter Names


