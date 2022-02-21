# Enumerations

> Version: *Swift 5.6*  
> Source: [*swift-book: Enumerations*](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html)  
> Digest Date: *February 4, 2022*  

An `enumeration` defines a common type for a group of related values and enables you to work with those values in a type-safe way within your code.

If you are familiar with C, you will know that C enumerations assign related names to a set of integer values. Enumerations in Swift are much more flexible, and don’t have to provide a value for each case of the enumeration. If a value (known as a *raw value*) is provided for each enumeration case, the value can be a *string*, a *character*, or a value of any *integer* or *floating-point* type.

Alternatively, enumeration cases can specify associated values of *any* type to be stored along with each different case value, much as *unions* or *variants* do in other languages. You can define a common set of related cases as part of one enumeration, each of which has a different set of values of appropriate types associated with it.

Enumerations in Swift are *first-class types* in their own right. They adopt many features traditionally supported only by classes,

- such as *computed properties* to provide additional information about the enumeration’s current value,
- and *instance methods* to provide functionality related to the values the enumeration represents.
- Enumerations can also define *initializers* to provide an initial case value;
- can be extended to *expand* their functionality beyond their original implementation;
- and can conform to *protocols* to provide standard functionality.

---

- [Enumerations](#enumerations)
  - [Enumeration Syntax](#enumeration-syntax)
  - [Matching Enumeration Values with a Switch Statement](#matching-enumeration-values-with-a-switch-statement)
  - [Iterating over Enumeration Cases](#iterating-over-enumeration-cases)
  - [Associated Values](#associated-values)
  - [Raw Values](#raw-values)
    - [Implicitly Assigned Raw Values](#implicitly-assigned-raw-values)

## Enumeration Syntax

You introduce enumerations with the `enum` keyword and place their entire definition within a pair of braces:

```swift
enum SomeEnumeration {
    // enumeration definition goes here
}
```

Here’s an example for the four main points of a compass:

```swift
enum CompassPoint {
    case north
    case south
    case east
    case west
}
```

The values defined in an enumeration (such as `north`, `south`, `east`, and `west`) are its *enumeration cases*. You use the `case` keyword to introduce new enumeration cases.

> **NOTE**: Swift enumeration cases don’t have an integer value set by default, unlike languages like C and Objective-C. In the CompassPoint example above, north, south, east and west don’t implicitly equal 0, 1, 2 and 3. Instead, the different enumeration cases are values in their own right, with an explicitly defined type of CompassPoint.

Multiple cases can appear on a single line, separated by commas:

```swift
enum Planet {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}
```

Each enumeration definition defines a new type. Like other types in Swift, their names (such as `CompassPoint` and `Planet`) start with a capital letter. Give enumeration types *singular* rather than plural names, so that they read as self-evident:

```swift
var directionToHead = CompassPoint.west
```

The type of `directionToHead` is inferred when it’s initialized with one of the possible values of `CompassPoint`. Once `directionToHead` is declared as a `CompassPoint`, you can set it to a different `CompassPoint` value using a shorter *dot syntax*:

```swift
directionToHead = .east
```

## Matching Enumeration Values with a Switch Statement

You can match individual enumeration values with a `switch` statement:

```swift
directionToHead = .south
switch directionToHead {
case .north:
    print("Lots of planets have a north")
case .south:
    print("Watch out for penguins")
case .east:
    print("Where the sun rises")
case .west:
    print("Where the skies are blue")
}
// Prints "Watch out for penguins"
```

As described in [Control Flow](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html), a `switch` statement must be exhaustive when considering an enumeration’s cases. If the `case` for `.west` is omitted, this code doesn’t compile, because it doesn’t consider the complete list of `CompassPoint` cases. Requiring exhaustiveness ensures that enumeration cases aren’t accidentally omitted.

When it isn’t appropriate to provide a `case` for every enumeration case, you can provide a `default` case to cover any cases that aren’t addressed explicitly:

```swift
let somePlanet = Planet.earth
switch somePlanet {
case .earth:
    print("Mostly harmless")
default:
    print("Not a safe place for humans")
}
// Prints "Mostly harmless"
```

## Iterating over Enumeration Cases

For some enumerations, it’s useful to have a collection of all of that enumeration’s cases. You enable this by writing `: CaseIterable` after the enumeration’s name. Swift exposes a collection of all the cases as an `allCases` property of the enumeration type. Here’s an example:

```swift
enum Beverage: CaseIterable {
    case coffee, tea, juice
}
let numberOfChoices = Beverage.allCases.count
print("\(numberOfChoices) beverages available")
// Prints "3 beverages available"
```

The example above counts how many cases there are, and the example below uses a `for-in` loop to iterate over all the cases.

```swift
for beverage in Beverage.allCases {
    print(beverage)
}
// coffee
// tea
// juice
```

The syntax used in the examples above marks the enumeration as conforming to the [CaseIterable](https://developer.apple.com/documentation/swift/caseiterable) protocol.

## Associated Values

The examples in the previous section show how the cases of an enumeration are a defined (and typed) value in their own right. You can set a constant or variable to Planet.earth, and check for this value later.

However, it’s sometimes useful to be able to store values of other types alongside these case values. This additional information is called an *associated value*, and it varies each time you use that case as a value in your code.

You can define Swift enumerations to store *associated values* of any given type, and the value types can be different for each case of the enumeration if needed. Enumerations similar to these are known as *discriminated unions*, *tagged unions*, or *variants* in other programming languages.

For example, suppose an inventory tracking system needs to track products by two different types of barcode. Some products are labeled with *1D barcodes* in *UPC format*, which uses the numbers *0* to *9*. Each barcode has a *number system digit*, followed by five *manufacturer code digits* and five *product code digits*. These are followed by a *check digit* to verify that the code has been scanned correctly:

![barcode_UPC_2x.png](../../media/Swift/swift.org/barcode_UPC_2x.png)

Other products are labeled with *2D barcodes* in *QR code format*, which can use any *ISO 8859-1* character and can encode a string up to 2,953 characters long:

![barcode_QR_2x.png](../../media/Swift/swift.org/barcode_QR_2x.png)

It’s convenient for an inventory tracking system to store *UPC barcodes* as a *tuple* of four integers, and *QR code barcodes* as a string of any length.

In Swift, an enumeration to define product barcodes of either type might look like this:

```swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}
```

This can be read as:

“Define an enumeration type called `Barcode`, which can take either a value of `upc` with an *associated value* of type (`Int, Int, Int, Int`), or a value of `qrCode` with an *associated value* of type `String`.”

This definition doesn’t provide any actual `Int` or `String` values, it just defines the type of *associated values* that `Barcode` constants and variables can store when they’re equal to `Barcode.upc` or `Barcode.qrCode`.

You can then create new barcodes using either type:

```swift
var productBarcode = Barcode.upc(8, 85909, 51226, 3)
```

This example creates a new variable called `productBarcode` and assigns it a value of `Barcode.upc` with an *associated tuple value* of `(8, 85909, 51226, 3)`.

You can assign the same product a different type of barcode:

```swift
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
```

Constants and variables of type `Barcode` can store either a `.upc` or a `.qrCode` (together with their *associated values*), but they can store only one of them at any given time.

You extract each associated value as a constant (with the `let` prefix) or a variable (with the `var` prefix) for use within the `switch` case’s body:

```swift
switch productBarcode {
case .upc(let numberSystem, let manufacturer, let product, let check):
    print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")
case .qrCode(let productCode):
    print("QR code: \(productCode).")
}
// Prints "QR code: ABCDEFGHIJKLMNOP."
```

If all of the associated values for an enumeration case are extracted as constants, or if all are extracted as variables, you can place a single `var` or `let` annotation before the case name, for brevity:

```swift
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
    print("UPC : \(numberSystem), \(manufacturer), \(product), \(check).")
case let .qrCode(productCode):
    print("QR code: \(productCode).")
}
// Prints "QR code: ABCDEFGHIJKLMNOP."
```

## Raw Values

The barcode example in [Associated Values](#associated-values) shows how cases of an enumeration can declare that they store associated values of different types. As an alternative to associated values, enumeration cases can come prepopulated with default values (called *raw values*), which are all of the same type.

Here’s an example that stores raw ASCII values alongside named enumeration cases:

```swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
```

Raw values can be *strings*, *characters*, or any of the *integer* or *floating-point number* types. Each raw value must be unique within its enumeration declaration.

> **NOTE**: 
>  
> Raw values are *not* the same as associated values.
>  
> - Raw values are set to prepopulated values when you first define the enumeration in your code, like the three ASCII codes above. The raw value for a particular enumeration case is always the same.
> - Associated values are set when you create a new constant or variable based on one of the enumeration’s cases, and can be different each time you do so.

### Implicitly Assigned Raw Values


