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

## Adding frameworks to an application

Once you have Carthage installed, you can begin adding frameworks to your project. Note that
Carthage only supports **dynamic frameworks**, which are only available on *iOS 8* or later (or any version of OS X).

## Differences between Carthage and CocoaPods

CocoaPods is a long-standing dependency manager for Cocoa. So why was Carthage created?

- CocoaPods (by default) automatically creates and updates an Xcode workspace for your application and all dependencies.
- Carthage builds framework binaries using `xcodebuild`, but leaves the responsibility of integrating them up to the user

CocoaPods’ approach is easier to use, while Carthage’s is flexible and non-intrusive.

The goal of CocoaPods is listed in its [README](https://github.com/CocoaPods/CocoaPods/blob/master/README.md) as follows:

> CocoaPods aims to improve the engagement with, and discoverability of, third party open-source Cocoa libraries.

By contrast, Carthage has been created as a *decentralized* dependency manager. There is no central list of projects, which reduces maintenance work and avoids any central point of failure. However, project discovery is more difficult, users must resort to GitHub’s [Trending](https://github.com/trending?l=swift) pages or similar.

- CocoaPods projects must also have what’s known as a [podspec](https://guides.cocoapods.org/syntax/podspec.html) file, which includes metadata about the project and specifies how it should be built.
- Carthage uses `xcodebuild` to build dependencies, instead of integrating them into a single workspace, it doesn’t have a similar specification file but your dependencies must include their own Xcode project that describes how to build their products.

Ultimately, we created Carthage because we wanted the **simplest** tool possible, a dependency manager that gets the job done without taking over the responsibility of Xcode, and without creating extra work for framework authors. **CocoaPods offers many amazing features that Carthage will never have, at the expense of additional complexity.**
