# Testing and Debugging

- [Testing and Debugging](#testing-and-debugging)
  - [Introduction](#introduction)

## Introduction

The `Publisher`/`Subscriber` interface in Combine is beautifully suited to be an easily testable interface.

With the composability of Combine, you can use this to your advantage, creating APIs that present, or consume, code that conforms to `Publisher`.

With the `Publisher` protocol as the key interface, you can replace either side to validate your code in isolation.

For example, if your code was focused on providing its data from external web services through Combine, you might make the interface to this conform to `AnyPublisher<Data, Error>`. You could then use that interface to test either side of that pipeline independently.

- You can mock data responses that emulate the underlying API calls and possible responses, including various error conditions. This might include returning data from a publisher created with `Just` or `Fail`, or something more complex using `Future`. None of these options require you to make actual network interface calls.
- Likewise you can isolate the testing of making the publisher do the API calls and verify the various success and failure conditions expected.


