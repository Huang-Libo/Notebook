# Optional Chaining

> Version: *Swift 5.5*  
> Source: [*swift-book: Optional Chaining*](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html)  
> Digest Date: *January 24, 2022*  

*Optional chaining* is a process for querying and calling *properties*, *methods*, and *subscripts* on an optional that might currently be `nil`.  Multiple queries can be chained together, and the entire chain fails gracefully if any link in the chain is `nil`.

- [Optional Chaining](#optional-chaining)
  - [Optional Chaining as an Alternative to Forced Unwrapping](#optional-chaining-as-an-alternative-to-forced-unwrapping)
  - [Defining Model Classes for Optional Chaining](#defining-model-classes-for-optional-chaining)

## Optional Chaining as an Alternative to Forced Unwrapping

- You specify optional chaining by placing a *question mark* (`?`) after the optional value on which you wish to call a *property*, *method* or *subscript* if the optional is non-`nil`.
- This is very similar to placing an *exclamation point* (`!`) after an optional value to *force* the unwrapping of its value.

The main difference is that optional chaining fails gracefully when the optional is `nil`, whereas forced unwrapping triggers a *runtime error* when the optional is `nil`.

The next several code snippets demonstrate how optional chaining differs from forced unwrapping and enables you to check for success.

First, two classes called `Person` and `Residence` are defined:

```swift
class Person {
    var residence: Residence?
}

class Residence {
    var numberOfRooms = 1
}
```

If you create a new `Person` instance, its `residence` property is default initialized to `nil`, by virtue of being optional. In the code below, `john` has a `residence` property value of `nil`:

```swift
let john = Person()
```

If you try to access the `numberOfRooms` property of this person’s `residence`, by placing an exclamation point after `residence` to force the unwrapping of its value, you trigger a runtime error, because there’s no `residence` value to unwrap:

```swift
let roomCount = john.residence!.numberOfRooms
// this triggers a runtime error
```

Optional chaining provides an alternative way to access the value of `numberOfRooms`. To use optional chaining, use a *question mark* in place of the exclamation point:

```swift
if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
// Prints "Unable to retrieve the number of rooms."
```

This tells Swift to “*chain*” on the optional `residence` property and to retrieve the value of `numberOfRooms` if `residence` exists.

Because the attempt to access `numberOfRooms` has the potential to fail, the optional chaining attempt returns a value of type `Int?`, or “*optional Int*”.

The optional Int is accessed through *optional binding* to unwrap the integer and assign the non-optional value to the `roomCount` constant.

You can assign a Residence instance to john.residence, so that it no longer has a nil value:

```swift
john.residence = Residence()
```

`john.residence` now contains an actual `Residence` instance, rather than `nil`. If you try to access `numberOfRooms` with the same optional chaining as before, it will now return an `Int?` that contains the default `numberOfRooms` value of `1`:

```swift
if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
// Prints "John's residence has 1 room(s)."
```

## Defining Model Classes for Optional Chaining


