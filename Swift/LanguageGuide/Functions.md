# Functions

> Version: *Swift 5.6*  
> Source: [*swift-book: Functions*](https://docs.swift.org/swift-book/LanguageGuide/Functions.html)  
> Digest Date: *March 2, 2022*  

*Functions* are self-contained chunks of code that perform a specific task.

- [Functions](#functions)
  - [Introduction](#introduction)
  - [Defining and Calling Functions](#defining-and-calling-functions)

## Introduction

Swift’s unified function syntax is flexible enough to express anything from a simple C-style function with no parameter names to a complex Objective-C-style method with *names* and *argument labels* for each parameter.

Parameters can provide default values to simplify function calls and can be passed as `in-out` parameters, which modify a passed variable once the function has completed its execution.

Every function in Swift has a type, consisting of the function’s *parameter types* and *return type*. You can use this type like any other type in Swift, which makes it easy to pass functions as parameters to other functions, and to return functions from functions.

Functions can also be written within other functions to encapsulate useful functionality within a *nested function* scope.

## Defining and Calling Functions


