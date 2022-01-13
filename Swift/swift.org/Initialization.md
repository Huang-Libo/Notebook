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


