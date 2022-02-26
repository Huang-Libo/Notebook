# Inheritance

> Version: *Swift 5.6*  
> Source: [*swift-book: Inheritance*](https://docs.swift.org/swift-book/LanguageGuide/Inheritance.html)  
> Digest Date: *February 23, 2022*  

A class can *inherit* methods, properties, and other characteristics from another class.

Classes in Swift can call and access *methods*, *properties*, and *subscripts* belonging to their superclass and can provide their own *overriding* versions of those methods, properties, and subscripts to refine or modify their behavior.

Classes can also add *property observers* to inherited properties in order to be notified when the value of a property changes. *Property observers can be added to any property, regardless of whether it was originally defined as a stored or computed property.*

- [Inheritance](#inheritance)
  - [Defining a Base Class](#defining-a-base-class)
  - [Subclassing](#subclassing)
  - [Overriding](#overriding)
    - [Accessing Superclass Methods, Properties, and Subscripts](#accessing-superclass-methods-properties-and-subscripts)
    - [Overriding Methods](#overriding-methods)

## Defining a Base Class

Any class that doesn’t inherit from another class is known as a *base* class.

> **NOTE**: Swift classes don’t inherit from a universal base class. Classes you define without specifying a superclass automatically become base classes for you to build upon.

The example below defines a base class called `Vehicle`. This base class defines a stored property called `currentSpeed`, with a default value of `0.0` (inferring a property type of `Double`). The `currentSpeed` property’s value is used by a read-only computed `String` property called `description` to create a description of the vehicle.

The Vehicle base class also defines a method called `makeNoise`. This method doesn’t actually do anything for a base `Vehicle` instance, but will be customized by subclasses of `Vehicle` later on:

```swift
class Vehicle {
    var currentSpeed = 0.0
    var description: String {
        return "traveling at \(currentSpeed) miles per hour"
    }
    func makeNoise() {
        // do nothing - an arbitrary vehicle doesn't necessarily make a noise
    }
}
```

You create a new instance of `Vehicle` with *initializer* syntax, which is written as a type name followed by empty parentheses:

```swift
let someVehicle = Vehicle()
```

Having created a new `Vehicle` instance, you can access its `description` property to print a human-readable description of the vehicle’s current speed:

```swift
print("Vehicle: \(someVehicle.description)")
// Vehicle: traveling at 0.0 miles per hour
```

The `Vehicle` class defines common characteristics for an arbitrary vehicle, but isn’t much use in itself. To make it more useful, you need to refine it to describe more specific kinds of vehicles.

## Subclassing

*Subclassing* is the act of basing a new class on an existing class.

To indicate that a subclass has a superclass, write the subclass name before the superclass name, separated by a colon:

```swift
class SomeSubclass: SomeSuperclass {
    // subclass definition goes here
}
```

The following example defines a subclass called `Bicycle`, with a superclass of `Vehicle`:

```swift
class Bicycle: Vehicle {
    var hasBasket = false
}
```

In addition to the characteristics it inherits, the `Bicycle` class defines a new *stored property*, `hasBasket`, with a default value of `false` (inferring a type of `Bool` for the property).

By default, any new `Bicycle` instance you create will not have a basket. You can set the `hasBasket` property to `true` for a particular `Bicycle` instance after that instance is created:

```swift
let bicycle = Bicycle()
bicycle.hasBasket = true
```

You can also modify the inherited `currentSpeed` property of a `Bicycle` instance, and query the instance’s inherited `description` property:

```swift
bicycle.currentSpeed = 15.0
print("Bicycle: \(bicycle.description)")
// Bicycle: traveling at 15.0 miles per hour
```

Subclasses can themselves be subclassed. The next example creates a subclass of `Bicycle` for a *two-seater bicycle* known as a “tandem”:

```swift
class Tandem: Bicycle {
    var currentNumberOfPassengers = 0
}
```

Tandem inherits all of the properties and methods from `Bicycle`, which in turn inherits all of the properties and methods from `Vehicle`. The `Tandem` subclass also adds a new *stored property* called `currentNumberOfPassengers`, with a default value of `0`.

If you create an instance of `Tandem`, you can work with any of its new and inherited properties, and query the read-only `description` property it inherits from `Vehicle`:

```swift
let tandem = Tandem()
tandem.hasBasket = true
tandem.currentNumberOfPassengers = 2
tandem.currentSpeed = 22.0
print("Tandem: \(tandem.description)")
// Tandem: traveling at 22.0 miles per hour
```

## Overriding

A subclass can provide its own custom implementation of an

- *instance method*, *type method*,
- *instance property*, *type property*,
- or *subscript*

that it would otherwise inherit from a superclass. This is known as *overriding*.

To override a characteristic that would otherwise be inherited, you prefix your overriding definition with the `override` keyword. Doing so clarifies that you intend to provide an override and haven’t provided a matching definition by mistake. Overriding by accident can cause unexpected behavior, and any overrides without the `override` keyword are diagnosed as an error when your code is compiled.

The `override` keyword also prompts the Swift compiler to check that your overriding class’s superclass (or one of its parents) has a declaration that matches the one you provided for the override. This check ensures that your overriding definition is correct.

### Accessing Superclass Methods, Properties, and Subscripts



### Overriding Methods


