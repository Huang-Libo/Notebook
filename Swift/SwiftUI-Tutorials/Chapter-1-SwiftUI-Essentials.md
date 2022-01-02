# Chapter 1: SwiftUI Essentials

- [Chapter 1: SwiftUI Essentials](#chapter-1-swiftui-essentials)
  - [Creating and Combining Views](#creating-and-combining-views)
    - [Section 1: Create a New Project and Explore the Canvas](#section-1-create-a-new-project-and-explore-the-canvas)
    - [Section 2: Customize the Text View](#section-2-customize-the-text-view)
    - [Section 3: Combine Views Using Stacks](#section-3-combine-views-using-stacks)
  - [Building Lists and Navigation](#building-lists-and-navigation)
    - [Section 1: Create a Landmark Model](#section-1-create-a-landmark-model)
    - [Section 4: Create the List of Landmarks](#section-4-create-the-list-of-landmarks)
    - [Section 5: Make the List Dynamic](#section-5-make-the-list-dynamic)
    - [Section 6: Set Up Navigation Between List and Detail](#section-6-set-up-navigation-between-list-and-detail)
    - [Section 8: Generate Previews Dynamically](#section-8-generate-previews-dynamically)
  - [Handling User Input](#handling-user-input)

## Creating and Combining Views

### Section 1: Create a New Project and Explore the Canvas

`APP`: A type that represents the structure and behavior of an app.

Create an app by declaring a structure that conforms to the `App` protocol. Implement the required `body` computed property to define the app’s content:

```swift
// LandmarksApp.swift

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
// ContentView.swift

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

## Building Lists and Navigation

### Section 1: Create a Landmark Model

### Section 4: Create the List of Landmarks

`LandmarkList.swift` :

```swift
import SwiftUI

struct LandmarkList: View {
    var body: some View {
        List {
            LandmarkRow(landmark: landmarks[0])
            LandmarkRow(landmark: landmarks[1])
        }
    }
}

struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
    }
}
```

### Section 5: Make the List Dynamic

`LandmarkList.swift` :

```swift
import SwiftUI

struct LandmarkList: View {
    var body: some View {
        List(landmarks, id: \.id) { landmark in
            LandmarkRow(landmark: landmark)
        }
    }
}

struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
    }
}
```

### Section 6: Set Up Navigation Between List and Detail

### Section 8: Generate Previews Dynamically

You can change the preview device by calling the `previewDevice(_:)` modifier method.

```swift
struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkList()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
    }
}
```

```swift
struct LandmarkList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE (2nd generation)", "iPhone XS Max"], id: \.self) { deviceName in
            LandmarkList()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
```

## Handling User Input
