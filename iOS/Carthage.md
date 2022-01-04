# Carthage

Carthage builds your dependencies and provides you with **binary frameworks**, but you retain full control over your project structure and setup. Carthage *does not* automatically modify your project files or your build settings.

## Quick Start

1. Get Carthage by running `brew update` and  `brew install carthage`
2. Create a **Cartfile** in the same directory where your `.xcodeproj` or `.xcworkspace` is
3. List the desired dependencies in the **Cartfile**, for example: `github "Alamofire/Alamofire" ~> 4.7.2`
4. Run `carthage update --use-xcframeworks`
5. A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is
6. Drag the built `.xcframework` bundles from `Carthage/Build` into the *"Frameworks and Libraries"* section of your application’s Xcode project.
7. If you are using Carthage for an application, select "*Embed & Sign*", otherwise "*Do Not Embed*".


