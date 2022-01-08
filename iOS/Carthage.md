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
  - [Supporting Carthage for your framework](#supporting-carthage-for-your-framework)
    - [Share your Xcode schemes](#share-your-xcode-schemes)
    - [Resolve build failures](#resolve-build-failures)
    - [Tag stable releases](#tag-stable-releases)
    - [Archive prebuilt frameworks into zip files](#archive-prebuilt-frameworks-into-zip-files)
      - [Use travis-ci to upload your tagged prebuilt frameworks](#use-travis-ci-to-upload-your-tagged-prebuilt-frameworks)
    - [Build static frameworks to speed up your app’s launch times](#build-static-frameworks-to-speed-up-your-apps-launch-times)
      - [Carthage 0.30.0 or higher](#carthage-0300-or-higher)
      - [Carthage 0.29.0 or lower](#carthage-0290-or-lower)
  - [Declare your compatibility](#declare-your-compatibility)
  - [Known issues](#known-issues)
    - [DWARFs symbol problem](#dwarfs-symbol-problem)
  - [CarthageKit](#carthagekit)
  - [Differences between Carthage and CocoaPods](#differences-between-carthage-and-cocoapods)

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

## Supporting Carthage for your framework

**Carthage only officially supports dynamic frameworks**. Dynamic frameworks can be used on any version of OS X, but only on **iOS 8 or later**. Additionally, since version 0.30.0 Carthage supports **static** frameworks.

Because Carthage has no centralized package list, and no project specification format, **most frameworks should build automatically**.

The specific requirements of any framework project are listed below.

### Share your Xcode schemes

Carthage will only build Xcode schemes that are shared from your `.xcodeproj`. You can see if all of your intended schemes build successfully by running `carthage build --no-skip-current`, then checking the `Carthage/Build` folder.

If an important scheme is not built when you run that command, open Xcode and make sure that the [scheme is marked as _Shared_](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/xcode_guide-continuous_integration/ConfigureBots.html#//apple_ref/doc/uid/TP40013292-CH9-SW3), so Carthage can discover it.

### Resolve build failures

If you encounter build failures in `carthage build --no-skip-current`, try running `xcodebuild -scheme SCHEME -workspace WORKSPACE build` or `xcodebuild -scheme SCHEME -project PROJECT build` (with the actual values) and see if the same failure occurs there. This should hopefully yield enough information to resolve the problem.

If you have multiple versions of the Apple developer tools installed (an Xcode beta, for example), use `xcode-select` to change which version Carthage uses.

If you’re still not able to build your framework with Carthage, please [open an issue](https://github.com/Carthage/Carthage/issues/new) and we’d be happy to help!

### Tag stable releases

Carthage determines which versions of your framework are available by searching through the tags published on the repository, and trying to interpret each tag name as a [semantic version](https://semver.org/). For example, in the tag `v1.2`, the semantic version is 1.2.0.

Tags without any version number, or with any characters following the version number (e.g., `1.2-alpha-1`) are currently unsupported, and will be ignored.

### Archive prebuilt frameworks into zip files

Carthage can automatically use prebuilt frameworks, instead of building from scratch, if they are attached to a [GitHub Release](https://help.github.com/articles/about-releases/) on your project’s repository or via a binary project definition file.

- To offer prebuilt frameworks for a specific tag, the binaries for *all* supported platforms should be zipped up together into *one* archive, and that archive should be attached to a published Release corresponding to that tag. The attachment should include `.framework` in its name (e.g., `ReactiveCocoa.framework.zip`), to indicate to Carthage that it contains binaries. The directory structure of the archive is free form but, **frameworks should only appear once in the archive** as they will be copied to `Carthage/Build/<platform>` based on their name (e.g. `ReactiveCocoa.framework`).
- To offer prebuilt XCFrameworks, build with `--use-xcframeworks` and follow the same process to zip up all XCFrameworks into one archive. Include `.xcframework` in the attachment name. Starting in version 0.38.0, Carthage prefers downloading `.xcframework` attachments when `--use-xcframeworks` is passed.

You can perform the archiving operation with carthage itself using:

```console
carthage build --no-skip-current
carthage archive YourFrameworkName
```

or alternatively

```console
carthage build --archive
```

Draft Releases will be automatically ignored, even if they correspond to the desired tag.

#### Use travis-ci to upload your tagged prebuilt frameworks

It is possible to use travis-ci in order to build and upload your tagged releases.

1. [Install travis CLI](https://github.com/travis-ci/travis.rb#installation) with `gem install travis`
2. [Setup](https://docs.travis-ci.com/user/getting-started/) travis-ci for your repository (Steps 1 and 2)
3. Create `.travis.yml` file at the root of your repository based on that template. Set `FRAMEWORK_NAME` to the correct value.
   - Replace `PROJECT_PLACEHOLDER` and `SCHEME_PLACEHOLDER`
   - If you are using a *workspace* instead of a *project* remove the `xcode_project` line and uncomment the `xcode_workspace` line.
     - The project should be in the format: `MyProject.xcodeproj`
     - The workspace should be in the format: `MyWorkspace.xcworkspace`
   - Feel free to update the `xcode_sdk` value to another SDK, note that testing on iphoneos SDK would require you to upload a code signing identity.
   - For more informations you can visit [travis docs for objective-c projects](https://docs.travis-ci.com/user/languages/objective-c)

    ```YAML
    language: objective-c
    osx_image: xcode7.3
    xcode_project: <PROJECT_PLACEHOLDER>
    # xcode_workspace: <WORKSPACE_PLACEHOLDER>
    xcode_scheme: <SCHEME_PLACEHOLDER>
    xcode_sdk: iphonesimulator9.3
    env:
      global:
        - FRAMEWORK_NAME=<THIS_IS_A_PLACEHOLDER_REPLACE_ME>
    before_install:
      - brew update
      - brew outdated carthage || brew upgrade carthage
    before_script:
      # bootstrap the dependencies for the project
      # you can remove if you don't have dependencies
      - carthage bootstrap
    before_deploy:
      - carthage build --no-skip-current
      - carthage archive $FRAMEWORK_NAME
    ```

4. Run `travis setup releases`, follow documentation [here](https://docs.travis-ci.com/user/deployment/releases/)
   - This command will encode your GitHub credentials into the `.travis.yml` file in order to let travis upload the release to GitHub.com When prompted for the file to upload, enter `$FRAMEWORK_NAME.framework.zip`

5. Update the deploy section to run on tags:

   - In `.travis.yml` locate:

    ```YAML
    on:
      repo: repo/repo
    ```

   - And add `tags: true` and `skip_cleanup: true`:

    ```YAML
    skip_cleanup: true
    on:
      repo: repo/repo
      tags: true
    ```

   - That will let travis know to create a deployment when a new tag is pushed and prevent travis to cleanup the generated zip file.

### Build static frameworks to speed up your app’s launch times

If you embed many dynamic frameworks into your app, its pre-main launch times may be quite slow. Carthage is able to help mitigate this by building your dynamic frameworks as static frameworks instead. Static frameworks can be linked directly into your application or merged together into a larger dynamic framework with a few simple modifications to your workflow, which can result in dramatic reductions in pre-main launch times.

#### Carthage 0.30.0 or higher

Since version 0.30.0 Carthage project rolls out support for statically linked frameworks written in Swift or Objective-C, support for which has been introduced in Xcode 9.4. Please note however that it specifically says *frameworks*, hence Darwin bundles with **.framework** extension and statically linked object archives inside. Carthage does not currently support static *library* schemes, nor are there any plans to introduce their support in the future.

The workflow differs barely:

- You still need to tick your Carthage-compliant project's schemes as *shared* in *Product -> Scheme -> Manage Schemes...* , just as with dynamic binaries
- You still need to link against static **.frameworks** in your project's *Build Phases* just as with dynamic binaries

However:

- In your Carthage-compliant project's Cocoa Framework target's *Build Settings*, *Linking* section, set **Mach-O Type** to **Static Library**
- Your statically linked frameworks will be built at *./Carthage/Build/$(PLATFORM_NAME)/Static*
- You should not add any of static frameworks as input/output files in **carthage copy-frameworks** *Build Phase*

#### Carthage 0.29.0 or lower

See the [StaticFrameworks](https://github.com/Carthage/Carthage/blob/master/Documentation/StaticFrameworks.md) doc for details.

*Please note that a few caveats apply to this approach:*

- Swift static frameworks are not officially supported by Apple
- This is an advanced workflow that is not built into Carthage, YMMV

## Declare your compatibility

Want to advertise that your project can be used with Carthage? You can add a compatibility badge:

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

… to your `README`, by simply inserting the following Markdown:

```markdown
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
```

## Known issues

### DWARFs symbol problem

Pre-built framework cannot be debugged using step execution on other machine than on which the framework was built. Simply `carthage bootstrap/build/update --no-use-binaries` should fix this, but for muore automated workaround, see [#924](https://github.com/Carthage/Carthage/isses/924). Dupe [rdar://23551273](http://www.openradar.me/23551273) if you want Apple to fix the root cause of this problem.

- [#2137](https://github.com/Carthage/Carthage/issues/2137)
- [stackoverflow: Debugging (owned) Framework when using Carthage](https://stackoverflow.com/questions/38862464/debugging-owned-framework-when-using-carthage)

## CarthageKit

Most of the functionality of the `carthage` command line tool is actually encapsulated in a framework named CarthageKit.

If you’re interested in using Carthage as part of another tool, or perhaps extending the functionality of Carthage, take a look at the [CarthageKit](https://github.com/Carthage/Carthage/blob/master/Source/CarthageKit) source code to see if the API fits your needs.

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
