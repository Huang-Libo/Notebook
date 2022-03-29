# Testing and Debugging

- [Testing and Debugging](#testing-and-debugging)
  - [Introduction](#introduction)
  - [Testing a publisher with XCTestExpectation](#testing-a-publisher-with-xctestexpectation)
  - [Testing a subscriber with a PassthroughSubject](#testing-a-subscriber-with-a-passthroughsubject)
  - [Testing a subscriber with scheduled sends from PassthroughSubject](#testing-a-subscriber-with-scheduled-sends-from-passthroughsubject)

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



