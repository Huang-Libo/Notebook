# Testing and Debugging

- [Testing and Debugging](#testing-and-debugging)
  - [Introduction](#introduction)
  - [Testing a publisher with XCTestExpectation](#testing-a-publisher-with-xctestexpectation)
  - [Testing a subscriber with a PassthroughSubject](#testing-a-subscriber-with-a-passthroughsubject)

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


