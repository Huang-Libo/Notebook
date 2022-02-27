# Concurrency

> Version: *Swift 5.6*  
> Source: [*swift-book: Concurrency*](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)  
> Digest Date: *February 27, 2022*  

- [Concurrency](#concurrency)
  - [Introduction](#introduction)
  - [Defining and Calling Asynchronous Functions](#defining-and-calling-asynchronous-functions)
  - [Asynchronous Sequences](#asynchronous-sequences)

## Introduction

Swift has built-in support for writing asynchronous and parallel code in a structured way.

- *Asynchronous code* can be suspended and resumed later, although only one piece of the program executes at a time.
- *Suspending and resuming code* in your program lets it continue to make progress on short-term operations like updating its UI while continuing to work on long-running operations like fetching data over the network or parsing files.
- *Parallel code* means multiple pieces of code run simultaneously, for example, a computer with a four-core processor can run four pieces of code at the same time, with each core carrying out one of the tasks.

A program that uses parallel and asynchronous code carries out multiple operations at a time; it suspends operations that are waiting for an external system, and makes it easier to write this code in a memory-safe way.

The additional scheduling flexibility from parallel or asynchronous code also comes with a cost of increased complexity. Swift lets you express your intent in a way that enables some compile-time checking, for example, you can use *actors* to safely access mutable state.

- However, adding concurrency to slow or buggy code isn’t a guarantee that it will become fast or correct. In fact, adding concurrency might even make your code harder to debug.
- However, using Swift’s language-level support for concurrency in code that needs to be concurrent means Swift can help you catch problems at compile time.

The rest of this chapter uses the term concurrency to refer to this common combination of asynchronous and parallel code.

> **NOTE**: If you’ve written concurrent code before, you might be used to working with threads. The concurrency model in Swift is built on top of threads, but you don’t interact with them directly. An asynchronous function in Swift can give up the thread that it’s running on, which lets another asynchronous function run on that thread while the first function is blocked.

Although it’s possible to write concurrent code without using Swift’s language support, that code tends to be harder to read.

For example, the following code downloads a list of photo names, downloads the first photo in that list, and shows that photo to the user:

```swift
listPhotos(inGallery: "Summer Vacation") { photoNames in
    let sortedNames = photoNames.sorted()
    let name = sortedNames[0]
    downloadPhoto(named: name) { photo in
        show(photo)
    }
}
```

Even in this simple case, because the code has to be written as a series of completion handlers, you end up writing **nested closures**. In this style, more complex code with deep nesting can quickly become unwieldy.

## Defining and Calling Asynchronous Functions

An *asynchronous function* or *asynchronous method* is a special kind of function or method that can be suspended while it’s partway through execution. This is in contrast to ordinary, synchronous functions and methods, which either run to *completion*, throw an *error*, or never *return*.

An asynchronous function or method still does one of those *three* things, but it can also pause in the middle when it’s waiting for something. Inside the body of an asynchronous function or method, you mark each of these places where execution can be suspended.

- To indicate that a *function* or *method* is asynchronous, you write the `async` keyword in its declaration after its parameters, similar to how you use `throws` to mark a throwing function.
- If the function or method returns a value, you write `async` before the return arrow (`->`).

For example, here’s how you might fetch the names of photos in a gallery:

```swift
func listPhotos(inGallery name: String) async -> [String] {
    let result = // ... some asynchronous networking code ...
    return result
}
```

For a *function* or *method* that’s both asynchronous and throwing, you write `async` before `throws`.

When calling an asynchronous method, execution suspends until that method returns. You write `await` in front of the call to mark the possible suspension point. This is like writing `try` when calling a throwing function, to mark the possible change to the program’s flow if there’s an error.

Inside an asynchronous method, the flow of execution is suspended *only* when you call another asynchronous method, suspension is never implicit or preemptive, which means every possible suspension point is marked with `await`.

For example, the code below fetches the names of all the pictures in a gallery and then shows the first picture:

```swift
let photoNames = await listPhotos(inGallery: "Summer Vacation")
let sortedNames = photoNames.sorted()
let name = sortedNames[0]
let photo = await downloadPhoto(named: name)
show(photo)
```

Because the `listPhotos(inGallery:)` and `downloadPhoto(named:)` functions both need to make network requests, they could take a relatively long time to complete. Making them both asynchronous by writing `async` before the return arrow lets the rest of the app’s code keep running while this code waits for the picture to be ready.

To understand the concurrent nature of the example above, here’s one possible order of execution:

1. The code starts running from the first line and runs up to the first `await`. It calls the `listPhotos(inGallery:)` function and suspends execution while it waits for that function to return.
2. While this code’s execution is suspended, some other concurrent code in the same program runs. For example, maybe a long-running background task continues updating a list of new photo galleries. That code also runs until the next suspension point, marked by `await`, or until it completes.
3. After `listPhotos(inGallery:)` returns, this code continues execution starting at that point. It assigns the value that was returned to `photoNames`.
4. The lines that define `sortedNames` and `name` are regular, synchronous code. Because nothing is marked `await` on these lines, there aren’t any possible suspension points.
5. The next `await` marks the call to the `downloadPhoto(named:)` function. This code pauses execution again until that function returns, giving other concurrent code an opportunity to run.
6. After `downloadPhoto(named:)` returns, its return value is assigned to `photo` and then passed as an argument when calling `show(_:)`.

The possible suspension points in your code marked with `await` indicate that the current piece of code might pause execution while waiting for the asynchronous function or method to return. This is also called *yielding the thread* because, behind the scenes, Swift suspends the execution of your code on the current thread and runs some other code on that thread instead. Because code with `await` needs to be able to suspend execution, only certain places in your program can call asynchronous functions or methods:

- Code in the body of an asynchronous function, method, or property.
- Code in the static `main()` method of a structure, class, or enumeration that’s marked with `@main`.
- Code in an unstructured child task, as shown in [Unstructured Concurrency](#unstructured-concurrency) below.

**Note**:

The [Task.sleep(nanoseconds:)](https://developer.apple.com/documentation/swift/task/3862701-sleep) method is useful when writing simple code to learn how concurrency works. This method does nothing, but waits at least the given number of nanoseconds before it returns.

Here’s a version of the `listPhotos(inGallery:)` function that uses `sleep(nanoseconds:)` to simulate waiting for a network operation:

```swift
func listPhotos(inGallery name: String) async throws -> [String] {
    try await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // Two seconds
    return ["IMG001", "IMG99", "IMG0404"]
}
```

## Asynchronous Sequences


