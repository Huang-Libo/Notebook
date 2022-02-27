# Concurrency

> Version: *Swift 5.6*  
> Source: [*swift-book: Concurrency*](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)  
> Digest Date: *February 27, 2022*  

- [Concurrency](#concurrency)
  - [Introduction](#introduction)
  - [Defining and Calling Asynchronous Functions](#defining-and-calling-asynchronous-functions)
  - [Asynchronous Sequences](#asynchronous-sequences)
  - [Calling Asynchronous Functions in Parallel](#calling-asynchronous-functions-in-parallel)
  - [Tasks and Task Groups](#tasks-and-task-groups)
    - [Unstructured Concurrency](#unstructured-concurrency)
    - [Task Cancellation](#task-cancellation)
  - [Actors](#actors)

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

The `listPhotos(inGallery:)` function in the previous section asynchronously returns the whole array at once, after all of the array’s elements are ready. Another approach is to wait for one element of the collection at a time using an *asynchronous sequence*. Here’s what iterating over an asynchronous sequence looks like:

```swift
import Foundation

let handle = FileHandle.standardInput
for try await line in handle.bytes.lines {
    print(line)
}
```

Instead of using an ordinary `for-in` loop, the example above writes `for` with `await` after it. Like when you call an asynchronous function or method, writing `await` indicates a possible suspension point. **A `for-await-in` loop potentially suspends execution at the beginning of each iteration, when it’s waiting for the next element to be available.**

In the same way that you can use your own types in a `for-in` loop by adding conformance to the [Sequence](https://developer.apple.com/documentation/swift/sequence) protocol, you can use your own types in a `for-await-in` loop by adding conformance to the [AsyncSequence](https://developer.apple.com/documentation/swift/asyncsequence) protocol.

## Calling Asynchronous Functions in Parallel

Calling an asynchronous function with `await` runs only one piece of code at a time. While the asynchronous code is running, the caller waits for that code to finish before moving on to run the next line of code.

For example, to fetch the first three photos from a gallery, you could await three calls to the `downloadPhoto(named:)` function as follows:

```swift
let firstPhoto = await downloadPhoto(named: photoNames[0])
let secondPhoto = await downloadPhoto(named: photoNames[1])
let thirdPhoto = await downloadPhoto(named: photoNames[2])

let photos = [firstPhoto, secondPhoto, thirdPhoto]
show(photos)
```

This approach has an important drawback: Although the download is asynchronous and lets other work happen while it progresses, only one call to `downloadPhoto(named:)` runs at a time. Each photo downloads completely before the next one starts downloading. However, there’s no need for these operations to wait, each photo can download independently, or even at the same time.

To call an asynchronous function and let it run in parallel with code around it, write `async` in front of `let` when you define a constant, and then write `await` each time you use the constant.

```swift
async let firstPhoto = downloadPhoto(named: photoNames[0])
async let secondPhoto = downloadPhoto(named: photoNames[1])
async let thirdPhoto = downloadPhoto(named: photoNames[2])

let photos = await [firstPhoto, secondPhoto, thirdPhoto]
show(photos)
```

None of these function calls are marked with `await` because the code doesn’t suspend to wait for the function’s result. Instead, execution continues until the line where `photos` is defined, at that point, the program needs the results from these asynchronous calls, so you write `await` to pause execution until all three photos finish downloading.

Here’s how you can think about the differences between these two approaches:

- Call asynchronous functions with `await` when the code on the following lines depends on that function’s result. This creates work that is carried out sequentially.
- Call asynchronous functions with `async-let` when you don’t need the result until later in your code. This creates work that can be carried out in parallel.
- Both `await` and `async-let` allow other code to run while they’re suspended.
- In both cases, you mark the possible suspension point with `await` to indicate that execution will pause, if needed, until an asynchronous function has returned.

You can also mix both of these approaches in the same code.

## Tasks and Task Groups

A *task* is a unit of work that can be run asynchronously as part of your program. All asynchronous code runs as part of some task. The `async-let` syntax described in the previous section creates a child task for you. You can also create a task group and add child tasks to that group, which gives you more control over priority and cancellation, and lets you create a dynamic number of tasks.

Tasks are arranged in a hierarchy. Each task in a task group has the same parent task, and each task can have child tasks. Because of the explicit relationship between tasks and task groups, this approach is called *structured concurrency*. Although you take on some of the responsibility for correctness, the explicit parent-child relationships between tasks lets Swift handle some behaviors like propagating cancellation for you, and lets Swift detect some errors at compile time.

```swift
await withTaskGroup(of: Data.self) { taskGroup in
    let photoNames = await listPhotos(inGallery: "Summer Vacation")
    for name in photoNames {
        taskGroup.addTask { await downloadPhoto(named: name) }
    }
}
```

For more information about task groups, see [TaskGroup](https://developer.apple.com/documentation/swift/taskgroup).

### Unstructured Concurrency

In addition to the structured approaches to concurrency described in the previous sections, Swift also supports *unstructured concurrency*.

Unlike tasks that are part of a task group, an *unstructured task* doesn’t have a parent task. You have complete flexibility to manage unstructured tasks in whatever way your program needs, but you’re also completely responsible for their correctness.

- To create an *unstructured task* that runs on the current actor, call the [Task.init(priority:operation:)](https://developer.apple.com/documentation/swift/task/3856790-init) initializer.
- To create an *unstructured task* that’s not part of the current actor, known more specifically as a *detached task*, call the [Task.detached(priority:operation:)](https://developer.apple.com/documentation/swift/task/3856786-detached) class method.

Both of these operations return a task handle that lets you interact with the task, for example, to wait for its result or to cancel it.

```swift
let newPhoto = // ... some photo data ...
let handle = Task {
    return await add(newPhoto, toGalleryNamed: "Spring Adventures")
}
let result = await handle.value
```

For more information about managing *detached tasks*, see [Task](https://developer.apple.com/documentation/swift/task).

### Task Cancellation

Swift concurrency uses a cooperative cancellation model. Each task checks whether it has been canceled at the appropriate points in its execution, and responds to cancellation in whatever way is appropriate. Depending on the work you’re doing, that usually means one of the following:

- Throwing an error like `CancellationError`
- Returning `nil` or an empty collection
- Returning the partially completed work

To check for cancellation,

- either call [Task.checkCancellation()](https://developer.apple.com/documentation/swift/task/3814826-checkcancellation), which throws `CancellationError` if the task has been canceled,
- or check the value of `Task.isCancelled` and handle the cancellation in your own code.

For example, a task that’s downloading photos from a gallery might need to delete partial downloads and close network connections.

To propagate cancellation manually, call [Task.cancel()](https://developer.apple.com/documentation/swift/task/3851218-cancel).

## Actors

Like classes, **actors are reference types**, so the comparison of *value types* and *reference types* in [Classes Are Reference Types](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html#ID89) applies to actors as well as classes.

Unlike classes, actors allow only one task to access their mutable state at a time, which makes it safe for code in multiple tasks to interact with the same instance of an actor.

For example, here’s an actor that records temperatures:

```swift
actor TemperatureLogger {
    let label: String
    var measurements: [Int]
    private(set) var max: Int

    init(label: String, measurement: Int) {
        self.label = label
        self.measurements = [measurement]
        self.max = measurement
    }
}
```

You introduce an actor with the `actor` keyword, followed by its definition in a pair of braces. The `TemperatureLogger` actor has properties that other code outside the actor can access, and restricts the `max` property so only code inside the actor can update the maximum value.

You create an instance of an actor using the same initializer syntax as structures and classes. When you access a *property* or *method* of an actor, you use `await` to mark the potential suspension point, for example:

```swift
let logger = TemperatureLogger(label: "Outdoors", measurement: 25)
print(await logger.max)
// Prints "25"
```

In this example, accessing `logger.max` is a possible suspension point. Because the actor allows only one task at a time to access its mutable state, if code from another task is already interacting with the logger, this code suspends while it waits to access the property.

In contrast, code that’s part of the actor doesn’t write `await` when accessing the actor’s properties. For example, here’s a method that updates a `TemperatureLogger` with a new temperature:

```swift
extension TemperatureLogger {
    func update(with measurement: Int) {
        measurements.append(measurement)
        if measurement > max {
            max = measurement
        }
    }
}
```

If you try to access those properties from outside the actor, like you would with an instance of a class, you’ll get a compile-time error; for example:

```swift
print(logger.max)  // Error
```

Accessing `logger.max` without writing `await` fails because the properties of an actor are part of that actor’s isolated local state. **Swift guarantees that only code inside an actor can access the actor’s local state.** This guarantee is known as *actor isolation*.
