# Commands

- [Commands](#commands)
  - [`brew --env`](#brew---env)
  - [`brew config`](#brew-config)
  - [`brew list`](#brew-list)
  - [`brew search <formula-name>`: Use regular expression](#brew-search-formula-name-use-regular-expression)
  - [`brew deps`](#brew-deps)
  - [`brew <cmd> -h`](#brew-cmd--h)
  - [`brew commands`](#brew-commands)

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

## `brew list`

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

## `brew search <formula-name>`: Use regular expression

If *`<formula-name>`* is flanked by slashes, it is interpreted as a **regular expression**. e.g.:

```sh
$ brew search /^wget$/
==> Formulae
wget ✔
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

## `brew <cmd> -h`

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
