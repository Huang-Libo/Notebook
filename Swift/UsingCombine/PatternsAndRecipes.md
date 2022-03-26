# Patterns and Recipes

- [Patterns and Recipes](#patterns-and-recipes)
  - [Creating a subscriber with sink](#creating-a-subscriber-with-sink)
  - [Creating a subscriber with assign](#creating-a-subscriber-with-assign)
  - [Making a network request with dataTaskPublisher](#making-a-network-request-with-datataskpublisher)
  - [Stricter request processing with dataTaskPublisher](#stricter-request-processing-with-datataskpublisher)
    - [Normalizing errors from a dataTaskPublisher](#normalizing-errors-from-a-datataskpublisher)
  - [Wrapping an asynchronous call with a Future to create a one-shot publisher](#wrapping-an-asynchronous-call-with-a-future-to-create-a-one-shot-publisher)
  - [Sequencing asynchronous operations](#sequencing-asynchronous-operations)
  - [Error Handling](#error-handling)
    - [Verifying a failure hasn’t happened using assertNoFailure](#verifying-a-failure-hasnt-happened-using-assertnofailure)
    - [Using catch to handle errors in a one-shot pipeline](#using-catch-to-handle-errors-in-a-one-shot-pipeline)
    - [Retrying in the event of a temporary failure](#retrying-in-the-event-of-a-temporary-failure)
    - [Using flatMap and catch to handle errors without cancelling the pipeline](#using-flatmap-and-catch-to-handle-errors-without-cancelling-the-pipeline)
    - [Requesting data from an alternate URL when the network is constrained](#requesting-data-from-an-alternate-url-when-the-network-is-constrained)
  - [UIKit or AppKit Integration](#uikit-or-appkit-integration)
    - [Declarative UI updates from user input](#declarative-ui-updates-from-user-input)
    - [Cascading multiple UI updates, including a network request](#cascading-multiple-ui-updates-including-a-network-request)

## Creating a subscriber with sink

**Goal**:

- To receive the output, and the errors or completion messages, generated from a publisher or through a pipeline, you can create a subscriber with `sink`.

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

**Goal**:

- To use the results of a pipeline to set a value, often a property on a user interface view or control, but any KVO compliant object can be the provider.

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

**Goal**:

- One common use case is requesting JSON data from a URL and decoding it.

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

**Goal**:

- When `URLSession` makes a connection, it only reports an error if the remote server does not respond. You may want to consider a number of responses, based on status code, to be errors. To accomplish this, you can use `tryMap` to inspect the http response and *throw* an error in the pipeline.

To have more control over what is considered a failure in the URL response, use a `tryMap` operator on the tuple response from dataTaskPublisher. Since `dataTaskPublisher` returns both the response data and the `URLResponse` into the pipeline, you can immediately inspect the response and throw an error of your own if desired.

An example of that might look like:

```swift
let myURL = URL(string: "https://postman-echo.com/time/valid?timestamp=2016-10-10")
// checks the validity of a timestamp - this one returns {"valid":true}
// matching the data structure returned from https://postman-echo.com/time/valid
fileprivate struct PostmanEchoTimeStampCheckResponse: Decodable, Hashable {
    let valid: Bool
}
enum TestFailureCondition: Error {
    case invalidServerResponse
}

let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: myURL!)
    .tryMap { data, response -> Data in 1️⃣
                guard let httpResponse = response as? HTTPURLResponse, 2️⃣
                    httpResponse.statusCode == 200 else { 3️⃣
                        throw TestFailureCondition.invalidServerResponse 4️⃣
                }
                return data 5️⃣
    }
    .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder())

let cancellableSink = remoteDataPublisher
    .sink(receiveCompletion: { completion in
            print(".sink() received the completion", String(describing: completion))
            switch completion {
                case .finished:
                    break
                case .failure(let anError):
                    print("received error: ", anError)
            }
    }, receiveValue: { someValue in
        print(".sink() received \(someValue)")
    })
```

- 1️⃣ `tryMap` still gets the tuple of `(data: Data, response: URLResponse)`, and is defined here as returning just the type of Data down the pipeline.
- 2️⃣ Within the closure for `tryMap`, we can cast the response to `HTTPURLResponse` and dig deeper into it, including looking at the specific status code.
- 3️⃣ In this case, we want to consider anything other than a `200` response code as a failure. `HTTPURLResponse.statusCode` is an `Int` type, so you could also have logic such as `httpResponse.statusCode > 300`.
- 4️⃣ If the predicates are not met it throws an instance of an error of our choosing; `invalidServerResponse` in this case.
- 5️⃣ If no error has occurred, then we simply pass down `Data` for further processing.

### Normalizing errors from a dataTaskPublisher

When an error is triggered on the pipeline, a `.failure` completion is sent with the error encapsulated within it, regardless of where it happened in the pipeline.

This pattern can be expanded to return a publisher that accommodates any number of specific error conditions using this general pattern. In many of the examples, we replace the error conditions with a default value. If we want to have a function that returns a publisher that *doesn’t* choose what happens on failure, then the same `tryMap` operator can be used in conjunction with `mapError` to translate review the response object as well as convert `URLError` error types.

```swift
enum APIError: Error, LocalizedError { 
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from): 
            return from.localizedDescription
        }
    }
}

func fetch(url: URL) -> AnyPublisher<Data, APIError> {
    let request = URLRequest(url: url)

    return URLSession.DataTaskPublisher(request: request, session: .shared) 
        .tryMap { data, response in 
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            if (httpResponse.statusCode == 401) {
                throw APIError.apiError(reason: "Unauthorized");
            }
            if (httpResponse.statusCode == 403) {
                throw APIError.apiError(reason: "Resource forbidden");
            }
            if (httpResponse.statusCode == 404) {
                throw APIError.apiError(reason: "Resource not found");
            }
            if (405..<500 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "client error");
            }
            if (500..<600 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "server error");
            }
            return data
        }
        .mapError { error in 
            // if it's our kind of error already, we can return it directly
            if let error = error as? APIError {
                return error
            }
            // if it is a TestExampleError, convert it into our new error type
            if error is TestExampleError {
                return APIError.parserError(reason: "Our example error")
            }
            // if it is a URLError, we can convert it into our more general error kind
            if let urlerror = error as? URLError {
                return APIError.networkError(from: urlerror)
            }
            // if all else fails, return the unknown error condition
            return APIError.unknown
        }
        .eraseToAnyPublisher() 
}
```

- 1️⃣ `APIError` is a Error enumeration that we are using in this example to collect all the variant errors that can occur.
- 2️⃣ `.networkError` is one of the specific cases of `APIError` that we will translate into when `URLSession.dataTaskPublisher` returns an error.
- 3️⃣ We start the generation of this publisher with a standard `dataTaskPublisher`.
- 4️⃣ We then route into the `tryMap` operator to inspect the response, creating specific error conditions based on the server response.
- 5️⃣ And finally we use `mapError` to convert any lingering error types down into a common Failure type of `APIError`.

## Wrapping an asynchronous call with a Future to create a one-shot publisher

**Goal**:

- Using `Future` to turn an asynchronous call into publisher to use the result in a Combine pipeline.

```swift
import Contacts
let futureAsyncPublisher = Future<Bool, Error> { promise in 
    CNContactStore().requestAccess(for: .contacts) { grantedAccess, err in 
        // err is an optional
        if let err = err { 
            return promise(.failure(err))
        }
        return promise(.success(grantedAccess)) 
    }
}.eraseToAnyPublisher()
```

- 1️⃣ `Future` itself has you define the return types and takes a closure. It hands in a `Result` object matching the type description, which you interact.
- 2️⃣ You can invoke the async API however is relevant, including passing in its required closure.
- 3️⃣ Within the completion handler, you determine what would cause a failure or a success. A call to `promise(.failure(<FailureType>))` returns the failure.
- 4️⃣ Or a call to `promise(.success(<OutputType>))` returns a value.

> **Warning**: A `Future` immediately calls the enclosed asynchronous API call when it is created, **not** when it receives a subscription demand. This may not be the behavior you want or need. If you want the call to be bound to subscribers requesting data, you probably want to wrap the `Future` with Deferred.

If you want to return a resolved promise as a `Future` publisher, you can do so by immediately returning the result you desire its closure.

The following example returns a single value as a success, with a boolean `true` value. You could just as easily return `false`, and the publisher would still act as a successful promise.

An example of returning a Future publisher that immediately resolves as an error:

```swift
enum ExampleFailure: Error {
    case oneCase
}

let resolvedFailureAsPublisher = Future<Bool, Error> { promise in
    promise(.failure(ExampleFailure.oneCase))
}.eraseToAnyPublisher()
```

## Sequencing asynchronous operations

**Goal**:

- To explicitly order asynchronous operations with a Combine pipeline

> This is similar to a concept called "promise chaining". While you can arrange combine such that it acts similarly, it is likely not a good replacement for using a promise library. The primary difference is that promise libraries always deal with a single result per promise, and a Combine brings along the complexity of needing to handle the possibility of many values.

By wrapping any asynchronous API calls with the `Future` publisher and then chaining them together with the `flatMap` operator, you invoke the wrapped asynchronous API calls in a specific order. Multiple parallel asynchronous efforts can be created by creating multiple pipelines, with `Future` or another publisher, and waiting for the pipelines to complete in parallel by merging them together with the `zip` operator.

If you want force an `Future` publisher to not be invoked until another has completed, then creating the future publisher in the `flatMap` closure causes it to wait to be created until a value has been passed to the `flatMap` operator.

These techniques can be composed to create any structure of parallel or serial tasks.

This technique of coordinating asynchronous calls can be especially effective if later tasks need data from earlier tasks. In those cases, the data results needed can be passed directly the pipeline.

An example of this sequencing follows below. In this example, buttons (arranged visually to show the ordering of actions) are highlighted when they complete. The whole sequence is triggered by a separate button action, which also resets the state of all the buttons and cancels any existing running sequence if it’s not yet finished. In this example, the asynchronous API call is a call that simply takes a random amount of time to complete to provide an example of how the timing works.

<img src="../../media/Swift/UsingCombine/AsyncCoordinatorViewController.png" width="350"/>

The workflow that is created is represented in steps:

- step 1 runs first.
- step 2 has three parallel efforts, running after step 1 completes.
- step 3 waits to start until all three elements of step 2 complete.
- step 4 runs after step 3 has completed.

Additionally, there is an activity indicator that is triggered to start animating when the sequence begins, stopping when step 4 has completed.

[AsyncCoordinatorViewController.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/AsyncCoordinatorViewController.swift)

```swift
import UIKit
import Combine

class AsyncCoordinatorViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var step1_button: UIButton!
    @IBOutlet weak var step2_1_button: UIButton!
    @IBOutlet weak var step2_2_button: UIButton!
    @IBOutlet weak var step2_3_button: UIButton!
    @IBOutlet weak var step3_button: UIButton!
    @IBOutlet weak var step4_button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var cancellable: AnyCancellable?
    var coordinatedPipeline: AnyPublisher<Bool, Error>?

    @IBAction func doit(_ sender: Any) {
        runItAll()
    }

    func runItAll() { 1️⃣
        if let cancellable = cancellable {
            print("Cancelling existing run")
            cancellable.cancel()
            activityIndicator.stopAnimating()
        }
        print("resetting all the steps")
        resetAllSteps() 2️⃣
        // driving it by attaching it to .sink
        activityIndicator.startAnimating() 3️⃣
        print("attaching a new sink to start things going")
        cancellable = coordinatedPipeline? 4️⃣
            .print()
            .sink(receiveCompletion: { completion in
                print(".sink() received the completion: ", String(describing: completion))
                self.activityIndicator.stopAnimating()
            }, receiveValue: { value in
                print(".sink() received value: ", value)
            })
    }
    
    // MARK: - helper pieces that would normally be in other files

    // this emulates an async API call with a completion callback
    // it does nothing other than wait and ultimately return with a boolean value
    func randomAsyncAPI(completion completionBlock: @escaping ((Bool, Error?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            sleep(.random(in: 1...4))
            completionBlock(true, nil)
        }
    }

    /// Creates and returns pipeline that uses a Future to wrap randomAsyncAPI, then updates a UIButton to represent
    /// the completion of the async work before returning a boolean True
    /// - Parameter button: button to be updated
    func createFuturePublisher(button: UIButton) -> AnyPublisher<Bool, Error> { 5️⃣
        return Future<Bool, Error> { promise in
            self.randomAsyncAPI() { (result, err) in
                if let err = err {
                    promise(.failure(err))
                } else {
                    promise(.success(result))
                }
            }
        }
        .receive(on: RunLoop.main)
            // so that we can update UI elements to show the "completion"
            // of this step
        .map { inValue -> Bool in 6️⃣
            // intentially side effecting here to show progress of pipeline
            self.markStepDone(button: button)
            return true
        }
        .eraseToAnyPublisher()
    }

    /// highlights a button and changes the background color to green
    /// - Parameter button: reference to button being updated
    func markStepDone(button: UIButton) {
        button.backgroundColor = .systemGreen
        button.isHighlighted = true
    }

    func resetAllSteps() {
        for button in [step1_button, step2_1_button, step2_2_button, step2_3_button, step3_button, step4_button] {
            button?.backgroundColor = .lightGray
            button?.isHighlighted = false
        }
        activityIndicator.stopAnimating()
    }

    // MARK: - view setup

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.stopAnimating()

        coordinatedPipeline = createFuturePublisher(button: step1_button) 7️⃣
            .flatMap { flatMapInValue -> AnyPublisher<Bool, Error> in
                let step2_1 = self.createFuturePublisher(button: self.step2_1_button)
                let step2_2 = self.createFuturePublisher(button: self.step2_2_button)
                let step2_3 = self.createFuturePublisher(button: self.step2_3_button)
                return Publishers.Zip3(step2_1, step2_2, step2_3)
                        .map{ _ -> Bool in
                            return true
                        }
                        .eraseToAnyPublisher()
            }
            .flatMap { _ in
                return self.createFuturePublisher(button: self.step3_button)
            }
            .flatMap { _ in
                return self.createFuturePublisher(button: self.step4_button)
            }
            .eraseToAnyPublisher()
    }
}
```

- 1️⃣ `runItAll` coordinates the operation of this workflow, starting with checking to see if one is currently running. If defined, it invokes `cancel()` on the existing subscriber.
- 2️⃣ `resetAllSteps` iterates through all the existing buttons used represent the progress of this workflow, and resets them to gray and unhighlighted to reflect an initial state. It also verifies that the activity indicator is not currently animated.
- 3️⃣ Then we get things started, first with activating the animation on the activity indicator.
- 4️⃣ Creating the *subscriber* with `sink` and storing the reference initiates the workflow. The publisher to which it is subscribing is setup outside this function, allowing it to be re-used multiple times. The `print` operator in the pipeline is for debugging, showing console output when the pipeline is triggered.
- 5️⃣ Each step is represented by the invocation of a `Future` publisher, followed immediately by pipeline elements to switch to the *main thread* and then update a `UIButton`’s background to show the step has completed. This is encapsulated in a `createFuturePublisher` call, using `eraseToAnyPublisher` to simplify the type being returned.
- 6️⃣ The `map` operator is used to create this specific side effect of updating the a `UIButton` to show the step has been completed.
- 7️⃣ The creation of the overall pipeline and its structure of serial and parallel tasks is created from the combination of calls to `createFuturePublisher` using the operators `flatMap` and `zip`.

## Error Handling

Previous examples above expect that the *subscriber* would handle the error conditions, if they occurred. However, you are not always able to control what the *subscriber* requires - as might be the case if you are using SwiftUI. In these cases, you need to build your pipeline so that the output types match the subscriber types. This implies that you are handling any errors within the pipeline.

For example, if you are working with SwiftUI and the you want to use `assign` to set the `isEnabled` property on a button, the *subscriber* will have a few requirements:

- the subscriber should match the type output of `<Bool, Never>`
- the subscriber should be called on the *main thread*

With a publisher that can throw an error (such as `URLSession.dataTaskPublisher`), you need to construct a pipeline to convert the output type, but also handle the error within the pipeline to match a failure type of `<Never>`.

How you handle the errors within a pipeline is dependent on how the pipeline is defined.

- If the pipeline is set up to return a *single* result and terminate, a good example is [Using catch to handle errors in a one-shot pipeline](#using-catch-to-handle-errors-in-a-one-shot-pipeline).
- If the pipeline is set up to *continually* update, the error handling needs to be a little more complex. In this case, look at the example [Using flatMap with catch to handle errors](#using-flatmap-and-catch-to-handle-errors-without-cancelling-the-pipeline).

### Verifying a failure hasn’t happened using assertNoFailure

**Goal**:

- Verify no error has occurred within a pipeline

`assertNoFailure` *operator* also converts the failure type to `<Never>`. The operator will cause the application to terminate (or tests to crash to a debugger) if the assertion is triggered.

This is useful for verifying the invariant of having dealt with an error. If you are sure you handled the errors and need to map a pipeline which technically can generate a failure type of `<Error>` to a subscriber that requires a failure type of `<Never>`.

### Using catch to handle errors in a one-shot pipeline

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

### Retrying in the event of a temporary failure

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

### Using flatMap and catch to handle errors without cancelling the pipeline

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

### Requesting data from an alternate URL when the network is constrained

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

## UIKit or AppKit Integration

### Declarative UI updates from user input

**Goal**:

- Querying a API and returning the data to be displayed in your UI

A pattern for integrating Combine with UIKit is setting up a variable which will hold a reference to the updated state, and linking the controls using `IBAction`.

The sample is a portion of the code at in a larger view controller implementation.

This example overlaps with the next pattern [Cascading UI updates including a network request](#cascading-multiple-ui-updates-including-a-network-request), which builds upon the initial publisher.

[UIKit-Combine/GithubAPI.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubAPI.swift)

```swift
import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var github_id_entry: UITextField! 1️⃣

    var usernameSubscriber: AnyCancellable?

    // username from the github_id_entry field, updated via IBAction
    // @Published is creating a publisher $username of type <String, Never>
    @Published var username: String = "" 2️⃣

    // github user retrieved from the API publisher. As it's updated, it
    // is "wired" to update UI elements
    @Published private var githubUserData: [GithubAPIUser] = []

    // MARK - Actions

    @IBAction func githubIdChanged(_ sender: UITextField) {
        username = sender.text ?? "" 3️⃣
        print("Set username to ", username)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        usernameSubscriber = $username 4️⃣
            .throttle(for: 0.5, scheduler: myBackgroundQueue, latest: true) 5️⃣
            // ^^ scheduler myBackGroundQueue publishes resulting elements
            // into that queue, resulting on this processing moving off the
            // main runloop.
            .removeDuplicates() 6️⃣
            .print("username pipeline: ") // debugging output for pipeline
            .map { username -> AnyPublisher<[GithubAPIUser], Never> in 7️⃣
                return GithubAPI.retrieveGithubUser(username: username)
            }
            // ^^ type returned by retrieveGithubUser is a Publisher, so we use
            // switchToLatest to resolve the publisher to its value
            // to return down the chain, rather than returning a
            // publisher down the pipeline.
            .switchToLatest() 8️⃣
            // using a sink to get the results from the API search lets us
            // get not only the user, but also any errors attempting to get it.
            .receive(on: RunLoop.main)
            .assign(to: \.githubUserData, on: self) 9️⃣
```

- 1️⃣ The `UITextField` is the interface element which is driving the updates from user interaction.
- 2️⃣ We defined a `@Published` property to both hold the data and reflect updates when they happen. Because its a `@Published` property, it provides a publisher that we can use with Combine pipelines to update other variables or elements of the interface.
- 3️⃣ We set the variable `*username*` from within an `IBAction`, which in turn triggers a data flow if the publisher `$username` has any subscribers.
- 4️⃣ We in turn set up a subscriber on the publisher `$username` that does further actions. In this case it uses updated values of username to retrieves an instance of a `GithubAPIUser` from *Github’s REST API*. It will make a new HTTP request to the every time the *username* value is updated.
- 5️⃣ The `throttle` is there to keep from triggering a network request on every possible edit of the text field. The throttle keeps it to a maximum of 1 request every half-second.
- 6️⃣ `removeDuplicates` collapses events from the changing *username* so that API requests are not made on the same value twice in a row. The `removeDuplicates` prevents redundant requests from being made, should the user edit and the return the previous value.
- 7️⃣ `map` is used similarly to `flatMap` in error handling here, returning an instance of a publisher. The API object returns a publisher, which this map is invoking. This doesn’t return the value from the call, but the publisher itself.
- 8️⃣ `switchToLatest` operator takes the instance of the publisher and resolves out the data. `switchToLatest` resolves a publisher into a value and passes that value down the pipeline, in this case an instance of `[GithubAPIUser]`.
- 9️⃣ And `assign` at the end up the pipeline is the subscriber, which assigns the value into another variable: `githubUserData`.

The pattern [Cascading UI updates including a network request](#cascading-multiple-ui-updates-including-a-network-request) expands upon this code to multiple cascading updates of various UI elements.

### Cascading multiple UI updates, including a network request

**Goal**:

- Have multiple UI elements update triggered by an upstream subscriber

**References**:

- The ViewController with this code is in the github project at [UIKit-Combine/GithubViewController.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubViewController.swift). You can see this code in operation by running the UIKit target within the github project.
- The GithubAPI is in the github project at [UIKit-Combine/GithubAPI.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubAPI.swift)

> The example provided expands on a publisher updating from [Declarative UI updates from user input](#declarative-ui-updates-from-user-input), adding additional Combine pipelines to update multiple UI elements as someone interacts with the provided interface.

The general pattern of this view starts with a textfield that accepts user input, from which the following actions flow:

1. Using an `IBAction` the `@Published` `username` variable is updated.
2. We have a subscriber (`usernameSubscriber`) attached `$username` publisher, which publishes the value on change and attempts to retrieve the GitHub user. The resulting variable `githubUserData` (also `@Published`) is a list of GitHub user objects. Even though we only expect a single value here, we use a list because we can conveniently return an empty list on failure scenarios: unable to access the API or the username isn’t registered at GitHub.
3. We have the `passthroughSubject` `apiNetworkActivitySubscriber` to reflect when the `GithubAPI` object starts or finishes making network requests.
4. We have a another subscriber `repositoryCountSubscriber` attached to `$githubUserData` publisher that pulls the repository count off the github user data object and assigns it to a text field to be displayed.
5. We have a final subscriber `avatarViewSubscriber` attached to `$githubUserData` that attempts to retrieve the image associated with the user’s avatar for display.

> Tips: The empty list is useful to return because when a `username` is provided that doesn’t resolve, we want to explicitly remove any avatar image that was previously displayed. To do this, we need the pipelines to fully resolve to some value, so that further pipelines are triggered and the relevant UI interfaces updated. If we used an optional `String?` instead of an array of `String[]`, the optional does not trigger some of the pipeline when it is `nil`, and we always want a result value - even an empty value - to come from the pipeline.

The subscribers (created with `assign` and `sink`) are stored as `AnyCancellable` variables on the view controller instance. Because they are defined on the class instance, the Swift compiler creates deinitializers which will cancel and clean up the publishers when the class is torn down.

> Info: A number of developers comfortable with *RxSwift* are using a "*CancelBag*" object to collect cancellable references, and cancel the pipelines on tear down. An example of this can be seen at [here](https://github.com/tailec/CombineExamples/blob/master/CombineExamples/Shared/CancellableBag.swift). This is accommodated within Combine with the `store` function on `AnyCancellable` that easily allows you to put a reference to the subscriber into a collection, such as `Set<AnyCancellable>`.

The pipelines have been explicitly configured to work on a background queue using the `subscribe` operator. Without that additional detail configured, the pipelines would be invoked and run on the main runloop since they were invoked from the UI, which may cause a noticeable slow-down in responsiveness in the user interface. Likewise when the resulting pipelines assign or update UI elements, the `receive` operator is used to transfer that work back onto the main runloop.

> **Warning**: To have the UI continuously updated from changes propagating through `@Published` properties, we want to make sure that any configured pipelines have a `<Never>` failure type. This is required for the `assign` operator. It is also a potential source of bugs when using a `sink` operator. If the pipeline from a `@Published` variable terminates to a `sink` that accepts an Error failure type, the `sink` will send a termination signal if an error occurs. This will then stop the pipeline from any further processing, even when the variable is updated.

[UIKit-Combine/GithubAPI.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubAPI.swift)

```swift

```


