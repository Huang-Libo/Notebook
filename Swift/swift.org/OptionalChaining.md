# Optional Chaining

> Version: *Swift 5.5*  
> Source: [*swift-book: Optional Chaining*](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html)  
> Digest Date: *January 24, 2022*  

*Optional chaining* is a process for querying and calling *properties*, *methods*, and *subscripts* on an optional that might currently be `nil`.  Multiple queries can be chained together, and the entire chain fails gracefully if any link in the chain is `nil`.

- [Optional Chaining](#optional-chaining)
  - [Optional Chaining as an Alternative to Forced Unwrapping](#optional-chaining-as-an-alternative-to-forced-unwrapping)
  - [Defining Model Classes for Optional Chaining](#defining-model-classes-for-optional-chaining)
  - [Accessing Properties Through Optional Chaining](#accessing-properties-through-optional-chaining)
  - [Calling Methods Through Optional Chaining](#calling-methods-through-optional-chaining)

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

You can use optional chaining with calls to properties, methods, and subscripts that are more than one level deep.

The code snippets below define four model classes for use in several subsequent examples, including examples of multilevel optional chaining.

These classes expand upon the `Person` and `Residence` model from above by adding a `Room` and `Address` class, with associated *properties*, *methods*, and *subscripts*.

The `Person` class is defined in the same way as before:

```swift
class Person {
    var residence: Residence?
}
```

The `Residence` class is more complex than before. This time, the `Residence` class defines a variable property called `rooms`, which is initialized with an empty array of type `[Room]`:

```swift
class Residence {
    var rooms: [Room] = []
    var numberOfRooms: Int {
        return rooms.count
    }
    subscript(i: Int) -> Room {
        get {
            return rooms[i]
        }
        set {
            rooms[i] = newValue
        }
    }
    func printNumberOfRooms() {
        print("The number of rooms is \(numberOfRooms)")
    }
    var address: Address?
}
```

As a shortcut to accessing its `rooms` array, this version of `Residence` provides a *read-write* subscript that provides access to the room at the requested index in the `rooms` array.

Finally, `Residence` defines an optional property called `address`, with a type of `Address?`. The `Address` class type for this property is defined below.

The `Room` class used for the `rooms` array is a simple class with one property called `name`, and an initializer to set that property to a suitable room name:

```swift
class Room {
    let name: String
    init(name: String) { self.name = name }
}
```

The final class in this model is called `Address`. This class has three optional properties of type `String?`. The first two properties, `buildingName` and `buildingNumber`, are alternative ways to identify a particular building as part of an address. The third property, `street`, is used to name the street for that address:

```swift
class Address {
    var buildingName: String?
    var buildingNumber: String?
    var street: String?
    func buildingIdentifier() -> String? {
        if let buildingNumber = buildingNumber, let street = street {
            return "\(buildingNumber) \(street)"
        } else if buildingName != nil {
            return buildingName
        } else {
            return nil
        }
    }
}
```

## Accessing Properties Through Optional Chaining

Use the classes defined above to create a new Person instance, and try to access its `numberOfRooms` property as before:

```swift
let john = Person()
if let roomCount = john.residence?.numberOfRooms {
    print("John's residence has \(roomCount) room(s).")
} else {
    print("Unable to retrieve the number of rooms.")
}
// Prints "Unable to retrieve the number of rooms."
```

Because `john.residence` is `nil`, this optional chaining call fails in the same way as before.

```swift
let someAddress = Address()
someAddress.buildingNumber = "29"
someAddress.street = "Acacia Road"
john.residence?.address = someAddress
```

In this example, the attempt to set the `address` property of `john.residence` will fail, because `john.residence` is currently `nil`.

The assignment is part of the *optional chaining*, which means none of the code on the *right-hand side* of the `=` operator is evaluated.

In the previous example, it’s not easy to see that `someAddress` is *never* evaluated, because accessing a constant doesn’t have any side effects.

The listing below does the same assignment, but it uses a function to create the address. The function prints “*Function was called*” before returning a value, which lets you see whether the *right-hand side* of the `=` operator was evaluated.

```swift
func createAddress() -> Address {
    print("Function was called.")

    let someAddress = Address()
    someAddress.buildingNumber = "29"
    someAddress.street = "Acacia Road"

    return someAddress
}
john.residence?.address = createAddress()
```

You can tell that the `createAddress()` function isn’t called, because *nothing* is printed. （因为 `john.residence` 目前还是 `nil` ）

## Calling Methods Through Optional Chaining

You can use optional chaining to call a method on an optional value, and to check whether that method call is successful. You can do this even if that method doesn’t define a return value.

The `printNumberOfRooms()` method on the `Residence` class prints the current value of `numberOfRooms`. Here’s how the method looks:

```swift
func printNumberOfRooms() {
    print("The number of rooms is \(numberOfRooms)")
}
```

This method doesn’t specify a return type. However, functions and methods with no return type have an implicit return type of `Void`, as described in [Functions Without Return Values](https://docs.swift.org/swift-book/LanguageGuide/Functions.html#ID163). This means that they return a value of `()`, or an empty tuple.

If you call this method on an optional value with optional chaining, the method’s return type will be `Void?`, not `Void`, because return values are always of an optional type when called through optional chaining. This enables you to use an `if` statement to check whether it was possible to call the `printNumberOfRooms()` method, even though the method doesn’t itself define a return value. Compare the return value from the `printNumberOfRooms` call against `nil` to see if the method call was successful:

```swift
if john.residence?.printNumberOfRooms() != nil {
    print("It was possible to print the number of rooms.")
} else {
    print("It was not possible to print the number of rooms.")
}
// Prints "It was not possible to print the number of rooms."
```

The same is true if you attempt to set a property through optional chaining. Any attempt to set a property through optional chaining returns a value of type `Void?`, which enables you to compare against `nil` to see if the property was set successfully:

```swift
if (john.residence?.address = someAddress) != nil {
    print("It was possible to set the address.")
} else {
    print("It was not possible to set the address.")
}
// Prints "It was not possible to set the address."
```
