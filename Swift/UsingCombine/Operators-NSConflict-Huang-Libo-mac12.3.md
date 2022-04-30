# Operators

The chapter on [Core Concepts](https://heckj.github.io/swiftui-notes/#coreconcepts) includes an overview of all available [Operators](https://heckj.github.io/swiftui-notes/#coreconcepts-operators).

- [Operators](#operators)
  - [Mapping elements](#mapping-elements)
    - [scan](#scan)
    - [tryScan](#tryscan)
    - [map](#map)
    - [tryMap](#trymap)
    - [flatMap](#flatmap)
    - [setFailureType](#setfailuretype)
  - [Filtering elements](#filtering-elements)
    - [compactMap](#compactmap)
    - [tryCompactMap](#trycompactmap)
    - [filter](#filter)
    - [tryFilter](#tryfilter)
    - [removeDuplicates](#removeduplicates)
    - [tryRemoveDuplicates](#tryremoveduplicates)
    - [replaceEmpty](#replaceempty)
    - [replaceError](#replaceerror)
    - [replaceNil](#replacenil)
  - [Reducing elements](#reducing-elements)
    - [collect](#collect)
    - [ignoreOutput](#ignoreoutput)
    - [reduce](#reduce)
    - [tryReduce](#tryreduce)
  - [Mathematic operations on elements](#mathematic-operations-on-elements)
    - [max](#max)
    - [tryMax](#trymax)
    - [min](#min)
    - [tryMin](#trymin)
    - [count](#count)
  - [Applying matching criteria to elements](#applying-matching-criteria-to-elements)
    - [allSatisfy](#allsatisfy)
    - [tryAllSatisfy](#tryallsatisfy)
    - [contains](#contains)
    - [containsWhere](#containswhere)
    - [tryContainsWhere](#trycontainswhere)
  - [Applying sequence operations to elements](#applying-sequence-operations-to-elements)
    - [first](#first)
    - [first(where:)](#firstwhere)
    - [tryFirst(where:)](#tryfirstwhere)
    - [last](#last)
    - [last(where:)](#lastwhere)
    - [tryLast(where:)](#trylastwhere)
    - [drop(untilOutputFrom:)](#dropuntiloutputfrom)

## Mapping elements

### scan

`scan` acts like an accumulator, collecting and modifying values according to a closure you provide, and publishing intermediate results with each change from upstream.

![scan.svg](../../media/Swift/UsingCombine/scan.svg)

Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.

**Declaration**:

```swift
func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Scan<Self, T>
```

**Discussion**:

Use `scan(_:_:)` to accumulate all previously-published values into a single value, which you then combine with each newly-published value.
The following example logs a running total of all values received from the sequence publisher.

```swift
let range = (0...5)
cancellable = range.publisher
    .scan(0) { return $0 + $1 }
    .sink { print ("\($0)", terminator: " ") }
 // Prints: "0 1 3 6 10 15 ".
```

`Scan` lets you accumulate values or otherwise modify a type as changes flow through the pipeline. You can use this to collect values into an array, implement a counter, or any number of other interesting use cases.

- If you want to be able to throw an error from within the closure doing the accumulation to indicate an error condition, use the `tryScan` operator.
- If you want to accumulate and process values, but refrain from publishing any results until the upstream publisher completes, consider using the `reduce` or `tryReduce` operators.

When you create a `scan` operator, you provide an initial value (of the type determined by the upstream publisher) and a closure that takes two parameters - the result returned from the previous invocation of the closure and a new value from the upstream publisher. You do not need to maintain the type of the upstream publisher, but can convert the type in your closure, returning whatever is appropriate to your needs.

For example, the following `scan` operator implementation counts the number of characters in strings provided by an upstream publisher, publishing an updated count every time a new string is received:

```swift
.scan(0, { prevVal, newValueFromPublisher -> Int in
    return prevVal + newValueFromPublisher.count
})
```

### tryScan

`tryScan` is a variant of the `scan` operator which allows for the provided closure to throw an error and cancel the pipeline. The closure provided updates and modifies a value based on any inputs from an upstream publisher and publishing intermediate results.

![tryscan.svg](../../media/Swift/UsingCombine/tryscan.svg)

**Declaration**:

```swift
func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> Publishers.TryScan<Self, T>
```

**Discussion**:

Use `tryScan(_:_:)` to accumulate all previously-published values into a single value, which you then combine with each newly-published value. If your accumulator closure throws an error, the publisher terminates with the error.

In the example below, `tryScan(_:_:)` calls a division function on elements of a collection publisher. The `Publishers.TryScan` publisher publishes each result until the function encounters a `DivisionByZeroError`, which terminates the publisher.

If the closure throws an error, the publisher fails with the error:

```swift
struct DivisionByZeroError: Error {}

/// A function that throws a DivisionByZeroError if `current` provided by the TryScan publisher is zero.
func myThrowingFunction(_ lastValue: Int, _ currentValue: Int) throws -> Int {
    guard currentValue != 0 else { throw DivisionByZeroError() }
    return (lastValue + currentValue) / currentValue
 }

let numbers = [1,2,3,4,5,0,6,7,8,9]
cancellable = numbers.publisher
    .tryScan(10) { try myThrowingFunction($0, $1) }
    .sink(
        receiveCompletion: { print ("\($0)") },
        receiveValue: { print ("\($0)", terminator: " ") }
     )

// Prints: "11 6 3 1 1 failure(DivisionByZeroError())".
```

### map

`map` is most commonly used to convert one data type into another along a pipeline.

![map.svg](../../media/Swift/UsingCombine/map.svg)

**Declaration**:

```swift
func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T>
```

**Discussion**:

The `map` operator does not allow for any additional failures to be thrown and does not transform the failure type. If you want to throw an error within your closure, use the `tryMap` operator.

`map` takes a single closure where you provide the logic for the map operation.

> `map` is the all purpose workhorse operator in Combine. It provides the ability to manipulate the data, or the type of data, and is the **most** commonly used operator in pipelines.

For example, the `URLSession.dataTaskPublisher` provides a *tuple* of `(data: Data, response: URLResponse)` as its output. You can use `map` to pass along the data, for example to use with `decode`:

```swift
.map { $0.data } 1️⃣
```

- 1️⃣ the `$0` indicates to grab the first parameter passed in, which is a tuple of `data` and `response`.

In some cases, the closure may not be able to infer what data type you are returning, so you may need to provide a definition to help the compiler. For example, if you have an object getting passed down that has a boolean property `isValid` on it, and you want the boolean for your pipeline, you might set that up like:

```swift
struct MyStruct {
    isValid: bool = true
}

Just(MyStruct())
    .map { inValue -> Bool in 1️⃣
    inValue.isValid 2️⃣
    }
```

- `inValue` is named as the parameter coming in, and the return type is being explicitly specified to Bool
- A single line is an implicit return, in this case it is pulling the `isValid` property off the struct and passing it down.

### tryMap

`tryMap` is similar to `map`, except that it also allows you to provide a closure that throws additional errors if your conversion logic is unsuccessful.

`tryMap` is useful when you have more complex business logic around your `map` and you want to indicate that the data passed in is an error, possibly handling that error later in the pipeline. If you are looking at `tryMap` to decode JSON, you may want to consider using the `decode` operator instead, which is set up for that common task.

```swift
enum MyFailure: Error {
    case notBigEnough
}

Just(5)
    .tryMap {
    if inValue < 5 { 
        throw MyFailure.notBigEnough 
    }
    return inValue 
    }
```

### flatMap

Used with error recovery or async operations that might fail (for example `Future`), `flatMap` will replace any incoming values with another publisher.

**Declaration**:

```swift
func flatMap<T, P>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P) -> Publishers.FlatMap<P, Self> where T == P.Output, P : Publisher, Self.Failure == P.Failure
```

Typically used in error handling scenarios, `flatMap` takes a closure that allows you to read the incoming data value, and provide a publisher that returns a value to the pipeline.

In error handling, this is most frequently used to take the incoming value and create a *one-shot* pipeline that does some potentially failing operation, and then handling the error condition with a `catch` operator.

A simple example `flatMap`, arranged to show recovering from a decoding error and returning a placeholder value:

```swift
.flatMap { data in
    return Just(data)
        .decode(YourType.self, JSONDecoder())
        .catch {
            return Just(YourType.placeholder)
        }
}
```

A diagram version of this pipeline construct:

![flatmap.svg](../../media/Swift/UsingCombine/flatmap.svg)

> `flatMap` expects to create a new pipeline within its closure for every input value that it receives. The expected result of this internal pipeline is a Publisher with its own output and failure type. The output type of the publisher resulting from the internal pipeline defines the output type of the `flatMap` operator. The error type of the internal publisher is often expected to be `<Never>`.

**Discussion**:

Use `flatMap(maxPublishers:_:)` when you want to create a new series of events for downstream subscribers based on the received value. The closure creates the new Publisher based on the received value. The new Publisher can emit more than one event, and successful completion of the new Publisher does not complete the overall stream. Failure of the new Publisher causes the overall stream to fail.

In the example below, a `PassthroughSubject` publishes `WeatherStation` elements. The `flatMap(maxPublishers:_:)` receives each element, creates a `URL` from it, and produces a new `URLSession.DataTaskPublisher`, which will publish the data loaded from that `URL`.

```swift
public struct WeatherStation {
    public let stationID: String
}

var weatherPublisher = PassthroughSubject<WeatherStation, URLError>()

cancellable = weatherPublisher.flatMap { station -> URLSession.DataTaskPublisher in
    let url = URL(string:"https://weatherapi.example.com/stations/\(station.stationID)/observations/latest")!
    return URLSession.shared.dataTaskPublisher(for: url)
}
.sink(
    receiveCompletion: { completion in
        // Handle publisher completion (normal or error).
    },
    receiveValue: {
        // Process the received data.
    }
 )

weatherPublisher.send(WeatherStation(stationID: "KSFO")) // San Francisco, CA
weatherPublisher.send(WeatherStation(stationID: "EGLC")) // London, UK
weatherPublisher.send(WeatherStation(stationID: "ZBBB")) // Beijing, CN
```

### setFailureType

`setFailureType` does not send a `.failure` completion, it just changes the `Failure` type associated with the pipeline. Use this publisher type when you need to match the error types for two otherwise mismatched publishers.

**Declaration**:

```swift
struct SetFailureType<Upstream, Failure> where Upstream : Publisher, Failure : Error, Upstream.Failure == Never
```

![setFailureType.svg](../../media/Swift/UsingCombine/setFailureType.svg)

`setFailureType` is an operator for transforming the error type within a pipeline, often from `<Never>` to some error type you may want to produce. `setFailureType` does not induce an error, but changes the types of the pipeline.

This can be especially convenient if you need to match an operator or subscriber that expects a failure type other than `<Never>` when you are working with a test or single-value publisher such as `Just` or `Sequence`.

If you want to return a `.failure` completion of a specific type into a pipeline, use the `Fail` operator.

## Filtering elements

### compactMap

Calls a closure with each received element and publishes any returned optional that has a value.

**Declaration**:

```swift
func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T>
```

![compactMap.svg](../../media/Swift/UsingCombine/compactMap.svg)

**Discussion**:

Combine’s `compactMap(_:)` operator performs a function similar to that of `compactMap(_:)` in the Swift standard library: the `compactMap(_:)` operator in Combine removes `nil` elements in a publisher’s stream and republishes non-`nil` elements to the downstream subscriber.

The example below uses a range of `numbers` as the source for a collection based publisher. The `compactMap(_:)` operator consumes each element from the `numbers` publisher attempting to access the dictionary using the element as the key. If the example’s dictionary returns a `nil`, due to a non-existent key, `compactMap(_:)` filters out the `nil` (missing) elements.

```swift
let numbers = (0...5)
let romanNumeralDict: [Int : String] =
    [1: "I", 2: "II", 3: "III", 5: "V"]

cancellable = numbers.publisher
    .compactMap { romanNumeralDict[$0] }
    .sink { print("\($0)", terminator: " ") }

// Prints: "I II III V"
```

> `compactMap` is very similar to the `map` operator, with the exception that it expects the closure to return an optional value, and drops any `nil` values from published responses. This is the combine equivalent of the `compactMap` function which iterates through a `Sequence` and returns a sequence of any non-`nil` values.

It can also be used to process results from an upstream publisher that produces an optional Output type, and collapse those into an unwrapped type. The simplest version of this just returns the incoming value directly, which will filter out the `nil` values.

```swift
.compactMap {
    return $0
}
```

There is also a variation of this operator, `tryCompactMap`, which allows the provided closure to throw an Error and cancel the stream on invalid conditions.

If you want to convert an optional type into a concrete type, always replacing the `nil` with an explicit value, you should likely use the `replaceNil` operator.

### tryCompactMap

`tryCompactMap` is a variant of the `compactMap` operator, allowing the values processed to throw an `Error` condition.

```swift
.tryCompactMap { someVal -> String? in 1️⃣
    if (someVal == "boom") {
        throw TestExampleError.example
    }
    return someVal
}
```

- 1️⃣ If you specify the return type within the closure, it should be an optional value. The operator that invokes the closure is responsible for filtering the non-`nil` values it publishes.

If you want to convert an optional type into a concrete type, always replacing the nil with an explicit value, you should likely use the `replaceNil` operator.

### filter

`Filter` passes through all instances of the output type that match a provided closure, dropping any that don’t match.

**Declaration**：

```swift
func filter(_ isIncluded: @escaping (Self.Output) -> Bool) -> Publishers.Filter<Self>
```

![filter.svg](../../media/Swift/UsingCombine/filter.svg)

`Filter` takes a single closure as a parameter that is provided the value from the previous publisher and returns a `Bool` value. If the return from the closure is true, then the operator republishes the value further down the chain. If the return from the closure is false, then the operator drops the value.

If you need a variation of this that will generate an error condition in the pipeline to be handled use the `tryFilter` operator, which allows the closure to throw an error in the evaluation.

**Discussion**:

Combine’s `filter(_:)` operator performs an operation similar to that of `filter(_:)` in the Swift Standard Library: it uses a closure to test each element to determine whether to republish the element to the downstream subscriber.

The following example, uses a filter operation that receives an `Int` and only republishes a value if it’s even.

```swift
let numbers: [Int] = [1, 2, 3, 4, 5]
cancellable = numbers.publisher
    .filter { $0 % 2 == 0 }
    .sink { print("\($0)", terminator: " ") }

// Prints: "2 4"
```

### tryFilter

`tryFilter` passes through all instances of the output type that match a provided closure, dropping any that don’t match, and allows generating an error during the evaluation of that closure.

Like filter, `tryFilter` takes a single closure as a parameter that is provided the value from the previous publisher and returns a `Bool` value. If the return from the closure is `true`, then the operator republishes the value further down the chain. If the return from the closure is `false`, then the operator drops the value.

You can additionally throw an error during the evaluation of `tryFilter`, which will then be propagated as the failure type down the pipeline.

### removeDuplicates

Publishes only elements that don’t match the *previous* element.

**Declaration**:

`removeDuplicates()`:

```swift
func removeDuplicates() -> Publishers.RemoveDuplicates<Self>
```

`removeDuplicates(by:)`:

```swift
func removeDuplicates(by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.RemoveDuplicates<Self>
```

![removeDuplicates.svg](../../media/Swift/UsingCombine/removeDuplicates.svg)

The default usage of removeDuplicates doesn’t require any parameters, and the operator will publish only elements that don’t match the previously sent element.

```swift
.removeDuplicates()
```

A second usage of `removeDuplicates` takes a single parameter by that accepts a closure that allows you to determine the logic of what will be removed. The parameter version does not have the constraint on the Output type being equatable, but requires you to provide the relevant logic. If the closure returns true, the `removeDuplicates` predicate will consider the values matched and not forward a the duplicate value.

```swift
.removeDuplicates(by: { first, second -> Bool in
    // your logic is required if the output type doesn't conform to equatable.
    first.id == second.id
})
```

A variation of removeDuplicates exists that allows the predicate closure to throw an error exists: `tryRemoveDuplicates`

**Discussion**:

Use `removeDuplicates()` to remove repeating elements from an upstream publisher. This operator has a **two-element memory**: the operator uses the current and *previously* published elements as the basis for its comparison.

In the example below, `removeDuplicates()` triggers on the doubled, tripled, and quadrupled occurrences of `1`, `3`, and `4` respectively. Because the *two-element memory* considers only the *current* element and the *previous* element, the operator prints the final `0` in the example data since its immediate predecessor is `4`.

```swift
let numbers = [0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 0]
cancellable = numbers.publisher
    .removeDuplicates()
    .sink { print("\($0)", terminator: " ") }

// Prints: "0 1 2 3 4 0"
```

### tryRemoveDuplicates

`tryRemoveDuplicates` is a variant of `removeDuplicates` that allows the predicate testing equality to throw an error, resulting in an `Error` completion type.

The parameter is a closure that allows you to determine the logic of what will be removed. If the closure throws an `error`, a failure completion will be propagated down the chain, and no value is sent.

```swift
.removeDuplicates(by: { first, second -> Bool throws in
    // your logic is required if the output type doesn't conform to equatable.

})
```

### replaceEmpty

Replaces an empty stream with the provided element. If the upstream publisher finishes without producing any elements, this publisher emits the provided element, then finishes normally.

`replaceEmpty` will only produce a result if it has not received any values before it receives a `.finished` completion. This operator will not trigger on an error passing through it, so if no value has been received with a `.failure` completion is triggered, it will simply not provide a value. The operator takes a single parameter, `with` where you specify the replacement value.

```swift
.replaceEmpty(with: "-replacement-")
```

This operator is useful specifically when you want a stream to always provide a value, even if an upstream publisher may not propagate one.

### replaceError

A publisher that replaces any errors with an output value that matches the upstream Output type.

Where `mapError` transforms an error, `replaceError` captures the error and returns a value that matches the Output type of the upstream publisher. If you don’t care about the specifics of the error itself, it can be a more convenient operator than using `catch` to handle an error condition.

```swift
.replaceError(with: "foo")
```

is more compact than

```swift
.catch { err in
    return Just("foo")
}
```

`catch` would be the preferable error handler if you wanted to return *another publisher* rather than a singular value.

### replaceNil

Replaces `nil` elements in the stream with the provided element.

![replace_nil.svg](../../media/Swift/UsingCombine/replace_nil.svg)

Used when the output type is an optional type, the `replaceNil` operator replaces any nil instances provided by the upstream publisher with a value provided by the user. The operator takes a single parameter, `with` where you specify the replacement value. The type of the replacement should be a *non-optional* version of the type provided by the upstream publisher.

```swift
.replaceNil(with: "-replacement-")
```

This operator can also be viewed as a way of converting an optional type to an explicit type, where optional values have a pre-determined placeholder. Put another way, the `replaceNil` operator is a Combine specific variant of the swift coalescing operator that you might use when unwrapping an optional.

If you want to convert an optional type into a concrete type, simply ignoring or collapsing the nil values, you should likely use the `compactMap` (or `tryCompactMap`) operator.

## Reducing elements

### collect

Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.

There are two primary forms of `collect`, one you specify without any parameters, and one you provide a `count` parameter. `collect` can also take a more complex form, with a defined strategy for how to buffer and send on items.

```swift
.collect()
```

The operator will collect all elements from an upstream publisher, holding those in memory until the upstream publisher sends a completion.

- Upon receiving the `.finished` completion, the operator will publish an array of all the values collected.
- If the upstream publisher fails with an error, the collect operator forwards the error to the downstream receiver instead of sending its output.

> **Warning**: This operator uses an unbounded amount of memory to store the received values.

`collect` without any parameters will request an unlimited number of elements from its upstream publisher. It only sends the collected array to its downstream after a request whose demand is greater than `0` items.

---

The second variation of collect takes a single parameter (`count`), which influences how many values it buffers and when it sends results.

```swift
.collect(3)
```

This version of `collect` will buffer up to the specified `count` number of elements. When it has received the count specified, it emits a single array of the collection.

If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received upon receiving a `finished` completion. This may be fewer than `count` elements.

If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.

---

The more complex form of `collect` operates on a provided strategy of how to collect values and when to emit.

As of iOS 13.3 there are two strategies published in `Publishers.TimeGroupingStrategy`:

- `byTime`
- `byTimeOrCount`

`byTime` allows you to specify a scheduler on which to operate, and a time interval stride over which to run. It collects all values received within that stride and publishes any values it has received from its upstream publisher during that interval. Like the parameterless version of `collect`, this will consume an unbounded amount of memory during that stride interval to collect values.

```swift
let queue = DispatchQueue(label: self.debugDescription)
let cancellable = publisher
    .collect(.byTime(queue, 1.0))
```

- `byTime` operates very similarly to `throttle` with its defined Scheduler and Stride, but where throttle collapses the values over a sequence of time, `collect(.byTime(q, 1.0))` will buffer and capture those values. When the time stride interval is exceeded, the collected set will be sent to the operator’s subscriber.
- `byTimeOrCount` also takes a scheduler and a time interval stride, and in addition allows you to specify an upper bound on the count of items received before the operator sends the collected values to its subscriber. The ability to provide a count allows you to have some confidence about the maximum amount of memory that the operator will consume while buffering values.

If either of the count or time interval provided are elapsed, the `collect` operator will forward the currently collected set to its subscribers.

- If a `.finished` completion is received, the currently collected set will be immediately sent to it’s subscribers.
- If a `.failure` completion is received, any currently buffered values are dropped and the `.failure` completion is forwarded to collect’s subscribers.

```swift
let queue = DispatchQueue(label: self.debugDescription)
let cancellable = publisher
    .collect(.byTimeOrCount(queue, 1.0, 5))
```

### ignoreOutput

A publisher that ignores all upstream elements, but passes along a completion state (finish or failed).

If you only want to know if a stream has finished (or failed), then `ignoreOutput` may be what you want.

```swift
.ignoreOutput()
.sink(receiveCompletion: { completion in
    print(".sink() received the completion", String(describing: completion))
    switch completion {
    case .finished: 2️⃣
        finishReceived = true
        break
    case .failure(let anError): 3️⃣
        print("received error: ", anError)
        failureReceived = true
        break
    }
}, receiveValue: { _ in 1️⃣
    print(".sink() data received")
})
```

- 1️⃣ No data will ever be presented to a downstream subscriber of `ignoreOutput`, so the `receiveValue` closure will never be invoked.
- 2️⃣ When the stream completes, it will invoke `receiveCompletion`. You can switch on the case from that completion to respond to the success.
- 3️⃣ Or you can do further processing based on receiving a failure.

### reduce

A publisher that applies a closure to all received elements and produces an accumulated value when the upstream publisher finishes.

![reduce.svg](../../media/Swift/UsingCombine/reduce.svg)

Very similar in function to the [scan](#scan) operator, reduce collects values produced within a stream. **The big difference between `scan` and `reduce` is that `reduce` does not trigger any values until the upstream publisher completes successfully.**

When you create a `reduce` operator, you provide an initial value (of the type determined by the upstream publisher) and a closure that takes two parameters - the result returned from the previous invocation of the closure and a new value from the upstream publisher.

Like `scan`, you don’t need to maintain the type of the upstream publisher, but can convert the type in your closure, returning whatever is appropriate to your needs.

An example of `reduce` that collects strings and appends them together:

```swift
.reduce("", { prevVal, newValueFromPublisher -> String in
    return prevVal+newValueFromPublisher
})
```

The `reduce` operator is excellent at converting a stream that provides many values over time into one that provides a single value upon completion.

### tryReduce

A publisher that applies a closure to all received elements and produces an accumulated value when the upstream publisher finishes, while also allowing the closure to throw an exception, terminating the pipeline.

`tryReduce` is a variation of the `reduce` operator that allows for the closure to throw an error. If the exception path is taken, the `tryReduce` operator will *not* publish any output values to downstream subscribers.

Like `reduce`, the `tryReduce` will only publish a *single* downstream result upon a `.finished` completion from the upstream publisher.

## Mathematic operations on elements

### max

Publishes the max value of all values received upon completion of the upstream publisher.

![max.svg](../../media/Swift/UsingCombine/max.svg)

`max` can be set up with either no parameters, or taking a closure. If defined as an operator with no parameters, the Output type of the upstream publisher must conform to `Comparable`.

```swift
.max()
```

If what you are publishing doesn’t conform to `Comparable`, then you may specify a closure to provide the ordering for the operator.

```swift
.max { (struct1, struct2) -> Bool in
    return struct1.property1 < struct2.property1
    // returning boolean true to order struct2 greater than struct1
    // the underlying method parameter for this closure hints to it:
    // `areInIncreasingOrder`
}
```

The parameter name of the closure hints to how it should be provided, being named `areInIncreasingOrder`. The closure will take two values of the output type of the upstream publisher, and within it you should provide a `boolean` result indicating if they are in increasing order.

The operator will not provide any results under the upstream published has sent a `.finished` completion. If the upstream publisher sends a `.failure` completion, then no values will be published and the `.failure` completion will be forwarded.

### tryMax

Publishes the `max` value of all values received upon completion of the upstream publisher.

A variation of the `max` operator that takes a closure to define ordering, and it also allowed to throw an error.

### min

Publishes the minimum value of all values received upon completion of the upstream publisher.

![min.svg](../../media/Swift/UsingCombine/min.svg)

`min` can be set up with either no parameters, or taking a closure. If defined as an operator with no parameters, the Output type of the upstream publisher must conform to `Comparable`.

```swift
.min()
```

If what you are publishing doesn’t conform to `Comparable`, then you may specify a closure to provide the ordering for the operator.

```swift
.min { (struct1, struct2) -> Bool in
    return struct1.property1 < struct2.property1
    // returning boolean true to order struct2 greater than struct1
    // the underlying method parameter for this closure hints to it:
    // `areInIncreasingOrder`
}
```

The parameter name of the closure hints to how it should be provided, being named `areInIncreasingOrder`. The closure will take two values of the output type of the upstream publisher, and within it you should provide a `boolean` result indicating if they are in increasing order.

The operator will not provide any results under the upstream published has sent a `.finished` completion. If the upstream publisher sends a `.failure` completion, then no values will be published and the `.failure` completion will be forwarded.

### tryMin

Publishes the minimum value of all values received upon completion of the upstream publisher.

A variation of the `min` operator that takes a closure to define ordering, and it also allowed to throw an error.

### count

`count` publishes the number of items received from the upstream publisher

![count.svg](../../media/Swift/UsingCombine/count.svg)

The operator will not provide any results under the upstream published has sent a `.finished` completion. If the upstream publisher sends a `.failure` completion, then no values will be published and the `.failure` completion will be forwarded.

## Applying matching criteria to elements

### allSatisfy

A publisher that publishes a *single* `Boolean` value that indicates whether all received elements pass a provided predicate.

![allSatisfy.svg](../../media/Swift/UsingCombine/allSatisfy.svg)

The operator will compare any incoming values, only responding when the upstream publisher sends a `.finished` completion. At that point, the `allSatisfies` operator will return a *single* `boolean` value indicating if *all* the values received matched (or not) based on processing through the provided closure.

If the operator receives a `.failure` completion from the upstream publisher, or throws an error itself, then *no* data values will be published to subscribers. In those cases, the operator will only return (or forward) the `.failure` completion.

### tryAllSatisfy

A publisher that publishes a *single* `Boolean` value that indicates whether all received elements pass a given throwing predicate.

### contains

A publisher that emits a `Boolean` value when a specified element is received from its upstream publisher.

![contains.svg](../../media/Swift/UsingCombine/contains.svg)

The simplest form of `contains` accepts a single parameter. The type of this parameter must match the Output type of the upstream publisher.

The operator will compare any incoming values, only responding when the incoming value is equatable to the parameter provided.

- When it does find a match, the operator returns a single boolean value (`true`) and then terminates the stream. **Any further values published from the upstream provider are then ignored.**
- If the upstream published sends a `.finished` completion before any values do match, the operator will publish a *single* boolean (`false`) and then terminate the stream.

### containsWhere

A publisher that emits a `Boolean` value upon receiving an element that satisfies the predicate closure.

![containsWhere.svg](../../media/Swift/UsingCombine/containsWhere.svg)

A more flexible version of the [contains](#contains) operator. Instead of taking a single parameter value to match, you provide a closure which takes in a single value (of the type provided by the upstream publisher) and returns a boolean.

Like `contains`, it will compare multiple incoming values, only responding when the incoming value is equatable to the parameter provided. When it does find a match, the operator returns a single `boolean` value and terminates the stream. **Any further values published from the upstream provider are ignored.**

If the upstream published sends a `.finished` completion before any values do match, the operator will publish a *single* boolean (`false`) and terminates the stream.

If you want a variant of this functionality that checks multiple incoming values to determine if *all* of them match, consider using the [allSatisfy](#allsatisfy) operator.

### tryContainsWhere

A publisher that emits a `Boolean` value upon receiving an element that satisfies the throwing predicate closure.

If the operator receives a `.failure` completion from the upstream publisher, or throws an error itself, *no* data values will be published to subscribers. In those cases, the operator will only return (or forward) the `.failure` completion.

## Applying sequence operations to elements

### first

Publishes the first element of a stream, then finishes.

**Declaration**:

```swift
func first() -> Publishers.First<Self>
```

![first.svg](../../media/Swift/UsingCombine/first.svg)

The `first` operator, when used without any parameters, will pass through the first value it receives, after which it sends a `.finish` completion message to any subscribers. If no values are received before the `first` operator receives a `.finish` completion from upstream publishers, the stream is terminated and no values are published.

```swift
let numbers = (-10...10)
cancellable = numbers.publisher
    .first()
    .sink { print("\($0)") }

// Print: "-10"
```

If you want a set number of values from the front of the stream you can also use `prefixUntilOutput` or the variants: `prefixWhile` and `tryPrefixWhile`.

If you want a set number of values from the middle the stream by count, you may want to use `output`, which allows you to select either a single value, or a range value from the sequence of values received by this operator.

### first(where:)

Publishes the first element of a stream to satisfy a predicate closure, then finishes normally.

**Declaration**:

```swift
func first(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.FirstWhere<Self>
```

**Discussion**:

Use `first(where:)` to republish only the first element of a stream that satisfies a closure you specify. The publisher ignores all elements after the first element that satisfies the closure and finishes normally. If this publisher doesn’t receive any elements, it finishes without publishing.

In the example below, the provided closure causes the `Publishers.FirstWhere` publisher to republish the first received element that’s greater than 0, then finishes normally.

```swift
let numbers = (-10...10)
cancellable = numbers.publisher
    .first { $0 > 0 }
    .sink { print("\($0)") }

// Prints: "1"
```

### tryFirst(where:)

The `tryFirstWhere` operator is a variant of `firstWhere` that accepts a closure that can throw an error.

**Declaration**:

```swift
func tryFirst(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryFirstWhere<Self>
```

**Discussion**:

Use `tryFirst(where:)` when you need to republish only the first element of a stream that satisfies an error-throwing closure you specify. The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing. If the predicate closure throws an error, the publisher fails.

In the example below, a range publisher emits the first element in the range then finishes normally:

```swift
let numberRange: ClosedRange<Int> = (-1...50)
numberRange.publisher
    .tryFirst {
        guard $0 < 99 else {throw RangeError()}
        return true
    }
    .sink(
        receiveCompletion: { print ("completion: \($0)", terminator: " ") },
        receiveValue: { print ("\($0)", terminator: " ") }
     )

// Prints: "-1 completion: finished"
// If instead the number range were ClosedRange<Int> = (100...200), the tryFirst operator would terminate publishing with a RangeError.
```

### last

Publishes the last element of a stream, after the stream finishes.

**Declaration**:

```swift
func last() -> Publishers.Last<Self>
```

![last.svg](../../media/Swift/UsingCombine/last.svg)

The `last` operator waits until the upstream publisher sends a `.finished` completion, then publishes the last value it received. If no values were received prior to receiving the `.finished` completion, no values are published to subscribers.

```swift
let numbers = (-10...10)
cancellable = numbers.publisher
    .last()
    .sink { print("\($0)") }

// Prints: "10"
```

### last(where:)

The `lastWhere` operator takes a single closure, accepting a value matching the output type of the upstream publisher, and returning a `boolean`. The operator publishes a value when the upstream published completes with a `.finished` completion.

**Declaration**:

```swift
func last(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.LastWhere<Self>
```

- The value published will be the last one to satisfy the provide closure.
- If no values satisfied the closure, then no values are published and the pipeline is terminated normally with a `.finished` completion.

```swift
let numbers = (-10...10)
cancellable = numbers.publisher
    .last { $0 < 6 }
    .sink { print("\($0)") }

// Prints: "5"
```

### tryLast(where:)

Publishes the last element of a stream that satisfies an error-throwing predicate closure, after the stream finishes.

**Declaration**:

```swift
func tryLast(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryLastWhere<Self>
```

**Discussion**:

In the example below, a publisher emits the last element that satisfies the error-throwing closure, then finishes normally:

```swift
struct RangeError: Error {}

let numbers = [-62, 1, 6, 10, 9, 22, 41, -1, 5]
cancellable = numbers.publisher
    .tryLast {
        guard 0 != 0  else {throw RangeError()}
        return true
    }
    .sink(
        receiveCompletion: { print ("completion: \($0)", terminator: " ") },
        receiveValue: { print ("\($0)", terminator: " ") }
    )
// Prints: "5 completion: finished"
// If instead the numbers array had contained a `0`, the `tryLast` operator would terminate publishing with a RangeError."
```

### drop(untilOutputFrom:)

A publisher that ignores elements from the upstream publisher until it receives an element from second publisher.




