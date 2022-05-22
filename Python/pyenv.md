# pyenv

- [pyenv](#pyenv)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Install Python build dependencies](#install-python-build-dependencies)
    - [Getting Pyenv](#getting-pyenv)
      - [1. Homebrew in macOS](#1-homebrew-in-macos)
      - [2. Automatic installer](#2-automatic-installer)
    - [Set up your shell environment for Pyenv](#set-up-your-shell-environment-for-pyenv)

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

### Getting Pyenv

#### 1. Homebrew in macOS

- Consider installing with [Homebrew](https://brew.sh):

    ```sh
    brew update
    brew install pyenv
    ```

- Then follow the rest of the post-installation steps, starting with  [Set up your shell environment for Pyenv](#set-up-your-shell-environment-for-pyenv).

#### 2. Automatic installer

Visit our other project [pyenv-installer](https://github.com/pyenv/pyenv-installer).

### Set up your shell environment for Pyenv

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
