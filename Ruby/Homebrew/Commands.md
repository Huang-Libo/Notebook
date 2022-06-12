# Frequently used Commands

- [Frequently used Commands](#frequently-used-commands)
  - [`brew update`](#brew-update)
  - [`brew upgrade`](#brew-upgrade)
  - [`brew outdated`](#brew-outdated)
  - [`brew list/ls`](#brew-listls)
  - [`brew search/-S <formula>`: Use regular expression](#brew-search-s-formula-use-regular-expression)
  - [`brew install`](#brew-install)
  - [`brew uninstall/remove/rm`](#brew-uninstallremoverm)
  - [`brew deps`](#brew-deps)
  - [`brew shellenv`](#brew-shellenv)
  - [`brew info`](#brew-info)
  - [`brew home`](#brew-home)
  - [`brew commands`](#brew-commands)
  - [`brew help <cmd>`](#brew-help-cmd)
  - [`brew --env`](#brew---env)
  - [`brew config`](#brew-config)

## `brew update`

**Fetch** the newest version of *Homebrew* and *all formulae* from GitHub using git(1)
and perform any necessary **migrations**.

```sh
$ brew update
Already up-to-date.
```

## `brew upgrade`

**Upgrade** *outdated casks* and *outdated&unpinned formulae* using the same options
they were originally installed with, plus any appended brew formula options.

If *cask* or *formula* are specified, upgrade only the given *cask* or *formula*
kegs (unless they are pinned; see `pin`, `unpin`).

## `brew outdated`

List installed *casks* and *formulae* that have an updated version available. By
default, version information is displayed in interactive shells, and suppressed
otherwise.

## `brew list/ls`

List all installed *formulae* and *casks*.

```sh
$ brew list
==> Formulae
autoconf	git		libtool		pcre2		ruby-build
automake	gmp		libunistring	pkg-config	tree
ca-certificates	libgpg-error	libyaml		pyenv		wget
coreutils	libidn2		m4		rbenv		zlib
gettext		libksba		openssl@1.1	readline

==> Casks
bob		eul		tinypng4mac
```

## `brew search/-S <formula>`: Use regular expression

If *`<formula>`* is flanked by slashes, it is interpreted as a **regular expression**. e.g.:

```sh
$ brew search /^wget$/
==> Formulae
wget ✔
```

## `brew install`

Install a *formula* or *cask*. Additional options specific to a formula may be
appended to the command.

```sh
brew install wget
```

## `brew uninstall/remove/rm`

Uninstall a *formula* or *cask*.

```sh
brew install wget
```

## `brew deps`

Show dependencies for *formula*. Additional options specific to formula may be appended to the command. When given multiple formula arguments, show the intersection of dependencies for each formula.

```sh
$ brew deps wget
ca-certificates
gettext
libidn2
libunistring
openssl@1.1
```

## `brew shellenv`

Print export statements. When run in a shell, this installation of Homebrew will
be added to your `PATH`, `MANPATH`, and `INFOPATH`.

```sh
$ brew shellenv
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
```

## `brew info`

Display brief statistics for your Homebrew installation.

If a *formula* or *cask* is provided, show summary of information about it.

```sh
$ brew info
24 kegs, 14,493 files, 135MB

$ brew info wget
wget: stable 1.21.3 (bottled), HEAD
Internet file retriever
https://www.gnu.org/software/wget/
/opt/homebrew/Cellar/wget/1.21.3 (89 files, 4.2MB) *
  Poured from bottle on 2022-02-28 at 14:55:22
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/wget.rb
License: GPL-3.0-or-later
==> Dependencies
Build: pkg-config ✔
Required: libidn2 ✔, openssl@1.1 ✔
==> Options
--HEAD
	Install HEAD version
==> Analytics
install: 124,882 (30 days), 470,809 (90 days), 1,870,829 (365 days)
install-on-request: 124,131 (30 days), 468,274 (90 days), 1,862,068 (365 days)
build-error: 20 (30 days)
```

## `brew home`

Open a *formula* or *cask*'s homepage in a browser, or open Homebrew's own homepage if no argument is provided.

```sh
$ brew home wget
Opening homepage for Formula wget
```

## `brew commands`

Display the path to the file being used when invoking `brew <cmd>`.

```sh
$ brew commands
==> Built-in commands
--cache           casks             fetch             list              reinstall         update-report
--caskroom        cleanup           formulae          log               search            update-reset
--cellar          commands          gist-logs         migrate           shellenv          update
--env             completions       help              missing           tap-info          upgrade
--prefix          config            home              options           tap               uses
--repository      deps              info              outdated          uninstall         vendor-install
--version         desc              install           pin               unlink
analytics         developer         leaves            postinstall       unpin
autoremove        doctor            link              readall           untap

==> Built-in developer commands
audit                      edit                       pr-upload                  typecheck
bottle                     extract                    prof                       unbottled
bump-cask-pr               formula                    release                    unpack
bump-formula-pr            generate-man-completions   rubocop                    update-license-data
bump-revision              install-bundler-gems       ruby                       update-maintainers
bump-unversioned-casks     irb                        sh                         update-python-resources
bump                       linkage                    sponsors                   update-test
cat                        livecheck                  style                      vendor-gems
command                    pr-automerge               tap-new
create                     pr-publish                 test
dispatch-build-bottle      pr-pull                    tests

==> External commands
aspell-dictionaries                 determine-rebottle-runners          postgresql-upgrade-database
```

## `brew help <cmd>`

> Or use `brew <cmd> -h`

Show help info for a *command*. e.g.:

```sh
$ brew config -h
Usage: brew config, --config

Show Homebrew and system configuration info useful for debugging. If you file a
bug report, you will be required to provide this information.

  -d, --debug                      Display any debugging information.
  -q, --quiet                      Make some output more quiet.
  -v, --verbose                    Make some output more verbose.
  -h, --help                       Show this message.
```

## `brew --env`

Summarize Homebrew's build environment as a plain list.

```sh
$ brew --env
HOMEBREW_CC: clang
HOMEBREW_CXX: clang++
MAKEFLAGS: -j8
CMAKE_PREFIX_PATH: /opt/homebrew
CMAKE_INCLUDE_PATH: /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers
CMAKE_LIBRARY_PATH: /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries
PKG_CONFIG_LIBDIR: /usr/lib/pkgconfig:/opt/homebrew/Library/Homebrew/os/mac/pkgconfig/12
HOMEBREW_GIT: git
HOMEBREW_SDKROOT: /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk
ACLOCAL_PATH: /opt/homebrew/share/aclocal
PATH: /opt/homebrew/Library/Homebrew/shims/mac/super:/usr/bin:/bin:/usr/sbin:/sbin
```

## `brew config`

Show Homebrew and system configuration info useful for debugging. If you file a bug report, you will be required to provide this information.

```sh
$ brew config
HOMEBREW_VERSION: 3.5.1
ORIGIN: https://github.com/Homebrew/brew
HEAD: 2258ba5797c1ea8149a49673b5c080011c366237
Last commit: 5 days ago
Core tap ORIGIN: https://github.com/Homebrew/homebrew-core
Core tap HEAD: f76e1aeb5b11fd4560ce16968a9df177a38dba4b
Core tap last commit: 6 hours ago
Core tap branch: master
HOMEBREW_PREFIX: /opt/homebrew
HOMEBREW_CASK_OPTS: []
HOMEBREW_CORE_GIT_REMOTE: https://github.com/Homebrew/homebrew-core
HOMEBREW_MAKE_JOBS: 8
Homebrew Ruby: 2.6.8 => /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
CPU: octa-core 64-bit arm_firestorm_icestorm
Clang: 13.1.6 build 1316
Git: 2.36.1 => /opt/homebrew/bin/git
Curl: 7.79.1 => /usr/bin/curl
macOS: 12.4-arm64
CLT: 13.4.0.0.1.1651278267
Xcode: 13.4.1
Rosetta 2: false
```
