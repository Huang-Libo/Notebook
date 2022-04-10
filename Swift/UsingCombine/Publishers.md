# Publishers

For general information about publishers see [Publishers](https://heckj.github.io/swiftui-notes/#coreconcepts-publishers) and [Lifecycle of Publishers and Subscribers](https://heckj.github.io/swiftui-notes/#coreconcepts-lifecycle).

- [Publishers](#publishers)
  - [`enum Publishers`](#enum-publishers)
  - [Just](#just)
  - [Future](#future)
  - [Empty](#empty)
  - [Fail](#fail)
  - [Publishers.Sequence](#publisherssequence)

## `enum Publishers`

>  docs: [Publishers](https://developer.apple.com/documentation/combine/publishers)

A namespace for types that serve as publishers.

 **Declaration**:

```swift
enum Publishers
```

**Overview**:

The various operators defined as extensions on `Publisher` implement their functionality as *classes* or *structures* that extend this enumeration. For example, the `contains(_:)` operator returns a `Publishers.Contains` instance.

## Just

A publisher that emits an output to each subscriber just *once*, and then finishes.

 **Declaration**:

```swift
struct Just<Output>
```

**Overview**:

You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Publishers.Catch`.

- In contrast with `Result.Publisher`, a `Just` publisher can’t fail with an error.
- And unlike `Optional.Publisher`, a `Just` publisher always produces a value.

`Just` has a failure type of `<Never>`, often used within a closure to `flatMap` in error handling, it creates a single-response pipeline for use in error handling of continuous values.

## Future

A publisher that eventually produces a single value and then *finishes* or *fails*.

 **Declaration**:

```swift
final class Future<Output, Failure> where Failure : Error
```

**Overview**:

> Future is a publisher that lets you combine in any asynchronous call and use that call to generate a value or a completion as a publisher. It is ideal for when you want to make a single request, or get a single response, where the API you are using has a completion handler closure.

The obvious example that everyone immediately thinks about is `URLSession`. Fortunately, `URLSession.dataTaskPublisher` exists to make a call with a `URLSession` and return a *publisher*.

If you *already* have an API object that wraps the direct calls to `URLSession`, then making a single request using `Future` can be a great way to integrate the result into a Combine pipeline.

There are a number of APIs in the Apple frameworks that use a completion closure. An example of one is requesting permission to access the *contacts* store in `Contacts`.

An example of wrapping that request for access into a publisher using `Future` might be:

```swift
import Contacts

let futureAsyncPublisher = Future<Bool, Error> { promise in 1️⃣
    CNContactStore().requestAccess(for: .contacts) { grantedAccess, err in 2️⃣
        // err is an optional
        if let err = err { 3️⃣
            promise(.failure(err))
        }
        return promise(.success(grantedAccess)) 4️⃣
    }
}
```

- 1️⃣ `Future` itself has you define the return types and takes a closure. It hands in a `Result` object matching the type description, which you interact.
- 2️⃣ You can invoke the async API however is relevant, including passing in its required closure.
- 3️⃣ Within the completion handler, you determine what would cause a failure or a success. A call to `promise(.failure(<FailureType>))` returns the failure.
- 4️⃣ Or a call to `promise(.success(<OutputType>))` returns a value.

If you want to wrap an async API that could return many values over time, you should not use `Future` directly, as it only returns a single value. Instead, you should consider creating your own publisher based on `passthroughSubject` or `currentValueSubject`, or wrapping the `Future` publisher with `Deferred`.

> `Future` creates and invokes its closure to do the asynchronous request **at the time of creation**, not when the publisher receives a demand request. This can be counter-intuitive, as many other publishers invoke their closures when they receive demand. This also means that you can’t directly link a `Future` publisher to an operator like `retry`.
>  
> The `retry` operator works by making another subscription to the publisher, and `Future` doesn’t currently re-invoke the closure you provide upon additional request demands. This means that chaining a `retry` operator after Future will not result in Future’s closure being invoked repeatedly when a `.failure` completion is returned.
>  
> The failure of the `retry` and `Future` to work together directly has been submitted to Apple as feedback: **FB7455914**.
>  
> The `Future` publisher can be wrapped with `Deferred` to have it work based on demand, rather than as a one-shot at the time of creation of the publisher. You can see unit tests illustrating `Future` wrapped with `Deferred` in the tests at [UsingCombineTests/FuturePublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/FuturePublisherTests.swift).

If you are wanting repeated requests to a `Future` (for example, wanting to use a `retry` operator to retry failed requests), wrap the `Future` publisher with `Deferred`.

```swift
let deferredPublisher = Deferred { 1️⃣
    return Future<Bool, Error> { promise in 2️⃣
        self.asyncAPICall(sabotage: false) { (grantedAccess, err) in
            if let err = err {
                return promise(.failure(err))
            }
            return promise(.success(grantedAccess))
        }
    }
}.eraseToAnyPublisher()
```

- 1️⃣ The closure provided in to `Deferred` will be invoked as demand requests come to the publisher.
- 2️⃣ This in turn resolves the underlying api call to generate the result as a `Promise`, with internal closures to resolve the promise.

## Empty

A publisher that never publishes any values, and optionally finishes immediately.

**Declaration**:

```swift
struct Empty<Output, Failure> where Failure : Error
```

**Overview**:

You can create a ”Never” publisher — one which never sends values and never finishes or fails — with the initializer `Empty(completeImmediately: false)`.

> `Empty` is useful in error handling scenarios where the value is an *optional*, or where you want to resolve an *error* by simply not sending anything. `Empty` can be invoked to be a publisher of any output and failure type combination.

`Empty` is most commonly used where you need to return a publisher, but don’t want to propagate any values (a possible error handling scenario). If you want a publisher that provides a single value, then look at `Just` or `Deferred` publishers as alternatives.

When subscribed to, an instance of the `Empty` publisher will not return any values (or errors) and will immediately return a finished completion message to the subscriber.

An example of using `Empty`:

```swift
let myEmptyPublisher = Empty<String, Never>() 
```

Because the types are not be able to be inferred, expect to define the types you want to return.

## Fail

A publisher that immediately terminates with the specified error.

**Declaration**:

```swift
struct Fail<Output, Failure> where Failure : Error
```

**Overview**:

> `Fail` is commonly used when implementing an API that returns a publisher. In the case where you want to return an immediate failure, `Fail` provides a publisher that immediately triggers a failure on subscription. One way this might be used is to provide a failure response when invalid parameters are passed. The `Fail` publisher lets you generate a publisher of the correct type that provides a failure completion when demand is requested.

Initializing a `Fail` publisher can be done two ways: with the type notation specifying the output and failure types or with the types implied by handing parameters to the initializer.

For example:

Initializing `Fail` by specifying the types:

```swift
let cancellable = Fail<String, Error>(error: TestFailureCondition.exampleFailure)
```

Initializing `Fail` by providing types as parameters:

```swift
let cancellable = Fail(outputType: String.self, failure: TestFailureCondition.exampleFailure)
```

## Publishers.Sequence


