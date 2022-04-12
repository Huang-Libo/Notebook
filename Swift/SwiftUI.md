# SwiftUI

- [SwiftUI](#swiftui)
  - [UIViewControllerRepresentable](#uiviewcontrollerrepresentable)
  - [Environment](#environment)
    - [`environment(_:_:)`](#environment__)
    - [`EnvironmentKey`](#environmentkey)
    - [`EnvironmentValues`](#environmentvalues)
    - [`@Environment`](#environment-1)
    - [`@EnvironmentObject`](#environmentobject)
    - [`environmentObject(_:)`](#environmentobject_)
  - [viewBuilder?](#viewbuilder)

## UIViewControllerRepresentable

A view that represents a `UIKit` *view controller*.

**Declaration**:

```swift
protocol UIViewControllerRepresentable : View where Self.Body == Never
```

**Overview**:

Use a `UIViewControllerRepresentable` instance to create and manage a `UIViewController` object in your SwiftUI interface.

Adopt this protocol in one of your app’s custom instances, and use its methods to create, update, and tear down your view controller. The creation and update processes parallel the behavior of SwiftUI views, and you use them to configure your view controller with your app’s current state information. Use the teardown process to remove your view controller cleanly from your SwiftUI.

For example, you might use the teardown process to notify other objects that the view controller is disappearing.

To add your view controller into your SwiftUI interface, create your `UIViewControllerRepresentable` instance and add it to your SwiftUI interface. The system calls the methods of your custom instance at appropriate times.

The system doesn’t automatically communicate changes occurring within your view controller to other parts of your SwiftUI interface. When you want your view controller to coordinate with other SwiftUI views, you must provide a `Coordinator` instance to facilitate those interactions.

For example, you use a coordinator to forward *target-action* and *delegate messages* from your view controller to any SwiftUI views.

**Topics**:

---

- `makeUIViewController(context:)`

    Creates the view controller object and configures its initial state.

    **Declaration**:

    ```swift
    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType
    ```

    **Discussion**:

    You *must* implement this method and use it to create your view controller object. Create the view controller using your app’s current data and contents of the `context` parameter. The system calls this method *only once*, when it creates your view controller for the first time. For all subsequent updates, the system calls the `updateUIViewController(_:context:)` method.

---

- `updateUIViewController(_:context:)`

    Updates the state of the specified view controller with new information from SwiftUI.

    **Declaration**:

    ```swift
    func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Self.Context)
    ```

    **Discussion**:

    When the state of your app changes, SwiftUI updates the portions of your interface affected by those changes. SwiftUI calls this method for any changes affecting the corresponding `AppKit` view controller.

    Use this method to update the configuration of your view controller to match the new state information provided in the `context` parameter.

    ---

- `makeCoordinator()`

    Creates the custom instance that you use to communicate changes from your view controller to other parts of your SwiftUI interface.

    **Declaration**:

    ```swift
    func makeCoordinator() -> Self.Coordinator
    ```

    **Discussion**:

    Implement this method if changes to your view controller might affect other parts of your app. In your implementation, create a custom Swift instance that can communicate with other parts of your interface.

    For example, you might provide an instance that binds its variables to SwiftUI properties, causing the two to remain synchronized. If your view controller doesn’t interact with other parts of your app, providing a coordinator is unnecessary.

    SwiftUI calls this method before calling the `makeUIViewController(context:)` method. The system provides your coordinator either directly or as part of a context structure when calling the other methods of your representable instance.

## Environment

### `environment(_:_:)`

- [`environment(_:_:)`](https://developer.apple.com/documentation/swiftui/view/environment(_:_:))

(View) Sets the environment value of the specified key path to the given value.

**Declaration**:

```swift
func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some View
```

### `EnvironmentKey`

### `EnvironmentValues`

### `@Environment`

### `@EnvironmentObject`

### `environmentObject(_:)`

## viewBuilder?


