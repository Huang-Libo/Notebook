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
  - [Property Wrappers](#property-wrappers)
    - [Setting Initial Values for Wrapped Properties](#setting-initial-values-for-wrapped-properties)
    - [Projecting a Value From a Property Wrapper](#projecting-a-value-from-a-property-wrapper)
  - [Global and Local Variables](#global-and-local-variables)
  - [Type Properties](#type-properties)

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

Property observers are called every time a property’s value is set, even if the new value is the same as the property’s current value.

You can add property observers in the following places:

- Stored properties that you define
- Stored properties that you inherit
- Computed properties that you inherit

For an inherited property, you add a property observer by overriding that property in a subclass.

For a computed property that you define, use the property’s setter to observe and respond to value changes, instead of trying to create an observer.

You have the option to define either or both of these observers on a property:

- `willSet` is called just *before* the value is stored.
- `didSet` is called immediately *after* the new value is stored.

If you implement a `willSet` observer, it’s passed the new property value as a constant parameter. You can specify a name for this parameter as part of your willSet implementation. If you don’t write the parameter name and parentheses within your implementation, the parameter is made available with a default parameter name of `newValue`.

Similarly, if you implement a `didSet` observer, it’s passed a constant parameter containing the old property value. You can name the parameter or use the default parameter name of `oldValue`. If you assign a value to a property within its own `didSet` observer, the new value that you assign replaces the one that was just set.

> **NOTE**: The `willSet` and `didSet` observers of superclass properties are called when a property is set in a subclass initializer, after the superclass initializer has been called. They aren’t called while a class is setting its own properties, before the superclass initializer has been called.

The example below defines a new class called `StepCounter`, which tracks the total number of steps that a person takes while walking.

```swift
class StepCounter {
    var totalSteps: Int = 0 {
        willSet(newTotalSteps) {
            print("About to set totalSteps to \(newTotalSteps)")
        }
        didSet {
            if totalSteps > oldValue  {
                print("Added \(totalSteps - oldValue) steps")
            }
        }
    }
}
let stepCounter = StepCounter()
stepCounter.totalSteps = 200
// About to set totalSteps to 200
// Added 200 steps
stepCounter.totalSteps = 360
// About to set totalSteps to 360
// Added 160 steps
stepCounter.totalSteps = 896
// About to set totalSteps to 896
// Added 536 steps
```

The `willSet` and `didSet` observers for `totalSteps` are called whenever the property is assigned a new value. This is true even if the new value is the *same* as the current value.

> **NOTE**: If you pass a property that has observers to a function as an *in-out* parameter, the `willSet` and `didSet` observers are always called. This is because of the copy-in copy-out memory model for *in-out* parameters: The value is always *written back* to the property at the end of the function. For a detailed discussion of the behavior of *in-out* parameters, see [LANGUAGE REFERENCE: In-Out Parameters](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID545).

## Property Wrappers

A *property wrapper* adds a layer of separation between *code that manages how a property is stored* and the *code that defines a property*.

For example, if you have properties that provide thread-safety checks or store their underlying data in a database, you have to write that code on every property. When you use a property wrapper, you write the management code once when you define the wrapper, and then reuse that management code by applying it to multiple properties.

To define a property wrapper, you make a *structure*, *enumeration*, or *class* that defines a `wrappedValue` property.

In the code below, the `TwelveOrLess` structure ensures that the value it wraps always contains a number less than or equal to `12`. If you ask it to store a larger number, it stores `12` instead.

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number = 0
    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, 12) }
    }
}
```

You apply a wrapper to a property by writing the wrapper’s name before the property as an attribute. Here’s a structure that stores a rectangle that uses the `TwelveOrLess` property wrapper to ensure its dimensions are always `12` or less:

```swift
struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height)
// Prints "0"

rectangle.height = 10
print(rectangle.height)
// Prints "10"

rectangle.height = 24
print(rectangle.height)
// Prints "12"
```

When you apply a wrapper to a property, the compiler synthesizes code that provides storage for the wrapper and code that provides access to the property through the wrapper. (The property wrapper is responsible for storing the wrapped value, so there’s no synthesized code for that.)

You could write code that uses the behavior of a property wrapper, without taking advantage of the special attribute syntax. For example, here’s a version of `SmallRectangle` from the previous code listing that wraps its properties in the `TwelveOrLess` structure explicitly, instead of writing `@TwelveOrLess` as an attribute:

```swift
struct SmallRectangle {
    private var _height = TwelveOrLess()
    private var _width = TwelveOrLess()
    var height: Int {
        get { return _height.wrappedValue }
        set { _height.wrappedValue = newValue }
    }
    var width: Int {
        get { return _width.wrappedValue }
        set { _width.wrappedValue = newValue }
    }
}
```

The `_height` and `_width` properties store an instance of the property wrapper, `TwelveOrLess`. The getter and setter for height and width wrap access to the `wrappedValue` property.

### Setting Initial Values for Wrapped Properties

To support setting an initial value or other customization, the property wrapper needs to add an initializer. Here’s an expanded version of `TwelveOrLess` called `SmallNumber` that defines initializers that set the wrapped and maximum value:

```swift
@propertyWrapper
struct SmallNumber {
    private var maximum: Int
    private var number: Int

    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, maximum) }
    }

    init() {
        maximum = 12
        number = 0
    }
    init(wrappedValue: Int) {
        maximum = 12
        number = min(wrappedValue, maximum)
    }
    init(wrappedValue: Int, maximum: Int) {
        self.maximum = maximum
        number = min(wrappedValue, maximum)
    }
}
```

When you apply a wrapper to a property and you don’t specify an initial value, Swift uses the init() initializer to set up the wrapper. For example:

```swift
struct ZeroRectangle {
    @SmallNumber var height: Int
    @SmallNumber var width: Int
}

var zeroRectangle = ZeroRectangle()
print(zeroRectangle.height, zeroRectangle.width)
// Prints "0 0"
```

`SmallNumber` also supports writing those initial values as part of declaring the property. When you specify an initial value for the property, Swift uses the `init(wrappedValue:)` initializer to set up the wrapper. For example:

```swift
struct UnitRectangle {
    @SmallNumber var height: Int = 1
    @SmallNumber var width: Int = 1
}

var unitRectangle = UnitRectangle()
print(unitRectangle.height, unitRectangle.width)
// Prints "1 1"
```

When you write `= 1` on a property with a wrapper, that’s translated into a call to the `init(wrappedValue:)` initializer.

When you write arguments in parentheses after the custom attribute, Swift uses the initializer that accepts those arguments to set up the wrapper. For example, if you provide an initial value and a maximum value, Swift uses the `init(wrappedValue:maximum:)` initializer:

```swift
struct NarrowRectangle {
    @SmallNumber(wrappedValue: 2, maximum: 5) var height: Int
    @SmallNumber(wrappedValue: 3, maximum: 4) var width: Int
}

var narrowRectangle = NarrowRectangle()
print(narrowRectangle.height, narrowRectangle.width)
// Prints "2 3"

narrowRectangle.height = 100
narrowRectangle.width = 100
print(narrowRectangle.height, narrowRectangle.width)
// Prints "5 4"
```

This syntax is the most general way to use a property wrapper. You can provide whatever arguments you need to the attribute, and they’re passed to the initializer.

When you include property wrapper arguments, you can also specify an initial value using assignment. Swift treats the assignment like a `wrappedValue` argument and uses the initializer that accepts the arguments you include. For example:

```swift
struct MixedRectangle {
    @SmallNumber var height: Int = 1
    @SmallNumber(maximum: 9) var width: Int = 2
}

var mixedRectangle = MixedRectangle()
print(mixedRectangle.height)
// Prints "1"

mixedRectangle.height = 20
print(mixedRectangle.height)
// Prints "12"
```

The instance of `SmallNumber` that wraps `height` is created by calling `SmallNumber(wrappedValue: 1)`, which uses the default `maximum` value of `12`. The instance that wraps width is created by calling `SmallNumber(wrappedValue: 2, maximum: 9)`.

### Projecting a Value From a Property Wrapper

In addition to the *wrapped value*, a property wrapper can expose additional functionality by defining a *projected value*.

For example, a *property wrapper* that manages access to a database can expose a `flushDatabaseConnection()` method on its projected value. **The name of the projected value is the same as the wrapped value, except it begins with a dollar sign (`$`).**

In the `SmallNumber` example above, if you try to set the property to a number that’s too large, the property wrapper adjusts the number before storing it. The code below adds a `projectedValue` property to the `SmallNumber` structure to keep track of whether the property wrapper adjusted the new value for the property before storing that new value.

```swift
@propertyWrapper
struct SmallNumber {
    private var number: Int
    private(set) var projectedValue: Bool

    var wrappedValue: Int {
        get { return number }
        set {
            if newValue > 12 {
                number = 12
                projectedValue = true
            } else {
                number = newValue
                projectedValue = false
            }
        }
    }

    init() {
        self.number = 0
        self.projectedValue = false
    }
}
struct SomeStructure {
    @SmallNumber var someNumber: Int
}
var someStructure = SomeStructure()

someStructure.someNumber = 4
print(someStructure.$someNumber)
// Prints "false"

someStructure.someNumber = 55
print(someStructure.$someNumber)
// Prints "true"
```

Writing `someStructure.$someNumber` accesses the wrapper’s projected value.

A wrapper that needs to expose more information can return an instance of some other data type, or it can return `self` to expose the instance of the wrapper as its projected value.

When you access a *projected value* from code that’s part of the type, like a property getter or an instance method, you can omit `self.` before the property name, just like accessing other properties.

The code in the following example refers to the *projected value* of the wrapper around `height` and `width` as `$height` and `$width`:

```swift
enum Size {
    case small, large
}

struct SizedRectangle {
    @SmallNumber var height: Int
    @SmallNumber var width: Int

    mutating func resize(to size: Size) -> Bool {
        switch size {
        case .small:
            height = 10
            width = 20
        case .large:
            height = 100
            width = 100
        }
        return $height || $width
    }
}
```

Because *property wrapper* syntax is just *syntactic sugar* for a property with a getter and a setter, accessing height and width behaves the same as accessing any other property.

## Global and Local Variables

The capabilities described above for *computing* and *observing* properties are also available to *global variables* and *local variables*.

- Global variables are variables that are defined outside of any function, method, closure, or type context.
- Local variables are variables that are defined within a function, method, or closure context.

The global and local variables you have encountered in previous chapters have all been *stored variables*. Stored variables, like stored properties, provide storage for a value of a certain type and allow that value to be set and retrieved.

However, you can also define *computed variables* and define observers for stored variables, in either a global or local scope. Computed variables calculate their value, rather than storing it, and they’re written in the same way as computed properties.

> **NOTE**:
>  
> - Global constants and variables are always computed lazily, in a similar manner to [Lazy Stored Properties](#lazy-stored-properties). Unlike lazy stored properties, global constants and variables don’t need to be marked with the `lazy` modifier.
> - Local constants and variables are never computed lazily.

You can apply a property wrapper to a local stored variable, but not to a global variable or a computed variable. For example, in the code below, myNumber uses SmallNumber as a property wrapper.

```swift
func someFunction() {
    @SmallNumber var myNumber: Int = 0

    myNumber = 10
    // now myNumber is 10

    myNumber = 24
    // now myNumber is 12
}
```

## Type Properties


