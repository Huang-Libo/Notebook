# Installation

The Missing Package Manager for macOS.

- [Installation](#installation)
  - [Overview](#overview)
  - [Git Remote Mirroring](#git-remote-mirroring)
  - [Unattended installation](#unattended-installation)
  - [Uninstallation](#uninstallation)

## Overview

Install Homebrew:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This script installs Homebrew to its preferred prefix:

- `/usr/local` for macOS Intel
- `/opt/homebrew` for Apple Silicon

so that [you don’t need sudo](https://docs.brew.sh/FAQ#why-does-homebrew-say-sudo-is-bad) when you `brew install`. It is a careful script; it can be run even if you have stuff installed in the preferred prefix already. It tells you exactly what it will do before it does it too. You have to confirm everything it will do before it starts.

**macOS Requirements**:

- macOS Catalina (10.15) or higher
- *Command Line Tools (CLT)* :`xcode-select --install`

## Git Remote Mirroring

You can use geo-localized Git mirrors to speed up Homebrew's installation and `brew update` by setting `HOMEBREW_BREW_GIT_REMOTE` and/or `HOMEBREW_CORE_GIT_REMOTE` in your shell environment with this script:

```bash
export HOMEBREW_BREW_GIT_REMOTE="..."  # put your Git mirror of Homebrew/brew here
export HOMEBREW_CORE_GIT_REMOTE="..."  # put your Git mirror of Homebrew/homebrew-core here
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

The default Git remote will be used if the corresponding environment variable is unset.

## Unattended installation

If you want a non-interactive run of the Homebrew installer that doesn't prompt for passwords (e.g. in automation scripts), prepend [`NONINTERACTIVE=1`](https://github.com/Homebrew/install/#install-homebrew-on-macos-or-linux) to the installation command.

```sh
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Uninstallation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

If you want to run the Homebrew uninstaller non-interactively, you can use:

```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

Download the uninstall script and run `/bin/bash uninstall.sh --help` to view more uninstall options.
