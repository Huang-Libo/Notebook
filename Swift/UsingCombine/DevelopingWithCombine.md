# Developing with Combine

- [Developing with Combine](#developing-with-combine)
  - [Reasoning about pipelines](#reasoning-about-pipelines)
  - [Swift types with Combine publishers and subscribers](#swift-types-with-combine-publishers-and-subscribers)
  - [Pipelines and threads](#pipelines-and-threads)

## Reasoning about pipelines

When developing with Combine, there are two broader patterns of publishers that frequently recur:

1. expecting a publisher to return a *single* value and complete
2. expecting a publisher to return *many* values over time.

The *first* is what I’m calling a "*one-shot*" publisher or pipeline. These publishers are expected to create a single response (or perhaps no response) and then terminate normally.

The *second* is what I’m calling a "*continuous*" publisher. These publishers and associated pipelines are expected to be always active and providing the means to respond to ongoing events. In this case, the lifetime of the pipeline is significantly longer, and it is often not desirable to have such pipelines fail or terminate.

When you are thinking about your development and how to use Combine, it is often beneficial to think about pipelines as being one of these types, and mixing them together to achieve your goals.

- For example, the pattern [Using flatMap with catch to handle errors](https://heckj.github.io/swiftui-notes/#patterns-continual-error-handling) explicitly uses one-shot pipelines to support error handling on a continual pipeline.

When you are creating an instance of a publisher or a pipeline, it is worthwhile to be thinking about how you want it to work - to either be a *one-shot*, or *continuous*. This choice will inform how you handle errors or if you want to deal with operators that manipulate the timing of the events (such as `debounce` or `throttle`).

In addition to how much data the pipeline or publisher will provide, you will often want to think about what type pair the pipeline is expected to provide. A number of pipelines are more about transforming data through various types, and handling possible error conditions in that processing.

- An example of this is returning a pipeline returning a list in the example [Declarative UI updates from user input](https://heckj.github.io/swiftui-notes/#patterns-update-interface-userinput) to provide a means to represent an "empty" result, even though the list is never expected to have more than `1` item within it.

Ultimately, using Combine types are grounded at both ends; by the originating publisher, and how it is providing data (when it is available), and the subscriber ultimately consuming the data.

## Swift types with Combine publishers and subscribers

When you compose pipelines within Swift, the chaining of functions results in the type being aggregated as nested generic types. If you are creating a pipeline, and then wanting to provide that as an API to another part of your code, the type definition for the exposed property or function can be exceptionally (and un-usefully) complex for the developer.

To illustrate the exposed type complexity, if you created a publisher from a `PassthroughSubject` such as:

```swift
let x = PassthroughSubject<String, Never>()
    .flatMap { name in
        return Future<String, Error> { promise in
            promise(.success(""))
            }.catch { _ in
                Just("No user found")
            }.map { result in
                return "\(result) foo"
        }
}
```

The resulting type is:

```swift
Publishers.FlatMap<Publishers.Map<Publishers.Catch<Future<String, Error>, Just<String>>, String>, PassthroughSubject<String, Never>>
```

When you want to expose the subject, all of that composition detail can be very distracting and make your code harder to use.

To clean up that interface, and provide a nice API boundary, there are *type-erased* classes which can wrap either publishers or subscribers. These explicitly hide the type complexity that builds up from chained functions in Swift.

The two classes used to expose simplified types for *subscribers* and *publishers* are:

- `AnyPublisher`
- `AnySubscriber`

Every publisher also inherits a convenience method `eraseToAnyPublisher()` that returns an instance of `AnyPublisher`. `eraseToAnyPublisher()` is used very much like an operator, often as the last element in a chained pipeline, to simplify the type returned.

If you updated the above code to add .`eraseToAnyPublisher()` at the end of the pipeline:

```swift
let x = PassthroughSubject<String, Never>()
    .flatMap { name in
        return Future<String, Error> { promise in
            promise(.success(""))
            }.catch { _ in
                Just("No user found")
            }.map { result in
                return "\(result) foo"
        }
}.eraseToAnyPublisher()
```

The resulting type would simplify to:

```swift
AnyPublisher<String, Never>
```

This same technique can be immensely useful when constructing smaller pipelines within closures. For example, when you want to return a publisher in the closure for a `flatMap` operator, you get simpler reasoning about types by explicitly asserting the closure should expect `AnyPublisher`. An example of this can be seen in the pattern [Sequencing operations with Combine](https://heckj.github.io/swiftui-notes/#patterns-sequencing-operations).

## Pipelines and threads







