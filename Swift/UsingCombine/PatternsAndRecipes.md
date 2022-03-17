# Patterns and Recipes

- [Patterns and Recipes](#patterns-and-recipes)
  - [Creating a subscriber with sink](#creating-a-subscriber-with-sink)
  - [Creating a subscriber with assign](#creating-a-subscriber-with-assign)
  - [Making a network request with dataTaskPublisher](#making-a-network-request-with-datataskpublisher)
  - [Stricter request processing with dataTaskPublisher](#stricter-request-processing-with-datataskpublisher)

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

## Making a network request with dataTaskPublisher

**Goal**: One common use case is requesting JSON data from a URL and decoding it.

This can be readily accomplished with Combine using `URLSession.dataTaskPublisher` followed by a series of operators that process the data. Minimally, `dataTaskPublisher` on `URLSession` uses `map` and `decode` before going to the subscriber.

The simplest case of using this might be:

```swift
let myURL = URL(string: "https://postman-echo.com/time/valid?timestamp=2016-10-10")
// checks the validity of a timestamp - this one returns {"valid":true}
// matching the data structure returned from https://postman-echo.com/time/valid
fileprivate struct PostmanEchoTimeStampCheckResponse: Decodable, Hashable { 1️⃣
    let valid: Bool
}

let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: myURL!) 2️⃣
    // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
    .map { $0.data } 3️⃣
    .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder()) 4️⃣

let cancellableSink = remoteDataPublisher
    .sink(receiveCompletion: { completion in
            print(".sink() received the completion", String(describing: completion))
            switch completion {
                case .finished: 5️⃣
                    break
                case .failure(let anError): 
                    print("received error: ", anError) 6️⃣
            }
    }, receiveValue: { someValue in 7️⃣
        print(".sink() received \(someValue)")
    })
```

- 1️⃣ Commonly you will have a struct defined that supports at least `Decodable` (if not the full `Codable` protocol). This struct can be defined to only pull the pieces you are interested in from the JSON provided over the network. The complete JSON payload does not need to be defined.
- 2️⃣ `dataTaskPublisher` is instantiated from `URLSession`. You can configure your own options on `URLSession`, or use a shared session.
- 3️⃣ The data that is returned is a tuple: `(data: Data, response: URLResponse)`. The `map` operator is used to get the data and drops the `URLResponse`, returning just Data down the pipeline.
- 4️⃣ `decode` is used to load the data and attempt to parse it. Decode can throw an error itself if the decode fails. If it succeeds, the object passed down the pipeline will be the struct from the JSON data.
- 5️⃣ If the decoding completed without errors, the finished completion will be triggered and the value will be passed to the `receiveValue` closure.
- 6️⃣ If the a failure happens (either with the original network request or the decoding), the error will be passed into with the `failure` closure.
- 7️⃣ Only if the data succeeded with request and decoding will this closure get invoked, and the data format received will be an instance of the struct `PostmanEchoTimeStampCheckResponse`.

## Stricter request processing with dataTaskPublisher



