# Combine

Swift, iOS 13.0+, macOS 10.15+

- [Combine](#combine)
  - [Overview](#overview)
  - [Publisher](#publisher)
  - [Subscriber](#subscriber)
  - [Subscription](#subscription)
  - [CustomCombineIdentifierConvertible](#customcombineidentifierconvertible)
  - [WWDC Video](#wwdc-video)

## Overview

- *publisher* : expose values that can change over time.
- *subscriber* : receive those values from the publishers.

## Publisher

```swift
protocol Publisher
```

Publishers have *operators* to act on the values received from upstream publishers and republish them.

The *publisher* implements the `receive(subscriber:)` method to accept a *subscriber*.

After this, the *publisher* can call the following methods on the *subscriber* :

- `receive(subscription:):` Acknowledges the subscribe request and returns a `Subscription` instance. The `subscriber` uses the `subscription` to demand elements from the *publisher* and can use it to cancel publishing.
- `receive(_:):` Delivers one element from the *publisher* to the *subscriber*.
- `receive(completion:):` Informs the `subscriber` that publishing has ended, either normally or with an error.

## Subscriber

```swift
protocol Subscriber : CustomCombineIdentifierConvertible
```

Publishers only emit values when explicitly **requested** to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.

## Subscription

A protocol representing the **connection** of a *subscriber* to a *publisher*.

```swift
protocol Subscription : Cancellable, CustomCombineIdentifierConvertible
```

`request(_:)`

Tells a publisher that it may send more values to the subscriber.

```swift
func request(_ demand: Subscribers.Demand)
```

## CustomCombineIdentifierConvertible

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

## WWDC Video

- [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
