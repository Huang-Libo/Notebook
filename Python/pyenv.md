# pyenv <!-- omit in toc -->

- [1. Overview](#1-overview)
- [2. Installation](#2-installation)
  - [2.1. Install Python build dependencies](#21-install-python-build-dependencies)
  - [2.2. Getting pyenv](#22-getting-pyenv)
    - [2.2.1. Homebrew in macOS](#221-homebrew-in-macos)
    - [2.2.2. Automatic installer](#222-automatic-installer)
  - [2.3. Upgrading](#23-upgrading)
  - [2.4. Set up your shell environment for pyenv](#24-set-up-your-shell-environment-for-pyenv)
- [3. Usage](#3-usage)
  - [3.1. Install additional Python versions](#31-install-additional-python-versions)
  - [3.2. Switch between Python versions](#32-switch-between-python-versions)
  - [3.3. Uninstall Python versions](#33-uninstall-python-versions)
- [4. Uninstalling pyenv](#4-uninstalling-pyenv)
- [5. Advanced Configuration](#5-advanced-configuration)
  - [5.1. Using pyenv without shims](#51-using-pyenv-without-shims)
  - [5.2. Environment variables](#52-environment-variables)
- [6. How It Works](#6-how-it-works)
  - [6.1. Understanding PATH](#61-understanding-path)
  - [6.2. Understanding Shims](#62-understanding-shims)
  - [6.3. Understanding Python version selection](#63-understanding-python-version-selection)
  - [6.4. Locating pyenv-provided Python installations](#64-locating-pyenv-provided-python-installations)
- [7. Command Reference](#7-command-reference)
  - [7.1. `pyenv global`](#71-pyenv-global)
    - [7.1.1. `pyenv global` (advanced)](#711-pyenv-global-advanced)
  - [7.2. `pyenv local`](#72-pyenv-local)
    - [7.2.1. `pyenv local` (advanced)](#721-pyenv-local-advanced)
  - [7.3. `pyenv shell`](#73-pyenv-shell)
    - [7.3.1. Set `PYENV_VERSION` Manually](#731-set-pyenv_version-manually)
    - [7.3.2. `pyenv shell` (advanced)](#732-pyenv-shell-advanced)
  - [7.4. `pyenv install`](#74-pyenv-install)
  - [7.5. `pyenv uninstall`](#75-pyenv-uninstall)
  - [7.6. `pyenv rehash`](#76-pyenv-rehash)
  - [7.7. `pyenv version`](#77-pyenv-version)
  - [7.8. `pyenv versions`](#78-pyenv-versions)
  - [7.9. `pyenv which`](#79-pyenv-which)
  - [7.10. `pyenv whence`](#710-pyenv-whence)
  - [7.11. `pyenv exec`](#711-pyenv-exec)
  - [7.12. `pyenv root`](#712-pyenv-root)
  - [7.13. `pyenv prefix`](#713-pyenv-prefix)
  - [7.14. `pyenv hooks`](#714-pyenv-hooks)
  - [7.15. `pyenv shims`](#715-pyenv-shims)
  - [7.16. `pyenv init`](#716-pyenv-init)
  - [7.17. `pyenv completions`](#717-pyenv-completions)
- [8. Compare with other version tools](#8-compare-with-other-version-tools)
  - [8.1. What pyenv *does...*](#81-what-pyenv-does)
  - [8.2. In contrast with pythonbrew and pythonz, pyenv *does not...*](#82-in-contrast-with-pythonbrew-and-pythonz-pyenv-does-not)
- [9. Development](#9-development)

## 1. Overview

[pyenv](https://github.com/pyenv/pyenv) lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

This project was forked from [rbenv](https://github.com/rbenv/rbenv) and [ruby-build](https://github.com/rbenv/ruby-build), and modified for Python.

## 2. Installation

### 2.1. Install Python build dependencies

[**Install Python build dependencies**](https://github.com/pyenv/pyenv/wiki#suggested-build-environment) before attempting to install a new Python version.

For macOS:

If you haven't done so, install Xcode Command Line Tools (`xcode-select --install`) and [Homebrew](http://brew.sh/). Then:

```sh
brew install openssl readline sqlite3 xz zlib tcl-tk
```

### 2.2. Getting pyenv

#### 2.2.1. Homebrew in macOS

- Consider installing with [Homebrew](https://brew.sh):

    ```sh
    brew update
    brew install pyenv
    ```

- Then follow the rest of the post-installation steps, starting with  [Set up your shell environment for pyenv](#24-set-up-your-shell-environment-for-pyenv).

#### 2.2.2. Automatic installer

Visit our other project [pyenv-installer](https://github.com/pyenv/pyenv-installer).

### 2.3. Upgrading

If you've installed pyenv using Homebrew, upgrade using:

```sh
brew upgrade pyenv
```

### 2.4. Set up your shell environment for pyenv

- (*Optional*) Define environment variable `PYENV_ROOT` to point to the path where pyenv will store its data. `$HOME/.pyenv` is the default.
- (*Optional*) Add the `pyenv` executable to your `PATH` if it's not already there
- (**Important**) run **`eval "$(pyenv init -)"`** to install `pyenv` into your shell as a shell function, enable shims and autocompletion
  - (*Optional*) You may run `eval "$(pyenv init --path)"` instead to just enable shims, without shell integration

The below setup should work for the vast majority of users for common use cases.

> See [Advanced configuration](#5-advanced-configuration) for details and more configuration options.

- For **Zsh**:

    ```zsh
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    ```

  If you wish to get pyenv in *non-interactive login shells* as well, also add the commands to `~/.zprofile` or `~/.zlogin`.

 **Proxy note**: If you use a proxy, export `http_proxy` and `https_proxy`, too.

## 3. Usage

### 3.1. Install additional Python versions

To search standard python only:

```sh
pyenv install -l | grep "^[^a-z]*$"
```

To install additional Python versions, use `pyenv install`.

For example, to download and install Python 3.11.4, run:

```sh
pyenv install 3.11.4
```

**NOTE:** Most pyenv-provided Python releases are source releases and are built from source as part of installation (that's why you need Python build dependencies preinstalled).

To install the latest version of Python without giving a specific version use the `:latest` syntax.

- For example, to install the latest patch version for Python `3.8` you could do:

```sh
pyenv install 3.8:latest
```

- To install the latest major release for Python `3` try:

```sh
pyenv install 3:latest
```

### 3.2. Switch between Python versions

To select a pyenv-installed Python as the version to use, run one
of the following commands:

- [`pyenv shell <version>`](COMMANDS.md#pyenv-shell) -- select just for current shell session
- [`pyenv local <version>`](COMMANDS.md#pyenv-local) -- automatically select whenever you are in the current directory (or its subdirectories)
- [`pyenv global <version>`](COMMANDS.md#pyenv-shell) -- select globally for your user account

E.g. to select the above-mentioned newly-installed Python 3.11.4 as your preferred version to use:

```bash
pyenv global 3.11.4
```

Now whenever you invoke `python`, `pip` etc., an executable from the pyenv-provided 3.11.4 installation will be run instead of the system Python.

Using "`system`" as a version name would reset the selection to your system-provided Python.

If you want to use multiple python versions in shell, you can specify the versions in sequence:

```sh
pyenv global 3.11.4 2.7.18
```

For the scenario above,

- `python` command will use *3.11.4* version;
- `python3`/`python3.11`/`python3.11.4` commands will all use *3.11.4* version;
- `python2`/`python2.7`/`python2.18` commands will use *2.7.18* version.

**Note**: You can specify multiple versions with `pyenv global` and invoke them by the specific version number, e.g. `pythonX` or `pythonX.Y` or `pythonX.Y.Z` name.

### 3.3. Uninstall Python versions

As time goes on, you will accumulate Python versions in your `$(pyenv root)/versions` directory.

- To remove old Python versions, use `pyenv uninstall <version>`.
- Alternatively, you can simply `rm -rf` the directory of the version you want to remove. You can find the directory of a particular Python version with the `pyenv prefix` command, e.g. `pyenv prefix 2.6.8`. Note however that plugins may run additional operations on uninstall which you would need to do by hand as well. E.g. pyenv-Virtualenv also removes any virtual environments linked to the version being uninstalled.

## 4. Uninstalling pyenv

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

## 5. Advanced Configuration

Skip this section unless you must know what every line in your shell profile is doing.

`pyenv init` is the only command that *crosses* the line of loading extra commands into your shell. Coming from RVM, some of you might be opposed to this idea.

**Here's what `eval "$(pyenv init -)"` actually does**:

1. **Sets up the shims path.** This is what allows pyenv to intercept and redirect invocations of `python`, `pip` etc. transparently. It prepends `$(pyenv root)/shims` to your `$PATH`. It also deletes any other instances of `$(pyenv root)/shims` on `PATH` which allows to invoke `eval "$(pyenv init -)"` multiple times without getting duplicate `PATH` entries.

2. **Installs autocompletion.** This is entirely optional but pretty useful. Sourcing `$(pyenv root)/completions/pyenv.bash` will set that up. There are also completions for Zsh and Fish.

3. **Rehashes shims.** From time to time you'll need to rebuild your shim files. Doing this on init makes sure everything is up to date. You can always run `pyenv rehash` manually.

4. **Installs `pyenv` into the current shell as a shell function.** This bit is also optional, but allows pyenv and plugins to change variables in your current shell. This is required for some commands like `pyenv shell` to work. The sh dispatcher doesn't do anything crazy like override `cd` or hack your shell prompt, but if for some reason you need `pyenv` to be a real script rather than a shell function, you can safely skip it.

**Note**:

- **`eval "$(pyenv init --path)"`** only does items **1** and **3**.
- To see exactly what happens under the hood for yourself, run `pyenv init -` or `pyenv init --path`.
- `eval "$(pyenv init -)"` is supposed to run at any interactive shell's startup (including nested shells -- e.g. those invoked from editors) so that you get completion and convenience shell functions.
- `eval "$(pyenv init --path)"` can be used instead of `eval "$(pyenv init -)"` to just enable shims, *without shell integration*. It can also be used to bump shims to the front of `PATH` after some other logic has prepended stuff to `PATH` that may shadow pyenv's shims.

### 5.1. Using pyenv without shims

If you don't want to use `pyenv init` and shims, you can still benefit from pyenv's ability to install Python versions for you. Just run `pyenv install` and you will find versions installed in `$(pyenv root)/versions`.

You can manually execute or symlink them as required, or you can use [`pyenv exec <command>`](COMMANDS.md#pyenv-exec) whenever you want `<command>` to be affected by pyenv's version selection as currently configured.

`pyenv exec` works by prepending `$(pyenv root)/versions/<selected version>/bin` to `PATH` in the `<command>`'s environment, the same as what e.g. RVM does.

### 5.2. Environment variables

You can affect how pyenv operates with the following environment variables:

name | default | description
-----|---------|------------
`PYENV_VERSION` | | Specifies the Python version to be used.<br>(Also see [`pyenv shell`](COMMANDS.md#pyenv-shell))
`PYENV_ROOT` | `~/.pyenv` | Defines the directory under which Python versions and shims reside.<br>(Also see [`pyenv root`](COMMANDS.md#pyenv-root))
`PYENV_DEBUG` | | Outputs debug information.<br>(Also as: `pyenv --debug <subcommand>`)
`PYENV_HOOK_PATH` | [*see wiki*][hooks] | Colon-separated list of paths searched for pyenv hooks.
`PYENV_DIR` | `$PWD` | Directory to start searching for `.python-version` files.
`PYTHON_BUILD_ARIA2_OPTS` | | Used to pass additional parameters to [`aria2`](https://aria2.github.io/).<br><br>If the `aria2c` binary is available on `PATH`, pyenv uses `aria2c` instead of `curl` or `wget` to download the Python Source code. If you have an unstable internet connection, you can use this variable to instruct `aria2` to accelerate the download.<br><br>In most cases, you will only need to use `-x 10 -k 1M` as value to `PYTHON_BUILD_ARIA2_OPTS` environment variable

## 6. How It Works

At a high level, pyenv intercepts Python commands using shim executables injected into your `PATH`, determines which Python version has been specified by your application, and passes your commands along to the correct Python installation.

### 6.1. Understanding PATH

When you run a command like `python` or `pip`, your operating system searches through a list of directories to find an executable file with that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

```plaintext
/usr/local/bin:/usr/bin:/bin
```

**Directories in `PATH` are searched from left to right**, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### 6.2. Understanding Shims

pyenv works by inserting a directory of *shims* at the **front** of your `PATH`:

```plaintext
$(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin
```

Through a process called *rehashing*, pyenv maintains shims in that directory to match every Python command across every installed version of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along to pyenv. So with pyenv installed, when you run, say, `pip`, your operating system will do the following:

- Search your `PATH` for an executable file named `pip`
- Find the pyenv shim named `pip` at the beginning of your `PATH`
- Run the shim named `pip`, which in turn passes the command along to   pyenv

### 6.3. Understanding Python version selection

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

`pyenv which <command>` displays which **real** executable would be run when you invoke `<command>` via a shim.

E.g. if you have 3.3.6, 3.2.1 and 2.5.2 installed of which 3.3.6 and 2.5.2 are selected and your system Python is 3.2.5, `pyenv which python2.5` should display `$(pyenv root)/versions/2.5.2/bin/python2.5`, `pyenv which python3` -- `$(pyenv root)/versions/3.3.6/bin/python3` and `pyenv which python3.2` -- path to your system Python due to the fall-through (see below).

Shims also fall through to anything further on `PATH` if the corresponding executable is not present in any of the selected Python installations.

This allows you to use any programs installed elsewhere on the system as long as they are not shadowed by a selected Python installation.

### 6.4. Locating pyenv-provided Python installations

Once pyenv has determined which version of Python your application has specified, it passes the command along to the corresponding Python installation.

Each Python version is installed into its own directory under `$(pyenv root)/versions`.

For example, you might have these versions installed:

- `$(pyenv root)/versions/2.7.8/`
- `$(pyenv root)/versions/3.4.2/`
- `$(pyenv root)/versions/pypy-2.4.0/`

As far as pyenv is concerned, version names are simply directories under `$(pyenv root)/versions`.

## 7. Command Reference

Like `git`, the `pyenv` command delegates to subcommands based on its
first argument.

### 7.1. `pyenv global`

Sets the global version of Python to be used in all shells by writing the version name to the `~/.pyenv/version` file. This version can be overridden by an *application-specific* `.python-version` file, or by setting the `PYENV_VERSION` environment variable.

```sh
pyenv global 3.11.4
```

The special version name `system` tells pyenv to use the system Python (detected by searching your `$PATH`).

**Note**: When running without a version number, `pyenv global` prints the currently configured global version.

#### 7.1.1. `pyenv global` (advanced)

You can specify multiple versions as global Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

```sh
$ pyenv global 2.7.6 3.3.3

$ pyenv versions
  system
* 2.7.6 (set by /Users/<name>/.pyenv/version)
* 3.3.3 (set by /Users/<name>/.pyenv/version)

$ python --version
Python 2.7.6

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

or, if you prefer 3.3.3 over 2.7.6,

```sh
$ pyenv global 3.3.3 2.7.6

$ pyenv versions
  system
* 2.7.6 (set by /Users/<name>/.pyenv/version)
* 3.3.3 (set by /Users/<name>/.pyenv/version)
  venv27

$ python --version
Python 3.3.3

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

### 7.2. `pyenv local`

Sets a *local application-specific* Python version by writing the version name to a `.python-version` file in the current directory. This version overrides the *global* version, and can be overridden itself by setting the `PYENV_VERSION` environment variable or with the `pyenv shell` command.

```sh
pyenv local 2.7.6
```

**Note**: When run without a version number, `pyenv local` prints the currently configured local version.

You can also **unset** the local version:

```sh
pyenv local --unset
```

#### 7.2.1. `pyenv local` (advanced)

You can specify multiple versions as local Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

```sh
$ pyenv local 2.7.6 3.3.3

$ pyenv versions
  system
* 2.7.6 (set by /Users/<name>/path/to/project/.python-version)
* 3.3.3 (set by /Users/<name>/path/to/project/.python-version)
    
$ python --version
Python 2.7.6

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

or, if you prefer 3.3.3 over 2.7.6,

```sh
$ pyenv local 3.3.3 2.7.6

$ pyenv versions
  system
* 2.7.6 (set by /Users/<name>/path/to/project/.python-version)
* 3.3.3 (set by /Users/<name>/path/to/project/.python-version)
  venv27

$ python --version
Python 3.3.3

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

### 7.3. `pyenv shell`

Sets a *shell-specific* Python version by setting the `PYENV_VERSION` environment variable in your shell. This version overrides *application-specific* versions and the *global version*. (Priority level: `pyenv shell` > `pyenv local` > `pyenv global`)

```sh
pyenv shell pypy-2.2.1
```

**Note**: When run without a version number, `pyenv shell` prints the current value of `PYENV_VERSION`.

You can also **unset** the shell version:

```sh
pyenv shell --unset
```

#### 7.3.1. Set `PYENV_VERSION` Manually

Note that you'll need pyenv's shell integration enabled (step 3 of the installation instructions) in order to use this command. If you prefer not to use shell integration, you may simply set the `PYENV_VERSION` variable yourself:

```sh
export PYENV_VERSION=pypy-2.2.1
```

And also **unset** it manually:

```bash
unset PYENV_VERSION
```

#### 7.3.2. `pyenv shell` (advanced)

You can specify multiple versions via `PYENV_VERSION` at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

```sh
$ pyenv shell 2.7.6 3.3.3
$ pyenv versions
  system
* 2.7.6 (set by PYENV_VERSION environment variable)
* 3.3.3 (set by PYENV_VERSION environment variable)

$ python --version
Python 2.7.6

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

or, if you prefer 3.3.3 over 2.7.6,

```sh
$ pyenv shell 3.3.3 2.7.6

$ pyenv versions
  system
* 2.7.6 (set by PYENV_VERSION environment variable)
* 3.3.3 (set by PYENV_VERSION environment variable)
  venv27

$ python --version
Python 3.3.3

$ python2.7 --version
Python 2.7.6

$ python3.3 --version
Python 3.3.3
```

### 7.4. `pyenv install`

Install a Python version (using [`python-build`](https://github.com/pyenv/pyenv/tree/master/plugins/python-build)).

```sh
Usage: pyenv install [-f] [-kvp] <version>
       pyenv install [-f] [-kvp] <definition-file>
       pyenv install -l|--list

    -l/--list             List all available versions
    -f/--force            Install even if the version appears to be installed already
    -s/--skip-existing    Skip the installation if the version appears to be installed already

    python-build options:

    -k/--keep        Keep source tree in $PYENV_BUILD_ROOT after installation
                    (defaults to $PYENV_ROOT/sources)
    -v/--verbose     Verbose mode: print compilation status to stdout
    -p/--patch       Apply a patch from stdin before building
    -g/--debug       Build a debug version
```

To list the all available versions of Python, including *Anaconda*, *Jython*, *pypy*, and *stackless*, use:

```sh
$ pyenv install --list

Then install the desired versions:

$ pyenv install 2.7.6

$ pyenv install 2.6.8

$ pyenv versions
  system
  2.6.8
* 2.7.6 (set by /home/<name>/.pyenv/version)
```

To install the latest version of Python without giving a specific version use the `:latest` syntax.

- For example, to install the latest patch version for Python `3.8` you could do:

```sh
pyenv install 3.8:latest
```

- To install the latest major release for Python `3` try:

```sh
pyenv install 3:latest
```

### 7.5. `pyenv uninstall`

Uninstall a specific Python version.

```sh
Usage: pyenv uninstall [-f|--force] <version>

    -f  Attempt to remove the specified version without prompting
        for confirmation. If the version does not exist, do not
        display an error message.
```

### 7.6. `pyenv rehash`

Installs *shims* for all Python binaries known to pyenv (i.e., `~/.pyenv/versions/*/bin/*`). Run this command after you install a new version of Python, or install a package that provides binaries.

```sh
pyenv rehash
```

### 7.7. `pyenv version`

Displays the currently active Python version, along with information on how it was set.

```sh
$ pyenv version
2.7.6 (set by /home/<name>/.pyenv/version)
```

### 7.8. `pyenv versions`

Lists all Python versions known to pyenv, and shows an asterisk next to the currently active version.

```sh
$ pyenv versions
    2.5.6
    2.6.8
  * 2.7.6 (set by /home/<name>/.pyenv/version)
    3.3.3
    jython-2.5.3
    pypy-2.2.1
```

### 7.9. `pyenv which`

Displays the *full* path to the executable that pyenv will invoke when you run the given command.

```sh
$ pyenv which python3.3
/home/<name>/.pyenv/versions/3.3.3/bin/python3.3
```

Use `--nosystem` argument in case when you don't need to search command in the system environment.

### 7.10. `pyenv whence`

Lists all Python versions with the given command installed.

```sh
$ pyenv whence 2to3
2.6.8
2.7.6
3.3.3
```

### 7.11. `pyenv exec`

```sh
Usage: pyenv exec <command> [arg1 arg2...]
```

Runs an executable by first preparing `PATH` so that the selected Python version's `bin` directory is at the front.

For example, if the currently selected Python version is 3.9.7:

```sh
pyenv exec pip install -r requirements.txt
```

is equivalent to:

```sh
PATH="$PYENV_ROOT/versions/3.9.7/bin:$PATH" pip install -r requirements.txt
```

### 7.12. `pyenv root`

Displays the root directory where versions and shims are kept.

```sh
$ pyenv root
/home/user/.pyenv
```

### 7.13. `pyenv prefix`

Displays the directories where the given Python versions are installed, separated by colons. If no version is given, `pyenv prefix` displays the locations of the currently selected versions.

```sh
$ pyenv prefix 3.9.7
/home/user/.pyenv/versions/3.9.7
```

### 7.14. `pyenv hooks`

Lists installed hook scripts for a given pyenv command.

```sh
Usage: pyenv hooks <command>
```

### 7.15. `pyenv shims`

List existing pyenv shims.

```sh
Usage: pyenv shims [--short]

$ pyenv shims
/home/user/.pyenv/shims/2to3
/home/user/.pyenv/shims/2to3-3.9
/home/user/.pyenv/shims/idle
/home/user/.pyenv/shims/idle3
/home/user/.pyenv/shims/idle3.9
/home/user/.pyenv/shims/pip
/home/user/.pyenv/shims/pip3
/home/user/.pyenv/shims/pip3.9
/home/user/.pyenv/shims/pydoc
/home/user/.pyenv/shims/pydoc3
/home/user/.pyenv/shims/pydoc3.9
/home/user/.pyenv/shims/python
/home/user/.pyenv/shims/python3
/home/user/.pyenv/shims/python3.9
/home/user/.pyenv/shims/python3.9-config
/home/user/.pyenv/shims/python3.9-gdb.py
/home/user/.pyenv/shims/python3-config
/home/user/.pyenv/shims/python-config
```

### 7.16. `pyenv init`

Configure the shell environment for pyenv

```sh
Usage: eval "$(pyenv init [-|--path] [--no-rehash] [<shell>])"

    -                    Initialize shims directory, print PYENV_SHELL variable, completions path and shell function
    --path               Print shims path
    --no-rehash          Add no rehash command to output   
```  

### 7.17. `pyenv completions`

Lists available completions for a given pyenv command.

```sh
Usage: pyenv completions <command> [arg1 arg2...]
```

## 8. Compare with other version tools

### 8.1. What pyenv *does...*

- Lets you **change the global Python version** on a per-user basis.
- Provides support for **per-project Python versions**.
- Allows you to **override the Python version** with an environment   variable.
- Searches for commands from **multiple versions of Python at a time**. This may be helpful to test across Python versions with [tox](https://pypi.python.org/pypi/tox).

### 8.2. In contrast with pythonbrew and pythonz, pyenv *does not...*

- **Depend on Python itself.** pyenv was made from pure shell scripts. There is no bootstrap problem of Python.
- **Need to be loaded into your shell.** Instead, pyenv's shim approach works by adding a directory to your `PATH`.
- **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv) yourself, or [pyenv-virtualenv][pyenv-virtualenv] to automate the process.

## 9. Development

The pyenv source code is [hosted on GitHub](https://github.com/pyenv/pyenv).  It's clean, modular, and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/bats-core/bats-core):

```sh
bats test
bats/test/<file>.bats
```

[pyenv-virtualenv]: https://github.com/pyenv/pyenv-virtualenv#readme
[hooks]: https://github.com/pyenv/pyenv/wiki/Authoring-plugins#pyenv-hooks
