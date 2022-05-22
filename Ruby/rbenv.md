# rbenv

- [rbenv](#rbenv)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Using Package Managers](#using-package-managers)
    - [How rbenv hooks into your shell](#how-rbenv-hooks-into-your-shell)
    - [Installing Ruby versions](#installing-ruby-versions)
      - [Installing Ruby gems](#installing-ruby-gems)
    - [Uninstalling Ruby versions](#uninstalling-ruby-versions)
    - [Uninstalling rbenv](#uninstalling-rbenv)
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

## Installation

**Compatibility note**: rbenv is *incompatible* with RVM. Please make  sure to fully uninstall RVM and remove any references to it from your shell initialization files before installing rbenv.

### Using Package Managers

1. On macOS, we recommend installing rbenv with [Homebrew](https://brew.sh).

    ```sh
    brew install rbenv ruby-build
    ```

2. Set up rbenv in your shell.

    ```sh
    rbenv init
    ```

    Follow the printed instructions to [set up rbenv shell integration](#how-rbenv-hooks-into-your-shell).

3. Close your Terminal window and open a new one so your changes take effect.

4. Verify that rbenv is properly set up using this [rbenv-doctor](https://github.com/rbenv/rbenv-installer/blob/main/bin/rbenv-doctor) script:

    ```sh
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash
    ```

    ```sh
    Checking for `rbenv' in PATH: /usr/local/bin/rbenv
    Checking for rbenv shims in PATH: OK
    Checking `rbenv install' support: /usr/local/bin/rbenv-install (ruby-build 20170523)
    Counting installed Ruby versions: none
      There aren't any Ruby versions installed under `~/.rbenv/versions'.
      You can install Ruby versions like so: rbenv install 2.2.4
    Checking RubyGems settings: OK
    Auditing installed plugins: OK
    ```

5. That's it! Installing *rbenv* includes *ruby-build*, so now you're ready to [install some Ruby versions](#installing-ruby-versions) using `rbenv install`.

### How rbenv hooks into your shell

Skip this section unless you must know what every line in your shell profile is doing.

`rbenv init` is the only command that crosses the line of loading extra commands into your shell. Coming from RVM, some of you might be opposed to this idea. Here's what `rbenv init` actually does:

1. Sets up your shims path. This is the only requirement for rbenv to function properly. You can do this by hand by prepending `~/.rbenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty useful. Sourcing `~/.rbenv/completions/rbenv.bash` will set that up. There is also a `~/.rbenv/completions/rbenv.zsh` for Zsh users.

3. Rehashes shims. From time to time you'll need to rebuild your shim files. Doing this automatically makes sure everything is up to date. You can always run `rbenv rehash` manually.

4. Installs the *sh dispatcher*. This bit is also optional, but allows rbenv and plugins to change variables in your current shell, making commands like `rbenv shell` possible. *The sh dispatcher* doesn't do anything invasive like override `cd` or hack your shell prompt, but if for some reason you need `rbenv` to be a real script rather than a shell function, you can safely skip it.

Run `rbenv init -` for yourself to see exactly what happens under the hood.

### Installing Ruby versions

The `rbenv install` command doesn't ship with rbenv out of the box, but is provided by the [ruby-build][] project. If you installed it either as part of GitHub checkout process outlined above or via Homebrew, you should be able to:

```sh
# list latest stable versions:
rbenv install -l

# list all local versions:
rbenv install -L

# install a Ruby version:
rbenv install 2.0.0-p247

# List installed Ruby versions
rbenv versions
```

Set a Ruby version to finish installation and start using commands `rbenv global 2.0.0-p247` or `rbenv local 2.0.0-p247`

Alternatively to the `install` command, you can download and compile Ruby manually as a subdirectory of `~/.rbenv/versions/`. An entry in that directory can also be a symlink to a Ruby version installed elsewhere on the filesystem. rbenv doesn't care; it will simply treat any entry in the `versions/` directory as a separate Ruby version.

#### Installing Ruby gems

Once you've installed some Ruby versions, you'll want to install gems.

First, ensure that the target version for your project is the one you want by checking `rbenv version` (see [Command Reference](#command-reference)). Select another version using `rbenv local 2.0.0-p247`, for example. Then, proceed to install gems as you normally would:

```sh
gem install bundler
```

**You don't need `sudo`** to install gems. Typically, the Ruby versions will be installed and writeable by your user. No extra privileges are required to install gems.

Check the location where gems are being installed with `gem env`:

```sh
gem env home
# => ~/.rbenv/versions/<ruby-version>/lib/ruby/gems/...
```

### Uninstalling Ruby versions

As time goes on, Ruby versions you install will accumulate in your `~/.rbenv/versions` directory.

To remove old Ruby versions, simply `rm -rf` the directory of the version you want to remove. You can find the directory of a particular Ruby version with the `rbenv prefix` command, e.g. `rbenv prefix 1.8.7-p357`.

The [ruby-build][] plugin provides an `rbenv uninstall` command to automate the removal process.

### Uninstalling rbenv

The simplicity of rbenv makes it easy to temporarily disable it, or uninstall from the system.

1. To **disable** rbenv managing your Ruby versions, simply remove the `rbenv init` line from your shell startup configuration. This will remove rbenv shims directory from PATH, and future invocations like `ruby` will execute the system Ruby version, as before rbenv.

    While disabled, `rbenv` will still be accessible on the command line, but your Ruby apps won't be affected by version switching.

2. To completely **uninstall** rbenv, perform step (1) and then remove its root directory. This will **delete all Ruby versions** that were installed under `` `rbenv root`/versions/ `` directory:

    ```sh
    rm -rf `rbenv root`
    ```

   If you've installed rbenv using a package manager, as a final step perform the rbenv package removal:
   - Homebrew: `brew uninstall rbenv`
   - Debian, Ubuntu, and their derivatives: `sudo apt purge rbenv`
   - Arch linux and its derivatives: `sudo pacman -R rbenv`

## How It Works

At a high level, rbenv intercepts Ruby commands using **shim** executables injected into your `PATH`, determines which Ruby version has been specified by your application, and passes your commands along to the correct Ruby installation.

### Understanding PATH

When you run a command like `ruby` or `rake`, your operating system searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

```plaintext
/usr/local/bin:/usr/bin:/bin
```

**Directories in `PATH` are searched from left to right**, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### Understanding Shims

rbenv works by inserting a directory of **shims** at the front of your `PATH`:

```plaintext
~/.rbenv/shims:/usr/local/bin:/usr/bin:/bin
```

Through a process called **rehashing**, rbenv maintains shims in that directory to match every Ruby command across every installed version of Ruby: `irb`, `gem`, `rake`, `rails`, `ruby`, and so on.

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

[ruby-build]: https://github.com/rbenv/ruby-build#readme
[hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks