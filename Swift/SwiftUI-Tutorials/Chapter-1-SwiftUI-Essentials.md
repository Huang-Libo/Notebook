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
    - [Section 1: Mark the User’s Favorite Landmarks](#section-1-mark-the-users-favorite-landmarks)
    - [Section 2: Filter the List View](#section-2-filter-the-list-view)
    - [Section 3: Add a Control to Toggle the State](#section-3-add-a-control-to-toggle-the-state)
    - [Section 4: Use an Observable Object for Storage](#section-4-use-an-observable-object-for-storage)
    - [Section 5: Adopt the Model Object in Your Views](#section-5-adopt-the-model-object-in-your-views)
    - [Section 6: Create a Favorite Button for Each Landmark](#section-6-create-a-favorite-button-for-each-landmark)

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

### Section 1: Mark the User’s Favorite Landmarks

### Section 2: Filter the List View

*State* is a value, or a set of values, that can change over time, and that affects a view’s behavior, content, or layout. You use a property with the `@State` attribute to add state to a view.

Because you use state properties to hold information that’s specific to a view and its subviews, you always create state as `private`.

> Tips: When you make changes to your view’s structure, like adding or modifying a property, you need to manually refresh the canvas.

### Section 3: Add a Control to Toggle the State

A *binding* acts as a reference to a mutable state. When a user taps the toggle from off to on, and off again, the control uses the binding to update the view’s state accordingly.

```swift
var body: some View {
    NavigationView {
        List(filteredLandmarks) { landmark in
            NavigationLink {
                LandmarkDetail(landmark: landmark)
            } label: {
                LandmarkRow(landmark: landmark)
            }
        }
        .navigationTitle("Landmarks")
    }
}
```

To combine static and dynamic views in a list, or to combine two or more different groups of dynamic views, use the `ForEach` type instead of passing your collection of data to `List`.

You use the `$` prefix to access a binding to a state variable, or one of its properties.

```swift
var body: some View {
    NavigationView {
        List {
            Toggle(isOn: $showFavoritesOnly) {
                Text("Favorites only")
            }

            ForEach(filteredLandmarks) { landmark in
                NavigationLink {
                    LandmarkDetail(landmark: landmark)
                } label: {
                    LandmarkRow(landmark: landmark)
                }
            }
        }
        .navigationTitle("Landmarks")
    }
}
```

### Section 4: Use an Observable Object for Storage

An *observable object* is a custom object for your data that can be bound to a view from storage in SwiftUI’s environment. SwiftUI watches for any changes to observable objects that could affect a view, and displays the correct version of the view after a change.

Declare a new model type that conforms to the `ObservableObject` protocol from the Combine framework.

```swift
import Combine

final class ModelData: ObservableObject {
    @Published var landmarks: [Landmark] = load("landmarkData.json")
}
```

### Section 5: Adopt the Model Object in Your Views

### Section 6: Create a Favorite Button for Each Landmark

Embed the landmark’s name in an HStack with a new FavoriteButton; provide a binding to the isFavorite property with the dollar sign (`$`).

```swift
HStack {
    Text(landmark.name)
        .font(.title)
    FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
}
```
