# Error Handling

> Version: *Swift 5.6*  
> Source: [*swift-book: Error Handling*](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html)  
> Digest Date: *February 27, 2022*  

*Error handling* is the process of responding to and recovering from error conditions in your program. Swift provides first-class support for *throwing*, *catching*, *propagating*, and *manipulating* recoverable errors at runtime.

Some operations aren’t guaranteed to always complete execution or produce a useful output. Optionals are used to represent the absence of a value, but when an operation fails, it’s often useful to understand what caused the failure, so that your code can respond accordingly.

As an example, consider the task of reading and processing data from a file on disk. There are a number of ways this task can fail, including

- the file not existing at the specified path,
- the file not having read permissions,
- or the file not being encoded in a compatible format.

Distinguishing among these different situations allows a program to resolve some errors and to communicate to the user any errors it can’t resolve.

> **NOTE**: Error handling in Swift interoperates with error handling patterns that use the `NSError` class in Cocoa and Objective-C. For more information about this class, see [Handling Cocoa Errors in Swift](https://developer.apple.com/documentation/swift/cocoa_design_patterns/handling_cocoa_errors_in_swift).

- [Error Handling](#error-handling)
  - [Representing and Throwing Errors](#representing-and-throwing-errors)
  - [Handling Errors](#handling-errors)

## Representing and Throwing Errors

In Swift, errors are represented by values of types that conform to the `Error` protocol. This empty protocol indicates that a type can be used for error handling.

Swift enumerations are particularly well suited to modeling a group of related error conditions, with associated values allowing for additional information about the nature of an error to be communicated.

For example, here’s how you might represent the error conditions of operating a vending machine inside a game:

```swift
enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}
```

Throwing an error lets you indicate that something unexpected happened and the normal flow of execution can’t continue. You use a `throw` statement to throw an error.

For example, the following code throws an error to indicate that five additional coins are needed by the vending machine:

```swift
throw VendingMachineError.insufficientFunds(coinsNeeded: 5)
```

## Handling Errors


