# Error Handling

- [Error Handling](#error-handling)
  - [Introduction](#introduction)
  - [Verifying a failure hasn’t happened using assertNoFailure](#verifying-a-failure-hasnt-happened-using-assertnofailure)
  - [Using catch to handle errors in a one-shot pipeline](#using-catch-to-handle-errors-in-a-one-shot-pipeline)
  - [Retrying in the event of a temporary failure](#retrying-in-the-event-of-a-temporary-failure)
  - [Using flatMap and catch to handle errors without cancelling the pipeline](#using-flatmap-and-catch-to-handle-errors-without-cancelling-the-pipeline)
  - [Requesting data from an alternate URL when the network is constrained](#requesting-data-from-an-alternate-url-when-the-network-is-constrained)

## Introduction

Previous examples above expect that the *subscriber* would handle the error conditions, if they occurred. However, you are not always able to control what the *subscriber* requires - as might be the case if you are using SwiftUI. In these cases, you need to build your pipeline so that the output types match the subscriber types. This implies that you are handling any errors within the pipeline.

For example, if you are working with SwiftUI and the you want to use `assign` to set the `isEnabled` property on a button, the *subscriber* will have a few requirements:

- the subscriber should match the type output of `<Bool, Never>`
- the subscriber should be called on the *main thread*

With a publisher that can throw an error (such as `URLSession.dataTaskPublisher`), you need to construct a pipeline to convert the output type, but also handle the error within the pipeline to match a failure type of `<Never>`.

How you handle the errors within a pipeline is dependent on how the pipeline is defined.

- If the pipeline is set up to return a *single* result and terminate, a good example is [Using catch to handle errors in a one-shot pipeline](#using-catch-to-handle-errors-in-a-one-shot-pipeline).
- If the pipeline is set up to *continually* update, the error handling needs to be a little more complex. In this case, look at the example [Using flatMap with catch to handle errors](#using-flatmap-and-catch-to-handle-errors-without-cancelling-the-pipeline).

## Verifying a failure hasn’t happened using assertNoFailure

**Goal**:

- Verify no error has occurred within a pipeline

`assertNoFailure` *operator* also converts the failure type to `<Never>`. The operator will cause the application to terminate (or tests to crash to a debugger) if the assertion is triggered.

This is useful for verifying the invariant of having dealt with an error. If you are sure you handled the errors and need to map a pipeline which technically can generate a failure type of `<Error>` to a subscriber that requires a failure type of `<Never>`.

## Using catch to handle errors in a one-shot pipeline

**Goal**:

- If you need to handle a failure within a pipeline, for example before using the `assign` operator or another operator that requires the failure type to be `<Never>`, you can use catch to provide the appropriate logic.

`catch` handles errors by replacing the upstream publisher with another publisher that you provide as a return in a closure.

> **Warning**: Be aware that this effectively terminates the pipeline. If you’re using a one-shot publisher (one that doesn’t create more than a single event), then this is fine.

For example, `URLSession.dataTaskPublisher` is a one-shot publisher and you might use catch with it to ensure that you get a response, returning a placeholder in the event of an error. Extending our previous example to provide a default response:

```swift
struct IPInfo: Codable {
    // matching the data structure returned from ip.jsontest.com
    var ip: String
}
let myURL = URL(string: "http://ip.jsontest.com")
// NOTE(heckj): you'll need to enable insecure downloads in your Info.plist for this example, since the URL scheme is 'http'

let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: myURL!)
    // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
    .map({ (inputTuple) -> Data in
        return inputTuple.data
    })
    .decode(type: IPInfo.self, decoder: JSONDecoder()) 1️⃣
    .catch { err in 2️⃣
        return Publishers.Just(IPInfo(ip: "8.8.8.8")) 3️⃣
    }
    .eraseToAnyPublisher()
```

- 1️⃣ Often, a `catch` operator will be placed after several operators that could fail, in order to provide a fallback or placeholder in the event that any of the possible previous operations failed.
- 2️⃣ When using `catch`, you get the error type in and can inspect it to choose how you provide a response.
- 3️⃣ The `Just` publisher is frequently used to either start another *one-shot* pipeline or to directly provide a placeholder response in the event of failure.

A possible problem with this technique is that the if the original *publisher* generates more values to which you wish to react, the original pipeline has been ended. If you are creating a pipeline that reacts to a `@Published` property, then after any failed value that activates the `catch` operator, the pipeline will cease to react further. See [catch](https://heckj.github.io/swiftui-notes/#reference-catch) for more details of how this works.

If you want to continue to respond to errors and handle them, see the pattern Using flatMap with catch to handle errors.

## Retrying in the event of a temporary failure

**Goal**:

- The `retry` operator can be included in a pipeline to retry a *subscription* when a `.failure` completion occurs.

> When requesting data from a `dataTaskPublisher`, the request may fail. In that case you will receive a `.failure` completion with an error. When it fails, the `retry` operator will let you retry that same request for a set number of attempts. The retry operator passes through the resulting values when the publisher does not send a `.failure` completion. `retry` only reacts within a combine pipeline when a `.failure` completion is sent.

When `retry` receives a `.failure` completion, the way it retries is by recreating the subscription to the operator or publisher to which it was chained.

The `retry` operator is commonly desired when attempting to request network resources with an unstable connection, or other situations where the request might succeed if the request happens again. If the number of retries specified all fail, then the `.failure` completion is passed down to the subscriber.

In our example below, we are using `retry` in combination with a `delay` operator. Our use of the delay operator puts a small random delay before the next request. This spaces out the retry attempts, so that the retries do not happen in quick succession.

This example also includes the use of the `tryMap` operator to more fully inspect any `URLResponse` returned from the `dataTaskPublisher`. Any response from the server is encapsulated by `URLSession`, and passed forward as a valid response. `URLSession` does not treat a *404 Not Found* http response as an error response, nor any of the *50x* error codes. Using `tryMap` lets us inspect the response code that was sent, and verify that it was a `200` response code. In this example, if the response code is anything but a `200` response, it throws an exception - which in turn causes the `tryMap` operator to pass down a `.failure` completion rather than data. This example sets the `tryMap` **after** the retry operator so that `retry` will only re-attempt the request when the site didn’t respond.

```swift
let remoteDataPublisher = urlSession.dataTaskPublisher(for: self.URL!)
    .delay(for: DispatchQueue.SchedulerTimeType.Stride(integerLiteral: Int.random(in: 1..<5)), scheduler: backgroundQueue) 1️⃣
    .retry(3) 2️⃣
    .tryMap { data, response -> Data in 3️⃣
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
                throw TestFailureCondition.invalidServerResponse
        }
        return data
    }
    .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder())
    .subscribe(on: backgroundQueue)
    .eraseToAnyPublisher()
```

- 1️⃣ The `delay` operator will hold the results flowing through the pipeline for a short duration, in this case for a random selection of `1` to `5` seconds. By adding delay here in the pipeline, it will always occur, even if the original request is successful.
- 2️⃣ Retry is specified as trying `3` times. This will result in a total of `4` attempts if each fails - the original request and `3` additional attempts.
- 3️⃣ `tryMap` is being used to inspect the data result from `dataTaskPublisher` and return a `.failure` completion if the response from the server is valid, but not a `200` HTTP response code.

> When using the `retry` operator with `URLSession.dataTaskPublisher`, verify that the URL you are requesting isn’t going to have negative side effects if requested repeatedly or with a retry. Ideally such requests are be expected to be idempotent. If they are not, the `retry` operator may make multiple requests, with very unexpected side effects.

## Using flatMap and catch to handle errors without cancelling the pipeline

**Goal**:

- The `flatMap` operator can be used with `catch` to continue to handle errors on new published values.

> The `flatMap` operator is the operator to use in handling errors on a continual flow of events.

You provide a closure to `flatMap` that can read in the value that was provided, and creates a one-shot publisher that does the possibly failing work. An example of this is requesting data from a network and then decoding the returned data. You can include a `catch` operator to capture any errors and provide an appropriate value.

This is a perfect mechanism for when you want to maintain updates up an upstream publisher, as it creates one-shot publisher or short pipelines that send a single value and then complete for every incoming value. The completion from the created one-shot publishers terminates in the `flatMap` and is not passed to downstream subscribers.

An example of this with a dataTaskPublisher:

```swift
let remoteDataPublisher = Just(self.testURL!) 1️⃣
    .flatMap { url in 2️⃣
        URLSession.shared.dataTaskPublisher(for: url) 3️⃣
        .tryMap { data, response -> Data in 4️⃣
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    throw TestFailureCondition.invalidServerResponse
            }
            return data
        }
        .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder()) 5️⃣
        .catch {_ in 6️⃣
            return Just(PostmanEchoTimeStampCheckResponse(valid: false))
        }
    }
    .eraseToAnyPublisher()
```

- 1️⃣ Just starts this publisher as an example by passing in a URL.
- 2️⃣ `flatMap` takes the URL as input and the closure goes on to create a *one-shot* publisher pipeline.
- 3️⃣ `dataTaskPublisher` uses the input url to make the request.
- 4️⃣ The result output ( a tuple of `(Data, URLResponse)` ) flows into `tryMap` to be parsed for additional errors.
- 5️⃣ `decode` attempts to refine the returned data into a locally defined type.
- 6️⃣ If any of this has failed, catch will convert the error into a placeholder sample. In this case an object with a preset `valid = false` property.

## Requesting data from an alternate URL when the network is constrained

**Goal**:

- From Apple’s WWDC 2019 presentation [Advances in Networking, Part 1](https://developer.apple.com/videos/play/wwdc2019/712/), a sample pattern was provided using `tryCatch` and `tryMap` operators to react to the specific error of the network being constrained.

```swift
// Generalized Publisher for Adaptive URL Loading
func adaptiveLoader(regularURL: URL, lowDataURL: URL) -> AnyPublisher<Data, Error> {
    var request = URLRequest(url: regularURL) 
    request.allowsConstrainedNetworkAccess = false 
    return URLSession.shared.dataTaskPublisher(for: request) 
        .tryCatch { error -> URLSession.DataTaskPublisher in 
            guard error.networkUnavailableReason == .constrained else {
               throw error
            }
            return URLSession.shared.dataTaskPublisher(for: lowDataURL) 
        .tryMap { data, response -> Data in
            guard let httpResponse = response as? HTTPUrlResponse, 
                   httpResponse.statusCode == 200 else {
                       throw MyNetworkingError.invalidServerResponse
            }
            return data
}
.eraseToAnyPublisher()
```

This example, from Apple’s WWDC, provides a function that takes two URLs - a primary and a fallback. It returns a publisher that will request data and fall back requesting a secondary URL when the network is constrained.

- 1️⃣ The request starts with an attempt requesting data.
- 2️⃣ Setting `request.allowsConstrainedNetworkAccess` will cause the `dataTaskPublisher` to error if the network is constrained.
- 3️⃣ Invoke the `dataTaskPublisher` to make the request.
- 4️⃣ `tryCatch` is used to capture the immediate error condition and check for a specific error (the *constrained network*).
- 5️⃣ If it finds an error, it creates a new *one-shot* publisher with the fall-back URL.
- 6️⃣ The resulting publisher can still fail, and `tryMap` can map this a failure by throwing an error on HTTP response codes that map to error conditions
- 7️⃣ `eraseToAnyPublisher` enables type erasure on the chain of operators so the resulting signature of the adaptiveLoader function is `AnyPublisher<Data, Error>`

In the sample, if the error returned from the original request wasn’t an issue of the network being constrained, it passes on the `.failure` completion down the pipeline. If the error is that the network is constrained, then the `tryCatch` operator creates a new request to an alternate URL.
