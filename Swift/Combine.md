# Combine

Swift, iOS 13.0+, macOS 10.15+

- [Combine](#combine)
  - [Overview](#overview)
  - [Protocol](#protocol)
    - [Publisher](#publisher)
    - [Subscriber](#subscriber)
    - [Subscription](#subscription)
    - [CustomCombineIdentifierConvertible](#customcombineidentifierconvertible)
    - [ObservableObject](#observableobject)
  - [State](#state)
  - [Binding](#binding)
  - [StateObject](#stateobject)
  - [ObservedObject](#observedobject)
  - [Published](#published)
  - [EnvironmentObject](#environmentobject)
  - [EnvironmentValues](#environmentvalues)
  - [Environment](#environment)
  - [WWDC Video](#wwdc-video)

## Overview

- *publisher* : expose values that can change over time.
- *subscriber* : receive those values from the publishers.

## Protocol

### Publisher

```swift
protocol Publisher
```

Publishers have *operators* to act on the values received from upstream publishers and republish them.

The *publisher* implements the `receive(subscriber:)` method to accept a *subscriber*.

After this, the *publisher* can call the following methods on the *subscriber* :

- `receive(subscription:):` Acknowledges the subscribe request and returns a `Subscription` instance. The `subscriber` uses the `subscription` to demand elements from the *publisher* and can use it to cancel publishing.
- `receive(_:):` Delivers one element from the *publisher* to the *subscriber*.
- `receive(completion:):` Informs the `subscriber` that publishing has ended, either normally or with an error.

### Subscriber

```swift
protocol Subscriber : CustomCombineIdentifierConvertible
```

Publishers only emit values when explicitly **requested** to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.

### Subscription

A protocol representing the **connection** of a *subscriber* to a *publisher*.

**Declaration**:

```swift
protocol Subscription : Cancellable, CustomCombineIdentifierConvertible
```

**Topics**:

- `request(_:)`, Tells a publisher that it may send more values to the subscriber.

    ```swift
    func request(_ demand: Subscribers.Demand)
    ```

### CustomCombineIdentifierConvertible

A protocol for *uniquely identifying* publisher streams.

Inherited by: `Subscriber`, `Subscription`.

**Declaration**:

```swift
protocol CustomCombineIdentifierConvertible
```

**Overview**:

If you create a custom `Subscription` or `Subscriber` type, implement this protocol so that development tools can uniquely identify publisher chains in your app.

- If your type is a class, Combine provides an implementation of `combineIdentifier` for you.
- If your type is a structure, set up the identifier as follows:

    ```swift
    let combineIdentifier = CombineIdentifier()
    ```

**Topics**:

- `combineIdentifier`, A unique identifier for identifying publisher streams:

    ```swift
    var combineIdentifier: CombineIdentifier { get }
    ```

### ObservableObject

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

## Binding

A *property wrapper* type that can read and write a value owned by a source of truth.

**Declaration**:

```swift
@frozen @propertyWrapper @dynamicMemberLookup struct Binding<Value>
```

**Overview**:

Use a binding to create a two-way connection between *a property that stores data*, and *a view that displays and changes the data*. A binding connects a property to a source of truth stored elsewhere, instead of storing data directly.

For example, a button that toggles between *play* and *pause* can create a binding to a property of its parent view using the `Binding` *property wrapper*.

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

When `PlayerView` initializes `PlayButton`, it passes a binding of its state property into the button’s binding property. Applying the `$` prefix to a *property wrapped value* returns its `projectedValue`, which for a `state` *property wrapper* returns a binding to the value.

Whenever the user taps the `PlayButton`, the `PlayerView` updates its `isPlaying` state.

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

SwiftUI creates a new instance of the object *only once* for each instance of the structure that declares the object. When `published` properties of the `observable` object change, SwiftUI updates the parts of any view that depend on those properties:

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

## ObservedObject

A *property wrapper* type that subscribes to an *observable object* and **invalidates** a view whenever the observable object changes.

**Declaration**:

```swift
@propertyWrapper @frozen struct ObservedObject<ObjectType> where ObjectType : ObservableObject
```

## Published

A type that publishes a property marked with an attribute.

**Declaration**:

```swift
@propertyWrapper struct Published<Value>
```

**Overview**:

Publishing a property with the `@Published` attribute creates a `publisher` of this type. You access the publisher with the `$` operator, as shown here:

```swift
class Weather {
    @Published var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}

let weather = Weather(temperature: 20)
cancellable = weather.$temperature
    .sink() {
        print ("Temperature now: \($0)")
}
weather.temperature = 25

// Prints:
// Temperature now: 20.0
// Temperature now: 25.0
```

When the property changes, publishing occurs in the property’s `willSet` block, meaning `subscriber`s receive the new value before it’s actually set on the property. In the above example, the second time the `sink` executes its closure, it receives the parameter value `25`. However, if the closure evaluated `weather.temperature`, the value returned would be `20`.

> **Important**: The `@Published` attribute is `class` constrained. Use it with properties of classes, not with non-class types like structures.

## EnvironmentObject

A *property wrapper* type for an `observable` object supplied by a parent or ancestor view.

**Declaration**:

```swift
@frozen @propertyWrapper struct EnvironmentObject<ObjectType> where ObjectType : ObservableObject
```

**Overview**:

An *environment object* **invalidates** the current view whenever the observable object changes. If you declare a property as an *environment object*, be sure to set a corresponding model object on an ancestor view by calling its `environmentObject(_:)` modifier.

## EnvironmentValues

A collection of environment values propagated through a view hierarchy.

**Declaration**:

```swift
struct EnvironmentValues
```

**Overview**:

SwiftUI exposes a collection of values to your app’s views in an `EnvironmentValues` structure. To read a value from the structure, declare a property using the `Environment` *property wrapper* and specify the value’s key path. For example, you can read the current `locale`:

```swift
@Environment(\.locale) var locale: Locale
```

Use the property you declare to dynamically control a view’s layout. SwiftUI automatically sets or updates many environment values, like `pixelLength`, `scenePhase`, or `locale`, based on *device characteristics*, *system state*, or *user settings*. For others, like *lineLimit*, SwiftUI provides a reasonable default value.

You can set or override some values using the `environment(_:_:)` view modifier:

```swift
MyView()
    .environment(\.lineLimit, 2)
```

The value that you set affects the environment for the view that you modify — including its descendants in the view hierarchy — but only up to the point where you apply a different environment modifier.

SwiftUI provides dedicated view modifiers for setting some values, which typically makes your code easier to read. For example, rather than setting the `lineLimit` value directly, as in the previous example, you should instead use the `lineLimit(_:)` modifier:

```swift
MyView()
    .lineLimit(2)
```

In some cases, using a dedicated view modifier provides additional functionality. For example, you must use the `preferredColorScheme(_:)` modifier rather than setting `colorScheme` directly to ensure that the new value propagates up to the presenting container when presenting a view like a popover:

```swift
MyView()
    .popover(isPresented: $isPopped) {
        PopoverContent()
            .preferredColorScheme(.dark)
    }
```

Create custom environment values by defining a type that conforms to the `EnvironmentKey` protocol, and then extending the environment values structure with a new property. Use your key to get and set the value, and provide a dedicated modifier for clients to use when setting the value:

```swift
private struct MyEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = "Default value"
}

extension EnvironmentValues {
    var myCustomValue: String {
        get { self[MyEnvironmentKey.self] }
        set { self[MyEnvironmentKey.self] = newValue }
    }
}

extension View {
    func myCustomValue(_ myCustomValue: String) -> some View {
        environment(\.myCustomValue, myCustomValue)
    }
}
```

Clients of your value then access the value in the usual way, reading it with the `Environment` *property wrapper*, and setting it with the `myCustomValue` view modifier.

## Environment

A *property wrapper* that reads a value from a view’s environment.

**Declaration**:

```swift
@frozen @propertyWrapper struct Environment<Value>
```

**Overview**:

Use the `Environment` *property wrapper* to read a value stored in a view’s environment. Indicate the value to read using an `EnvironmentValues` key path in the property declaration. For example, you can create a property that reads the *color scheme* of the current view using the key path of the `colorScheme` property:

```swift
@Environment(\.colorScheme) var colorScheme: ColorScheme
```

You can condition a view’s content on the associated value, which you read from the declared property’s `wrappedValue`. As with any *property wrapper*, you access the wrapped value by directly referring to the property:

```swift
if colorScheme == .dark { // Checks the wrapped value.
    DarkContent()
} else {
    LightContent()
}
```

If the value changes, SwiftUI updates any parts of your view that depend on the value. For example, that might happen in the above example if the user changes the Appearance settings.

You can use this *property wrapper* to read — but not set — an environment value. SwiftUI updates some environment values automatically based on system settings and provides reasonable defaults for others. You can override some of these, as well as set custom environment values that you define, using the `environment(_:_:)` view modifier.

For the complete list of environment values provided by SwiftUI, see the properties of the `EnvironmentValues` structure. For information about creating custom environment values, see the `EnvironmentKey` protocol.

## WWDC Video

- [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
