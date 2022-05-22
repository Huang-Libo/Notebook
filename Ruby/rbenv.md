# rbenv

- [rbenv](#rbenv)
  - [Overview](#overview)
  - [How It Works](#how-it-works)
    - [Understanding PATH](#understanding-path)
    - [Understanding Shims](#understanding-shims)
    - [Choosing the Ruby Version](#choosing-the-ruby-version)
    - [Locating the Ruby Installation](#locating-the-ruby-installation)

## Overview

> Seamlessly manage your app’s Ruby environment with [rbenv](https://github.com/rbenv/rbenv).  
> Here is [wiki](https://github.com/rbenv/rbenv/wiki).

Use rbenv to pick a Ruby version for your application and guarantee that your development environment matches production. Put rbenv to work with [Bundler](http://bundler.io/) for painless Ruby upgrades and bulletproof deployments.

[Why choose rbenv over RVM?](https://github.com/rbenv/rbenv/wiki/Why-rbenv%3F)

## How It Works

At a high level, rbenv intercepts Ruby commands using **shim** executables injected into your `PATH`, determines which Ruby version has been specified by your application, and passes your commands along to the correct Ruby installation.

### Understanding PATH

When you run a command like `ruby` or `rake`, your operating system searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

**Directories in `PATH` are searched from left to right**, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### Understanding Shims

rbenv works by inserting a directory of **_shims_** at the front of your `PATH`:

    ~/.rbenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called **_rehashing_**, rbenv maintains shims in that directory to match every Ruby command across every installed version of Ruby: `irb`, `gem`, `rake`, `rails`, `ruby`, and so on.

Shims are lightweight executables that simply pass your command along to rbenv. So with rbenv installed, when you run, say, `rake`, your operating system will do the following:

- Search your `PATH` for an executable file named `rake`
- Find the rbenv shim named `rake` at the beginning of your `PATH`
- Run the shim named `rake`, which in turn passes the command along to
  rbenv

### Choosing the Ruby Version

When you execute a shim, rbenv determines which Ruby version to use by reading it from the following sources, in this order:

1. The `RBENV_VERSION` environment variable, if specified. You can use the [`rbenv shell`](#rbenv-shell) command to set this environment variable in your current shell session.

2. The first `.ruby-version` file found by searching the directory of the script you are executing and each of its parent directories until reaching the root of your filesystem.

3. The first `.ruby-version` file found by searching the current working directory and each of its parent directories until reaching the root of your filesystem. You can modify the `.ruby-version` file in the current working directory with the [`rbenv local`](#rbenv-local) command.

4. The global `~/.rbenv/version` file. You can modify this file using the [`rbenv global`](#rbenv-global) command. If the global version file is not present, rbenv assumes you want to use the "system" Ruby, i.e. whatever version would be run if rbenv weren't in your path.

### Locating the Ruby Installation

Once rbenv has determined which version of Ruby your application has specified, it passes the command along to the corresponding Ruby installation.

Each Ruby version is installed into its own directory under `~/.rbenv/versions`. For example, you might have these versions installed:

- `~/.rbenv/versions/1.8.7-p371/`
- `~/.rbenv/versions/1.9.3-p327/`
- `~/.rbenv/versions/jruby-1.7.1/`

Version names to rbenv are simply the names of the directories in `~/.rbenv/versions`.
