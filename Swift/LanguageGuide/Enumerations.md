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


