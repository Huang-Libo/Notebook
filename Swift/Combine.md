# Combine

Swift, iOS 13.0+, macOS 10.15+

- [Combine](#combine)
  - [Overview](#overview)
    - [Publisher](#publisher)
    - [Subscriber](#subscriber)
    - [Subscription](#subscription)
    - [CustomCombineIdentifierConvertible](#customcombineidentifierconvertible)

## Overview

- *publisher* : expose values that can change over time.
- *subscriber* : receive those values from the publishers.

### Publisher

```swift
protocol Publisher
```

Publishers have *operators* to act on the values received from upstream publishers and republish them.

### Subscriber

```swift
protocol Subscriber : CustomCombineIdentifierConvertible
```

Publishers only emit values when explicitly **requested** to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.

### Subscription

A protocol representing the **connection** of a *subscriber* to a *publisher*.

```swift
protocol Subscription : Cancellable, CustomCombineIdentifierConvertible
```

`request(_:)`

Tells a publisher that it may send more values to the subscriber.

```swift
func request(_ demand: Subscribers.Demand)
```

### CustomCombineIdentifierConvertible

A protocol for **uniquely identifying** publisher streams.

Inherited by: `Subscriber`, `Subscription`.

**combineIdentifier** (Default Implementation Provided):

Declaration:

```swift
var combineIdentifier: CombineIdentifier { get }
```

Usage:

```swift
let combineIdentifier = CombineIdentifier()
```
