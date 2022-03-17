# Patterns and Recipes

- [Patterns and Recipes](#patterns-and-recipes)
  - [Creating a subscriber with sink](#creating-a-subscriber-with-sink)
  - [Creating a subscriber with assign](#creating-a-subscriber-with-assign)

## Creating a subscriber with sink

**Goal**: To receive the output, and the errors or completion messages, generated from a publisher or through a pipeline, you can create a subscriber with `sink`.

**simple sink**:

```swift
let cancellablePipeline = publishingSource.sink { someValue in 1️⃣
    // do what you want with the resulting value passed down
    // be aware that depending on the publisher, this closure
    // may be invoked multiple times.
    print(".sink() received \(someValue)")
})
```

- 1️⃣ The simple version of a sink is very compact, with a single trailing closure receiving data when presented through the pipeline.

**sink with completions and data**:

```swift
let cancellablePipeline = publishingSource.sink(receiveCompletion: { completion in 1️⃣
    switch completion {
    case .finished:
        // no associated data, but you can react to knowing the
        // request has been completed
        break
    case .failure(let anError):
        // do what you want with the error details, presenting,
        // logging, or hiding as appropriate
        print("received the error: ", anError)
        break
    }
}, receiveValue: { someValue in
    // do what you want with the resulting value passed down
    // be aware that depending on the publisher, this closure
    // may be invoked multiple times.
    print(".sink() received \(someValue)")
})

cancellablePipeline.cancel() 2️⃣
```

- 1️⃣ Sinks are created by chaining the code from a publisher or pipeline, and provide an *end point* for the pipeline. When the sink is created or invoked on a publisher, it implicitly starts the lifecycle with the `subscribe` method, requesting unlimited data.
- 2️⃣ Sinks are *cancellable* subscribers. At any time you can take the reference that terminated with sink and invoke `.cancel()` on it to invalidate and shut down the pipeline.

## Creating a subscriber with assign

**Goal**: To use the results of a pipeline to set a value, often a property on a user interface view or control, but any KVO compliant object can be the provider.

`assign` is a subscriber that’s specifically designed to apply data from a publisher or pipeline into a property, updating that property whenever it receives data. Like `sink`, it activates when created and requests an unlimited data.

`assign` requires the failure type to be specified as `<Never>`, so if your pipeline could fail (such as using an *operator* like `tryMap`) you will need to [convert or handle the failure cases](https://heckj.github.io/swiftui-notes/#patterns-general-error-handling) before using `.assign`.

```swift
let cancellablePipeline = publishingSource 
    .receive(on: RunLoop.main) 
    .assign(to: \.isEnabled, on: yourButton) 

cancellablePipeline.cancel() 
```

- 1️⃣ `.assign` is typically chained onto a publisher when you create it, and the return value is *cancellable*.
- 2️⃣ If `.assign` is being used to update a *user interface* element, you need to make sure that it is being updated on the *main thread*. This call makes sure the subscriber is received on the main thread.
- 3️⃣ `assign` references the property being updated using a [key path](https://developer.apple.com/documentation/swift/referencewritablekeypath), and a reference to the object being updated.
- 4️⃣ At any time you can cancel to terminate and invalidate pipelines with `cancel()`. Frequently, you cancel the pipelines when you deactivate the objects (such as a viewController) that are getting updated from the pipeline.
