# Subjects

General information on [Subjects](https://heckj.github.io/swiftui-notes/#coreconcepts-subjects) can be found in the Core Concepts section.

- [Subjects](#subjects)
  - [CurrentValueSubject](#currentvaluesubject)
  - [PassthroughSubject](#passthroughsubject)

## CurrentValueSubject

A subject that wraps a single value and publishes a new element whenever the value changes.

**Declaration**:

```swift
final class CurrentValueSubject<Output, Failure> where Failure : Error
```

**Overview**:

Unlike `PassthroughSubject`, `CurrentValueSubject` maintains a *buffer* of the most recently published element.

Calling `send(_:)` on a `CurrentValueSubject` also updates the current value, making it equivalent to updating the `value` directly.

## PassthroughSubject

A subject that broadcasts elements to downstream subscribers.

**Declaration**:

```swift
final class PassthroughSubject<Output, Failure> where Failure : Error
```

**Discussion**:

As a concrete implementation of `Subject`, the `PassthroughSubject` provides a convenient way to adapt existing imperative code to the Combine model.

Unlike `CurrentValueSubject`, a `PassthroughSubject` doesn’t have an initial value or a buffer of the most recently-published element. A `PassthroughSubject` drops values if there are no subscribers, or its current demand is zero.
