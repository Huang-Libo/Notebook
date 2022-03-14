# Core Concepts

There are only a few core concepts that you need to know to use Combine effectively, but they are very important to understand. Each of these concepts is mirrored in the framework with a *generic protocol*, formalizing the concepts into expected functions.

These core concepts are: *Publisher*, *Subscriber*, *Operator*, *Subject*.

- [Core Concepts](#core-concepts)
  - [Publisher and Subscriber](#publisher-and-subscriber)
  - [Describing pipelines with marble diagrams](#describing-pipelines-with-marble-diagrams)

## Publisher and Subscriber

Two key concepts, [publisher](https://developer.apple.com/documentation/combine/publisher) and [subscriber](https://developer.apple.com/documentation/combine/subscriber), are described in Swift as protocols.

Combine is all about defining the process of what you do with many possible values over time. Combine also goes farther than defining the result, it also defines how it can fail.

A **publisher** provides data when available and upon request. A publisher that hasn't had any *subscription* requests will not provide any data. When you are describing a Combine publisher, you describe it with two associated types: one for `Output` and one for `Failure`.

![basic_types.svg](../../media/Swift/UsingCombine/basic_types.svg)

For example, if a publisher returned an instance of `String`, and could return a failure in the form of an instance of `URLError`, then the publisher might be described with the string `<String, URLError>`.

A **subscriber** is responsible for requesting data and accepting the data (and possible failures) provided by a publisher. A subscriber is described with two associated types, one for `Input` and one for `Failure`. The subscriber initiates the request for data, and controls the amount of data it receives. It can be thought of as "driving the action" within Combine, as without a subscriber, the other components stay idle.

*Publishers* and *subscribers* are meant to be connected, and make up the core of Combine. When you connect a subscriber to a publisher, both types must match: `Output` to `Input`, and `Failure` to `Failure`. One way to visualize this is as a series of operations on two types in parallel, where both types need to match in order to plug the components together.

![input_output.svg](../../media/Swift/UsingCombine/input_output.svg)

The third core concept is an **operator**: an object that **acts both like a subscriber and a publisher**. Operators are classes that adopt both the [Subscriber protocol](https://developer.apple.com/documentation/combine/subscriber) and [Publisher protocol](https://developer.apple.com/documentation/combine/publisher). They support subscribing to a publisher, and sending results to any subscribers.

You can create chains of these together, for *processing*, *reacting*, and *transforming* the data provided by a publisher, and requested by the subscriber.

I’m calling these composed sequences **pipelines**.

![pipeline.svg](../../media/Swift/UsingCombine/pipeline.svg)

Operators can be used to transform either values or types - both the `Output` and `Failure` type. Operators may also *split* or *duplicate* streams, or *merge* streams together. Operators must always be aligned by the combination of `Output`/`Failure` types. The compiler will enforce the matching types, so getting it wrong will result in a compiler error (and, if you are lucky, a useful *fixit* snippet suggesting a solution).

A simple Combine pipeline written in swift might look like:

```swift
let _ = Just(5) 1️⃣
    .map { value -> String in 2️⃣
        // do something with the incoming value here
        // and return a string
        return "a string"
    }
    .sink { receivedValue in 3️⃣
        // sink is the subscriber and terminates the pipeline
        print("The end result was \(receivedValue)")
    }
```

- 1️⃣ The pipeline starts with the *publisher* `Just`, which responds with the value that its defined with (in this case, the Integer `5`). The output type is `<Integer>`, and the failure type is `<Never>`.
- 2️⃣ The pipeline then has a `map` *operator*, which is transforming the value and its type. In this example it is ignoring the published input and returning a string. This is also transforming the output type to `<String>`, and leaving the failure type still set as `<Never>`.
- 3️⃣ The pipeline then ends with a `sink` *subscriber*.

When you are thinking about a pipeline you can think of it as a sequence of operations linked by both *output* and *failure* types. This pattern will come in handy when you start constructing your own pipelines.

When creating pipelines, you are often selecting *operators* to help you transform the data, types, or both to achieve your end goal. That end goal might be enabling or disabling a user interface element, or it might be retrieving some piece of data to be displayed. Many Combine *operators* are specifically created to help with these transformations.

There are a number of *operators* that have a similar *operator* prefixed with `try`, which indicates they return an `<Error>` failure type. An example of this is `map` and `tryMap`.

- `map` *operator* allows for any combination of `Output` and `Failure` type and passes them through.
- `tryMap` accepts any `Input`, `Failure` types, and allows any `Output` type, but will always output an `<Error>` failure type.

Operators like `map` allow you to define the output type being returned by inferring the output type based on what you return in a closure provided to the *operator*. In the example above, the `map` *operator* is returning a `String` output type since that is what the closure returns.

To illustrate the example of changing types more concretely, we expand upon the logic to use the values being passed. This example still starts with a publisher providing the types `<Int, Never>` and end with a subscription taking the types `<String, Never>`.

```swift
let _ = Just(5)  1️⃣
    .map { value -> String in 2️⃣
        switch value {
        case _ where value < 1:
            return "none"
        case _ where value == 1:
            return "one"
        case _ where value == 2:
            return "couple"
        case _ where value == 3:
            return "few"
        case _ where value > 8:
            return "many"
        default:
            return "some"
        }
    }
    .sink { receivedValue in 3️⃣
        print("The end result was \(receivedValue)")
    }
```

- 1️⃣ `Just` is a *publisher* that creates an `<Int, Never>` type combination, provides a single value and then completes.
- 2️⃣ the closure provided to the `.map()` function takes in an `<Int>` and transforms it into a `<String>`. Since the failure type of `<Never>` is not changed, it is passed through.
- 3️⃣ `sink`, the *subscriber*, receives the `<String, Never>` combination.

> When you are creating pipelines in Xcode and don’t match the types, the error message from Xcode may include a helpful *fixit*.  
> In some cases, such as the example above, the compiler is unable to infer the return types of closure provided to `map` without specifying the return type.  
> *Xcode (11 beta 2 and beta 3)* displays this as the error message: `Unable to infer complex closure return type; add explicit type to disambiguate.` In the example above, we explicitly specified the type being returned with the line *value -> String* in.

You can view Combine publishers, operators, and subscribers as having two parallel types that both need to be aligned: one for the functional case and one for the error case. Designing your pipeline is frequently choosing how to convert one or both of those types and the associated data with it.

## Describing pipelines with marble diagrams



