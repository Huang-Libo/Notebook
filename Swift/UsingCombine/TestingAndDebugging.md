# Testing and Debugging

- [Testing and Debugging](#testing-and-debugging)
  - [Introduction](#introduction)
  - [Testing a publisher with XCTestExpectation](#testing-a-publisher-with-xctestexpectation)
  - [Testing a subscriber with a PassthroughSubject](#testing-a-subscriber-with-a-passthroughsubject)
  - [Testing a subscriber with scheduled sends from PassthroughSubject](#testing-a-subscriber-with-scheduled-sends-from-passthroughsubject)
  - [Using EntwineTest to create a testable publisher and subscriber](#using-entwinetest-to-create-a-testable-publisher-and-subscriber)
  - [Debugging pipelines with the print operator](#debugging-pipelines-with-the-print-operator)
  - [Debugging pipelines with the handleEvents operator](#debugging-pipelines-with-the-handleevents-operator)
  - [Debugging pipelines with the debugger](#debugging-pipelines-with-the-debugger)

## Introduction

The `Publisher`/`Subscriber` interface in Combine is beautifully suited to be an easily testable interface.

With the composability of Combine, you can use this to your advantage, creating APIs that present, or consume, code that conforms to `Publisher`.

With the `Publisher` protocol as the key interface, you can replace either side to validate your code in isolation.

For example, if your code was focused on providing its data from external web services through Combine, you might make the interface to this conform to `AnyPublisher<Data, Error>`. You could then use that interface to test either side of that pipeline independently.

- You can mock data responses that emulate the underlying API calls and possible responses, including various error conditions. This might include returning data from a publisher created with `Just` or `Fail`, or something more complex using `Future`. None of these options require you to make actual network interface calls.
- Likewise you can isolate the testing of making the publisher do the API calls and verify the various success and failure conditions expected.

## Testing a publisher with XCTestExpectation

**Goal**:

- For testing a publisher (and any pipeline attached)

**References**:

- [UsingCombineTests/](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests)
  - [DataTaskPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/DataTaskPublisherTests.swift)
  - [EmptyPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/EmptyPublisherTests.swift)
  - [FuturePublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/FuturePublisherTests.swift)
  - [PublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/PublisherTests.swift)
  - [DebounceAndRemoveDuplicatesPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/DebounceAndRemoveDuplicatesPublisherTests.swift)

> When you are testing a publisher, or something that creates a publisher, you may not have the option of controlling when the publisher returns data for your tests. Combine, being driven by its subscribers, can set up a sync that initiates the data flow. You can use an `XCTestExpectation` to *wait* an explicit amount of time for the test to run to completion.

A general pattern for using this with Combine includes:

1. set up the expectation within the test
2. establish the code you are going to test
3. set up the code to be invoked such that on the success path you call the expectation’s `.fulfill()` function
4. set up a `wait()` function with an explicit timeout that will fail the test if the expectation isn’t fulfilled within that time window.

- If you are testing the *data results* from a pipeline, then triggering the `fulfill()` function within the `sink`'s `receiveValue` closure can be very convenient.
- If you are testing a *failure condition* from the pipeline, then often including `fulfill()` within the `sink`'s `receiveCompletion` closure is effective.

The following example shows testing a one-shot publisher (`URLSession.dataTaskPublisher` in this case) using expectation, and expecting the data to flow without an error.

[UsingCombineTests/DataTaskPublisherTests.swift - testDataTaskPublisher](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/DataTaskPublisherTests.swift#L47)

```swift
func testDataTaskPublisher() {
    // setup
    let expectation = XCTestExpectation(description: "Download from \(String(describing: testURL))") 1️⃣
    let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: self.testURL!)
        // validate
        .sink(receiveCompletion: { fini in
            print(".sink() received the completion", String(describing: fini))
            switch fini {
            case .finished: expectation.fulfill() 2️⃣
            case .failure: XCTFail() 3️⃣
            }
        }, receiveValue: { (data, response) in
            guard let httpResponse = response as? HTTPURLResponse else {
                XCTFail("Unable to parse response an HTTPURLResponse")
                return
            }
            XCTAssertNotNil(data)
            // print(".sink() data received \(data)")
            XCTAssertNotNil(httpResponse)
            XCTAssertEqual(httpResponse.statusCode, 200) 4️⃣
            // print(".sink() httpResponse received \(httpResponse)")
        })

    XCTAssertNotNil(remoteDataPublisher)
    wait(for: [expectation], timeout: 5.0) 5️⃣
}
```

- 1️⃣ The expectation is set up with a string that makes debugging in the event of failure a bit easier. This string is really only seen when a test failure occurs. The code we are testing here is `dataTaskPublisher` retrieving data from a preset test URL, defined earlier in the test. The publisher is invoked by attaching the `sink` subscriber to it. Without the expectation, the code will still run, but the test running structure wouldn’t wait to see if there were any exceptions. The expectation within the test "holds the test" waiting for a response to let the operators do their work.
- 2️⃣ In this case, the test is expected to complete successfully and terminate normally, therefore the `expectation.fulfill()` invocation is set within the `receiveCompletion` closure, specifically linked to a received `.finished` completion.
- 3️⃣ Since we don’t expect a failure, we also have an explicit `XCTFail()` invocation if we receive a `.failure` completion.
- 4️⃣ We have a few additional assertions within the `receiveValue`. Since this publisher set returns a single value and then terminates, we can make inline assertions about the data received. If we received multiple values, then we could collect those and make assertions on what was received after the fact.
- 5️⃣ This test uses a single expectation, but you can include multiple independent expectations to require fulfillment. It also sets that maximum time that this test can run to `5` seconds. The test will not always take `5` seconds, as it will complete the test as soon as the fulfill is received. If for some reason the test takes longer than `5` seconds to respond, the `XCTest` will report a test failure.

## Testing a subscriber with a PassthroughSubject

**Goal**:

- For testing a subscriber, or something that includes a subscriber, we can emulate the publishing source with PassthroughSubject to provide explicit control of what data gets sent and when.

- [UsingCombineTests/](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/)
  - [EncodeDecodeTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/EncodeDecodeTests.swift)
  - [FilterPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/FilterPublisherTests.swift)
  - [FuturePublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/FuturePublisherTests.swift)
  - [RetryPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/RetryPublisherTests.swift)
  - [SinkSubscriberTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/SinkSubscriberTests.swift)
  - [SwitchAndFlatMapPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/SwitchAndFlatMapPublisherTests.swift)
  - [DebounceAndRemoveDuplicatesPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/DebounceAndRemoveDuplicatesPublisherTests.swift)

> When you are testing a subscriber in isolation, you can get more fine-grained control of your tests by emulating the publisher with a `passthroughSubject` and using the associated `.send()` method to trigger updates.

This pattern relies on the subscriber setting up the initial part of the publisher-subscriber lifecycle upon construction, and leaving the code to stand waiting until data is provided. With a `PassthroughSubject`, sending the data to trigger the pipeline and subscriber closures, or following state changes that can be verified, is at the control of the test code itself.

This kind of testing pattern also works well when you are testing the response of the subscriber to a failure, which might otherwise terminate a subscription.

A general pattern for using this kind of test construct is:

1. Set up your subscriber and any pipeline leading to it that you want to include within the test.
2. Create a `PassthroughSubject` in the test that produces an *output type* and *failure type* to match with your subscriber.
3. Assert any initial values or preconditions.
4. Send the data through the subject.
5. Test the results of having sent the data - either directly or asserting on state changes that were expected.
6. Send additional data if desired.
7. Test further evolution of state or other changes.

[UsingCombineTests/SinkSubscriberTests.swift - testSinkReceiveDataThenError](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/SinkSubscriberTests.swift#L46)

```swift
func testSinkReceiveDataThenError() {
    // setup - preconditions 1️⃣
    let expectedValues = ["firstStringValue", "secondStringValue"]
    enum TestFailureCondition: Error {
        case anErrorExample
    }
    var countValuesReceived = 0
    var countCompletionsReceived = 0
    // setup
    let simplePublisher = PassthroughSubject<String, Error>() 2️⃣

    let cancellable = simplePublisher 3️⃣
        .sink(receiveCompletion: { completion in
            countCompletionsReceived += 1
            switch completion { 4️⃣
            case .finished:
                print(".sink() received the completion:", String(describing: completion))
                // no associated data, but you can react to knowing the request has been completed
                XCTFail("We should never receive the completion, because the error should happen first")
                break
            case .failure(let anError):
                // do what you want with the error details, presenting, logging, or hiding as appropriate
                print("received the error: ", anError)
                XCTAssertEqual(anError.localizedDescription,
                                TestFailureCondition.anErrorExample.localizedDescription) 5️⃣
                break
            }
        }, receiveValue: { someValue in 6️⃣
            // do what you want with the resulting value passed down
            // be aware that depending on the data type being returned, you may get this closure invoked
            // multiple times.
            XCTAssertNotNil(someValue)
            XCTAssertTrue(expectedValues.contains(someValue))
            countValuesReceived += 1
            print(".sink() received \(someValue)")
        })

    // validate
    XCTAssertNotNil(cancellable) 7️⃣
    XCTAssertEqual(countValuesReceived, 0)
    XCTAssertEqual(countCompletionsReceived, 0)

    simplePublisher.send("firstStringValue") 8️⃣
    XCTAssertEqual(countValuesReceived, 1)
    XCTAssertEqual(countCompletionsReceived, 0)

    simplePublisher.send("secondStringValue")
    XCTAssertEqual(countValuesReceived, 2)
    XCTAssertEqual(countCompletionsReceived, 0)

    simplePublisher.send(completion: Subscribers.Completion.failure(TestFailureCondition.anErrorExample)) 9️⃣
    XCTAssertEqual(countValuesReceived, 2)
    XCTAssertEqual(countCompletionsReceived, 1)

    // this data will never be seen by anything in the pipeline above because we've already sent a completion
    simplePublisher.send(completion: Subscribers.Completion.finished) 🔟
    XCTAssertEqual(countValuesReceived, 2)
    XCTAssertEqual(countCompletionsReceived, 1)
}
```

- 1️⃣ This test sets up some variables to capture and modify during test execution that we use to validate when and how the `sink` code operates. Additionally, we have an error defined here because it’s not coming from other code elsewhere.
- 2️⃣ The setup for this code uses the `passthroughSubject` to drive the test, but the code we are interested in testing is the subscriber.
- 3️⃣ The subscriber setup under test (in this case, a standard `sink`). We have code paths that trigger on receiving data and completions.
- 4️⃣ Within the completion path, we switch on the type of completion, adding an assertion that will fail the test if a finish is called, as we expect to only generate a `.failure` completion.
- 5️⃣ Testing error equality in Swift can be awkward, but if the error is code you are controlling, you can sometimes use the `localizedDescription` as a convenient way to test the type of error received.
- 6️⃣ The `receiveValue` closure is more complex in how it asserts against received values. Since we are receiving multiple values in the process of this test, we have some additional logic to check that the values are within the set that we send. Like the completion handler, We also increment test specific variables that we will assert on later to validate state and order of operation.
- 7️⃣ The count variables are validated as preconditions before we send any data to double check our assumptions.
- 8️⃣ In the test, the `send()` triggers the actions, and immediately after we can test the side effects through the test variables we are updating. In your own code, you may not be able to (or want to) modify your subscriber, but you may be able to provide private/testable properties or windows into the objects to validate them in a similar fashion.
- 9️⃣ We also use `send()` to trigger a *completion*, in this case a failure completion.
- 🔟 And the final `send()` is validating the operation of the failure that just happened - that it was not processed, and no further state updates happened.

## Testing a subscriber with scheduled sends from PassthroughSubject

**Goal**:

- For testing a *pipeline*, or *subscriber*, when what you want to test is the *timing* of the pipeline.

**References**

- [UsingCombineTests/EntwineTestExampleTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/EntwineTestExampleTests.swift)

> There are a number of operators in Combine that are specific to the timing of data, including `debounce`, `throttle`, and `delay`. You may want to test that your pipeline timing is having the desired impact, independently of doing UI testing.

One way of handling this leverages the both `XCTestExpectation` and a `passthroughSubject`, and add `DispatchQueue` in the test to schedule invocations of `PassthroughSubject`’s `.send()` method.

[UsingCombineTests/PublisherTests.swift - testKVOPublisher](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/PublisherTests.swift#L205)

```swift
func testKVOPublisher() {
    let expectation = XCTestExpectation(description: self.debugDescription)
    let foo = KVOAbleNSObject()
    let q = DispatchQueue(label: self.debugDescription) 1️⃣

    let cancellable = foo.publisher(for: \.intValue)
        .print()
        .sink { someValue in
            print("value of intValue updated to: >>\(someValue)<<")
        }

    q.asyncAfter(deadline: .now() + 0.5, execute: { 2️⃣
        print("Updating to foo.intValue on background queue")
        foo.intValue = 5
        expectation.fulfill() 3️⃣
    })
    wait(for: [expectation], timeout: 5.0) 4️⃣
    XCTAssertNotNil(cancellable)
}
```

- 1️⃣ This adds a `DispatchQueue` to your test, naming the queue after the test itself. This really only shows when debugging test failures, and is convenient as a reminder of what is happening in the test code vs. any other background queues that might be in use.
- 2️⃣ `.asyncAfter` is used along with the deadline parameter to define when a call gets made.
- 3️⃣ The simplest form embeds any relevant assertions into the subscriber or around the subscriber. Additionally, invoking the `.fulfill()` on your expectation as the last queued entry you send lets the test know that it is now complete.
- 4️⃣ Make sure that when you set up the `wait` that allow for sufficient time for your queue’d calls to be invoked.

A definite downside to this technique is that it forces the test to take a minimum amount of time matching the maximum queue delay in the test.

Another option is a 3rd party library named `EntwineTest`, which was inspired by the `RxTest` library. `EntwineTest` is part of [Entwine](https://github.com/tcldr/Entwine.git), a Swift library that expands on Combine with some helpers.

One of the key elements included in `EntwineTest` is a *virtual time scheduler*, as well as additional classes that schedule (`TestablePublisher`) and collect and record (`TestableSubscriber`) the timing of results while using this scheduler.

An example of this from the `EntwineTest` project README is included:

[UsingCombineTests/EntwineTestExampleTests.swift - testExampleUsingVirtualTimeScheduler](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/EntwineTestExampleTests.swift)

```swift
func testExampleUsingVirtualTimeScheduler() {
    let scheduler = TestScheduler(initialClock: 0) 1️⃣
    var didSink = false
    let cancellable = Just(1) 2️⃣
        .delay(for: 1, scheduler: scheduler)
        .sink { _ in
            didSink = true
        }

    XCTAssertNotNil(cancellable)
    // where a real scheduler would have triggered when .sink() was invoked
    // the virtual time scheduler requires resume() to commence and runs to
    // completion.
    scheduler.resume() 3️⃣
    XCTAssertTrue(didSink) 4️⃣
}
```

- 1️⃣ Using the *virtual time scheduler* requires you create one at the start of the test, initializing its clock to a starting value. The *virtual time scheduler* in `EntwineTest` will commence subscription at the value `200` and times out at `900` if the pipeline isn’t complete by that time.
- 2️⃣ You create your pipeline, along with any publishers or subscribers, as normal. `EntwineTest` also offers a testable publisher and a testable subscriber that could be used as well.
- 3️⃣ `.resume()` needs to be invoked on the *virtual time scheduler* to commence its operation and run the pipeline.
- 4️⃣ Assert against expected end results after the pipeline has run to completion.

## Using EntwineTest to create a testable publisher and subscriber

**Goal**:

- For testing a *pipeline*, or *subscriber*, when what you want to test is the timing of the pipeline.

> In addition to a *virtual time scheduler*, EntwineTest has a `TestablePublisher` and a `TestableSubscriber`. These work in coordination with the *virtual time scheduler* to allow you to specify the timing of the publisher generating data, and to valid the data received by the subscriber.

[UsingCombineTests/EntwineTestExampleTests.swift - testMap](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/EntwineTestExampleTests.swift)

```swift
func testMap() {
    let testScheduler = TestScheduler(initialClock: 0)

    // creates a publisher that will schedule its elements relatively, at the point of subscription
    let testablePublisher: TestablePublisher<String, Never> = testScheduler.createRelativeTestablePublisher([ 1️⃣
        (100, .input("a")),
        (200, .input("b")),
        (300, .input("c")),
    ])

    // a publisher that maps strings to uppercase
    let subjectUnderTest = testablePublisher.map { $0.uppercased() }

    // uses the method described above (schedules a subscription at 200, to be cancelled at 900)
    let results = testScheduler.start { subjectUnderTest } 2️⃣

    XCTAssertEqual(results.recordedOutput, [ 3️⃣
        (200, .subscription),           // subscribed at 200
        (300, .input("A")),             // received uppercased input @ 100 + subscription time
        (400, .input("B")),             // received uppercased input @ 200 + subscription time
        (500, .input("C")),             // received uppercased input @ 300 + subscription time
    ])
}
```

- 1️⃣ The `TestablePublisher` lets you set up a publisher that returns specific values at specific times. In this case, it’s returning `3` items at consistent intervals.
- 2️⃣ When you use the *virtual time scheduler*, it is important to make sure to invoke it with `start`. This runs the *virtual time scheduler*, which can run faster than a clock since it only needs to increment the **virtual time** and not wait for elapsed time.
- 3️⃣ `results` is a `TestableSubscriber` object, and includes a `recordedOutput` property which provides an ordered list of all the data and combine control path interactions with their timing.

If this test sequence had been done with `asyncAfter`, then the test would have taken a minimum of `500ms` to complete. When I ran this test on my laptop, it was recording `0.0121` seconds to complete the test (`12.1ms`).

> **Info**: A side effect of `EntwineTest` is that tests using the *virtual time scheduler* can run much faster than a real time clock. The same tests being created using real time scheduling mechanisms to delay data sending values can take significantly longer to complete.

## Debugging pipelines with the print operator

**Goal**:

- To gain understanding of what is happening in a pipeline, seeing all control and data interactions.

> I have found the greatest detail of information comes from selectively using the `print` operator. The downside is that it prints quite a lot of information, so the output can quickly become overwhelming. For understanding a simple pipeline, using the `.print()` as an operator without any parameters is very straightforward. As soon as you want to add more than one print operator, you will likely want to use the string parameter, which is puts in as a prefix to the output.

The example [Cascading UI updates including a network request](https://heckj.github.io/swiftui-notes/#patterns-cascading-update-interface) uses it in several places, with long descriptive prefixes to make it clear which pipeline is providing the information.

The two pipelines cascade together by connecting through a private published variable - the github user data. The two relevant pipelines from that example code:

[UIKit-Combine/GithubViewController.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubViewController.swift)

```swift
usernameSubscriber = $username
    .throttle(for: 0.5, scheduler: myBackgroundQueue, latest: true)
    // ^^ scheduler myBackGroundQueue publishes resulting elements
    // into that queue, resulting on this processing moving off the
    // main runloop.
    .removeDuplicates()
    .print("username pipeline: ") // debugging output for pipeline
    .map { username -> AnyPublisher<[GithubAPIUser], Never> in
        return GithubAPI.retrieveGithubUser(username: username)
    }
    // ^^ type returned in the pipeline is a Publisher, so we use
    // switchToLatest to flatten the values out of that
    // pipeline to return down the chain, rather than returning a
    // publisher down the pipeline.
    .switchToLatest()
    // using a sink to get the results from the API search lets us
    // get not only the user, but also any errors attempting to get it.
    .receive(on: RunLoop.main)
    .assign(to: \.githubUserData, on: self)

// using .assign() on the other hand (which returns an
// AnyCancellable) *DOES* require a Failure type of <Never>
repositoryCountSubscriber = $githubUserData
    .print("github user data: ")
    .map { userData -> String in
        if let firstUser = userData.first {
            return String(firstUser.public_repos)
        }
        return "unknown"
    }
    .receive(on: RunLoop.main)
    .assign(to: \.text, on: repositoryCountLabel)
```

When you run the UIKit-Combine example code, the terminal shows the following output as I slowly enter the username `heckj`. In the course of doing these lookups, two other github accounts are found and retrieved (hec and heck) before the final one.

```plaintext
username pipeline: : receive subscription: (RemoveDuplicates)
username pipeline: : request unlimited
github user data: : receive subscription: (CurrentValueSubject)
github user data: : request unlimited
github user data: : receive value: ([])
username pipeline: : receive value: ()
github user data: : receive value: ([])

Set username to  h
username pipeline: : receive value: (h)
github user data: : receive value: ([])

Set username to  he
username pipeline: : receive value: (he)
github user data: : receive value: ([])

Set username to  hec
username pipeline: : receive value: (hec)

Set username to  heck
github user data: : receive value: ([UIKit_Combine.GithubAPIUser(login: "hec", public_repos: 3, avatar_url: "https://avatars3.githubusercontent.com/u/53656?v=4")])

username pipeline: : receive value: (heck)
github user data: : receive value: ([UIKit_Combine.GithubAPIUser(login: "heck", public_repos: 6, avatar_url: "https://avatars3.githubusercontent.com/u/138508?v=4")])

Set username to  heckj
username pipeline: : receive value: (heckj)
github user data: : receive value: ([UIKit_Combine.GithubAPIUser(login: "heckj", public_repos: 69, avatar_url: "https://avatars0.githubusercontent.com/u/43388?v=4")])
```

Some of the extraneous `print` statements placed in `sink` closures to see final results have been removed.

You see the initial subscription setup at the very beginning, and then notifications, including the debug representation of the value passed through the `print` operator. Although it is not shown in the example content above, you will also see cancellations when an error occurs, or completions when they emit from a publisher reporting no further data is available.

It can also be beneficial to use a `print` operator on either side of an operator to understand how it is operating.

An example of doing this, leveraging the prefix to show the `retry` operator and how it works:

[UsingCombineTests/RetryPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/RetryPublisherTests.swift)

```swift
func testRetryWithOneShotFailPublisher() {
    // setup
    let cancellable = Fail(outputType: String.self, failure: TestFailureCondition.invalidServerResponse)
        .print("(1)>") 1️⃣
        .retry(3)
        .print("(2)>") 2️⃣
        .sink(receiveCompletion: { fini in
            print(" ** .sink() received the completion:", String(describing: fini))
        }, receiveValue: { stringValue in
            XCTAssertNotNil(stringValue)
            print(" ** .sink() received \(stringValue)")
        })
    XCTAssertNotNil(cancellable)
}
```

- 1️⃣ The `(1)` prefix is to show the interactions above the `retry` operator
- 2️⃣ The `(2)` prefix shows the interactions after the `retry` operator

**output from unit test**:

```plaintext
Test Suite 'UsingCombineTests.xctest' started at 2022-03-30 23:16:33.824
Test Suite 'RetryPublisherTests' started at 2022-03-30 23:16:33.824
Test Case '-[UsingCombineTests.RetryPublisherTests testRetryWithOneShotFailPublisher]' started.
(1)>: receive subscription: (Empty) 1️⃣
(2)>: receive subscription: (Retry)
(2)>: request unlimited
(1)>: request unlimited
(1)>: receive error: (invalidServerResponse)
(1)>: receive subscription: (Empty)
(1)>: request unlimited
(1)>: receive error: (invalidServerResponse)
(1)>: receive subscription: (Empty)
(1)>: request unlimited
(1)>: receive error: (invalidServerResponse)
(1)>: receive subscription: (Empty)
(1)>: request unlimited
(1)>: receive error: (invalidServerResponse)
(2)>: receive error: (invalidServerResponse) 2️⃣
 ** .sink() received the completion: failure(UsingCombineTests.RetryPublisherTests.TestFailureCondition.invalidServerResponse)
Test Case '-[UsingCombineTests.RetryPublisherTests testRetryWithOneShotFailPublisher]' passed (0.004 seconds).
Test Suite 'RetryPublisherTests' passed at 2022-03-30 23:16:33.828.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.004) seconds
Test Suite 'UsingCombineTests.xctest' passed at 2022-03-30 23:16:33.832.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.008) seconds
Test Suite 'Selected tests' passed at 2022-03-30 23:16:33.832.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.004 (0.009) seconds
```

- 1️⃣ In the test sample, the publisher always reports a failure, resulting in seeing the prefix (1) receiving the error, and then the resubscription from the retry operator.
- 2️⃣ And after 4 of those attempts (3 "retries"), then you see the error falling through the pipeline. After the error hits the sink, you see the cancel signal propagated back up, which stops at the retry operator.

While very effective, the `print` operator can be a blunt tool, generating a lot of output that you have to parse and review. If you want to be more selective with what you identify and print, or if you need to process the data passing through for it to be used more meaningfully, then you look at the `handleEvents` operator.

## Debugging pipelines with the handleEvents operator

**Goal**:

- To get more targeted understanding of what is happening within a pipeline, employing breakpoints, *print* or *logging* statements, or additional logic.

> `handleEvents` passes data through, making no modifications to the output and failure types, or the data. When you put in the operator, you can specify a number of optional closures, allowing you to focus on the aspect of what you want to see. The `handleEvents` operator with specific closures can be a great way to get a window to see what is happening when a pipeline is cancelling, erroring, or otherwise terminating expectedly.

The closures you can provide include:

- `receiveSubscription`
- `receiveRequest`
- `receiveCancel`
- `receiveOutput`
- `receiveCompletion`

The power of `handleEvents` for debugging is in selecting what you want to view, reducing the amount of output, or manipulating the data to get a better understanding of it.

In the example viewcontroller at [UIKit-Combine/GithubViewController.swift](https://github.com/heckj/swiftui-notes/blob/master/UIKit-Combine/GithubViewController.swift), the subscription, cancellation, and completion handlers are used to provide a side effect of starting, or stopping, an activity indicator.

If you only wanted to see the data being passed on the pipeline, and didn’t care about the control messages, then providing a single closure for `receiveOutput` and ignoring the other closures can let you focus on just that detail.

The unit test example showing `handleEvents` has all options active with comments:

[UsingCombineTests/HandleEventsPublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/HandleEventsPublisherTests.swift)

```swift
func testHandleEvents() {

    let publisher = PassthroughSubject<String?, Never>()

    // this sets up the chain of whatever it's going to do
    let cancellable = publisher
        .handleEvents(receiveSubscription: { aValue in
            print("receiveSubscription event called with \(String(describing: aValue))") 2️⃣
            // this happened second:
            // receiveSubscription event called with PassthroughSubject
            XCTAssertNotNil(aValue) // type returned is a Subscription
        }, receiveOutput: { aValue in 3️⃣
            // third:
            // handle events gives us an interesting window into all the flow mechanisms that
            // can happen during the Publish/Subscribe conversation, including capturing when
            // we receive completions, values, etc
            print("receiveOutput was invoked with \(String(describing: aValue))")
            XCTAssertEqual(aValue, "DATA IN")
        }, receiveCompletion: { aValue in 4️⃣
            // completion .finished were sent in this test
            print("receiveCompletion event called with \(String(describing: aValue))")
        }, receiveCancel: { 5️⃣
            // no cancellations sent in this test
            print("receiveCancel event invoked")
            XCTFail("cancel should not be received in this test")
        }, receiveRequest: { aValue in 1️⃣
            print("receiveRequest event called with \(String(describing: aValue))")
            // this happened first:
            // receiveRequest event called with unlimited
            XCTAssertEqual(aValue, Subscribers.Demand.unlimited)
        })
        .sink(receiveValue: { aValue in
            // sink captures and terminates the pipeline of operators
            print("sink captured the result of \(String(describing: aValue))")
        })

    publisher.send("DATA IN")
    publisher.send(completion: .finished)
    XCTAssertNotNil(cancellable)
}
```

- 1️⃣ The first closure called is `receiveRequest`, which will have the *demand value* passed into it.
- 2️⃣ The second closure `receiveSubscription` is commonly the returning subscription from the publisher, which passes in a reference to the publisher. At this point, the pipeline is operational, and the publisher will provide data based on the amount of data requested in the original request.
- 3️⃣ This data is passed into `receiveOutput` as the publisher makes it available, invoking the closure for each value passed. This will repeat for as many values as the publisher sends.
- 4️⃣ If the pipeline is closed - either normally or terminated due to a failure - the `receiveCompletion` closure will get the completion. Just the like the `sink` closure, you can switch on the `completion` provided, and if it is a `.failure` completion, then you can inspect the enclosed error.
- 5️⃣ If the pipeline is cancelled, then the `receiveCancel` closure will be called. No data is passed into the cancellation closure.

> While you can also use `breakpoint` and `breakpointOnError` operators to break into a debugger (as shown in [Debugging pipelines with the debugger](#debugging-pipelines-with-the-debugger)), the `handleEvents()` operator with closures allows you to set breakpoints within Xcode. This allows you to immediately jump into the debugger to inspect the data flowing through the pipeline, or to get references to the subscriber, or the error in the case of a failed completion.

## Debugging pipelines with the debugger

**Goal**:

- To force the pipeline to trap into a debugger on specific scenarios or conditions.

> You can set a breakpoint within any closure to any operator within a pipeline, triggering the debugger to activate to inspect the data. Since the `map` operator is frequently used for simple output type conversions, it is often an excellent candidate that has a closure you can use. If you want to see into the control messages, then a breakpoint within any of the closures provided to `handleEvents` makes a very convenient target.

You can also use the `breakpoint` operator to trigger the debugger, which can be a very quick and convenient way to see what is happening in a pipeline. The `breakpoint` operator acts very much like `handleEvents`, taking a number of optional parameters, closures that are expected to return a *boolean*, and if `true` will invoke the debugger.

The optional closures include:

- `receiveSubscription`
- `receiveOutput`
- `receiveCompletion`

```swift
.breakpoint(receiveSubscription: { subscription in
    return false // return true to throw SIGTRAP and invoke the debugger
}, receiveOutput: { value in
    return false // return true to throw SIGTRAP and invoke the debugger
}, receiveCompletion: { completion in
    return false // return true to throw SIGTRAP and invoke the debugger
})
```

This allows you to provide logic to evaluate the data being passed through, and only triggering a breakpoint when your specific conditions are met. With very active pipelines processing a lot of data, this can be a great tool to be more surgical in getting the debugger active when you need it, and letting the other data move on by.

If you are only interested in the breaking into the debugger on error conditions, then convenience operator `breakPointOnError` is perfect. It takes no parameters or closures, simply invoking the debugger when an error condition of any form is passed through the pipeline.

```swift
.breakpointOnError()
```

> **Info**: The location of the breakpoint that is triggered by the breakpoint operator isn’t in your code, so getting to local frames and information can be a bit tricky. This does allow you to inspect global application state in highly specific instances (whenever the closure returns `true`, with logic you provide), but you may find it more effective to use regular breakpoints within closures.
>  
> The `breakpoint()` and `breakpointOnError()` operators don’t immediately drop you into a closure where you can see the data being passed, error thrown, or control signals that may have triggered the breakpoint. You can often walk back up the stack trace within the debugging window to see the publisher.
>  
> When you trigger a breakpoint within an operator’s closure, the debugger immediately gets the context of that closure as well, so you can see/inspect the data being passed.
