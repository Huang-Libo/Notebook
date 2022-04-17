# Operators

The chapter on [Core Concepts](https://heckj.github.io/swiftui-notes/#coreconcepts) includes an overview of all available [Operators](https://heckj.github.io/swiftui-notes/#coreconcepts-operators).

- [Operators](#operators)
  - [Mapping elements](#mapping-elements)
    - [scan](#scan)
    - [tryScan](#tryscan)
    - [map](#map)
    - [tryMap](#trymap)

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


