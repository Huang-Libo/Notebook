# Initialization

> Swift 5.5 , 2022/01/13

*Initialization* is the process of preparing an instance of a *class*, *structure*, or *enumeration* for use. Unlike Objective-C initializers, Swift initializers don’t return a value.

- [Initialization](#initialization)
  - [Setting Initial Values for Stored Properties](#setting-initial-values-for-stored-properties)
    - [Initializers](#initializers)
    - [Default Property Values](#default-property-values)
  - [Customizing Initialization](#customizing-initialization)
    - [Initialization Parameters](#initialization-parameters)
    - [Parameter Names and Argument Labels](#parameter-names-and-argument-labels)
    - [Initializer Parameters Without Argument Labels](#initializer-parameters-without-argument-labels)
    - [Optional Property Types](#optional-property-types)
    - [Assigning Constant Properties During Initialization](#assigning-constant-properties-during-initialization)
  - [Default Initializers](#default-initializers)
    - [Memberwise Initializers for Structure Types](#memberwise-initializers-for-structure-types)
  - [Initializer Delegation for Value Types](#initializer-delegation-for-value-types)
  - [Class Inheritance and Initialization](#class-inheritance-and-initialization)

## Setting Initial Values for Stored Properties

*Classes* and *structures* **must** set all of their *stored properties* to an appropriate initial value by the time an instance of that class or structure is created. Stored properties can’t be left in an indeterminate state.

- You can set an initial value for a stored property within an initializer
- Or by assigning a default property value as part of the property’s definition.

> **NOTE**: When you assign a default value to a stored property, or set its initial value within an initializer, the value of that property is set directly, without calling any *property observers*.

### Initializers

*Initializers* are called to create a new instance of a particular type.

```swift
init() {
    // perform some initialization here
}
```

The example below defines a new structure called `Fahrenheit` to store temperatures expressed in the Fahrenheit scale.

```swift
struct Fahrenheit {
    var temperature: Double
    init() {
        // the freezing point of water in degrees Fahrenheit
        temperature = 32.0
    }
}
var f = Fahrenheit()
print("The default temperature is \(f.temperature)° Fahrenheit")
// Prints "The default temperature is 32.0° Fahrenheit"
```

### Default Property Values

Alternatively, specify a *default property value* as part of the property’s declaration.

> If a property always takes the same initial value, provide a default value rather than setting a value within an initializer. The default value also makes it easier for you to take advantage of default initializers and initializer inheritance.

You can write the `Fahrenheit` structure from above in a simpler form by providing a default value for its temperature property at the point that the property is declared:

```swift
struct Fahrenheit {
    var temperature = 32.0
}
```

## Customizing Initialization

You can customize the initialization process with input parameters and optional property types, or by assigning constant properties during initialization。

### Initialization Parameters

You can provide *initialization parameters* as part of an initializer’s definition, to define the types and names of values that customize the initialization process.

The following example defines a structure called `Celsius`, which stores temperatures expressed in degrees Celsius.

The `Celsius` structure implements two custom initializers called `init(fromFahrenheit:)` and `init(fromKelvin:)`, which initialize a new instance of the structure with a value from a different temperature scale:

```swift
struct Celsius {
    var temperatureInCelsius: Double
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
}
let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
// boilingPointOfWater.temperatureInCelsius is 100.0
let freezingPointOfWater = Celsius(fromKelvin: 273.15)
// freezingPointOfWater.temperatureInCelsius is 0.0
```

### Parameter Names and Argument Labels

As with function and method parameters, initialization parameters can have both a *parameter name* for use within the initializer’s body and an *argument label* for use when calling the initializer.

Swift provides an automatic *argument label* for every parameter in an initializer if you don’t provide one.

The following example defines a structure called `Color`, with three constant properties called `red`, `green`, and `blue`. These properties store a value between `0.0` and `1.0` to indicate the amount of red, green, and blue in the color.

```swift
struct Color {
    let red, green, blue: Double
    init(red: Double, green: Double, blue: Double) {
        self.red   = red
        self.green = green
        self.blue  = blue
    }
    init(white: Double) {
        red   = white
        green = white
        blue  = white
    }
}
```

Note that it isn’t possible to call these initializers without using *argument labels*. Argument labels must **always** be used in an initializer if they’re defined, and omitting them is a compile-time error:

```swift
let magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
let halfGray = Color(white: 0.5)

// this reports a compile-time error - argument labels are required
let veryGreen = Color(0.0, 1.0, 0.0)
```

### Initializer Parameters Without Argument Labels

If you don’t want to use an *argument label* for an initializer parameter, write an *underscore* (`_`) instead of an explicit argument label for that parameter to override the default behavior.

Here’s an expanded version of the `Celsius` example from [Initialization Parameters](#initialization-parameters) above, with an additional initializer to create a new Celsius instance from a Double value that’s already in the Celsius scale:

```swift
struct Celsius {
    var temperatureInCelsius: Double
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
    init(_ celsius: Double) {
        temperatureInCelsius = celsius
    }
}
// bodyTemperature.temperatureInCelsius is 37.0
let bodyTemperature = Celsius(37.0)
```

### Optional Property Types

Properties of optional type are automatically initialized with a value of `nil`, indicating that the property is deliberately intended to have “no value yet” during initialization.

The following example defines a class called `SurveyQuestion`, with an optional String property called response:

```swift
class SurveyQuestion {
    var text: String
    var response: String?
    init(text: String) {
        self.text = text
    }
    func ask() {
        print(text)
    }
}
let cheeseQuestion = SurveyQuestion(text: "Do you like cheese?")
// Prints "Do you like cheese?"
cheeseQuestion.ask()
cheeseQuestion.response = "Yes, I do like cheese."
```

### Assigning Constant Properties During Initialization

You can assign a value to a *constant property* at any point during initialization, Once a constant property is assigned a value, it can’t be further modified.

> **NOTE**: For `class` instances, a constant property can be modified during initialization only by the class that introduces it. **It can’t be modified by a subclass.**

Even though the `text` property is now a constant, it can still be set within the class’s initializer:

```swift
class SurveyQuestion {
    let text: String
    var response: String?
    init(text: String) {
        self.text = text
    }
    func ask() {
        print(text)
    }
}
let beetsQuestion = SurveyQuestion(text: "How about beets?")
// Prints "How about beets?"
beetsQuestion.ask()
beetsQuestion.response = "I also like beets. (But not with cheese.)"
```

## Default Initializers

Swift provides a *default initializer* for any *structure* or *class* that provides default values for all of its properties and doesn’t provide at least one initializer itself. The default initializer simply creates a new instance with all of its properties set to their default values.

This example defines a class called *ShoppingListItem*, which encapsulates the *name*, *quantity*, and *purchase* state of an item in a shopping list:

```swift
class ShoppingListItem {
    var name: String?
    var quantity = 1
    var purchased = false
}
var item = ShoppingListItem()
```

Because all properties of the `ShoppingListItem` class have default values, and because it’s a *base class* with *no* superclass, `ShoppingListItem` automatically gains a default initializer implementation that creates a new instance with all of its properties set to their default values.

### Memberwise Initializers for Structure Types

Structure types automatically receive a *memberwise initializer* if they don’t define any of their own custom initializers. Unlike a *default initializer*, the structure receives a memberwise initializer even if it has stored properties that don’t have default values.

The `Size` structure automatically receives an `init(width:height:)` memberwise initializer, which you can use to initialize a new `Size` instance:

```swift
struct Size {
    var width = 0.0, height = 0.0
}
let twoByTwo = Size(width: 2.0, height: 2.0)
```

When you call a *memberwise initializer*, you can omit values for any properties that have default values. In the example above, the Size structure has a default value for both its `height` and `width` properties. You can omit either property or both properties, and the initializer uses the default value for anything you omit. For example:

```swift
let zeroByTwo = Size(height: 2.0)
print(zeroByTwo.width, zeroByTwo.height)
// Prints "0.0 2.0"

let zeroByZero = Size()
print(zeroByZero.width, zeroByZero.height)
// Prints "0.0 0.0"
```

## Initializer Delegation for Value Types

Initializers can call other initializers to perform part of an instance’s initialization. This process, known as *initializer delegation*, avoids duplicating code across multiple initializers.

The rules for how *initializer delegation* works, and for what forms of delegation are allowed, are different for *value types* and *class types*.

- *Value types* (structures and enumerations) don’t support inheritance, and so their initializer delegation process is relatively simple, because they can only delegate to another initializer that they provide themselves.
- Classes, however, can inherit from other classes. This means that classes have additional responsibilities for ensuring that all stored properties they inherit are assigned a suitable value during initialization.

Note that if you define a *custom initializer* for a value type, you will no longer have access to the *default initializer* (or the *memberwise initializer*, if it’s a *structure*) for that type. This constraint prevents a situation in which additional essential setup provided in a more complex initializer is accidentally circumvented by someone using one of the automatic initializers.

> **NOTE**: If you want your custom value type to be initializable with the *default initializer* and *memberwise initializer*, and also with your own *custom initializers*, write your custom initializers in an `extension` rather than as part of the value type’s original implementation.

The following example defines a custom `Rect` structure to represent a geometric rectangle. The example requires two supporting structures called `Size` and `Point`, both of which provide default values of `0.0` for all of their properties:

```swift
struct Size {
    var width = 0.0, height = 0.0
}
struct Point {
    var x = 0.0, y = 0.0
}
```

You can initialize the Rect structure below in one of three ways:

- by using its default zero-initialized *origin* and *size* property values
- by providing a specific *origin point* and *size*
- by providing a specific *center point* and *size*.

These initialization options are represented by three custom initializers that are part of the Rect structure’s definition:

```swift
struct Rect {
    var origin = Point()
    var size = Size()
    init() {}
    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}
```

The first `Rect` initializer, `init()`, is functionally the same as the default initializer that the structure would have received if it didn’t have its own custom initializers.

```swift
// basicRect's origin is (0.0, 0.0) and its size is (0.0, 0.0)
let basicRect = Rect()
```

The second `Rect` initializer, `init(origin:size:)`, is functionally the same as the *memberwise initializer* that the structure would have received if it didn’t have its own custom initializers.

```swift
// originRect's origin is (2.0, 2.0) and its size is (5.0, 5.0)
let originRect = Rect(origin: Point(x: 2.0, y: 2.0),
                      size: Size(width: 5.0, height: 5.0))
```

The third `Rect` initializer, `init(center:size:)` starts by calculating an appropriate *origin point* based on a *center point* and a *size* value. It then calls (or delegates) to the *init(origin:size:)* initializer, which stores the new *origin* and *size* values in the appropriate properties:

```swift
// centerRect's origin is (2.5, 2.5) and its size is (3.0, 3.0)
let centerRect = Rect(center: Point(x: 4.0, y: 4.0),
                      size: Size(width: 3.0, height: 3.0))
```

> **NOTE**: For an alternative way to write this example without defining the `init()` and `init(origin:size:)` initializers yourself, see [Extensions](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html).

## Class Inheritance and Initialization


