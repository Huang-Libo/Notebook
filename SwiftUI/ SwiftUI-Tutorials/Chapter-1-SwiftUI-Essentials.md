# Chapter 1: SwiftUI Essentials

- [Chapter 1: SwiftUI Essentials](#chapter-1-swiftui-essentials)
  - [Creating and Combining Views](#creating-and-combining-views)
    - [Section 1: Create a New Project and Explore the Canvas](#section-1-create-a-new-project-and-explore-the-canvas)
    - [Section 2: Customize the Text View](#section-2-customize-the-text-view)
    - [Section 3: Combine Views Using Stacks](#section-3-combine-views-using-stacks)
  - [Creating and Combining Views](#creating-and-combining-views-1)
  - [Building Lists and Navigation](#building-lists-and-navigation)
  - [Handling User Input](#handling-user-input)

## Creating and Combining Views

### Section 1: Create a New Project and Explore the Canvas

`APP`: A type that represents the structure and behavior of an app.

Create an app by declaring a structure that conforms to the `App` protocol. Implement the required `body` computed property to define the app’s content:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello, world!")
        }
    }
}
```

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}
```

> Tip: If the canvas isn’t visible, select Editor > Canvas to show it.

### Section 2: Customize the Text View

Open the inspector by Command-clicking.

To customize a SwiftUI view, you call methods called **modifiers**. Modifiers wrap a view to change its display or other properties. Each modifier returns a new view, so it’s common to chain multiple modifiers, stacked vertically.

### Section 3: Combine Views Using Stacks

## Creating and Combining Views

## Building Lists and Navigation

## Handling User Input
