# Using CocoaPods

- [Using CocoaPods](#using-cocoapods)
  - [Getting Started](#getting-started)
    - [Installation](#installation)
      - [Use Default Ruby](#use-default-ruby)
      - [Use Default Ruby with Sudo-less Installation](#use-default-ruby-with-sudo-less-installation)
        - [1. Configuring the RubyGems Environment](#1-configuring-the-rubygems-environment)
        - [2. gem install --user-install](#2-gem-install---user-install)
      - [Use Ruby Version Manager](#use-ruby-version-manager)
    - [Updating CocoaPods](#updating-cocoapods)
    - [Using a CocoaPods Fork](#using-a-cocoapods-fork)
  - [pod install vs. pod update](#pod-install-vs-pod-update)
    - [Introduction](#introduction)
    - [Detailed presentation of the commands](#detailed-presentation-of-the-commands)
      - [pod install](#pod-install)
      - [pod outdated](#pod-outdated)
      - [pod update](#pod-update)
    - [Intended usage](#intended-usage)

## Getting Started

### Installation

#### Use Default Ruby

CocoaPods is built with Ruby and it will be installable with the default Ruby available on macOS. You can use a *Ruby Version manager*, however we recommend that you use the standard Ruby available on macOS unless you know what you're doing.

Using the default Ruby install will require you to use `sudo` when installing gems. (This is only an issue for the duration of the gem installation, though.)

```bash
sudo gem install cocoapods
```

If you encounter any problems during installation, please visit [this](https://guides.cocoapods.org/using/troubleshooting#installing-cocoapods) guide.

#### Use Default Ruby with Sudo-less Installation

If you do *not* want to grant RubyGems admin privileges for this process, you can:

1. tell RubyGems to install into your user directory by using `gem install --user-install`,
2. or by configuring the RubyGems environment.

##### 1. Configuring the RubyGems Environment

**The latter is in our opinion the best solution.** To do this open up terminal and create or edit your `.bash_profile` with your preferred editor. Then enter these lines into the file:

```bash
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
```

Then you can install CocoaPods without `sudo`:

```bash
gem install cocoapods
```

##### 2. gem install --user-install

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

#### Use Ruby Version Manager

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


