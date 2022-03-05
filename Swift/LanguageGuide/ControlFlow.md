# ControlFlow

> Version: *Swift 5.6*  
> Source: [*swift-book: Control Flow*](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html)  
> Digest Date: *March 4, 2022*  

- [ControlFlow](#controlflow)
  - [Introduction](#introduction)
  - [For-In Loops](#for-in-loops)
  - [While Loops](#while-loops)
    - [While](#while)
    - [Repeat-While](#repeat-while)
  - [Conditional Statements](#conditional-statements)

## Introduction

Swift provides a variety of control flow statements. These include

- `while` loops to perform a task multiple times;
- `if`, `guard`, and `switch` statements to execute different branches of code based on certain conditions;
- and statements such as `break` and `continue` to transfer the flow of execution to another point in your code.

Swift also provides a `for-in` loop that makes it easy to iterate over *arrays*, *dictionaries*, *ranges*, *strings*, and other *sequences*.

Swift’s `switch` statement is considerably more powerful than its counterpart in many C-like languages. Cases can match many different patterns, including interval matches, tuples, and casts to a specific type. Matched values in a `switch` case can be bound to temporary constants or variables for use within the case’s body, and complex matching conditions can be expressed with a `where` clause for each case.

## For-In Loops

You use the `for-in` loop to iterate over a sequence, such as items in an array, ranges of numbers, or characters in a string.

This example uses a `for-in` loop to iterate over the items in an array:

```swift
let names = ["Anna", "Alex", "Brian", "Jack"]
for name in names {
    print("Hello, \(name)!")
}
// Hello, Anna!
// Hello, Alex!
// Hello, Brian!
// Hello, Jack!
```

You can also iterate over a dictionary to access its key-value pairs. Each item in the dictionary is returned as a `(key, value)` tuple when the dictionary is iterated, and you can decompose the `(key, value)` tuple’s members as explicitly named constants for use within the body of the `for-in` loop. In the code example below, the dictionary’s keys are decomposed into a constant called `animalName`, and the dictionary’s values are decomposed into a constant called `legCount`.

```swift
let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
for (animalName, legCount) in numberOfLegs {
    print("\(animalName)s have \(legCount) legs")
}
// cats have 4 legs
// ants have 6 legs
// spiders have 8 legs
```

The contents of a Dictionary are inherently unordered, and iterating over them doesn’t guarantee the order in which they will be retrieved. In particular, the order you insert items into a `Dictionary` doesn’t define the order they’re iterated. For more about arrays and dictionaries, see [Collection Types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html).

You can also use `for-in` loops with numeric ranges. This example prints the first few entries in a five-times table:

```swift
for index in 1...5 {
    print("\(index) times 5 is \(index * 5)")
}
// 1 times 5 is 5
// 2 times 5 is 10
// 3 times 5 is 15
// 4 times 5 is 20
// 5 times 5 is 25
```

The sequence being iterated over is a range of numbers from `1` to `5`, inclusive, as indicated by the use of the *closed range operator* (`...`).

In the example above, `index` is a constant whose value is automatically set at the start of each iteration of the loop. As such, `index` doesn’t have to be declared before it’s used. It’s *implicitly* declared simply by its inclusion in the loop declaration, without the need for a `let` declaration keyword.

If you don’t need each value from a sequence, you can ignore the values by using an underscore (`_`) in place of a variable name.

```swift
let base = 3
let power = 10
var answer = 1
for _ in 1...power {
    answer *= base
}
print("\(base) to the power of \(power) is \(answer)")
// Prints "3 to the power of 10 is 59049"
```

In some situations, you might not want to use closed ranges, which include both endpoints. Consider drawing the tick marks for every minute on a watch face. You want to draw `60` tick marks, starting with the `0` minute. Use the *half-open range operator* (`..<`) to include the lower bound but not the upper bound. For more about ranges, see [Range Operators](https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html#ID73).

```swift
let minutes = 60
for tickMark in 0..<minutes {
    // render the tick mark each minute (60 times)
}
```

Some users might want fewer tick marks in their UI. They could prefer one mark every `5` minutes instead. Use the `stride(from:to:by:)` function to skip the unwanted marks.

```swift
let minuteInterval = 5
for tickMark in stride(from: 0, to: minutes, by: minuteInterval) {
    // render the tick mark every 5 minutes (0, 5, 10, 15 ... 45, 50, 55)
}
```

Closed ranges are also available, by using `stride(from:through:by:)` instead:

```swift
let hours = 12
let hourInterval = 3
for tickMark in stride(from: 3, through: hours, by: hourInterval) {
    // render the tick mark every 3 hours (3, 6, 9, 12)
}
```

The examples above use a `for-in` loop to iterate ranges, arrays, dictionaries, and strings. However, you can use this syntax to iterate *any* collection, including your own classes and collection types, as long as those types conform to the [Sequence](https://developer.apple.com/documentation/swift/sequence) protocol.

## While Loops

A `while` loop performs a set of statements until a condition becomes `false`. These kinds of loops are best used when the number of iterations isn’t known before the first iteration begins. Swift provides two kinds of `while` loops:

- `while` evaluates its condition at the start of each pass through the loop.
- `repeat-while` evaluates its condition at the end of each pass through the loop.

### While

A `while` loop starts by evaluating a single condition. If the condition is `true`, a set of statements is repeated until the condition becomes `false`.

Here’s the general form of a while loop:

![](../../media/Swift/swift.org/while-syntax.png)

This example plays a simple game of *Snakes and Ladders* (also known as *Chutes and Ladders*):

![](../../media/Swift/swift.org/snakesAndLadders_2x.png)

The rules of the game are as follows:

- The board has 25 squares, and the aim is to land on or beyond square 25.
- The player’s starting square is “square zero”, which is just off the bottom-left corner of the board.
- Each turn, you roll a six-sided dice and move by that number of squares, following the horizontal path indicated by the dotted arrow above.
- If your turn ends at the bottom of a ladder, you move up that ladder.
- If your turn ends at the head of a snake, you move down that snake.

The game board is represented by an array of `Int` values. Its size is based on a constant called `finalSquare`, which is used to initialize the array and also to check for a win condition later in the example. Because the players start off the board, on “square zero”, the board is initialized with 26 zero `Int` values, not 25.

```swift
let finalSquare = 25
var board = [Int](repeating: 0, count: finalSquare + 1)
```

Some squares are then set to have more specific values for the snakes and ladders. Squares with a ladder base have a positive number to move you up the board, whereas squares with a snake head have a negative number to move you back down the board.

```swift
board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
```

To align the values and statements, the unary plus operator (`+i`) is explicitly used with the unary minus operator (`-i`) and numbers lower than `10` are padded with zeros. (Neither stylistic technique is strictly necessary, but they lead to neater code.)

```swift
var square = 0
var diceRoll = 0
while square < finalSquare {
    // roll the dice
    diceRoll += 1
    if diceRoll == 7 { diceRoll = 1 }
    // move by the rolled amount
    square += diceRoll
    if square < board.count {
        // if we're still on the board, move up or down for a snake or a ladder
        square += board[square]
    }
}
print("Game over!")
```

The example above uses a very simple approach to dice rolling. Instead of generating a random number, it starts with a `diceRoll` value of `0`. Each time through the `while` loop, `diceRoll` is incremented by one and is then checked to see whether it has become too large. Whenever this return value equals `7`, the dice roll has become too large and is reset to a value of `1`. The result is a sequence of diceRoll values that’s always `1`, `2`, `3`, `4`, `5`, `6`, `1`, `2` and so on.

A `while` loop is appropriate in this case, because the length of the game isn’t clear at the start of the `while` loop. Instead, the loop is executed until a particular condition is satisfied.

### Repeat-While

The other variation of the `while` loop, known as the `repeat-while` loop, performs a single pass through the loop block first, *before* considering the loop’s condition. It then continues to repeat the loop until the condition is `false`.

> **NOTE**: The `repeat-while` loop in Swift is analogous to a `do-while` loop in other languages.

Here’s the general form of a `repeat-while` loop:

![](../../media/Swift/swift.org/repeat-while-syntax.png)

Here’s the *Snakes and Ladders* example again, written as a `repeat-while` loop rather than a `while` loop. The values of `finalSquare`, `board`, `square`, and `diceRoll` are initialized in exactly the same way as with a `while` loop.

```swift
let finalSquare = 25
var board = [Int](repeating: 0, count: finalSquare + 1)
board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02
board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08
var square = 0
var diceRoll = 0
```

In this version of the game, the *first* action in the loop is to check for a ladder or a snake. No ladder on the board takes the player straight to square 25, and so it isn’t possible to win the game by moving up a ladder. Therefore, it’s safe to check for a snake or a ladder as the first action in the loop.

At the start of the game, the player is on “square zero”. `board[0]` always equals `0` and has no effect.

```swift
repeat {
    // move up or down for a snake or ladder
    square += board[square]
    // roll the dice
    diceRoll += 1
    if diceRoll == 7 { diceRoll = 1 }
    // move by the rolled amount
    square += diceRoll
} while square < finalSquare
print("Game over!")
```

The loop’s condition (`while square < finalSquare`) is the same as before, but this time it’s not evaluated until the *end* of the first run through the loop.

The structure of the `repeat-while` loop is better suited to this game than the `while` loop in the previous example. In the `repeat-while` loop above, `square += board[square]` is always executed immediately after the loop’s `while` condition confirms that square is still on the board. This behavior removes the need for the array bounds check seen in the `while` loop version of the game described earlier.

## Conditional Statements


