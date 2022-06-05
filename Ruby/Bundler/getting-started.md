# Getting Started

> <https://bundler.io/v2.3/#getting-started>

- [Getting Started](#getting-started)
  - [Overview](#overview)
  - [Install Bundler](#install-bundler)
  - [Add `Gemfile`](#add-gemfile)
  - [`bundle install`](#bundle-install)
  - [Use gems in code: `require`](#use-gems-in-code-require)
  - [`bundle exec`](#bundle-exec)
  - [Create a gem with Bundler: `bundle gem`](#create-a-gem-with-bundler-bundle-gem)
  - [Check Bundler's environment: `bundle env`](#check-bundlers-environment-bundle-env)

## Overview

Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed.

Bundler is an exit from dependency hell, and ensures that the gems you need are present in development, staging, and production. Starting work on a project is as simple as `bundle install`.

## Install Bundler

> **Note**: You should install ruby first.  
> **Recommended**: Use [rbenv](https://github.com/rbenv/rbenv) to install and manage different versions of ruby.

Getting started with bundler is easy! Open a terminal window and run this command:

```sh
gem install bundler
```

## Add `Gemfile`

Specify your dependencies in a `Gemfile` in your project's root:

```ruby
source 'https://rubygems.org'

gem 'nokogiri'
gem 'rack', '~> 2.0.1'
gem 'rspec'
```

## `bundle install`

Install all of the required gems from your specified sources:

```sh
bundle config set --local path 'vendor/bundle' # or: bundle config path vendor/bundle
bundle install
```

> **Warning**:  
> If you try to use `bundle install --path vendor/bundle`, you will get a warning:  
> [DEPRECATED] The `--path` flag is deprecated because it relies on being remembered across bundler invocations, which bundler will no longer do in future versions. Instead please use `bundle config set --local path 'vendor/bundle'`, and stop using this flag.

Other way to setup the install `path` for gems:

- Setup path for *current project* only: add `./.bundle/config` at the root of the project;
- Setup path *globally*: add `~/.bundle/config` at user's home directory.

`config` file sample:

```ruby
---
BUNDLE_PATH: "vendor/bundle"
```

## Use gems in code: `require`

Inside your App, load up the bundled environment:

```ruby
require 'rubygems'
require 'bundler/setup'

# require your gems as usual
require 'nokogiri'
```

## `bundle exec`

Run an executable that comes with a gem in your bundle:

```sh
bundle exec rspec spec/models
```

In some cases, running executables without `bundle exec` may work, if the executable happens to be installed in your system and does not pull in any gems that conflict with your bundle.

However, this is unreliable and is the source of considerable pain. Even if it looks like it works, it may not work in the future or on another machine.

Finally, if you want a way to get a shortcut to gems in your bundle:

```sh
bundle install --binstubs
bin/rspec spec/models
```

The executables installed into `bin` are scoped to the bundle, and will always work.

## Create a gem with Bundler: `bundle gem`

Bundler is also an easy way to create new gems. Just like you might create a standard Rails project using `rails new`, you can create a standard gem project with `bundle gem`.

Create a new gem with a `README`, `.gemspec`, `Rakefile`, directory structure, and all the basic boilerplate you need to describe, test, and publish a gem:

```console
$ bundle gem my_gem

Creating gem 'my_gem'...
Initializing git repo in my_gem
      create  my_gem/Gemfile
      create  my_gem/lib/my_gem.rb
      create  my_gem/lib/my_gem/version.rb
      create  my_gem/sig/my_gem.rbs
      create  my_gem/my_gem.gemspec
      create  my_gem/Rakefile
      create  my_gem/README.md
      create  my_gem/bin/console
      create  my_gem/bin/setup
      create  my_gem/.gitignore
      create  my_gem/LICENSE.txt
      create  my_gem/CHANGELOG.md
      create  my_gem/.rubocop.yml
Gem 'my_gem' was successfully created. For more information on making a RubyGem visit https://bundler.io/guides/creating_gem.html
```

## Check Bundler's environment: `bundle env`

Print information about the environment Bundler is running under.

```sh
$ bundle env

## Environment

Bundler       2.3.15
  Platforms   ruby, arm64-darwin-21
Ruby          2.7.6p219 (2022-04-12 revision c9c2245c0a25176072e02db9254f0e0c84c805cd) [arm64-darwin-21]
  Full Path   $HOME/.rbenv/versions/2.7.6/bin/ruby
  Config Dir  $HOME/.rbenv/versions/2.7.6/etc
RubyGems      3.1.6
  Gem Home    $HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
  Gem Path    $HOME/.gem/ruby/2.7.0:$HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
  User Home   $HOME
  User Path   $HOME/.gem/ruby/2.7.0
  Bin Dir     $HOME/.rbenv/versions/2.7.6/bin
Tools
  Git         2.36.1
  RVM         not installed
  rbenv       rbenv 1.2.0
  chruby      not installed

## Bundler Build Metadata

Built At          2022-06-01
Git SHA           e7e41afd92
Released Version  true

## Bundler settings

gem.changelog
  Set for your local app ($HOME/.bundle/config): true
  Set for the current user ($HOME/.bundle/config): true
gem.ci
  Set for your local app ($HOME/.bundle/config): false
  Set for the current user ($HOME/.bundle/config): false
gem.coc
  Set for your local app ($HOME/.bundle/config): false
  Set for the current user ($HOME/.bundle/config): false
gem.linter
  Set for your local app ($HOME/.bundle/config): "rubocop"
  Set for the current user ($HOME/.bundle/config): "rubocop"
gem.mit
  Set for your local app ($HOME/.bundle/config): true
  Set for the current user ($HOME/.bundle/config): true
gem.test
  Set for your local app ($HOME/.bundle/config): false
  Set for the current user ($HOME/.bundle/config): false
path
  Set for your local app ($HOME/.bundle/config): "vendor/bundle"
  Set for the current user ($HOME/.bundle/config): "vendor/bundle"
```