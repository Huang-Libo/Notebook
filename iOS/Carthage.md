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
  - [Build static frameworks to speed up your app’s launch times](#build-static-frameworks-to-speed-up-your-apps-launch-times-1)
    - [1. Linking many static frameworks into your application binary](#1-linking-many-static-frameworks-into-your-application-binary)
    - [2. Merging your static frameworks into a single larger dynamic framework](#2-merging-your-static-frameworks-into-a-single-larger-dynamic-framework)
      - [Resolving linker warnings](#resolving-linker-warnings)
    - [Linker flags](#linker-flags)
    - [Embedded resources](#embedded-resources)
  - [Artifacts](#artifacts)
    - [Cartfile](#cartfile)
      - [Origin](#origin)
        - [GitHub Repositories](#github-repositories)
        - [Git repositories](#git-repositories)
        - [Binary only frameworks](#binary-only-frameworks)
      - [Version requirement](#version-requirement)
      - [Example Cartfile](#example-cartfile)
    - [Cartfile.private](#cartfileprivate)
    - [Cartfile.resolved](#cartfileresolved)
    - [Carthage/Build](#carthagebuild)
    - [Carthage/Checkouts](#carthagecheckouts)
      - [With submodules](#with-submodules)
    - [~/Library/Caches/org.carthage.CarthageKit](#librarycachesorgcarthagecarthagekit)
    - [Binary Project Specification](#binary-project-specification)
      - [Publish an XCFramework build alongside the framework build using an `alt=` query parameter](#publish-an-xcframework-build-alongside-the-framework-build-using-an-alt-query-parameter)
      - [Example binary project specification](#example-binary-project-specification)
    - [Version Files](#version-files)
      - [File location and format](#file-location-and-format)
      - [Caching builds with version files](#caching-builds-with-version-files)
  - [Known issues](#known-issues)
    - [DWARFs symbol problem](#dwarfs-symbol-problem)
    - [Using Carthage with Xcode 12](#using-carthage-with-xcode-12)
      - [Why Carthage compilation fails](#why-carthage-compilation-fails)
      - [Workaround](#workaround)
      - [How to make it work](#how-to-make-it-work)
      - [Workaround script](#workaround-script)
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

### Declare your compatibility

Want to advertise that your project can be used with Carthage? You can add a compatibility badge:

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

… to your `README`, by simply inserting the following Markdown:

```markdown
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
```

## Build static frameworks to speed up your app’s launch times

Carthage supports building *static frameworks* in place of *dynamic frameworks* when used in concert with Keith Smiley’s `ld.py` script, published [here](https://github.com/keith/swift-staticlibs/blob/master/ld.py).

If you have many *dynamic frameworks*, you may have noticed that your application's launch times can be quite slow relative to other applications.To mitigate this, Apple suggests that you embed [at most six dynamic frameworks](https://developer.apple.com/videos/play/wwdc2016/406/?time=1794) into your applications.

Unfortunately, Xcode has not supported building *static Swift frameworks* out of the box since Apple made that recommendation, so it is a bit tricky to follow this advice. The goal of this guide is to show you how to reduce the number of *embedded dynamic frameworks* in your application with some simple wrappers around Carthage.

Since you’re going to be rebuilding *dynamic frameworks* as *static frameworks*, make sure that when you perform a `carthage checkout`, `carthage bootstrap`, or `carthage update` from this point forward, you are supplying the `--no-use-binaries` flag to `carthage`. This will ensure that Carthage doesn’t download prebuilt dynamic frameworks and place them into your `Carthage/Build` directory, since you won’t be needing them anyways.

To build *static frameworks* with Carthage, we suggest wrapping invocations of `carthage build` with a script that looks something like this:

```bash
#!/bin/sh -e

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

echo "LD = $PWD/the/path/to/ld.py" >> $xcconfig
echo "DEBUG_INFORMATION_FORMAT = dwarf" >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"

carthage build "$@"
```

This script ensures that whenever you invoke `carthage build` , there’s a temporary `.xcconfig` file that’s provided to Carthage’s invocations of `xcodebuild` that forces it to build dynamic frameworks as static frameworks by replacing the `ld` command with invocations to `libtool` instead.

It additionally makes sure that `xcodebuild` does not attempt to produce `dSYM` files for static frameworks, since this would cause a build failure otherwise.

Finally, this script also ensures that the temporary `xcconfig` file is automatically deleted whenever the script exits. After you've modified this script to suit your needs, don’t forget to make it executable via `chmod +x`.

Note that you’ll also need to download [ld.py](https://github.com/keith/swift-staticlibs/blob/master/ld.py) and make it executable via `chmod +x ld.py` to invoke it in the above script. It would probably make sense to check it into your repository, but that’s ultimately up to you.

Once you’ve modified the above script to fit your local directory structure and added `ld.py` to a location in your repository, you should be able to build *static frameworks* with Carthage now by invoking your script from above, e.g.:

```bash
./carthage-build-static.sh ReactiveCocoa --platform ios
```

To double-check that Carthage is building static frameworks, you can inspect the binary of one of your frameworks in the `Carthage/Build` folder:

```bash
file Carthage/Build/iOS/ReactiveCocoa.framework/ReactiveCocoa
```

- If the output includes `current ar archive`, congratulations—you’ve just built a static framework using Carthage.
- If you see `Mach-O dynamically linked shared library`, something went wrong with your script—please double-check that you’ve followed the instructions above.

Now that you have Carthage building *static frameworks*, there are two ways to integrate them into your existing projects:

### 1. Linking many static frameworks into your application binary

If you’re linking static frameworks into your existing application, it should be as simple as dragging and dropping the `.framework`s into the *Link Binary with Libraries* build phase, just as with *dynamic frameworks*. If you see any new failure, please refer to the below troubleshooting sections.

If you were previously building these frameworks as *dynamic frameworks*, make sure that you no longer embed them into your package's `Frameworks` folder via the `carthage copy-frameworks` command, as this step is not necessary with static frameworks.

### 2. Merging your static frameworks into a single larger dynamic framework

If your application has plugins or app extensions that need to share many frameworks, it may work best to merge many static frameworks together into one larger dynamic framework to share effectively between your targets.

To do so, create a framework target in your Xcode project that your application and each of the other relevant targets depend on. Then, drag and drop the static `.framework`s that you want to merge into this binary into the *Link Binary with Libraries* build step of this new merged framework target.

To ensure that this new merged framework is a true merge of all of its dependent static frameworks, you should include the `-all_load` flag in its `OTHER_LDFLAGS` build setting. **This forces the *linker* to merge the full static framework into the dynamic framework (rather than just the parts that are used by your merged framework).** If you don’t do this, consumers of the merged framework will likely encounter linker errors with undefined symbols.

#### Resolving linker warnings

At this stage, your targets probably have their `Framework Search Paths` pointed at the `Carthage/Build/iOS` folder which now contains *static frameworks*.

So you will start seeing: `ld: warning: Auto-Linking supplied 'X.framework/X', framework linker option at X.framework/X is not a dylib` for each of them when you compile. Unfortunately "Auto-Linking" is inferring frameworks that are used from your source, but doesn't know that your larger dynamic framework is providing them, and looks in `Framework Search Paths` for them. It finds the statics, hence the warnings.

To work around this, you can point the targets that consume your large dynamic framework at a folder containing regular dynamic framework builds instead of the static ones. Your larger dynamic framework stuff points to the static ones though. This way Xcode knows what modules and symbols are available for the consumers, the linker will not actually auto-link to them because they are dylibs, but the linker also won't complain. The symbols are still provided by the larger dynamic frameowrk, which is loaded at app start. Note that this is a workaround, so use at your own risk!

Another linker warning you might faced with during large dynamic framework is: `ld: warning: Auto-Linking library not found for -lswiftCore`, as well as errors such as: `Undefined symbols for architecture x86_64: "Swift.String.init<A>(stringInterpolationSegment: A) -> Swift.String", referenced from:...`. To fix this issue you need to add an empty class withing this dynamic framework: `final class Empty {}`.

### Linker flags

If any of your frameworks contain Objective-C extensions, you will need to supply the `-ObjC` flag in your `OTHER_LDFLAGS` build setting to ensure that they’re successfully invoked. If you do not supply this flag, you will see a runtime crash whenever an Objective-C extension is invoked.

If any of your *static frameworks* require you to pass additional linker flags, you will see linker failures like `Undefined symbols for architecture arm64:`. In this case, you may need to pass some additional linker flags to get the static framework to link into your project. It should be obvious from the output which static framework is at fault. To find out which flags to include in the `OTHER_LDFLAGS` build setting of your project to fix the error, you should open the Xcode project for the framework causing the build failures and inspect the *Other linker flags* setting. In that build setting, you should be able to find additional linker flags you will need to provide to your project to fix the linker error.

### Embedded resources

If any of your dynamic frameworks contained embedded resources, you may not be able to build them statically. However, you may find success in just copying the resources into the bundle that you’re linking the static frameworks with, but this will not work in all cases.

## Artifacts

This document lists all files and folders used or created by Carthage, and the purpose of each.

### Cartfile

A `Cartfile` describes your project’s dependencies to Carthage, allowing it to resolve and build them for you. Cartfiles are a restricted subset of the [Ordered Graph Data Language](http://ogdl.org/), and any standard OGDL tool should be able to parse them.

Dependency specifications consist of two main parts: the [origin](#origin), and the [version requirement](#version-requirement).

#### Origin

The three supported origins right now are

- GitHub repositories
- Git repositories
- Binary-only frameworks served over `https`

Other possible origins may be added in the future.

##### GitHub Repositories

GitHub repositories (both *GitHub.com* and *GitHub Enterprise*) are specified with the `github` keyword:

```sh
github "ReactiveCocoa/ReactiveCocoa" # GitHub.com
github "https://enterprise.local/ghe/desktop/git-error-translations" # GitHub Enterprise
```

`github` origin is for specifying by `owner/repo` form or using prebuilt binary download feature through its *WEB API*, so using `git` or `ssh` protocol for `github` origin does *not* make sense and will be an error.

##### Git repositories

Other Git repositories are specified with the `git` keyword:

```sh
git "https://enterprise.local/desktop/git-error-translations2.git"
```

##### Binary only frameworks

Dependencies that are only available as compiled binary `.framework`s are specified with the `binary` keyword and as an `https://` URL, a `file://` URL, or a relative or an absolute path with no scheme, that returns a [binary project specification](#binary-project-specification):

```sh
binary "https://my.domain.com/release/MyFramework.json"   // Remote Hosted
binary "file:///some/Path/MyFramework.json"               // Locally hosted at file path
binary "relative/path/MyFramework.json"                   // Locally hosted at relative path to CWD
binary "/absolute/path/MyFramework.json"                  // Locally hosted at absolute path
```

When downloading a binary only frameworks, `carthage` will take into account the user's `~/.netrc` file to determine authentication credentials if `--use-netrc` flag was set.

#### Version requirement

Carthage supports several kinds of version requirements:

1. `>= 1.0` for “at least version 1.0”
2. `~> 1.0` for “compatible with version 1.0”
3. `== 1.0` for “exactly version 1.0”
4. `"some-branch-or-tag-or-commit"` for a specific Git object (anything allowed by `git rev-parse`). **Note**: This form of requirement is *not* supported for `binary` origins.

If no version requirement is given, any version of the dependency is allowed.

Compatibility is determined according to [Semantic Versioning](http://semver.org/). This means that any version greater than or equal to `1.5.1`, but less than `2.0`, will be considered “compatible” with `1.5.1`.

According to [Semantic Versioning](http://semver.org/), any `0.x.y` release may completely break the exported API, so it's not safe to consider them compatible with one another. Only patch versions are compatible under `0.x`, meaning `0.1.1` is compatible with `0.1.2`, but not `0.2`. This isn't according to the SemVer spec but keeps `~>` useful for `0.x.y` versions.

**In all cases, Carthage will pin to a tag or SHA (for `git` and `github` origins) or a semantic version (for `binary` origins)**, and only bump those values when `carthage update` is run again in the future. This means that following a branch (for example) still results in commits that can be independently checked out just as they were originally.

#### Example Cartfile

```sh
# Require version 2.3.1 or later
github "ReactiveCocoa/ReactiveCocoa" >= 2.3.1

# Require version 1.x
github "Mantle/Mantle" ~> 1.0    # (1.0 or later, but less than 2.0)

# Require exactly version 0.4.1
github "jspahrsummers/libextobjc" == 0.4.1

# Use the latest version
github "jspahrsummers/xcconfigs"

# Use the branch
github "jspahrsummers/xcconfigs" "branch"

# Use a project from GitHub Enterprise
github "https://enterprise.local/ghe/desktop/git-error-translations"

# Use a project from any arbitrary server, on the "development" branch
git "https://enterprise.local/desktop/git-error-translations2.git" "development"

# Use a local project
git "file:///directory/to/project" "branch"

# A binary only framework
binary "https://my.domain.com/release/MyFramework.json" ~> 2.3

# A binary only framework via file: url
binary "file:///some/local/path/MyFramework.json" ~> 2.3

# A binary only framework via local relative path from Current Working Directory to binary project specification
binary "relative/path/MyFramework.json" ~> 2.3

# A binary only framework via absolute path to binary project specification
binary "/absolute/path/MyFramework.json" ~> 2.3
```

### Cartfile.private

Frameworks that want to include dependencies via Carthage, but do *not* want to force those dependencies on parent projects, can list them in the optional `Cartfile.private` file, identically to how they would be specified in the main [Cartfile](#cartfile).

Anything listed in the private Cartfile will not be seen by dependent (parent) projects, which is useful for dependencies that may be important during development, but not when building releases—for example, test frameworks.

### Cartfile.resolved

After running the `carthage update` command, a file named `Cartfile.resolved` will be created alongside the `Cartfile` in the working directory. This file specifies precisely *which* versions were chosen of each dependency, and lists all dependencies (even nested ones).

The `Cartfile.resolved` file ensures that any given commit of a Carthage project can be bootstrapped in exactly the same way, every time. For this reason, you are **strongly recommended** to commit this file to your repository.

Although the `Cartfile.resolved` file is meant to be human-readable and diffable, you **must not** modify it. The format of the file is very strict, and the order in which dependencies are listed is important for the build process.

### Carthage/Build

This folder is created by `carthage build` in the project’s working directory, and contains the *binary frameworks* and *debug information* for each dependency (whether built from scratch or downloaded).

You are not required to commit this folder to your repository, but you may wish to, if you want to guarantee that the built versions of each dependency will *always* be accessible at a later date.

### Carthage/Checkouts

This folder is created by `carthage checkout` in the application project’s working directory, and contains your dependencies’ source code (when *prebuilt* binaries are not available). The project folders inside `Carthage/Checkouts` are later used for the `carthage build` command.

You are not required to commit this folder to your repository, but you may wish to, if you want to guarantee that the source checkouts of each dependency will *always* be accessible at a later date.

Unless you are [using submodules](#with-submodules), the contents of **this directory should not be modified**, as they may be overwritten by a future `carthage checkout` command.

#### With submodules

If the `--use-submodules` flag was given when a project’s dependencies were bootstrapped, updated, or checked out, the dependencies inside `Carthage/Checkouts` will be available as Git submodules. **This allows you to make changes in the dependencies, and commit and push those changes upstream.**

### ~/Library/Caches/org.carthage.CarthageKit

This folder is created automatically by Carthage, and contains the “bare” Git repositories used for fetching and checking out dependencies, as well as *prebuilt* binaries that have been downloaded.

Keeping all repositories in this *centralized* location avoids polluting individual projects with Git metadata, and allows Carthage to share one copy of each repository across all projects.

If you need to reclaim disk space, you can safely delete this folder, or any of the individual folders inside. The folder will be automatically repopulated the next time `carthage checkout` is run.

### Binary Project Specification

For dependencies that do not have source code available, a binary project specification can be used to list the locations and versions of compiled frameworks. This data **must** be available via `https` and could be served from a static file or dynamically.

- The JSON specification file name **should** have the *same name* as the framework and **not** be named `Carthage.json`, (*Correct example*: `MyFramework.json`).
- The JSON structure is a top-level dictionary with the key-value pairs of version/location.
- The version **must** be a semantic version. Git branches, tags and commits are not valid.
- The location **must** be an `https` url.

#### Publish an XCFramework build alongside the framework build using an `alt=` query parameter

To support users who build with `--use-xcframework`, create two zips:

- One containing the framework bundle(s) for your dependency
- The other containing xcframework(s)

Include "framework" or "xcframework" in the names of the zips, for example:  `MyFramework.framework.zip` and `MyFramework.xcframework.zip`.

In your project specification, join the two URLs into one using a query string:

```plaintext
https://my.domain.com/release/1.0.0/MyFramework.framework.zip?alt=https://my.domain.com/release/1.0.0/MyFramework.xcframework.zip
```

Starting in version 0.38.0, Carthage extracts any `alt=` URLs from the version specification. When `--use-xcframeworks` is passed, it prefers downloading URLs with "xcframework" in the name.

**For backwards compatibility,** provide the plain frameworks build *first* (i.e. not as an alt URL), so that older versions of Carthage use it. Carthage versions prior to `0.38.0` fail to download and extract XCFrameworks.

#### Example binary project specification

```json
{
  "1.0": "https://my.domain.com/release/1.0.0/framework.zip",
  "1.0.1": "https://my.domain.com/release/1.0.1/MyFramework.framework.zip?alt=https://my.domain.com/release/1.0.1/MyFramework.xcframework.zip"
}
```

### Version Files

#### File location and format

In order to *avoid rebuilding* frameworks unnecessarily, Carthage stores cache data in hidden version files in the *Build folder*.  Version files are named `.Project.version` (where Project is the name of a project).

Each version file contains JSON data in a format similar to that of the version file for `.Prelude.version`:

```json
{
  "commitish" : "1.6.0",
  "Mac" : [
    {
        "hash" : "de07bfdba346deb20705712c2ea07e7191d57f07d793c8c0698ded085bdb5cce",
        "name" : "Prelude"
    }
  ]
}
```

#### Caching builds with version files

When a project is built, a version file is created with the dependency's commitish. An entry is added in the version file for each platform that was built, even if no frameworks are produced (in which case the given platform key is associated with an empty array). For each platform, the name and hash (`SHA256`) for each produced framework are recorded.

Before a project is built, if a version file already exists, it will be used to determine whether Carthage can **skip** building the project.

For a given *platform*, if the commitish matches and the *recorded hash* of each associated framework matches the hash of those frameworks in the *Build folder*, that platform is considered cached.

- If no platforms are provided as *build options* (via `--platform`), a dependency will be considered cached if all platforms are listed in the *version file* and considered cached.
- If platforms are provided as *build options*, a dependency will be considered cached if the *version file* contains an entry for every provided platform and each of those platforms are considered cached.

**Version files will be ignored and all dependencies will be built unless `--cache-builds` is provided as a build option.** Version files may also be manually deleted in order to clear Carthage’s cache data. Version files are always produced after a project has been built.

## Known issues

### DWARFs symbol problem

Pre-built framework cannot be debugged using step execution on other machine than on which the framework was built. Simply `carthage bootstrap/build/update --no-use-binaries` should fix this, but for muore automated workaround, see [#924](https://github.com/Carthage/Carthage/isses/924). Dupe [rdar://23551273](http://www.openradar.me/23551273) if you want Apple to fix the root cause of this problem.

- [#2137](https://github.com/Carthage/Carthage/issues/2137)
- [stackoverflow: Debugging (owned) Framework when using Carthage](https://stackoverflow.com/questions/38862464/debugging-owned-framework-when-using-carthage)

### Using Carthage with Xcode 12

As Carthage doesn't work out of the box with Xcode 12, this document will guide through a workaround that works for most cases.

#### Why Carthage compilation fails

Well, shortly, Carthage builds *fat frameworks*, which means that the framework contains binaries for all supported architectures.

Until *Apple Silicon* was introduced it all worked just fine, but now **there is a conflict as there are duplicate architectures (arm64 for devices and arm64 for simulator)**.
This means that Carthage cannot link architecture specific frameworks to a single fat framework.

You can find more info in [respective issue #3019](https://github.com/Carthage/Carthage/issues/3019).

#### Workaround

> Perhaps a better solution is to support **xcframework** instead of using `lipo`...

As a workaround you can invoke carthage **using this script, it will remove the arm64 architecture for simulator**, so the above mentioned conflict doesn't exist.

#### How to make it work

1. place this script somewhere to your `PATH` (I personally have it in `/usr/local/bin/carthage.sh`)
2. make it the script executable, so open your _Terminal_ and run

    ```shell
    chmod +x /usr/local/bin/carthage.sh
    ```

3. from now on instead of running e.g.

   ```shell
   carthage bootstrap --platform iOS --cache-builds
   ```

   you need to run our script

   ```shell
   carthage.sh bootstrap --platform iOS --cache-builds
   ```

#### Workaround script

This script has a known limitation - **it will remove arm64 simulator architecture from compiled framework, so frameworks compiled using it cannot be used on Macs running Apple Silicon.**

```bash
### carthage.sh
### Usage example: ./carthage.sh build --platform iOS

set -euo pipefail

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

### For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
### the build will fail on lipo due to duplicate architectures.

CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Build version" | cut -d' ' -f3)
echo "EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$CURRENT_XCODE_VERSION = arm64 arm64e armv7 armv7s armv6 armv8" >> $xcconfig

echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"
carthage "$@"
```

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
