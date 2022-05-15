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

