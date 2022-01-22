# Closures

> Version: *Swift 5.5*  
> Source: [*swift-book: Closures*](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)  
> Digest Date: *January 16, 2022*  

*Closures* in Swift are similar to *blocks* in C and Objective-C and to *lambdas* in other programming languages.

- [Closures](#closures)
  - [Introduction](#introduction)
  - [Closure Expressions](#closure-expressions)

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


