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
  - [Advanced Configuration](#advanced-configuration)
    - [Using pyenv without shims](#using-pyenv-without-shims)
    - [Environment variables](#environment-variables)

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

## Advanced Configuration

Skip this section unless you must know what every line in your shell profile is doing.

`pyenv init` is the only command that crosses the line of loading extra commands into your shell. Coming from ~~RVM~~, some of you might be opposed to this idea.

Here's what **`eval "$(pyenv init -)"`** actually does:

> Note:
>  
> - **`eval "$(pyenv init --path)"`** only does items **1** and **3**.
> - To see exactly what happens under the hood for yourself, run `pyenv init -` or `pyenv init --path`.

1. **Sets up the shims path.** This is what allows pyenv to intercept and redirect invocations of `python`, `pip` etc. transparently. It prepends `$(pyenv root)/shims` to your `$PATH`. It also deletes any other instances of `$(pyenv root)/shims` on `PATH` which allows to invoke `eval "$(pyenv init -)"` multiple times without getting duplicate `PATH` entries.

2. **Installs autocompletion.** This is entirely optional but pretty useful. Sourcing ~~`$(pyenv root)/completions/pyenv.bash`~~ will set that up. There are also completions for Zsh and Fish.

3. **Rehashes shims.** From time to time you'll need to rebuild your shim files. Doing this on init makes sure everything is up to date. You can always run `pyenv rehash` manually.

4. **Installs `pyenv` into the current shell as a shell function.** This bit is also optional, but allows pyenv and plugins to change variables in your current shell. This is required for some commands like `pyenv shell` to work. The sh dispatcher doesn't do anything crazy like override `cd` or hack your shell prompt, but if for some reason you need `pyenv` to be a real script rather than a shell function, you can safely skip it.

- `eval "$(pyenv init -)"` is supposed to run at any interactive shell's startup (including nested shells -- e.g. those invoked from editors) so that you get completion and convenience shell functions.
- `eval "$(pyenv init --path)"` can be used instead of `eval "$(pyenv init -)"` to just enable shims, without shell integration. It can also be used to bump shims to the front of `PATH` after some other logic has prepended stuff to `PATH` that may shadow pyenv's shims.

### Using pyenv without shims

If you don't want to use `pyenv init` and shims, you can still benefit from pyenv's ability to install Python versions for you. Just run `pyenv install` and you will find versions installed in `$(pyenv root)/versions`.

You can manually execute or symlink them as required, or you can use [`pyenv exec <command>`](COMMANDS.md#pyenv-exec) whenever you want `<command>` to be affected by pyenv's version selection as currently configured.

`pyenv exec` works by prepending `$(pyenv root)/versions/<selected version>/bin` to `PATH` in the `<command>`'s environment, the same as what e.g. ~~RVM~~ does.

### Environment variables

You can affect how pyenv operates with the following environment variables:

name | default | description
-----|---------|------------
`PYENV_VERSION` | | Specifies the Python version to be used.<br>(Also see [`pyenv shell`](COMMANDS.md#pyenv-shell))
`PYENV_ROOT` | `~/.pyenv` | Defines the directory under which Python versions and shims reside.<br>(Also see [`pyenv root`](COMMANDS.md#pyenv-root))
`PYENV_DEBUG` | | Outputs debug information.<br>(Also as: `pyenv --debug <subcommand>`)
`PYENV_HOOK_PATH` | [*see wiki*][hooks] | Colon-separated list of paths searched for pyenv hooks.
`PYENV_DIR` | `$PWD` | Directory to start searching for `.python-version` files.
`PYTHON_BUILD_ARIA2_OPTS` | | Used to pass additional parameters to [`aria2`](https://aria2.github.io/).<br><br>If the `aria2c` binary is available on `PATH`, pyenv uses `aria2c` instead of `curl` or `wget` to download the Python Source code. If you have an unstable internet connection, you can use this variable to instruct `aria2` to accelerate the download.<br><br>In most cases, you will only need to use `-x 10 -k 1M` as value to `PYTHON_BUILD_ARIA2_OPTS` environment variable
