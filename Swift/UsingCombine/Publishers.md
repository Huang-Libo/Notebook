# Publishers

For general information about publishers see [Publishers](https://heckj.github.io/swiftui-notes/#coreconcepts-publishers) and [Lifecycle of Publishers and Subscribers](https://heckj.github.io/swiftui-notes/#coreconcepts-lifecycle).

- [Publishers](#publishers)
  - [`enum Publishers`](#enum-publishers)
  - [Just](#just)
  - [Future](#future)
  - [Deferred](#deferred)
  - [Empty](#empty)
  - [Fail](#fail)
  - [Record](#record)
  - [Publishers.Sequence](#publisherssequence)
  - [Publishers.MakeConnectable](#publishersmakeconnectable)
  - [SwiftUI](#swiftui)
    - [Binding](#binding)
    - [SwiftUI and Combine](#swiftui-and-combine)
  - [ObservableObject](#observableobject)
  - [@Published](#published)
  - [Foundation](#foundation)
    - [NotificationCenter](#notificationcenter)
  - [Timer](#timer)
  - [publisher from a KeyValueObserving instance](#publisher-from-a-keyvalueobserving-instance)

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

## Deferred

A publisher that awaits subscription before running the supplied closure to create a publisher for the new subscriber.

**Declaration**:

```swift
struct Deferred<DeferredPublisher> where DeferredPublisher : Publisher
```

**Overview**:

`Deferred` is useful when creating an API to return a publisher, where creating the publisher is an expensive effort, either computationally or in the time it takes to set up. Deferred holds off on setting up any publisher data structures until a subscription is requested. This provides a means of deferring the setup of the publisher until it is actually needed.

The `Deferred` publisher is particularly useful with `Future`, which does not wait on demand to start the resolution of underlying (wrapped) asynchronous APIs.

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

## Record

A publisher that allows for recording a series of inputs and a completion, for later playback to each subscriber.

**Declaration**:

```swift
struct Record<Output, Failure> where Failure : Error
```

**Overview**:

> `Record` allows you to create a publisher with pre-recorded values for repeated playback. `Record` acts very similarly to `Publishers.Sequence` if you want to publish a sequence of values and then send a `.finished` completion. It goes beyond that allowing you to specify a `.failure` completion to be sent from the recording. `Record` does not allow you to control the timing of the values being returned, only the order and the eventual completion following them.

`Record` can also be serialized (encoded and decoded) as long as the output and failure values can be serialized as well.

An example of a simple recording that sends several string values and then a `.finished` completion:

```swift
// creates a recording
let recordedPublisher = Record<String, Never> { example in
    // example : type is Record<String, Never>.Recording
    example.receive("one")
    example.receive("two")
    example.receive("three")
    example.receive(completion: .finished)
}
```

The resulting instance can be used as a publisher immediately:

```swift
let cancellable = recordedPublisher.sink(receiveCompletion: { err in
    print(".sink() received the completion: ", String(describing: err))
    expectation.fulfill()
}, receiveValue: { value in
    print(".sink() received value: ", value)
})
```

`Record` also has a property `recording` that can be inspected, with its own properties of output and completion. `Record` and `recording` do not conform to `Equatable`, so can’t be easily compared within tests. It is fairly easy to compare the properties of `output` or `completion`, which are `Equatable` if the underlying contents (output type and failure type) are equatable.

> **Note**: No convenience methods exist for creating a recording as a subscriber. You can use the receive methods to create one, wrapping a `sink` subscriber.

## Publishers.Sequence

A publisher that publishes a given sequence of elements.

**Declaration**:

```swift
struct Sequence<Elements, Failure> where Elements : Sequence, Failure : Error
```

**Overview**:

> `Sequence` provides a way to return values as subscribers demand them initialized from a collection. Formally, it provides elements from any type conforming to the `Sequence` protocol.

If a subscriber requests unlimited demand, all elements will be sent, and then a `.finished` completion will terminate the output. If the subscribe requests a single element at a time, then individual elements will be returned based on demand.

If the type within the sequence is denoted as `optional`, and a `nil` value is included within the sequence, that will be sent as an instance of the optional type.

Combine provides an extension onto the `Sequence` protocol so that anything that corresponds to it can act as a sequence publisher. It does so by making a `.publisher` property available, which implicitly creates a `Publishers.Sequence` publisher.

```swift
let initialSequence = ["one", "two", "red", "blue"]
_ = initialSequence.publisher
    .sink {
        print($0)
    }
}
```

## Publishers.MakeConnectable

A publisher that provides explicit connectability to another publisher.

Creates a or converts a publisher to one that explicitly conforms to the `ConnectablePublisher` protocol. The failure type of the publisher must be `<Never>`.

**Declaration**:

```swift
struct MakeConnectable<Upstream> where Upstream : Publisher
```

**Overview**:

`Publishers.MakeConnectable` is a `ConnectablePublisher`, which allows you to perform configuration before publishing any elements. Call `connect()` on this publisher when you want to attach to its upstream publisher and start producing elements.
Use the `makeConnectable()` *operator* to wrap an upstream publisher with an instance of this publisher.

> A connectable publisher has an explicit mechanism for enabling when a subscription and the flow of demand from subscribers will be allowed to the publisher. By conforming to the `ConnectablePublisher` protocol, a publisher will have two additional methods exposed for this control: `connect()` and `autoconnect()`. Both of these methods return a `Cancellable`.

When using `connect()`, the receipt of subscription will be under imperative control. Normally when a subscriber is linked to a publisher, the connection is made automatically, subscriptions get sent, and demand gets negotiated per the [Lifecycle of Publishers and Subscribers](https://heckj.github.io/swiftui-notes/#coreconcepts-lifecycle). With a connectable publisher, in addition to setting up the subscription `connect()` needs to be explicitly invoked. Until `connect()` is invoked, the subscription won’t be received by the publisher.

```swift
var cancellables = Set<AnyCancellable>()
let publisher = Just("woot")
    .makeConnectable()

publisher.sink { value in
    print("Value received in sink: ", value)
}
.store(in: &cancellables)
```

The above code will not activate the subscription, and in turn show any results. In order to enable the subscription, an explicit `connect()` is required:

```swift
publisher
    .connect()
    .store(in: &cancellables)
```

One of the primary uses of having a connectable publisher is to coordinate the timing of connecting multiple subscribers with `multicast`. Because `multicast` only shares existing events and does not replay anything, a subscription joining late could miss some data. **By explicitly enabling the `connect()`, all subscribers can be attached before any upstream processing begins.**

In comparison, `autoconnect()` makes a Connectable publisher act like a non-connectable one. **When you enabled `autoconnect()` on a Connectable publisher, it will automate the connection such that the first subscription will activate upstream publishers.**

```swift
var cancellables = Set<AnyCancellable>()
let publisher = Just("woot")
    .makeConnectable() 1️⃣
    .autoconnect() 2️⃣

publisher.sink { value in
    print("Value received in sink: ", value)
}
.store(in: &cancellables)
```

- 1️⃣ `makeConnectable()` wraps an existing publisher and makes it explicitly connectable.
- 2️⃣ `autoconnect()` automates the process of establishing the connection for you; The *first* subscriber will establish the connection, subscriptions will be forwards and demand negotiated.

> **Info**: Making a publisher connectable and then immediately enabling `autoconnect` is an odd example, as you typically want one explicit pattern of behavior or the other. The two mechanisms allow you to choose which you want for the needs of your code. As such, it is extremely unlikely that you would ever want to use `makeConnectable()` followed immediately by `autoconnect()`.

Both `Timer` and `multicast` are examples of connectable publishers.

## SwiftUI

The SwiftUI framework is based upon displaying views from explicit state; as the state changes, the view updates.

SwiftUI uses a variety of *property wrappers* within its `View`s to reference and display content from outside of those views. `@ObservedObject`, `@EnvironmentObject`, and `@Published` are the most common that relate to Combine. SwiftUI uses these *property wrappers* to create a publisher that will inform SwiftUI when those models have changed, creating a `objectWillChange` publisher. Having an object conform to `ObservableObject` will also get a default `objectWillChange` publisher.

SwiftUI uses `ObservableObject`, which has a default concrete class implementation called `ObservableObjectPublisher` that exposes a publisher for reference objects (classes) marked with `@ObservedObject`.

### Binding

SwiftUI does this primarily by tracking the state and changes to the state using the SwiftUI struct `Binding`. A binding is **not** a Combine pipeline, or even usable as one. A `Binding` is based on closures that are used when you get or set data through the binding. When creating a `Binding`, you can specify the closures, or use the defaults, which handles the needs of SwiftUI elements to react when data is set or request data when a view requires it.

There are a number of SwiftUI *property wrappers* that create bindings:

`@State`: creates a binding to a local view property, and is intended to be used only in one view.

when you create:

```swift
@State private var exampleString = ""
```

then: `exampleString` is the state itself and the *property wrapper* creates *$exampleString* (also known as *property wrapper*’s *projected value*) which is of type `Binding<String>`.

- `@Binding`: is used to reference an externally provided binding that the view wants to use to present itself. You will see there upon occasion when a view is expected to be component, and it is watching for its relevant state data from an enclosing view.
- `@EnvironmentObject`: make state visible and usable across a set of views. `@EnvironmentObject` is used to inject your own objects or state models into the environment, making them available to be used by any of the views within the current view hierarchy.

> **Info**: The exception to `@EnvironmentObject` cascading across the view hierarchy in SwiftUI is notably when using sheets. **Sheets don’t inherit the environment from the view through which they are presented.**

- `@Environment is` used to expose environmental information already available from within the frameworks, for example:

```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass
```

### SwiftUI and Combine

All of this detail on Binding is important to how SwiftUI works, but irrelevant to Combine - *Bindings* are not combine pipelines or structures, and the classes and structs that SwiftUI uses are directly transformable from Combine publishers or subscribers.

SwiftUI does, however, use combine in coordination with *Bindings*. Combine fits in to SwiftUI when the state has been externalized into a reference to a model object, most often using the *property wrappers* `@ObservedObject` to reference a class conforming to the `ObservableObject` protocol.

The core of the `ObservableObject` protocol is a combine publisher `objectWillChange`, which is used by the SwiftUI framework to know when it needs to invalidate a view based on a model changing. The `objectWillChange` publisher only provides an indicator that **something** has changed on the model, not which property, or what changed about it.

The author of the model class can "opt-in" properties into triggering that change using the `@Published` *property wrapper*. If a model has properties that aren’t wrapped with `@Published`, then the automatic `objectWillChange` notification won’t get triggered when those values are modified. Typically the model properties will be referenced directly within the View elements. When the view is invalidated by a value being published through the `objectWillChange` publisher, the SwiftUI View will request the data it needs, as it needs it, directly from the various model references.

---

The other way that Combine fits into SwiftUI is the method `onReceive`, which is a generic instance method on SwiftUI views.

`onReceive` can be used when a view needs to be updated based on some external event that isn’t directly reflected in a model’s state being updated.

While there is no explicit guidance from Apple on how to use `onReceive` vs. *models*,

- as a general guideline it will be a cleaner pattern to update the model using Combine, keeping the combine publishers and pipelines external to SwiftUI views. In this mode, you would generally let the `@ObservedObject` SwiftUI declaration automatically invalidate and update the view, which separates the model updating from the presentation of the view itself.
- The alternative ends up having the view bound fairly tightly to the combine publishers providing asynchronous updates, rather than a coherent view of the end state. There are still some edge cases and needs where you want to trigger a view update directly from a publishers output, and that is where `onReceive` is most effectively used.

## ObservableObject

A type of object with a publisher that emits before the object has changed.

**Declaration**:

```swift
protocol ObservableObject : AnyObject
```

**Overview**:

By default an `ObservableObject` synthesizes an `objectWillChange` publisher that emits the changed value before any of its `@Published` properties changes.

```swift
class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func haveBirthday() -> Int {
        age += 1
        return age
    }
}

let john = Contact(name: "John Appleseed", age: 24)
cancellable = john.objectWillChange
    .sink { _ in
        print("\(john.age) will change")
}
print(john.haveBirthday())
// Prints "24 will change"
// Prints "25"
```

> When a class includes a `@Published` property and conforms to the `ObservableObject` protocol, this class instances will get a `objectWillChange` publisher endpoint providing this publisher. The `objectWillChange` publisher will not return any of the changed data, only an indicator that the referenced object has changed.

The output type of `ObservableObject.Output` is type aliased to `Void`, so while it is not `nil`, it will not provide any meaningful data. Because the output type does not include what changes on the referenced object, the best method for responding to changes is probably best done using `sink`.

In practice, this method is most frequently used by the SwiftUI framework. SwiftUI views use the `@ObservedObject` *property wrapper* to know when to invalidate and refresh views that reference classes implementing `ObservableObject`.

Classes implementing `ObservableObject` are also expected to use `@Published` to provide notifications of changes on specific properties, or to optionally provide a custom announcement that indicates the object has changed.

It can also be used locally to watch for updates to a reference-type model.

## @Published

A *property wrapper* that adds a Combine publisher to any property.

**Declaration**:

```swift
@propertyWrapper struct Published<Value>
```

**Overview**:

Publishing a property with the `@Published` attribute creates a *publisher* of this type. You access the *publisher* with the `$` operator, as shown here:

```swift
class Weather {
    @Published var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}

let weather = Weather(temperature: 20)
cancellable = weather.$temperature
    .sink() {
        print ("Temperature now: \($0)")
}
weather.temperature = 25

// Prints:
// Temperature now: 20.0
// Temperature now: 25.0
```

When the property changes, publishing occurs in the property’s `willSet` block, meaning subscribers receive the new value before it’s actually set on the property. In the above example, the second time the sink executes its closure, it receives the parameter value `25`. However, if the closure evaluated `weather.temperature`, the value returned would be `20`.

> **Important**: The `@Published` attribute is class constrained. Use it with properties of classes, not with non-class types like structures.

`@Published` is part of Combine, but allows you to wrap a property, enabling you to get a publisher that triggers data updates whenever the property is changed. The publisher’s output type is inferred from the type of the property, and the error type of the provided publisher is `<Never>`.

A smaller examples of how it can be used:

```swift
@Published var username: String = "" 1️⃣

$username 2️⃣
    .sink { someString in
        print("value of username updated to: ", someString)
    }

$username 3️⃣
    .assign(\.text, on: myLabel)

@Published private var githubUserData: [GithubAPIUser] = [] 4️⃣
```

- 1️⃣ `@Published` wraps the property, `username`, and will generate events whenever the property is changed. **If there is a subscriber at initialization time, the subscriber will also receive the initial value being set.** The publisher for the property is available at the same scope, and with the same permissions, as the property itself.
- 2️⃣ The publisher is accessible as `$username`, of type `Published<String>.publisher`.
- 3️⃣ A Published property can have more than one subscriber pipeline triggering from it.
- 4️⃣ **If you are publishing your own type, you may find it convenient to publish an array of that type as the property, even if you only reference a single value.** This allows you represent an "Empty" result that is still a concrete result within Combine pipelines, as `assign` and `sink` subscribers will only trigger updates on non-`nil` values.

If the publisher generated from `@Published` receives a cancellation from any subscriber, it is expected to, and will cease, reporting property changes. Because of this expectation, it is common to arrange pipelines from these publishers that have an error type of `<Never>` and do all error handling within the pipelines.

For example, if a `sink` subscriber is set up to capture errors from a pipeline originating from a `@Published` property, when the error is received, the sink will send a `cancel` message, causing the publisher to cease generating any updates on change. This is illustrated in the test `testPublishedSinkWithError` at [UsingCombineTests/PublisherTests.swift](https://github.com/heckj/swiftui-notes/blob/master/UsingCombineTests/PublisherTests.swift).

Additional examples of how to arrange error handling for a continuous publisher like `@Published` can be found at [Using flatMap with catch to handle errors](https://heckj.github.io/swiftui-notes/#patterns-continual-error-handling).

## Foundation

### NotificationCenter

Foundation’s `NotificationCenter` added the capability to act as a publisher, providing `Notification`s to pipelines.

`NotificationCenter` provides a *publisher* upon which you may create pipelines to declaratively react to application or system notifications. The *publisher* optionally takes an object reference which further filters notifications to those provided by the specific reference.

A number of AppKit controls provide notifications when the control has been updated. For example, AppKit’s `TextField` triggers a number of notifications including:

- `textDidBeginEditingNotification`
- `textDidChangeNotification`
- `textDidEndEditingNotification`

```swift
extension Notification.Name {
    static let yourNotification = Notification.Name("your-notification") 1️⃣
}

let cancellable = NotificationCenter.default.publisher(for: .yourNotification, object: nil) 2️⃣
    .sink {
        print ($0) 3️⃣
    }
```

- 1️⃣ Notifications are defined by a string for their name. If defining your own, be careful to define the strings uniquely.
- 2️⃣ A `NotificationCenter` publisher can be created for a single type of notification, `.yourNotification` in this case, defined previously in your code.
- 3️⃣ Notifications are received from the publisher. These include at least their `name`, and optionally a `object` reference from the sending object - most commonly provided from Apple frameworks. Notifications may also include a `userInfo` dictionary of arbitrary values, which can be used to pass additional information within your application.

## Timer

Foundation’s `Timer` added the capability to act as a publisher, providing a publisher to repeatedly send values to pipelines based on a `Timer` instance.

> `Timer.publish` returns an instance of `Timer.TimerPublisher`. This publisher is a connectable publisher, conforming to `ConnectablePublisher`. This means that even when subscribers are connected to it, it will **not** start producing values until `connect()` or `autoconnect()` is invoked on the publisher.

Creating the timer publisher requires an `interval` in seconds, and a `RunLoop` and `mode` upon which to run. The publisher may optionally take an additional parameter `tolerance`, which defines a variance allowed in the generation of timed events. The default for `tolerance` is `nil`, **allowing any variance**.

The publisher has an output type of `Date` and a failure type of `<Never>`.

If you want the publisher to automatically connect and start receiving values **as soon as subscribers are connected** and make requests for values, then you may include `autoconnect()` in the pipeline to have it automatically start to generate values as soon as a subscriber requests data.

```swift
let cancellable = Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
    .autoconnect()
    .sink { receivedTimeStamp in
        print("passed through: ", receivedTimeStamp)
    }
```

Alternatively, you can connect up the subscribers, which will receive no values until you invoke `connect()` on the publisher, which also returns a `Cancellable` reference.

```swift
let timerPublisher = Timer.publish(every: 1.0, on: RunLoop.main, in: .default)
let cancellableSink = timerPublisher
    .sink { receivedTimeStamp in
        print("passed through: ", receivedTimeStamp)
    }
// no values until the following is invoked elsewhere/later:
let cancellablePublisher = timerPublisher.connect()
```

## publisher from a KeyValueObserving instance





