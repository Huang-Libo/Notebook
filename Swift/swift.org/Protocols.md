# Protocols

> Version: *Swift 5.5*  
> Source: [*swift-book: Protocols*](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)  
> Digest Date: *February 3, 2022*  

A *protocol* defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a *class*, *structure*, or *enumeration* to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to *conform* to that protocol.

In addition to specifying requirements that conforming types must implement, you can *extend* a protocol to implement some of these requirements or to implement additional functionality that conforming types can take advantage of.

- [Protocols](#protocols)
  - [Protocol Syntax](#protocol-syntax)
  - [Property Requirements](#property-requirements)
  - [Method Requirements](#method-requirements)
  - [Mutating Method Requirements](#mutating-method-requirements)
  - [Initializer Requirements](#initializer-requirements)
    - [Class Implementations of Protocol Initializer Requirements](#class-implementations-of-protocol-initializer-requirements)
    - [Failable Initializer Requirements](#failable-initializer-requirements)
  - [Protocols as Types](#protocols-as-types)
  - [Delegation](#delegation)
  - [Adding Protocol Conformance with an Extension](#adding-protocol-conformance-with-an-extension)
    - [Conditionally Conforming to a Protocol](#conditionally-conforming-to-a-protocol)
    - [Declaring Protocol Adoption with an Extension](#declaring-protocol-adoption-with-an-extension)
  - [Adopting a Protocol Using a Synthesized Implementation](#adopting-a-protocol-using-a-synthesized-implementation)
    - [Equatable](#equatable)
    - [Hashable](#hashable)
    - [Comparable](#comparable)
  - [Collections of Protocol Types](#collections-of-protocol-types)

## Protocol Syntax

You define protocols in a very similar way to *classes*, *structures*, and *enumerations*:

```swift
protocol SomeProtocol {
    // protocol definition goes here
}
```

Custom types state that they adopt a particular protocol by placing the protocol’s name after the type’s name, separated by a *colon*, as part of their definition. Multiple protocols can be listed, and are separated by *commas*:

```swift
struct SomeStructure: FirstProtocol, AnotherProtocol {
    // structure definition goes here
}
```

If a class has a superclass, list the superclass name before any protocols it adopts, followed by a comma:

```swift
class SomeClass: SomeSuperclass, FirstProtocol, AnotherProtocol {
    // class definition goes here
}
```

## Property Requirements

A protocol can require any conforming type to provide an instance property or type property with a particular name and type. The protocol doesn’t specify whether the property should be a *stored property* or a *computed property*, it only specifies the required property *name* and *type*. The protocol also specifies whether each property must be *gettable* or *gettable and settable*.

- If a protocol requires a property to be *gettable and settable*, that property requirement can’t be fulfilled by a constant stored property or a read-only computed property.
- If the protocol only requires a property to be *gettable*, the requirement can be satisfied by any kind of property, *and it’s valid for the property to be also settable if this is useful for your own code*.

Property requirements are always declared as *variable properties*, prefixed with the `var` keyword. Gettable and settable properties are indicated by writing `{ get set }` after their type declaration, and gettable properties are indicated by writing `{ get }`.

```swift
protocol SomeProtocol {
    var mustBeSettable: Int { get set }
    var doesNotNeedToBeSettable: Int { get }
}
```

*Always* prefix *type property* requirements with the `static` keyword when you define them in a protocol. This rule pertains even though type property requirements can be prefixed with the `class` or `static` keyword when implemented by a class:

```swift
protocol AnotherProtocol {
    static var someTypeProperty: Int { get set }
}
```

Here’s an example of a protocol with a single instance property requirement:

```swift
protocol FullyNamed {
    var fullName: String { get }
}
```

Here’s an example of a simple structure that adopts and conforms to the `FullyNamed` protocol:

```swift
struct Person: FullyNamed {
    var fullName: String
}
let john = Person(fullName: "John Appleseed")
// john.fullName is "John Appleseed"
```

Here’s a more complex class, which also adopts and conforms to the `FullyNamed` protocol:

```swift
class Starship: FullyNamed {
    var prefix: String?
    var name: String
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    var fullName: String {
        return (prefix != nil ? prefix! + " " : "") + name
    }
}
var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
// ncc1701.fullName is "USS Enterprise"
```

This class implements the `fullName` property requirement as a *computed read-only property* for a starship. Each `Starship` class instance stores a mandatory `name` and an optional `prefix`. The `fullName` property uses the `prefix` value if it exists, and prepends it to the beginning of `name` to create a full name for the starship.

## Method Requirements

Protocols can require specific *instance methods* and *type methods* to be implemented by conforming types. These methods are written as part of the protocol’s definition in exactly the same way as for normal instance and type methods, but without curly braces or a method body. Variadic parameters are allowed, subject to the same rules as for normal methods. **Default values, however, can’t be specified for method parameters within a protocol’s definition.**

As with *type property* requirements, you always prefix type method requirements with the `static` keyword when they’re defined in a protocol. This is true even though type method requirements are prefixed with the `class` or `static` keyword when implemented by a class:

```swift
protocol SomeProtocol {
    static func someTypeMethod()
}
```

The following example defines a protocol with a single instance method requirement:

```swift
protocol RandomNumberGenerator {
    func random() -> Double
}
```

This protocol, `RandomNumberGenerator`, requires any conforming type to have an instance method called `random`, which returns a `Double` value whenever it’s called. Although it’s not specified as part of the protocol, it’s assumed that this value will be a number from `0.0` up to (but not including) `1.0`.

Here’s an implementation of a class that adopts and conforms to the `RandomNumberGenerator` protocol. This class implements a pseudorandom number generator algorithm known as a *linear congruential generator*:

```swift
class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c)
            .truncatingRemainder(dividingBy:m))
        return lastRandom / m
    }
}
let generator = LinearCongruentialGenerator()
print("Here's a random number: \(generator.random())")
// Prints "Here's a random number: 0.3746499199817101"
print("And another one: \(generator.random())")
// Prints "And another one: 0.729023776863283"
```

## Mutating Method Requirements

 It’s sometimes necessary for a method to modify (or *mutate*) the instance it belongs to. For instance methods on *value types* (that is, *structures* and *enumerations*) you place the `mutating` keyword before a method’s `func` keyword to indicate that the method is allowed to modify the instance it belongs to and any properties of that instance. This process is described in [Modifying Value Types from Within Instance Methods](https://docs.swift.org/swift-book/LanguageGuide/Methods.html#ID239).

> **NOTE**: If you mark a protocol instance method requirement as `mutating`, you don’t need to write the `mutating` keyword when writing an implementation of that method for a *class*. The `mutating` keyword is only used by *structures* and *enumerations*.

The example below defines a protocol called `Togglable`, which defines a single instance method requirement called `toggle`. As its name suggests, the `toggle()` method is intended to toggle or invert the state of any conforming type, typically by modifying a property of that type.

```swift
protocol Togglable {
    mutating func toggle()
}
```

The example below defines an enumeration called `OnOffSwitch`. This enumeration toggles between two states, indicated by the enumeration cases `on` and `off`. The enumeration’s `toggle` implementation is marked as `mutating`, to match the `Togglable` protocol’s requirements:

```swift
enum OnOffSwitch: Togglable {
    case off, on
    mutating func toggle() {
        switch self {
        case .off:
            self = .on
        case .on:
            self = .off
        }
    }
}
var lightSwitch = OnOffSwitch.off
lightSwitch.toggle()
// lightSwitch is now equal to .on
```

## Initializer Requirements

Protocols can require specific initializers to be implemented by conforming types. You write these initializers as part of the protocol’s definition in exactly the same way as for normal initializers, but without curly braces or an initializer body:

```swift
protocol SomeProtocol {
    init(someParameter: Int)
}
```

### Class Implementations of Protocol Initializer Requirements

You can implement a protocol initializer requirement on a conforming class as either a *designated initializer* or a *convenience initializer*. In both cases, you must mark the initializer implementation with the `required` modifier:

```swift
class SomeClass: SomeProtocol {
    required init(someParameter: Int) {
        // initializer implementation goes here
    }
}
```

The use of the `required` modifier ensures that you provide an explicit or inherited implementation of the initializer requirement on all subclasses of the conforming class, such that they also conform to the protocol.

For more information on required initializers, see [Required Initializers](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID231).

> **NOTE**: You don’t need to mark protocol initializer implementations with the `required` modifier on classes that are marked with the `final` modifier, because *final classes* can’t subclassed. For more about the `final` modifier, see [Preventing Overrides](https://docs.swift.org/swift-book/LanguageGuide/Inheritance.html#ID202).

If a subclass overrides a designated initializer from a superclass, and also implements a matching initializer requirement from a protocol, mark the initializer implementation with both the `required` and `override` modifiers:

```swift
protocol SomeProtocol {
    init()
}

class SomeSuperClass {
    init() {
        // initializer implementation goes here
    }
}

class SomeSubClass: SomeSuperClass, SomeProtocol {
    // "required" from SomeProtocol conformance; "override" from SomeSuperClass
    required override init() {
        // initializer implementation goes here
    }
}
```

### Failable Initializer Requirements

Protocols can define failable initializer requirements for conforming types, as defined in [Failable Initializers](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID224).

A failable initializer requirement can be satisfied by a failable or nonfailable initializer on a conforming type. A nonfailable initializer requirement can be satisfied by a nonfailable initializer or an implicitly unwrapped failable initializer.

## Protocols as Types

Protocols don’t actually implement any functionality themselves. Nonetheless, you can use protocols as a fully fledged types in your code. Using a protocol as a type is sometimes called an *existential type*, which comes from the phrase “there exists a type *T* such that *T* conforms to the protocol”.

You can use a protocol in many places where other types are allowed, including:

- As a parameter type or return type in a function, method, or initializer
- As the type of a constant, variable, or property
- As the type of items in an array, dictionary, or other container

Here’s an example of a protocol used as a type:

```swift
class Dice {
    let sides: Int
    let generator: RandomNumberGenerator
    init(sides: Int, generator: RandomNumberGenerator) {
        self.sides = sides
        self.generator = generator
    }
    func roll() -> Int {
        return Int(generator.random() * Double(sides)) + 1
    }
}
```

This example defines a new class called `Dice`, which represents an *n*-sided dice for use in a board game. `Dice` instances have an integer property called `sides`, which represents how many sides they have, and a property called `generator`, which provides a random number generator from which to create dice roll values.

`Dice` provides one instance method, `roll`, which returns an integer value between `1` and the number of sides on the dice. This method calls the generator’s `random()` method to create a new random number between `0.0` and `1.0`, and uses this random number to create a dice roll value within the correct range.

Here’s how the `Dice` class can be used to create a *six*-sided dice with a `LinearCongruentialGenerator` instance as its random number generator:

```swift
var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}
// Random dice roll is 3
// Random dice roll is 5
// Random dice roll is 4
// Random dice roll is 5
// Random dice roll is 4
```

## Delegation

*Delegation* is a design pattern that enables a *class* or *structure* to hand off (or delegate) some of its responsibilities to an instance of another type.

The example below defines two protocols for use with dice-based board games:

```swift
protocol DiceGame {
    var dice: Dice { get }
    func play()
}
protocol DiceGameDelegate: AnyObject {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}
```

The `DiceGame` protocol is a protocol that can be adopted by any game that involves dice.

The `DiceGameDelegate` protocol can be adopted to track the progress of a `DiceGame`. To prevent strong reference cycles, delegates are declared as `weak` references. For information about weak references, see [Strong Reference Cycles Between Class Instances](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html#ID51).

Marking the protocol as *class-only* lets the `SnakesAndLadders` class later in this chapter declare that its delegate must use a `weak` reference. **A class-only protocol is marked by its inheritance from `AnyObject`**, as discussed in [Class-Only Protocols](#class-only-protocols).

Here’s a version of the *Snakes and Ladders* game originally introduced in [Control Flow](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html). This version is adapted to use a `Dice` instance for its dice-rolls; to adopt the `DiceGame` protocol; and to notify a `DiceGameDelegate` about its progress:

```swift
class SnakesAndLadders: DiceGame {
    let finalSquare = 25
    let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    var square = 0
    var board: [Int]
    init() {
        board = Array(repeating: 0, count: finalSquare + 1)
        board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
        board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
    }
    weak var delegate: DiceGameDelegate?
    func play() {
        square = 0
        delegate?.gameDidStart(self)
        gameLoop: while square != finalSquare {
            let diceRoll = dice.roll()
            delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
            switch square + diceRoll {
            case finalSquare:
                break gameLoop
            case let newSquare where newSquare > finalSquare:
                continue gameLoop
            default:
                square += diceRoll
                square += board[square]
            }
        }
        delegate?.gameDidEnd(self)
    }
}
```

For a description of the *Snakes and Ladders* gameplay, see [Break](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html#ID137).

This version of the game is wrapped up as a class called `SnakesAndLadders`, which adopts the `DiceGame` protocol. It provides a gettable `dice` property and a `play()` method in order to conform to the protocol. (The `dice` property is declared as a constant property because it doesn’t need to change after initialization, and the protocol only requires that it must be gettable.)

Note that the `delegate` property is defined as an *optional* `DiceGameDelegate`, because a `delegate` isn’t required in order to play the game. Because it’s of an optional type, the `delegate` property is automatically set to an initial value of `nil`. Thereafter, the game instantiator has the option to set the property to a suitable delegate. Because the DiceGameDelegate protocol is *class-only*, you can declare the delegate to be `weak` to prevent reference cycles.

This next example shows a class called `DiceGameTracker`, which adopts the `DiceGameDelegate` protocol:

```swift
class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders {
            print("Started a new game of Snakes and Ladders")
        }
        print("The game is using a \(game.dice.sides)-sided dice")
    }
    func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Rolled a \(diceRoll)")
    }
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns")
    }
}
```

Here’s how `DiceGameTracker` looks in action:

```swift
let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegate = tracker
game.play()
// Started a new game of Snakes and Ladders
// The game is using a 6-sided dice
// Rolled a 3
// Rolled a 5
// Rolled a 4
// Rolled a 5
// The game lasted for 4 turns
```

## Adding Protocol Conformance with an Extension

You can extend an existing type to adopt and conform to a new protocol, even if you don’t have access to the source code for the existing type. Extensions can add new *properties*, *methods*, and *subscripts* to an existing type, and are therefore able to add any requirements that a protocol may demand. For more about extensions, see [Extensions](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html).

For example, this protocol, called `TextRepresentable`, can be implemented by any type that has a way to be represented as text. This might be a description of itself, or a text version of its current state:

```swift
protocol TextRepresentable {
    var textualDescription: String { get }
}
```

The `Dice` class from above can be extended to adopt and conform to `TextRepresentable`:

```swift
extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides)-sided dice"
    }
}
```

Any Dice instance can now be treated as TextRepresentable:

```swift
let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
print(d12.textualDescription)
// Prints "A 12-sided dice"
```

Similarly, the `SnakesAndLadders` game class can be extended to adopt and conform to the `TextRepresentable` protocol:

```swift
extension SnakesAndLadders: TextRepresentable {
    var textualDescription: String {
        return "A game of Snakes and Ladders with \(finalSquare) squares"
    }
}
print(game.textualDescription)
// Prints "A game of Snakes and Ladders with 25 squares"
```

### Conditionally Conforming to a Protocol

A generic type may be able to satisfy the requirements of a protocol only under certain conditions, such as when the type’s generic parameter conforms to the protocol. You can make a generic type conditionally conform to a protocol by listing constraints when extending the type. Write these constraints after the name of the protocol you’re adopting by writing a generic `where` clause. For more about generic where clauses, see [Generic Where Clauses](https://docs.swift.org/swift-book/LanguageGuide/Generics.html#ID192).

The following extension makes `Array` instances conform to the `TextRepresentable` protocol whenever they store elements of a type that conforms to `TextRepresentable`.

```swift
extension Array: TextRepresentable where Element: TextRepresentable {
    var textualDescription: String {
        let itemsAsText = self.map { $0.textualDescription }
        return "[" + itemsAsText.joined(separator: ", ") + "]"
    }
}
let myDice = [d6, d12]
print(myDice.textualDescription)
// Prints "[A 6-sided dice, A 12-sided dice]"
```

### Declaring Protocol Adoption with an Extension

If a type already conforms to all of the requirements of a protocol, but hasn’t yet stated that it adopts that protocol, you can make it adopt the protocol with an empty extension:

```swift
struct Hamster {
    var name: String
    var textualDescription: String {
        return "A hamster named \(name)"
    }
}
extension Hamster: TextRepresentable {}
```

Instances of `Hamster` can now be used wherever `TextRepresentable` is the required type:

```swift
let simonTheHamster = Hamster(name: "Simon")
let somethingTextRepresentable: TextRepresentable = simonTheHamster
print(somethingTextRepresentable.textualDescription)
// Prints "A hamster named Simon"
```

> **NOTE**: Types don’t automatically adopt a protocol just by satisfying its requirements. They must always explicitly declare their adoption of the protocol.

## Adopting a Protocol Using a Synthesized Implementation

Swift can automatically provide the protocol conformance for `Equatable`, `Hashable`, and `Comparable` in many simple cases. Using this synthesized implementation means you don’t have to write repetitive boilerplate code to implement the protocol requirements yourself.

### Equatable

Swift provides a synthesized implementation of `Equatable` for the following kinds of custom types:

- *Structures* that have only *stored properties* that conform to the `Equatable` protocol
- *Enumerations* that have only *associated types* that conform to the `Equatable` protocol
- *Enumerations* that have no *associated types*

To receive a synthesized implementation of `==`, declare conformance to `Equatable` in the file that contains the original declaration, without implementing an `==` operator yourself. The Equatable protocol provides a default implementation of `!=`.

The example below defines a `Vector3D` structure for a three-dimensional position vector `(x, y, z)`, similar to the `Vector2D` structure. Because the `x`, `y`, and `z` properties are all of an `Equatable` type, `Vector3D` receives synthesized implementations of the equivalence operators.

```swift
struct Vector3D: Equatable {
    var x = 0.0, y = 0.0, z = 0.0
}

let twoThreeFour = Vector3D(x: 2.0, y: 3.0, z: 4.0)
let anotherTwoThreeFour = Vector3D(x: 2.0, y: 3.0, z: 4.0)
if twoThreeFour == anotherTwoThreeFour {
    print("These two vectors are also equivalent.")
}
// Prints "These two vectors are also equivalent."
```

### Hashable

Swift provides a synthesized implementation of `Hashable` for the following kinds of custom types:

- *Structures* that have only *stored properties* that conform to the `Hashable` protocol
- *Enumerations* that have only *associated types* that conform to the `Hashable` protocol
- *Enumerations* that have no *associated types*

To receive a synthesized implementation of `hash(into:)`, declare conformance to `Hashable` in the file that contains the original declaration, without implementing a `hash(into:)` method yourself.

### Comparable

Swift provides a synthesized implementation of `Comparable` for *enumerations* that don’t have a *raw value*. If the enumeration has *associated types*, they must all conform to the `Comparable` protocol.

To receive a synthesized implementation of `<`, declare conformance to `Comparable` in the file that contains the original enumeration declaration, without implementing a `<` operator yourself. The Comparable protocol’s default implementation of `<=`, `>`, and `>=` provides the remaining comparison operators.

The example below defines a `SkillLevel` enumeration with cases for `beginners`, `intermediates`, and `experts`. Experts are additionally ranked by the number of stars they have.

```swift
enum SkillLevel: Comparable {
    case beginner
    case intermediate
    case expert(stars: Int)
}
var levels = [SkillLevel.intermediate, SkillLevel.beginner,
              SkillLevel.expert(stars: 5), SkillLevel.expert(stars: 3)]
for level in levels.sorted() {
    print(level)
}
// Prints "beginner"
// Prints "intermediate"
// Prints "expert(stars: 3)"
// Prints "expert(stars: 5)"
```

## Collections of Protocol Types


