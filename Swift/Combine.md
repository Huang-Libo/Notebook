# Combine

Swift, iOS 13.0+, macOS 10.15+

- [Combine](#combine)
  - [Overview](#overview)
  - [Publisher](#publisher)
  - [Subscriber](#subscriber)
  - [Subscription](#subscription)
  - [Binding](#binding)
  - [State](#state)
  - [EnvironmentObject](#environmentobject)
  - [StateObject](#stateobject)
  - [ObservableObject](#observableobject)
  - [CustomCombineIdentifierConvertible](#customcombineidentifierconvertible)
  - [WWDC Video](#wwdc-video)

## Overview

- *publisher* : expose values that can change over time.
- *subscriber* : receive those values from the publishers.

## Publisher

```swift
protocol Publisher
```

Publishers have *operators* to act on the values received from upstream publishers and republish them.

The *publisher* implements the `receive(subscriber:)` method to accept a *subscriber*.

After this, the *publisher* can call the following methods on the *subscriber* :

- `receive(subscription:):` Acknowledges the subscribe request and returns a `Subscription` instance. The `subscriber` uses the `subscription` to demand elements from the *publisher* and can use it to cancel publishing.
- `receive(_:):` Delivers one element from the *publisher* to the *subscriber*.
- `receive(completion:):` Informs the `subscriber` that publishing has ended, either normally or with an error.

## Subscriber

```swift
protocol Subscriber : CustomCombineIdentifierConvertible
```

Publishers only emit values when explicitly **requested** to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.

## Subscription

A protocol representing the **connection** of a *subscriber* to a *publisher*.

```swift
protocol Subscription : Cancellable, CustomCombineIdentifierConvertible
```

`request(_:)`

Tells a publisher that it may send more values to the subscriber.

```swift
func request(_ demand: Subscribers.Demand)
```

## Binding

A *property wrapper* type that can read and write a value owned by a source of truth.

**Declaration**:

```swift
@frozen @propertyWrapper @dynamicMemberLookup struct Binding<Value>
```

**Overview**:

Use a binding to create a two-way connection between a property that stores data, and a view that displays and changes the data. A binding connects a property to a source of truth stored elsewhere, instead of storing data directly.

For example, a button that toggles between play and pause can create a binding to a property of its parent view using the `Binding` *property wrapper*.

```swift
struct PlayButton: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            HStack {
                Image(systemName: (isPlaying ? "pause.circle" : "play.circle"))
                Text("abc")
                
            }
        }
    }
}
```

The parent view declares a property to hold the playing state, using the `State` *property wrapper* to indicate that this property is the value’s source of truth.

```swift
struct PlayerView: View {
    var name: String
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            Text(name)
            Text(isPlaying ? "✅" : "❌")
            PlayButton(isPlaying: $isPlaying)
        }
        .padding()
    }
}
```

When `PlayerView` initializes `PlayButton`, it passes a binding of its state property into the button’s binding property. Applying the `$` prefix to a property wrapped value returns its `projectedValue`, which for a *state property wrapper* returns a binding to the value.

Whenever the user taps the `PlayButton`, the `PlayerView` updates its `isPlaying` state.

## State

A *property wrapper* type that can read and write a value managed by SwiftUI.

**Declaration**:

```swift
@frozen @propertyWrapper struct State<Value>
```

**Overview**:

SwiftUI manages the storage of any property you declare as a state. When the state value changes, the view invalidates its appearance and recomputes the `body`. Use the state as the single source of truth for a given view.

A `State` instance isn’t the value itself; it’s a means of reading and writing the value. To access a state’s underlying value, use its variable name, which returns the `wrappedValue` property value.

You should only access a state property from inside the view’s body, or from methods called by it. For this reason, declare your state properties as `private`, to prevent clients of your view from accessing them. **It is safe to mutate state properties from any thread.**

To pass a state property to another view in the view hierarchy, use the variable name with the `$` prefix operator. This retrieves a binding of the state property from its `projectedValue` property.

For example, in the following code example `PlayerView` passes its state property `isPlaying` to `PlayButton` using `$isPlaying`.

## EnvironmentObject

A *property wrapper* type for an observable object supplied by a parent or ancestor view.

**Declaration**:

```swift
@frozen @propertyWrapper struct EnvironmentObject<ObjectType> where ObjectType : ObservableObject
```

**Overview**:

An *environment object* **invalidates** the current view whenever the observable object changes. If you declare a property as an *environment object*, be sure to set a corresponding model object on an ancestor view by calling its `environmentObject(_:)` modifier.

## StateObject

A *property wrapper* type that instantiates an observable object.

**Declaration**:

```swift
@frozen @propertyWrapper struct StateObject<ObjectType> where ObjectType : ObservableObject
```

**Overview**:

Create a state object in a `View`, `App`, or `Scene` by applying the `@StateObject` attribute to a property declaration and providing an initial value that conforms to the `ObservableObject` protocol:

```swift
@StateObject var model = DataModel()
```

SwiftUI creates a new instance of the object only once for each instance of the structure that declares the object. When published properties of the observable object change, SwiftUI updates the parts of any view that depend on those properties:

```swift
Text(model.title) // Updates the view any time `title` changes.
```

You can pass the *state object* into a property that has the `ObservedObject` attribute. You can alternatively add the object to the environment of a view hierarchy by applying the `environmentObject(_:)` modifier:

```swift
ContentView()
    .environmentObject(model)
```

If you create an *environment object* as shown in the code above, you can read the object inside `ContentView` or any of its descendants using the `EnvironmentObject` attribute:

```swift
@EnvironmentObject var model: DataModel
```

Get a `Binding` to one of the state object’s properties using the `$` operator. Use a binding when you want to create a two-way connection to one of the object’s properties. For example, you can let a `Toggle` control a Boolean value called `isEnabled` stored in the model:

```swift
Toggle("Enabled", isOn: $model.isEnabled)
```

## ObservableObject

A type of object with a `publisher` that emits before the object has changed.

**Declaration**:

```swift
protocol ObservableObject : AnyObject
```

**Overview**:

By default an `ObservableObject` synthesizes an `objectWillChange` *publisher* that emits the changed value before any of its `@Published` properties changes.

```swift
class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func haveBirthday() -> Int {
        age += 1
        return age
    }
}

let john = Contact(name: "John Appleseed", age: 24)
cancellable = john.objectWillChange
    .sink { _ in
        print("\(john.age) will change")
}
print(john.haveBirthday())
// Prints "24 will change"
// Prints "25"
```

## CustomCombineIdentifierConvertible

A protocol for **uniquely identifying** publisher streams.

Inherited by: `Subscriber`, `Subscription`.

**combineIdentifier** (Default Implementation Provided):

Declaration:

```swift
var combineIdentifier: CombineIdentifier { get }
```

Usage:

```swift
let combineIdentifier = CombineIdentifier()
```

## WWDC Video

- [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
