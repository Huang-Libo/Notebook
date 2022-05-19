# Using CocoaPods

- [Using CocoaPods](#using-cocoapods)
  - [Installation](#installation)
    - [1. Use Default Ruby](#1-use-default-ruby)
    - [2. Use Default Ruby with Sudo-less Installation](#2-use-default-ruby-with-sudo-less-installation)
      - [a. Configuring the RubyGems Environment (Recommended)](#a-configuring-the-rubygems-environment-recommended)
      - [b. gem install --user-install](#b-gem-install---user-install)
    - [3. Use Ruby Version Manager](#3-use-ruby-version-manager)
    - [Updating CocoaPods](#updating-cocoapods)
    - [Using a CocoaPods Fork](#using-a-cocoapods-fork)
  - [Adding Pods to an Xcode project](#adding-pods-to-an-xcode-project)
    - [Installation](#installation-1)
    - [Creating a new Xcode project with CocoaPods](#creating-a-new-xcode-project-with-cocoapods)
    - [Integration with an existing workspace](#integration-with-an-existing-workspace)
    - [Should I check the Pods directory into source control?](#should-i-check-the-pods-directory-into-source-control)
      - [Benefits of checking in the Pods directory](#benefits-of-checking-in-the-pods-directory)
      - [Benefits of ignoring the Pods directory](#benefits-of-ignoring-the-pods-directory)
    - [What is `Podfile.lock`?](#what-is-podfilelock)
    - [What is happening behind the scenes?](#what-is-happening-behind-the-scenes)
    - [Pods vs. Submodules](#pods-vs-submodules)
    - [Switching from submodules to CocoaPods](#switching-from-submodules-to-cocoapods)
  - [pod install vs. pod update](#pod-install-vs-pod-update)
    - [Introduction](#introduction)
    - [Detailed presentation of the commands](#detailed-presentation-of-the-commands)
      - [pod install](#pod-install)
      - [pod outdated](#pod-outdated)
      - [pod update](#pod-update)
    - [Intended usage](#intended-usage)
    - [Commit your Podfile.lock](#commit-your-podfilelock)
    - [Scenario Example](#scenario-example)
      - [Stage 1: User1 creates the project](#stage-1-user1-creates-the-project)
      - [Stage 2: User1 adds a new pod](#stage-2-user1-adds-a-new-pod)
      - [Stage 3: User2 joins the project](#stage-3-user2-joins-the-project)
      - [Stage 4: Checking for new versions of a pod](#stage-4-checking-for-new-versions-of-a-pod)
    - [Using exact versions in the Podfile is not enough](#using-exact-versions-in-the-podfile-is-not-enough)
  - [Podfile](#podfile)
    - [What is a Podfile?](#what-is-a-podfile)
      - [Examples](#examples)
      - [Specifying pod versions](#specifying-pod-versions)
    - [Using the files from a folder local to the machine](#using-the-files-from-a-folder-local-to-the-machine)
    - [From a podspec in the root of a library repo](#from-a-podspec-in-the-root-of-a-library-repo)

## Installation

### 1. Use Default Ruby

CocoaPods is built with Ruby and it will be installable with the default Ruby available on macOS. You can use a *Ruby Version manager*, however we recommend that you use the standard Ruby available on macOS unless you know what you're doing.

Using the default Ruby install will require you to use `sudo` when installing gems. (This is only an issue for the duration of the gem installation, though.)

```bash
sudo gem install cocoapods
```

If you encounter any problems during installation, please visit [this](https://guides.cocoapods.org/using/troubleshooting#installing-cocoapods) guide.

### 2. Use Default Ruby with Sudo-less Installation

If you do *not* want to grant RubyGems admin privileges for this process, you can:

- tell RubyGems to install into your user directory by using `gem install --user-install`,
- or by configuring the RubyGems environment.

#### a. Configuring the RubyGems Environment (Recommended)

**The latter is in our opinion the best solution.** To do this open up terminal and create or edit your `.bash_profile` with your preferred editor. Then enter these lines into the file:

```bash
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
```

Then you can install CocoaPods without `sudo`:

```bash
gem install cocoapods
```

#### b. gem install --user-install

Note that if you choose to use the `--user-install` option,

- you will *still* have to configure your `.bash_profile` file to set the `PATH`,
- *otherwise* you need to use the `pod` command with *full path*.

You can find out where a gem is installed with `gem which cocoapods`. E.g.

```bash
$ gem install cocoapods --user-install

$ gem which cocoapods
/Users/eloy/.gem/ruby/2.0.0/gems/cocoapods-0.29.0/lib/cocoapods.rb

# If you do not set the `PATH`, you need use full path of `pod` command
$ /Users/eloy/.gem/ruby/2.0.0/bin/pod install
```

### 3. Use Ruby Version Manager

If you already have Ruby installed with *Ruby Version manager* (For example, [RVM](https://rvm.io/)), you no longer need to use `sudo`:

```bash
gem install cocoapods
```

### Updating CocoaPods

- To update CocoaPods you simply install the gem again:

  ```bash
  [sudo] gem install cocoapods
  ```

- Or for a *pre-release* version with `--pre` option:

  ```bash
  [sudo] gem install cocoapods --pre
  ```

If you originally installed the cocoapods gem using `sudo`, you should use that command again.

> Later on, when you're actively using CocoaPods by installing pods, you will be notified when new versions become available with a *CocoaPods X.X.X is now available, please update* message.

### Using a CocoaPods Fork

There are two ways to do this, [using a Gemfile](https://guides.cocoapods.org/using/a-gemfile.html) (recommended) or using a [development build](https://guides.cocoapods.org/using/unreleased-features) that are in discussion or in implementation stage.

## Adding Pods to an Xcode project

Before you begin:

1. Check the [Specs](https://github.com/CocoaPods/Specs) repository or [cocoapods.org](https://cocoapods.org) to make sure the libraries you would like to use are available.
2. [Install CocoaPods](#installation) on your computer.

### Installation

- Create a [Podfile](#podfile), and add your dependencies:

```ruby
platform :ios, '9.0'

target 'MyApp' do
  pod 'AFNetworking', '~> 3.0'
  pod 'FBSDKCoreKit', '~> 4.9'
end
```

- Run `pod install` in your project directory.
- Open `MyApp.xcworkspace` and build.

### Creating a new Xcode project with CocoaPods

To create a new project with CocoaPods, follow these simple steps:

- Create a new project in Xcode as you would normally.
- Open a terminal window, and `cd` into your project directory.
- Create a `Podfile`. This can be done by running `pod init`.
- Open your `Podfile`. The first line should specify the platform and version supported.

```ruby
platform :ios, '9.0'
````

- In order to use CocoaPods you need to define the Xcode target to link them to. So for example if you are writing an iOS App, it would be the name of your app. Create a target section by writing `target '$TARGET_NAME' do` and an `end` a few lines after.
- Add a CocoaPod by specifying `pod '$PODNAME'` on a single line inside your target block.

```ruby
target 'MyApp' do
  pod 'ObjectiveSugar'
end
```

- Save your Podfile.
- Run `pod install`
- Open the `MyApp.xcworkspace` that was created. This should be the file you use everyday to create your app.

### Integration with an existing workspace

Integrating CocoaPods with an existing workspace requires one extra line in your Podfile. Simply specify the `.xcworkspace` filename in outside your target blocks like so:

```ruby
workspace 'MyWorkspace'
```

### Should I check the Pods directory into source control?

Whether or not you check in your `Pods` folder is up to you, as workflows vary from project to project. We recommend that you keep the `Pods` directory under source control, and don't add it to your `.gitignore`. But ultimately this decision is up to you:

#### Benefits of checking in the Pods directory

- After cloning the repo, the project can immediately build and run, even without having CocoaPods installed on the machine. There is no need to run `pod install`, and no Internet connection is necessary.
- The Pod artifacts (code/libraries) are always available, even if the source of a Pod (e.g. GitHub) were to go down.
- The Pod artifacts are guaranteed to be identical to those in the original installation after cloning the repo.

#### Benefits of ignoring the Pods directory

- The source control repo will be smaller and take up less space.
- As long as the sources (e.g. GitHub) for all Pods are available, CocoaPods is generally able to recreate the same installation. (Technically there is no guarantee that running `pod install` will fetch and recreate identical artifacts when not using a commit `SHA` in the `Podfile`. This is especially true when using zip files in the `Podfile`.)
- There won't be any conflicts to deal with when performing source control operations, such as merging branches with different Pod versions.

Whether or not you check in the `Pods` directory, the `Podfile` and `Podfile.lock` should always be kept under version control.

### What is `Podfile.lock`?

This file is generated after the first run of `pod install`, and tracks the version of each Pod that was installed. For example, imagine the following dependency specified in the Podfile:

```ruby
pod 'RestKit'
```

Running `pod install` will install the current version of RestKit, causing a `Podfile.lock` to be generated that indicates the exact version installed (e.g. `RestKit 0.10.3`).

Thanks to the `Podfile.lock`, running `pod install` on this hypothetical project at a later point in time on a different machine will still install RestKit `0.10.3` even if a newer version is available. CocoaPods will honour the Pod version in `Podfile.lock` unless the dependency is updated in the `Podfile` or `pod update` is called (which will cause a new `Podfile.lock` to be generated). In this way CocoaPods avoids headaches caused by unexpected changes to dependencies.

### What is happening behind the scenes?

In Xcode, with references directly from the [source code of CocoaPods (ruby)][user_project_integrator.rb], it:

1. Creates or updates a [workspace][user_project_integrator.rb].
2. [Adds your project to the workspace][user_project_integrator.rb] if needed.
3. Adds the [CocoaPods static library project to the workspace][target_installer.rb] if needed.
4. Adds `libPods.a` to: [targets => build phases => link with libraries][installer.rb].
5. Adds the CocoaPods [Xcode configuration file][target_integrator.rb] to your app’s project.
6. Changes your app's [target configurations](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/generator/xcconfig/aggregate_xcconfig.rb) to be based on CocoaPods's.
7. Adds a build phase to [copy resources from any pods][target_integrator.rb] you installed to your app bundle. i.e. a `Script build phase` after all other build phases with the following:
   1. Shell: `/bin/sh`
   2. Script: `${SRCROOT}/Pods/PodsResources.sh`

Reference for source code:

- [user_project_integrator.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/user_project_integrator.rb)
- [target_installer.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/xcode/pods_project_generator/target_installer.rb)
- [installer.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer.rb)
- [target_integrator.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/user_project_integrator/target_integrator.rb)

[user_project_integrator.rb]: https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/user_project_integrator.rb

[target_installer.rb]: https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/xcode/pods_project_generator/target_installer.rb

[installer.rb]: https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer.rb

[target_integrator.rb]: https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/installer/user_project_integrator/target_integrator.rb

Note that steps 3 onwards are skipped if the CocoaPods static library is already in your project. This is largely based on Jonah Williams' work on [Static Libraries](http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4).

### Pods vs. Submodules

CocoaPods and git submodules attempt to solve very similar problems. Both strive to simplify the process of including 3rd party code in your project.

Submodules link to a specific commit of that project, while a CocoaPod is tied to a versioned developer release.

### Switching from submodules to CocoaPods

Before you decide to make the full switch to CocoaPods, make sure that the libraries you are currently using are all available. It is also a good idea to record the versions of the libraries you are currently using, so that you can setup CocoaPods to use the same ones. It's also a good idea to do this incrementally, going dependency by dependency instead of one big move.

1. Install CocoaPods, if you have not done so already
2. Create your [Podfile](#podfile)
3. [Remove the submodule reference](http://davidwalsh.name/git-remove-submodule)
4. Add a reference to the removed library in your `Podfile`
5. Run `pod install`

## pod install vs. pod update

### Introduction

Many people starting with CocoaPods seem to think `pod install` is only used the first time you setup a project using CocoaPods and `pod update` is used afterwards. **But that's not the case at all.**

The aim of this guide is to explain when you should use `pod install` and when you should use `pod update`.

*TL;DR*:

- Use `pod install` to *install new pods* in your project. **Even if you already have a Podfile and ran `pod install` before**; so even if you are just adding/removing pods to a project already using CocoaPods.
- Use `pod update [PODNAME]` only when you want to **update pods to a newer version**.

### Detailed presentation of the commands

> Note: the vocabulary of `install` vs. `update` is not actually specific to CocoaPods. It is inspired by a lot of other dependency managers like [bundler](http://bundler.io/), [RubyGems](https://rubygems.org/) or [composer](https://getcomposer.org/), which have similar commands, with the exact same behavior and intents as the one described in this document.

#### pod install

This is to be used the first time you want to retrieve the pods for the project, but also every time you edit your `Podfile` to add, update or remove a pod.

- Every time the `pod install` command is run — and downloads and install new pods — it writes the version it has installed, for each pods, in the `Podfile.lock` file. This file keeps track of the installed version of each pod and *locks* those versions.
- When you run `pod install`, it only resolves dependencies for pods that are **not** already listed in the `Podfile.lock`.
  - For pods listed in the `Podfile.lock`, it downloads the explicit version listed in the `Podfile.lock` without trying to check if a newer version is available
  - For pods not listed in the `Podfile.lock` yet, it searches for the version that matches what is described in the `Podfile` (like in `pod 'MyPod', '~>1.2'`)

#### pod outdated

When you run `pod outdated`, CocoaPods will list all pods which have newer versions than the ones listed in the `Podfile.lock` (the versions currently installed for each pod). This means that if you run `pod update PODNAME` on those pods, they will be updated — as long as the new version still matches the restrictions like `pod 'MyPod', '~>x.y'` set in your `Podfile`.

#### pod update

When you run `pod update PODNAME`, CocoaPods will try to find an updated version of the pod `PODNAME`, without taking into account the version listed in `Podfile.lock`. It will update the pod to the latest version possible (as long as it matches the version restrictions in your `Podfile`).

If you run `pod update` with no pod name, CocoaPods will update **all** pod listed in your `Podfile` to the latest version possible.

### Intended usage

- With `pod update PODNAME`, you will be able to only **update** a specific pod (check if a new version exists and update the pod accordingly).
- As opposed to `pod install` which won't try to update versions of pods already installed.

When you add a pod to your `Podfile`, you should run `pod install`, not `pod update` — to install this new pod without risking to update existing pod in the same process.

You will only use `pod update` when you want to update the version of a specific pod (or all the pods).

### Commit your Podfile.lock

As a reminder, even if your policy is not to commit the `Pods` folder into your shared repository, **you should always commit & push your `Podfile.lock` file**.

*Otherwise, it would break the whole logic explained above about `pod install` being able to lock the installed versions of your pods.*

### Scenario Example

Here is a scenario example to illustrate the various use cases one might encounter during the life of a project.

#### Stage 1: User1 creates the project

*user1* creates a project and wants to use pods `A`, `B`, `C`. They create a `Podfile` with those pods, and run `pod install`.

This will install pods `A`, `B`, `C`, which we'll say are all in version `1.0.0`.

The `Podfile.lock` will keep track of that and note that `A`, `B`, `C` are each installed as version `1.0.0`.

> Incidentally, because that's the first time they run `pod install` and the `Pods.xcodeproj` project doesn't exist yet, the command will also create the `Pods.xcodeproj` and the `.xcworkspace`, but that's a side effect of the command, not its primary role.

#### Stage 2: User1 adds a new pod

Later, *user1* wants to add a pod `D` into their `Podfile`.

**They should thus run** `pod install` afterwards, so that even if the maintainer of pod `B` released a version `1.1.0` of their pod since the first execution of `pod install`, the project will keep using version `1.0.0` — because *user1* only wants to add pod `D`, without risking an unexpected update to pod `B`.

> That's where some people get it wrong, because they use `pod update` here — probably thinking this as "I want to update my project with new pods"? — instead of using `pod install` — to install new pods in the project.

#### Stage 3: User2 joins the project

Then *user2*, who never worked on the project before, joins the team. They clone the repository then use `pod install`.

The contents of `Podfile.lock` (which should be committed onto the git repo) will guarantee they will get the exact same pods, with the exact same versions that *user1* was using.

Even if a version `1.2.0` of pod `C` is now available, *user2* will get the pod `C` in version `1.0.0`. Because that's what is registered in `Podfile.lock`. pod `C` is *locked* to version `1.0.0` by the `Podfile.lock` (hence the name of this file).

#### Stage 4: Checking for new versions of a pod

Later, *user1* wants to check if any updates are available for the pods. They run `pod outdated` which will tell them that pod `B` have a new `1.1.0` version, and pod `C` have a new `1.2.0` version released.

*user1* decides they want to update pod `B`, but not pod `C`; so they will run `pod update B` which will update `B` from version `1.0.0` to version `1.1.0` (and update the `Podfile.lock` accordingly) **but** will keep pod `C` in version `1.0.0` (and *won't* update it to `1.2.0`).

### Using exact versions in the Podfile is not enough

Some might think that by specifying exact versions of their pods in their `Podfile`, like `pod 'A', '1.0.0'`, is enough to guarantee that every user will have the same version as other people on the team.

Then they might even use `pod update`, even when just adding a new pod, thinking it would never risk to update other pods because they are fixed to a specific version in the `Podfile`.

But in fact, **that is not enough to guarantee that *user1* and *user2* in our above scenario will always get the exact same version of all their pods**.

One typical example is if the pod `A` has a dependency on pod `A2` — declared in `A.podspec` as dependency `'A2', '~> 3.0'`. In such case, using pod 'A', '1.0.0' in your `Podfile` will indeed force *user1* and *user2* to both always use version `1.0.0` of the pod `A`, but:

- *user1* might end up with pod `A2` in version `3.4` (because that was `A2`'s latest version at that time)
- while when *user2* runs `pod install` when joining the project later, they might get pod `A2` in version `3.5` (because the maintainer of `A2` might have released a new version in the meantime).

That's why the only way to ensure every team member work with the same versions of all the pod on each's computer is to use the `Podfile.lock` and properly use `pod install` vs. `pod update`.

## Podfile

### What is a Podfile?

#### Examples

The `Podfile` is a specification that describes the dependencies of the
targets of one or more Xcode projects. The file should simply be named `Podfile`.

All the examples in the guides are based on CocoaPods version `1.0` and onwards.

> A Podfile can be very simple, this adds Alamofire to a single target:

```ruby
target 'MyApp' do
  use_frameworks!
  pod 'Alamofire', '~> 3.0'
end
```

> An example of a more complex Podfile linking an app and its test bundle:

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/Artsy/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

target 'MyApp' do
  pod 'GoogleAnalytics', '~> 3.1'

  # Has its own copy of OCMock
  # and has access to GoogleAnalytics via the app
  # that hosts the test target

  target 'MyAppTests' do
    inherit! :search_paths
    pod 'OCMock', '~> 2.0.1'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end
 ```

> If you want multiple targets to share the same pods, use an `abstract_target`.

```ruby
# There are no targets called "Shows" in any Xcode projects
abstract_target 'Shows' do
  pod 'ShowsKit'
  pod 'Fabric'

  # Has its own copy of ShowsKit + ShowWebAuth
  target 'ShowsiOS' do
    pod 'ShowWebAuth'
  end

  # Has its own copy of ShowsKit + ShowTVAuth
  target 'ShowsTV' do
    pod 'ShowTVAuth'
  end
end
```

There is implicit abstract target at the root of the Podfile, so you could write the above example as:

``` ruby
pod 'ShowsKit'
pod 'Fabric'

# Has its own copy of ShowsKit + ShowWebAuth
target 'ShowsiOS' do
  pod 'ShowWebAuth'
end

# Has its own copy of ShowsKit + ShowTVAuth
target 'ShowsTV' do
  pod 'ShowTVAuth'
end
```

#### Specifying pod versions

> When starting out with a project it is likely that you will want to use the latest version of a Pod. If this is the case, simply omit the version requirements.

```ruby
pod 'SSZipArchive'
```

> Later on in the project you may want to freeze to a specific version of a Pod, in which case you can specify that version number.

```ruby
pod 'Objection', '0.9'
```

Besides no version, or a specific one, it is also possible to use logical operators:

- `'> 0.1'`    Any version higher than 0.1
- `'>= 0.1'`   Version 0.1 and any higher version
- `'< 0.1'`    Any version lower than 0.1
- `'<= 0.1'`   Version 0.1 and any lower version

In addition to the logic operators CocoaPods has an optimistic operator `~>`:

- `'~> 0.1.2'` Version 0.1.2 and the versions up to 0.2, not including 0.2 and higher
- `'~> 0.1'` Version 0.1 and the versions up to 1.0, not including 1.0 and higher
- `'~> 0'` Version 0 and the versions up to 1.0, not including 1.0 and higher

For more information, regarding versioning policy, see:

- [Semantic Versioning](http://semver.org)
- [RubyGems Versioning Policies](http://guides.rubygems.org/patterns/#semantic-versioning)
- There's a great video from Google about how this works: ["CocoaPods and the Case of the Squiggly Arrow (Route 85)"](https://www.youtube.com/watch?v=x4ARXyovvPc).
  - Note that the information about `~> 1` in the video is incorrect.

### Using the files from a folder local to the machine

> If you would like to develop a Pod in tandem with its client
project you can use `:path`.

```ruby
pod 'Alamofire', :path => '~/Documents/Alamofire'
```

Using this option CocoaPods will assume the given folder to be the
root of the Pod and will link the files directly from there in the
Pods project. This means that your edits will persist between CocoaPods
installations. **The referenced folder can be a checkout of your favourite *SCM(Source Control Manager)* or even a *git submodule* of the current repo**.

<aside>Note that the `podspec` of the Pod file is expected to be in that the designated folder.</aside>

### From a podspec in the root of a library repo

Sometimes you may want to use the bleeding edge version of a Pod, a
specific revision or your own fork. If this is the case, you can specify that with your
pod declaration.

> To use the `master` branch of the repo:

```ruby
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git'
````

> To use a different branch of the repo:

```ruby
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'dev'
```

> To use a `tag` of the repo:

```ruby
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :tag => '3.1.1'
```

> Or specify a `commit`:

```ruby
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :commit => '0f506b1c45'
```

It is important to note, though, that this means that the version will
have to satisfy any other dependencies on the Pod by other Pods.

The `podspec` file is expected to be in the root of the repo, if this
library does not have a `podspec` file in its repo yet, you will have
to use one of the approaches outlined in the sections below.
