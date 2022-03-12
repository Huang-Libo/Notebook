# README

[Alamofire](https://github.com/Alamofire/Alamofire) is an HTTP networking library written in Swift.

- [README](#readme)
  - [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
    - [Swift Package Manager](#swift-package-manager)
    - [Manually](#manually)
      - [Embedded Framework](#embedded-framework)
  - [Usage](#usage)
  - [Advanced Usage](#advanced-usage)
  - [Component Libraries](#component-libraries)
  - [Resourse](#resourse)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Alamofire', '~> 5.5'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with *binary frameworks*. To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Alamofire/Alamofire" ~> 5.5
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0"))
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate Alamofire into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  git init
  ```

- Add Alamofire as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  git submodule add https://github.com/Alamofire/Alamofire.git
  ```

- Open the new `Alamofire` folder, and drag the `Alamofire.xcodeproj` into the Project Navigator of your application's Xcode project.

  > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Alamofire.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the *Embedded Binaries* section.
- You will see two different `Alamofire.xcodeproj` folders each with two different versions of the `Alamofire.framework` nested inside a `Products` folder.

  > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `Alamofire.framework`.

- Select the top `Alamofire.framework` for iOS and the bottom one for macOS.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `Alamofire` will be listed as `Alamofire iOS`, `Alamofire macOS`, `Alamofire tvOS`, or `Alamofire watchOS`.

- And that's it!

  > The `Alamofire.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Usage

- [Usage](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#using-alamofire)
  - [**Introduction -**](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#introduction) [Making Requests](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#making-requests), [Response Handling](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#response-handling), [Response Validation](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#response-validation), [Response Caching](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#response-caching)
  - **HTTP -** [HTTP Methods](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-methods), [Parameters and Parameter Encoder](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md##request-parameters-and-parameter-encoders), [HTTP Headers](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-headers), [Authentication](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#authentication)
  - **Large Data -** [Downloading Data to a File](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#downloading-data-to-a-file), [Uploading Data to a Server](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#uploading-data-to-a-server)
  - **Tools -** [Statistical Metrics](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#statistical-metrics), [cURL Command Output](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#curl-command-output)

## Advanced Usage

- [Advanced Usage](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md)
  - **URL Session -** [Session Manager](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#session), [Session Delegate](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#sessiondelegate), [Request](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#request)
  - **Routing -** [Routing Requests](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#routing-requests), [Adapting and Retrying Requests](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#adapting-and-retrying-requests-with-requestinterceptor)
  - **Model Objects -** [Custom Response Handlers](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#customizing-response-handlers)
  - **Advanced Concurrency -** [Swift Concurrency](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#using-alamofire-with-swift-concurrency) and [Combine](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#using-alamofire-with-combine)
  - **Connection -** [Security](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#security), [Network Reachability](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#network-reachability)

## Component Libraries

In order to keep Alamofire focused specifically on core networking implementations, additional component libraries have been created by the [Alamofire Software Foundation](https://github.com/Alamofire/Foundation) to bring additional functionality to the Alamofire ecosystem.

- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) - An image library including image response serializers, `UIImage` and `UIImageView` extensions, custom image filters, an auto-purging in-memory cache, and a priority-based image downloading system.
- [AlamofireNetworkActivityIndicator](https://github.com/Alamofire/AlamofireNetworkActivityIndicator) - Controls the visibility of the network activity indicator on iOS using Alamofire. It contains configurable delay timers to help mitigate flicker and can support `URLSession` instances not managed by Alamofire.

## Resourse

- [swift.org : alamofire](https://forums.swift.org/c/related-projects/alamofire)
