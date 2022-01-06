# Carthage

Carthage builds your dependencies and provides you with **binary frameworks**, but you retain full control over your project structure and setup. Carthage *does not* automatically modify your project files or your build settings.

- [Carthage](#carthage)
  - [Quick Start](#quick-start)
  - [Adding frameworks to an application](#adding-frameworks-to-an-application)
    - [Getting started](#getting-started)
      - [Building platform-independent XCFrameworks (Xcode 12 and above)](#building-platform-independent-xcframeworks-xcode-12-and-above)
        - [Migrating a project from framework bundles to XCFrameworks](#migrating-a-project-from-framework-bundles-to-xcframeworks)
      - [Building platform-specific framework bundles (default for Xcode 11 and below)](#building-platform-specific-framework-bundles-default-for-xcode-11-and-below)
      - [For all platforms](#for-all-platforms)
      - [(Optionally) Add build phase to warn about outdated dependencies](#optionally-add-build-phase-to-warn-about-outdated-dependencies)
      - [Swift binary framework download compatibility](#swift-binary-framework-download-compatibility)
    - [Running a project that uses Carthage](#running-a-project-that-uses-carthage)
    - [Adding frameworks to unit tests or a framework](#adding-frameworks-to-unit-tests-or-a-framework)
    - [Upgrading frameworks](#upgrading-frameworks)
      - [Experimental Resolver](#experimental-resolver)
    - [Nested dependencies](#nested-dependencies)
    - [Using submodules for dependencies](#using-submodules-for-dependencies)
    - [Automatically rebuilding dependencies](#automatically-rebuilding-dependencies)
    - [Caching builds](#caching-builds)
  - [Differences between Carthage and CocoaPods](#differences-between-carthage-and-cocoapods)
  - [FAQ](#faq)

## Quick Start

1. Get Carthage by running `brew update` and  `brew install carthage`
2. Create a `Cartfile` in the same directory where your `.xcodeproj` or `.xcworkspace` is
3. List the desired dependencies in the `Cartfile`, for example: `github "Alamofire/Alamofire" ~> 4.7.2`
4. Run `carthage update --use-xcframeworks`
5. A `Cartfile.resolved` file and a `Carthage` directory will appear in the same directory where your `.xcodeproj` or `.xcworkspace` is
6. Drag the built `.xcframework` bundles from `Carthage/Build` into the *"Frameworks and Libraries"* section of your application’s Xcode project.
7. If you are using Carthage for an application, select "*Embed & Sign*", otherwise "*Do Not Embed*".

## Adding frameworks to an application

Once you have Carthage installed, you can begin adding frameworks to your project. Note that
Carthage only supports **dynamic frameworks**, which are only available on *iOS 8* or later (or any version of OS X).

### Getting started

#### Building platform-independent XCFrameworks (Xcode 12 and above)

1. Create a `Cartfile` that lists the frameworks you’d like to use in your project.
2. Run `carthage update --use-xcframeworks`. This will fetch dependencies into a `Carthage/Checkouts` folder and build each one or download a **pre-compiled** XCFramework.
3. On your application targets’ *General* settings tab, in the *Frameworks, Libraries, and Embedded Content* section, drag and drop each XCFramework you want to use from the `Carthage/Build` folder on disk.

##### Migrating a project from framework bundles to XCFrameworks

We encourage using XCFrameworks as of version 0.37.0 (January 2021), and **require XCFrameworks when building on an Apple Silicon Mac**. Switching from discrete framework bundles to XCFrameworks requires a few changes to your project:

1. Delete your `Carthage/Build` folder to remove any existing framework bundles.
2. Build new XCFrameworks by running `carthage build --use-xcframeworks`. Any other arguments you build with can be provided like normal.
3. Remove references to the old frameworks in each of your targets:
    - Delete references to Carthage frameworks from the target's *Frameworks, Libraries, and Embedded Content* section and/or its *Link Binary with Libraries* build phase.
    - Delete references to Carthage frameworks from any *Copy Files* build phases.
    - Delete the target's `carthage copy-frameworks` build phase, if present.
4. Add references to XCFrameworks in each of your targets:
    - For an application target: In the *General* settings tab, in the *Frameworks, Libraries, and Embedded Content* section, drag and drop each XCFramework you use from the `Carthage/Build` folder on disk.
    - For a framework target: In the *Build Phases* tab, in a *Link Binary with Libraries* phase, drag and drop each XCFramework you use from the `Carthage/Build` folder on disk.

#### Building platform-specific framework bundles (default for Xcode 11 and below)

[omit]

#### For all platforms

Along the way, Carthage will have created some *build artifacts*. The most important of these is the `Cartfile.resolved` file, which lists the versions that were actually built for each framework. **Make sure to commit your Cartfile.resolved**, because anyone else using the project will need that file to build the same framework versions.

#### (Optionally) Add build phase to warn about outdated dependencies

You can add a Run Script phase to automatically warn you when one of your dependencies is out of date.

On your application targets’ `Build Phases` settings tab, click the `+` icon and choose `New Run Script Phase`. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell:

```sh
/usr/local/bin/carthage outdated --xcode-warnings 2>/dev/null
```

#### Swift binary framework download compatibility

Carthage will check to make sure that downloaded Swift (and mixed Objective-C/Swift) frameworks were built with the same version of Swift that is in use locally.

- If there is a version mismatch, Carthage will proceed to build the framework from source.
- If the framework cannot be built from source, Carthage will fail.

Because Carthage uses the output of `xcrun swift --version` to determine the local Swift version, make sure to run Carthage commands with the Swift toolchain that you intend to use.

For many use cases, nothing additional is needed.
However, for example, if you are building a Swift 2.3 project using Xcode 8.x, one approach to specifying your default `swift` for `carthage bootstrap` is to use the following command:

```shell
TOOLCHAINS=com.apple.dt.toolchain.Swift_2_3 carthage bootstrap
```

### Running a project that uses Carthage

After you’ve finished the above steps and pushed your changes, other users of the project only need to fetch the repository and run `carthage bootstrap` to get started with the frameworks you’ve added.

### Adding frameworks to unit tests or a framework

Using Carthage for the dependencies of any arbitrary target is fairly similar to [using Carthage for an application](#adding-frameworks-to-an-application). The main difference lies in how the frameworks are actually set up and linked in Xcode.

Because unit test targets are missing the *Linked Frameworks and Libraries* section in their *General* settings tab, you must instead drag the *built frameworks* in `Carthage/Build` to the *Link Binaries With Libraries* build phase.

In the Test target under the *Build Settings* tab, add `@loader_path/Frameworks` to the *Runpath Search Paths* if it isn't already present.

In rare cases, you may want to also copy each dependency into the build product (e.g., to embed dependencies within the outer framework, or make sure dependencies are present in a test bundle). To do this, create a new _Copy Files_ build phase with the _Frameworks_ destination, then add the framework reference there as well. You shouldn't use the `carthage copy-frameworks` command since test bundles don't need frameworks stripped, and running concurrent instances of `copy-frameworks` (with parallel builds turn on) is not supported.

### Upgrading frameworks

If you’ve modified your `Cartfile`, or you want to update to the newest versions of each framework (subject to the requirements you’ve specified), simply run the `carthage update` command again.

If you only want to update one, or specific, dependencies, pass them as a space-separated list to the `update` command. e.g.

```console
carthage update Box
```

or

```console
carthage update Box Result
```

#### Experimental Resolver

A rewrite of the logic for upgrading frameworks was done with the aim of increasing speed and reducing memory usage. It is currently an opt-in feature. It can be used by passing `--new-resolver` to the update command, e.g.,

```console
carthage update --new-resolver Box
```

If you are experiencing performance problems during updates, please give the new resolver a try.

### Nested dependencies

If the framework you want to add to your project has dependencies explicitly listed in a `Cartfile`, Carthage will automatically retrieve them for you. You will then have to **drag them yourself into your project** from the `Carthage/Build` folder.

If the embedded framework in your project has dependencies to other frameworks you must  **link them to application target** (even if application target does not have dependency to that frameworks and never uses them).

### Using submodules for dependencies

By default, Carthage will directly *check out* dependencies’ source files into your project folder, leaving you to commit or ignore them as you choose. If you’d like to have dependencies available as Git submodules instead (perhaps so you can commit and push changes within them), you can run `carthage update` or `carthage checkout` with the `--use-submodules` flag.

When run this way, Carthage will write to your repository’s `.gitmodules` and `.git/config` files, and automatically update the submodules when the dependencies’ versions change.

### Automatically rebuilding dependencies

If you want to work on your dependencies during development, and want them to be automatically rebuilt when you build your parent project, you can add a Run Script build phase that invokes Carthage like so:

```sh
/usr/local/bin/carthage build --platform "$PLATFORM_NAME" --project-directory "$SRCROOT"
```

Note that you should be [using submodules](#using-submodules-for-dependencies) before doing this, because plain checkouts(`Carthage/Checkouts`) *should not be modified* directly.

### Caching builds

By default Carthage will rebuild a dependency regardless of whether it's the same resolved version as before. Passing the `--cache-builds` will cause carthage to avoid rebuilding a dependency if it can. See information on `version files` for details on how Carthage performs this caching.

**Note**: At this time `--cache-builds` is incompatible with `--use-submodules`. Using both will result in working copy and committed changes to your submodule dependency not being correctly rebuilt. See [#1785](https://github.com/Carthage/Carthage/issues/1785) for details.

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

## FAQ

https://github.com/Carthage/Carthage/issues/2137

https://stackoverflow.com/questions/38862464/debugging-owned-framework-when-using-carthage
