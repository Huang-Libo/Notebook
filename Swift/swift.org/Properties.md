# Properties

> Version: *Swift 5.5*  
> Source: [*swift-book: Properties*](https://docs.swift.org/swift-book/LanguageGuide/Properties.html)  
> Digest Date: *January 15, 2022*  

Properties associate values with a particular *class*, *structure*, or *enumeration*.

- *Stored properties* store constant and variable values as part of an instance. (Provided only by *classes* and *structures*.)
- *Computed properties* calculate (rather than store) a value. (Provided by *classes*, *structures*, and *enumerations*.)

Stored and computed properties are usually associated with *instances* of a particular type. However, properties can also be associated with the *type* itself. Such properties are known as *type properties*.

In addition, you can define *property observers* to monitor changes in a property’s value, which you can respond to with custom actions. Property observers can be added to stored properties you define yourself, and also to properties that a subclass inherits from its superclass.

You can also use a *property wrapper* to reuse code in the getter and setter of multiple properties.

- [Properties](#properties)
  - [Stored Properties](#stored-properties)
    - [Stored Properties of Constant Structure Instances](#stored-properties-of-constant-structure-instances)
    - [Lazy Stored Properties](#lazy-stored-properties)
    - [Stored Properties and Instance Variables](#stored-properties-and-instance-variables)
  - [Computed Properties](#computed-properties)
    - [Shorthand Setter Declaration](#shorthand-setter-declaration)
    - [Shorthand Getter Declaration](#shorthand-getter-declaration)
    - [Read-Only Computed Properties](#read-only-computed-properties)
  - [Property Observers](#property-observers)

## Stored Properties

In its simplest form, a stored property is a constant (`var`) or variable (`let`) that’s stored as part of an instance of a particular *class* or *structure*.

The example below defines a structure called `FixedLengthRange`, which describes a range of integers whose range `length` can’t be changed after it’s created:

```swift
struct FixedLengthRange {
    var firstValue: Int
    let length: Int
}
var rangeOfThreeItems = FixedLengthRange(firstValue: 0, length: 3)
// the range represents integer values 0, 1, and 2
rangeOfThreeItems.firstValue = 6
// the range now represents integer values 6, 7, and 8
```

### Stored Properties of Constant Structure Instances

If you create an instance of a structure and assign that instance to a constant, you can’t modify the instance’s properties, even if they were declared as variable properties:

```swift
// this range represents integer values 0, 1, 2, and 3
let rangeOfFourItems = FixedLengthRange(firstValue: 0, length: 4)
// this will report an error, even though firstValue is a variable property
rangeOfFourItems.firstValue = 6

```

- This behavior is due to *structures* being *value types*. When an instance of a value type is marked as a constant, so are all of its properties.
- The same isn’t true for cla*s*ses, which are *reference types*. If you assign an instance of a reference type to a constant, you can still change that instance’s variable properties.

### Lazy Stored Properties

A *lazy stored property* is a property whose initial value isn’t calculated until the first time it’s used. You indicate a lazy stored property by writing the `lazy` modifier before its declaration.

> **NOTE**: You must *always* declare a `lazy` property as a variable (with the `var` keyword), because its initial value might not be retrieved until after instance initialization completes. Constant properties must always have a value *before* initialization completes, and therefore can’t be declared as `lazy`.

The example below uses a lazy stored property to avoid unnecessary initialization of a complex class. This example defines two classes called `DataImporter` and `DataManager`, neither of which is shown in full:

```swift
class DataImporter {
    /*
    DataImporter is a class to import data from an external file.
    The class is assumed to take a nontrivial amount of time to initialize.
    */
    var filename = "data.txt"
    // the DataImporter class would provide data importing functionality here
}

class DataManager {
    lazy var importer = DataImporter()
    var data: [String] = []
    // the DataManager class would provide data management functionality here
}

let manager = DataManager()
manager.data.append("Some data")
manager.data.append("Some more data")
// the DataImporter instance for the importer property hasn't yet been created
```

Because it’s marked with the `lazy` modifier, the `DataImporter` instance for the `importer` property is only created when the `importer` property is first accessed, such as when its `filename` property is queried:

```swift
print(manager.importer.filename)
// the DataImporter instance for the importer property has now been created
// Prints "data.txt"
```

> **NOTE**: If a property marked with the `lazy` modifier is accessed by multiple threads simultaneously and the property hasn’t yet been initialized, there’s no guarantee that the property will be initialized only once.

### Stored Properties and Instance Variables

If you have experience with Objective-C, you may know that it provides two ways to store values and references as part of a class instance. In addition to properties, you can use instance variables as a backing store for the values stored in a property.

Swift unifies these concepts into a single property declaration. A Swift property doesn’t have a corresponding instance variable, and the backing store for a property isn’t accessed directly.

## Computed Properties

In addition to stored properties, `classes`, `structures`, and `enumerations` can define *computed properties*, which don’t actually store a value. Instead, they provide a getter and an optional setter to retrieve and set other properties and values indirectly.

```swift
struct Point {
    var x = 0.0, y = 0.0
}
struct Size {
    var width = 0.0, height = 0.0
}
struct Rect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set(newCenter) {
            origin.x = newCenter.x - (size.width / 2)
            origin.y = newCenter.y - (size.height / 2)
        }
    }
}
var square = Rect(origin: Point(x: 0.0, y: 0.0),
                  size: Size(width: 10.0, height: 10.0))
let initialSquareCenter = square.center
square.center = Point(x: 15.0, y: 15.0)
print("square.origin is now at (\(square.origin.x), \(square.origin.y))")
// Prints "square.origin is now at (10.0, 10.0)"
```

`Rect` defines a custom *getter* and *setter* for a computed variable called `center`, to enable you to work with the rectangle’s `center` as if it were a real stored property.

Setting the `center` property calls the setter for `center`, which modifies the `x` and `y` values of the stored `origin` property, and moves the square to its new position.

<img src="../../media/Swift/computedProperties_2x.png" width="50%"/>

### Shorthand Setter Declaration

If a computed property’s setter doesn’t define a name for the new value to be set, a default name of `newValue` is used. Here’s an alternative version of the `Rect` structure that takes advantage of this shorthand notation:

```swift
struct AlternativeRect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}
```

### Shorthand Getter Declaration

If the entire body of a getter is a single expression, the getter implicitly returns that expression. Here’s an another version of the `Rect` structure that takes advantage of this shorthand notation and the shorthand notation for setters:

```swift
struct CompactRect {
    var origin = Point()
    var size = Size()
    var center: Point {
        get {
            Point(x: origin.x + (size.width / 2),
                  y: origin.y + (size.height / 2))
        }
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
}
```

Omitting the `return` from a getter follows the same rules as omitting `return` from a function, as described in [Functions With an Implicit Return](https://docs.swift.org/swift-book/LanguageGuide/Functions.html#ID607).

### Read-Only Computed Properties

A computed property with a getter but no setter is known as a *read-only computed property*.

> **NOTE**: You must declare computed properties, including read-only computed properties as *variable properties* with the `var` keyword, because their value isn’t fixed. The `let` keyword is only used for constant properties, to indicate that their values can’t be changed once they’re set as part of instance initialization.

You can simplify the declaration of a read-only computed property by removing the get keyword and its braces:

```swift
struct Cuboid {
    var width = 0.0, height = 0.0, depth = 0.0
    var volume: Double {
        return width * height * depth
    }
}
let fourByFiveByTwo = Cuboid(width: 4.0, height: 5.0, depth: 2.0)
print("the volume of fourByFiveByTwo is \(fourByFiveByTwo.volume)")
// Prints "the volume of fourByFiveByTwo is 40.0"
```

## Property Observers


