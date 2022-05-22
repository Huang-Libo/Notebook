# pyenv

- [pyenv](#pyenv)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Install Python build dependencies](#install-python-build-dependencies)
    - [Getting pyenv](#getting-pyenv)
      - [1. Homebrew in macOS](#1-homebrew-in-macos)
      - [2. Automatic installer](#2-automatic-installer)
    - [Upgrading](#upgrading)
    - [Set up your shell environment for pyenv](#set-up-your-shell-environment-for-pyenv)
  - [Usage](#usage)
    - [Install additional Python versions](#install-additional-python-versions)
    - [Switch between Python versions](#switch-between-python-versions)
    - [Uninstall Python versions](#uninstall-python-versions)
  - [Uninstalling pyenv](#uninstalling-pyenv)

## Overview

pyenv lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

This project was forked from [rbenv](https://github.com/rbenv/rbenv) and [ruby-build](https://github.com/rbenv/ruby-build), and modified for Python.

## Installation

### Install Python build dependencies

[**Install Python build dependencies**](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) before attempting to install a new Python version.

For macOS:

If you haven't done so, install Xcode Command Line Tools (`xcode-select --install`) and [Homebrew](http://brew.sh/). Then:

```sh
brew install openssl readline sqlite3 xz zlib tcl-tk
```

### Getting pyenv

#### 1. Homebrew in macOS

- Consider installing with [Homebrew](https://brew.sh):

    ```sh
    brew update
    brew install pyenv
    ```

- Then follow the rest of the post-installation steps, starting with  [Set up your shell environment for pyenv](#set-up-your-shell-environment-for-pyenv).

#### 2. Automatic installer

Visit our other project [pyenv-installer](https://github.com/pyenv/pyenv-installer).

### Upgrading

If you've installed pyenv using Homebrew, upgrade using:

```sh
brew upgrade pyenv
```

### Set up your shell environment for pyenv

- (*Optional*) Define environment variable `PYENV_ROOT` to point to the path where pyenv will store its data. `$HOME/.pyenv` is the default.
- (*Optional*) Add the `pyenv` executable to your `PATH` if it's not already there
- (**Important**) run **`eval "$(pyenv init -)"`** to install `pyenv` into your shell as a shell function, enable shims and autocompletion
  - (*Optional*) You may run `eval "$(pyenv init --path)"` instead to just enable shims, without shell integration

The below setup should work for the vast majority of users for common use cases.

> See [Advanced configuration](#advanced-configuration) for details and more configuration options.

- For **Zsh**:

    ```zsh
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    ```

  If you wish to get pyenv in *non-interactive login shells* as well, also add the commands to `~/.zprofile` or `~/.zlogin`.

 **Proxy note**: If you use a proxy, export `http_proxy` and `https_proxy`, too.

## Usage

### Install additional Python versions

To install additional Python versions, use `pyenv install`.

For example, to download and install Python 3.10.4, run:

```sh
pyenv install 3.10.4
```

**NOTE:** Most pyenv-provided Python releases are source releases and are built from source as part of installation (that's why you need Python build dependencies preinstalled).

### Switch between Python versions

To select a pyenv-installed Python as the version to use, run one
of the following commands:

- [`pyenv shell <version>`](COMMANDS.md#pyenv-shell) -- select just for current shell session
- [`pyenv local <version>`](COMMANDS.md#pyenv-local) -- automatically select whenever you are in the current directory (or its subdirectories)
- [`pyenv global <version>`](COMMANDS.md#pyenv-shell) -- select globally for your user account

E.g. to select the above-mentioned newly-installed Python 3.10.4 as your preferred version to use:

```bash
pyenv global 3.10.4
```

Now whenever you invoke `python`, `pip` etc., an executable from the pyenv-provided 3.10.4 installation will be run instead of the system Python.

Using "`system`" as a version name would reset the selection to your system-provided Python.

### Uninstall Python versions

As time goes on, you will accumulate Python versions in your `$(pyenv root)/versions` directory.

- To remove old Python versions, use `pyenv uninstall <version>`.
- Alternatively, you can simply `rm -rf` the directory of the version you want to remove. You can find the directory of a particular Python version with the `pyenv prefix` command, e.g. `pyenv prefix 2.6.8`. Note however that plugins may run additional operations on uninstall which you would need to do by hand as well. E.g. pyenv-Virtualenv also removes any virtual environments linked to the version being uninstalled.

## Uninstalling pyenv

The simplicity of pyenv makes it easy to temporarily disable it, or uninstall from the system.

1. To **disable** pyenv managing your Python versions, simply remove the
  `pyenv init` invocations from your shell startup configuration. This will remove *pyenv shims* directory from `PATH`, and future invocations like `python` will execute the system Python version, as it was before pyenv.

    (`pyenv` will still be accessible on the command line, but your Python apps won't be affected by version switching.)

2. To completely **uninstall** pyenv, remove *all* pyenv configuration lines from your shell startup configuration, and then remove its root directory. This will **delete all Python versions** that were installed under the `$(pyenv root)/versions/` directory:

    ```sh
    rm -rf $(pyenv root)
    ```

    If you've installed pyenv using a package manager, as a final step, perform the pyenv package removal. For instance, for Homebrew:

    ```sh
    brew uninstall pyenv
    ```
