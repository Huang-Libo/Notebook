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
  - [How It Works](#how-it-works)
    - [Understanding PATH](#understanding-path)
    - [Understanding Shims](#understanding-shims)
    - [Understanding Python version selection](#understanding-python-version-selection)
    - [Locating pyenv-provided Python installations](#locating-pyenv-provided-python-installations)
  - [Compare with other version tools](#compare-with-other-version-tools)
    - [What pyenv *does...*](#what-pyenv-does)
    - [In contrast with pythonbrew and pythonz, pyenv *does not...*](#in-contrast-with-pythonbrew-and-pythonz-pyenv-does-not)
  - [Development](#development)

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

## How It Works

At a high level, pyenv intercepts Python commands using shim executables injected into your `PATH`, determines which Python version has been specified by your application, and passes your commands along to the correct Python installation.

### Understanding PATH

When you run a command like `python` or `pip`, your operating system searches through a list of directories to find an executable file with that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

```plaintext
/usr/local/bin:/usr/bin:/bin
```

**Directories in `PATH` are searched from left to right**, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### Understanding Shims

pyenv works by inserting a directory of *shims* at the **front** of your `PATH`:

```plaintext
$(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin
```

Through a process called *rehashing*, pyenv maintains shims in that directory to match every Python command across every installed version of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along to pyenv. So with pyenv installed, when you run, say, `pip`, your operating system will do the following:

- Search your `PATH` for an executable file named `pip`
- Find the pyenv shim named `pip` at the beginning of your `PATH`
- Run the shim named `pip`, which in turn passes the command along to   pyenv

### Understanding Python version selection

When you execute a shim, pyenv determines which Python version to use by reading it from the following sources, in this order:

1. The `PYENV_VERSION` environment variable (if specified). You can use the [`pyenv shell`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-shell) command to set this environment variable in your *current shell session*.

2. The *application-specific* `.python-version` file in the current directory (if present). You can modify the current directory's `.python-version` file with the [`pyenv local`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-local) command.

3. The first `.python-version` file found (if any) by searching each parent directory, until reaching the root of your filesystem.

4. The *global* `$(pyenv root)/version` file. You can modify this file using the [`pyenv global`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-global) command. If the global version file is not present, pyenv assumes you want to use the "`system`" Python (see below).

A special version name "`system`" means to use whatever Python is found on `PATH` after the shims `PATH` entry (in other words, whatever would be run if pyenv shims weren't on `PATH`). Note that pyenv considers those installations outside its control and does not attempt to inspect or distinguish them in any way.

So e.g. if you are on MacOS and have *OS-bundled Python 3.8.9* and *Homebrew-installed Python 3.9.12 and 3.10.2* -- for pyenv, this is still a single "`system`" version, and **whichever of those is first on `PATH` under the executable name you specified will be run.**

**NOTE:**

- **You can activate multiple versions at the same time**, including multiple versions of Python2 or Python3 simultaneously. This allows for parallel usage of Python2 and Python3, and is required with tools like `tox`.
- For example, to instruct pyenv to first use your system Python and Python3 (which are e.g. 2.7.9 and 3.4.2) but also have Python 3.3.6, 3.2.1, and 2.5.2 available, you first `pyenv install` the missing versions,
  - then set **`pyenv global system 3.3.6 3.2.1 2.5.2`**. Then you'll be able to invoke any of those versions with an appropriate `pythonX` or `pythonX.Y` name.
  - **You can also specify multiple versions in a `.python-version` file by hand, separated by newlines.** Lines starting with a `#` are ignored.

`pyenv which <command>` displays which real executable would be run when you invoke `<command>` via a shim. E.g. if you have 3.3.6, 3.2.1 and 2.5.2 installed of which 3.3.6 and 2.5.2 are selected and your system Python is 3.2.5, `pyenv which python2.5` should display `$(pyenv root)/versions/2.5.2/bin/python2.5`, `pyenv which python3` -- `$(pyenv root)/versions/3.3.6/bin/python3` and `pyenv which python3.2` -- path to your system Python due to the fall-through (see below).

Shims also fall through to anything further on `PATH` if the corresponding executable is not present in any of the selected Python installations.

This allows you to use any programs installed elsewhere on the system as long as they are not shadowed by a selected Python installation.

### Locating pyenv-provided Python installations

Once pyenv has determined which version of Python your application has specified, it passes the command along to the corresponding Python installation.

Each Python version is installed into its own directory under `$(pyenv root)/versions`.

For example, you might have these versions installed:

- `$(pyenv root)/versions/2.7.8/`
- `$(pyenv root)/versions/3.4.2/`
- `$(pyenv root)/versions/pypy-2.4.0/`

As far as pyenv is concerned, version names are simply directories under `$(pyenv root)/versions`.

## Compare with other version tools

### What pyenv *does...*

- Lets you **change the global Python version** on a per-user basis.
- Provides support for **per-project Python versions**.
- Allows you to **override the Python version** with an environment   variable.
- Searches for commands from **multiple versions of Python at a time**. This may be helpful to test across Python versions with [tox](https://pypi.python.org/pypi/tox).

### In contrast with pythonbrew and pythonz, pyenv *does not...*

- **Depend on Python itself.** pyenv was made from pure shell scripts. There is no bootstrap problem of Python.
- **Need to be loaded into your shell.** Instead, pyenv's shim approach works by adding a directory to your `PATH`.
- **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv) yourself, or [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) to automate the process.

## Development

The pyenv source code is [hosted on GitHub](https://github.com/pyenv/pyenv).  It's clean, modular, and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/bats-core/bats-core):

```sh
bats test
bats/test/<file>.bats
```

[pyenv-virtualenv]: https://github.com/pyenv/pyenv-virtualenv#readme
[hooks]: https://github.com/pyenv/pyenv/wiki/Authoring-plugins#pyenv-hooks
