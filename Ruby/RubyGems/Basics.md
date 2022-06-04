# RubyGems Basics

> Use of common RubyGems commands.

The `gem` command allows you to interact with RubyGems. *Ruby 1.9* and newer ships with RubyGems built-in.

- [RubyGems Basics](#rubygems-basics)
  - [`gem search`](#gem-search)
  - [`gem install`](#gem-install)
  - [`gem uninstall`](#gem-uninstall)
  - [`gem list`](#gem-list)
  - [`gem environment`](#gem-environment)
    - [`gem environment gemdir`](#gem-environment-gemdir)
    - [`gem environment gempath`](#gem-environment-gempath)
    - [`gem environment remotesources`](#gem-environment-remotesources)
    - [`gem environment -h`](#gem-environment--h)
  - [`gem -h`](#gem--h)
  - [`gem help <COMMAND>`](#gem-help-command)
  - [`require` gem](#require-gem)
  - [`ri`: Viewing Documentation](#ri-viewing-documentation)
  - [`fetch` and `unpack` gems](#fetch-and-unpack-gems)
  - [Structure of a gem](#structure-of-a-gem)
  - [The `gemspec`](#the-gemspec)

## `gem search`

The `search` command lets you find remote gems by name.  You can use *regular expression characters* in your query:

```sh
$ gem search ^rails

*** REMOTE GEMS ***

rails (7.0.3)
rails-3-settings (0.1.1)
rails-acm (0.1.0)
rails-action-args (0.1.1)
rails-action-authorization (1.1.2)
rails-action_throttling (0.1.2)
rails-active_action (3.0.8)
rails-acu (4.1.0)
[...]
```

If you see a gem you want more information on you can add the *details option*(`-d`). You'll want to do this with a small number of gems, though, as listing gems with details requires downloading more files:

```sh
$ gem search ^rails$ -d

*** REMOTE GEMS ***

rails (7.0.3)
    Author: David Heinemeier Hansson
    Homepage: https://rubyonrails.org

    Full-stack web application framework.
```

You can also search for gems on [rubygems.org](rubygems.org) such as [this search for `rake`](https://rubygems.org/search?query=rake).

## `gem install`

> You can use `i` command instead of `install`.  
> e.g. `gem i GEMNAME`

The `install` command downloads and installs the gem and any necessary dependencies then builds documentation for the installed gems.

```sh
$ gem install drip
Fetching: rbtree-0.4.1.gem (100%)
Building native extensions.  This could take a while...
Successfully installed rbtree-0.4.1
Fetching: drip-0.0.2.gem (100%)
Successfully installed drip-0.0.2
Parsing documentation for rbtree-0.4.1
Installing ri documentation for rbtree-0.4.1
Parsing documentation for drip-0.0.2
Installing ri documentation for drip-0.0.2
Done installing documentation for rbtree, drip after 0 seconds
2 gems installed
```

Here the *drip* command depends upon the *rbtree* gem which has an extension. Ruby installs the dependency *rbtree* and builds its extension, installs the *drip* gem, then builds documentation for the installed gems.

You can disable documentation generation using the `--no-doc` argument when installing gems.

Default options:

```sh
--both --version '>= 0' --document --no-force
--install-dir $HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0 --lock
```

## `gem uninstall`

The `uninstall` command removes the gems you have installed:

```sh
$ gem uninstall drip
Successfully uninstalled drip-0.0.2
```

If you uninstall a *dependency* of a gem RubyGems will ask you for confirmation:

```sh
$ gem uninstall rbtree

You have requested to uninstall the gem:
    rbtree-0.4.1

drip-0.0.2 depends on rbtree (>= 0)
If you remove this gem, these dependencies will not be met.
Continue with Uninstall? [yN]  n
ERROR:  While executing gem ... (Gem::DependencyRemovalException)
    Uninstallation aborted due to dependent gem(s)
```

## `gem list`

The `list` command shows your locally installed gems:

```sh
$ gem list

*** LOCAL GEMS ***

bigdecimal (1.2.0)
drip (0.0.2)
io-console (0.4.2)
json (1.7.7)
minitest (4.3.2)
psych (2.0.0)
rake (0.9.6)
rbtree (0.4.1)
rdoc (4.0.0)
test-unit (2.0.0.0)
```

> Ruby ships with some gems by default, bigdecimal, io-console, json, minitest, psych, rake, rdoc, test-unit for ruby 2.0.0.

## `gem environment`

Display information about the RubyGems environment.

```sh
$ gem environment

RubyGems Environment:
  - RUBYGEMS VERSION: 3.1.6
  - RUBY VERSION: 2.7.6 (2022-04-12 patchlevel 219) [arm64-darwin21]
  - INSTALLATION DIRECTORY: $HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
  - USER INSTALLATION DIRECTORY: $HOME/.gem/ruby/2.7.0
  - RUBY EXECUTABLE: $HOME/.rbenv/versions/2.7.6/bin/ruby
  - GIT EXECUTABLE: /opt/homebrew/bin/git
  - EXECUTABLE DIRECTORY: $HOME/.rbenv/versions/2.7.6/bin
  - SPEC CACHE DIRECTORY: $HOME/.gem/specs
  - SYSTEM CONFIGURATION DIRECTORY: $HOME/.rbenv/versions/2.7.6/etc
  - RUBYGEMS PLATFORMS:
    - ruby
    - arm64-darwin-21
  - GEM PATHS:
     - $HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
     - $HOME/.gem/ruby/2.7.0
  - GEM CONFIGURATION:
     - :update_sources => true
     - :verbose => true
     - :backtrace => false
     - :bulk_threshold => 1000
  - REMOTE SOURCES:
     - https://rubygems.org/
  - SHELL PATH:
     - $HOME/.rbenv/versions/2.7.6/bin
     - /opt/homebrew/Cellar/rbenv/1.2.0/libexec
     - $HOME/.rbenv/shims
     - $HOME/.pyenv/shims
     - /opt/homebrew/bin
     - /opt/homebrew/sbin
     - /usr/local/bin
     - /usr/bin
     - /bin
     - /usr/sbin
     - /sbin
     - /Library/Apple/usr/bin
```

### `gem environment gemdir`

Display the path where gems are installed.

```sh
$ gem environment gemdir
$HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
```

### `gem environment gempath`

Display path used to search for gems.

```sh
$ gem environment gempath
$HOME/.gem/ruby/2.7.0:$HOME/.rbenv/versions/2.7.6/lib/ruby/gems/2.7.0
```

### `gem environment remotesources`

display the remote gem servers.

```sh
gem environment remotesources
https://rubygems.org/
```

### `gem environment -h`

```sh
$ gem environment -h

Usage: gem environment [arg] [options]

  Common Options:
    -h, --help                       Get help on this command
    -V, --[no-]verbose               Set the verbose level of output
    -q, --quiet                      Silence command progress meter
        --silent                     Silence RubyGems output
        --config-file FILE           Use this config file instead of default
        --backtrace                  Show stack backtrace on errors
        --debug                      Turn on Ruby debugging
        --norc                       Avoid loading any .gemrc file

  Arguments:
    gemdir          display the path where gems are installed
    gempath         display path used to search for gems
    version         display the gem format version
    remotesources   display the remote gem servers
    platform        display the supported gem platforms
    <omitted>       display everything

  ...
```

## `gem -h`

```sh
❯ gem -h
RubyGems is a sophisticated package manager for Ruby.  This is a
basic help message containing pointers to more information.

  Usage:
    gem -h/--help
    gem -v/--version
    gem command [arguments...] [options...]

  Examples:
    gem install rake
    gem list --local
    gem build package.gemspec
    gem help install

  Further help:
    gem help commands            list all 'gem' commands
    gem help examples            show some examples of usage
    gem help gem_dependencies    gem dependencies file guide
    gem help platforms           gem platforms guide
    gem help <COMMAND>           show help on COMMAND
                                   (e.g. 'gem help install')
    gem server                   present a web page at
                                 http://localhost:8808/
                                 with info about installed gems
  Further information:
    https://guides.rubygems.org
```

## `gem help <COMMAND>`

> You can also use `gem <COMMAND> -h`

Display help information for a *command*. e.g.

```sh
$ gem install -h

Usage: gem install GEMNAME [GEMNAME ...] [options] -- --build-flags [options]

  Options:
        --platform PLATFORM          Specify the platform of gem to install
    -v, --version VERSION            Specify version of gem to install
        --[no-]prerelease            Allow prerelease versions of a gem
                                     to be installed. (Only for listed gems)

  Deprecated Options:
    -u, --[no-]update-sources        Update local source cache

  Install/Update Options:
    -i, --install-dir DIR            Gem repository directory to get installed
                                     gems
    -n, --bindir DIR                 Directory where executables are
                                     located
        --document [TYPES]           Generate documentation for installed gems
                                     List the documentation types you wish to
                                     generate.  For example: rdoc,ri
        --build-root DIR             Temporary installation root. Useful for building
                                     packages. Do not use this when installing remote gems.
        --vendor                     Install gem into the vendor directory.
                                     Only for use by gem repackagers.
    -N, --no-document                Disable documentation generation
```

## `require` gem

RubyGems modifies your Ruby *load path*, which controls how your Ruby code is found by the `require` statement. When you `require` a gem, really you're just placing that gem's `lib` directory onto your `$LOAD_PATH`.

Let's try this out in `irb` and get some help from the `pretty_print` library included with Ruby:

> Tip: Passing `-r` to `irb` will automatically require a library when irb is loaded.

```sh
% irb -rpp

>> pp $LOAD_PATH
["/opt/homebrew/Cellar/rbenv/1.2.0/rbenv.d/exec/gem-rehash",
 ".../lib/ruby/gems/2.7.0/gems/reline-0.3.1/lib",
 ".../lib/ruby/gems/2.7.0/gems/irb-1.4.1/lib",
 ".../lib/ruby/gems/2.7.0/gems/io-console-0.5.11/lib",
 ".../lib/ruby/gems/2.7.0/extensions/arm64-darwin-21/2.7.0/io-console-0.5.11",
 ".../lib/ruby/site_ruby/2.7.0",
 ".../lib/ruby/site_ruby/2.7.0/arm64-darwin21",
 ".../lib/ruby/site_ruby",
 ".../lib/ruby/vendor_ruby/2.7.0",
 ".../lib/ruby/vendor_ruby/2.7.0/arm64-darwin21",
 ".../lib/ruby/vendor_ruby",
 ".../lib/ruby/2.7.0",
 ".../lib/ruby/2.7.0/arm64-darwin21"]
```

By default you have just a few system directories on the *load path* and the Ruby standard libraries.  To add the `awesome_print` directories to the *load path*, you can require one of its files:

```sh
% irb -rpp

>> require 'ap'
=> true

>> pp $LOAD_PATH
...
".../lib/ruby/gems/2.7.0/gems/awesome_print-1.9.2/lib""
...
```

> Note:  For Ruby 1.8 you must `require 'rubygems'` before requiring any gems.

Once you've required `ap`, RubyGems automatically places its `lib` directory on the `$LOAD_PATH`.

That's basically it for what's in a gem.  Drop Ruby code into `lib`, name a Ruby file the same as your gem and it's loadable by RubyGems. (for the gem "`freewill`" the file should be `freewill.rb`, see also [name your gem](https://guides.rubygems.org/name-your-gem/))

The `lib` directory itself normally contains only one `.rb` file and a directory with the same name as the gem which contains the rest of the files.

For example:

```sh
% tree freewill/
freewill/
└── lib/
    ├── freewill/
    │   ├── user.rb
    │   ├── widget.rb
    │   └── ...
    └── freewill.rb
```

## `ri`: Viewing Documentation

You can view the documentation for your installed gems with `ri`:

```sh
$ ri RBTree
RBTree < MultiRBTree

(from gem rbtree-0.4.0)
-------------------------------------------
A sorted associative collection that cannot
contain duplicate keys. RBTree is a
subclass of MultiRBTree.
-------------------------------------------
```

## `fetch` and `unpack` gems

If you wish to audit a gem's contents without installing it you can use the `fetch` command to download the `.gem` file then extract its contents with the `unpack` command.

```sh
$ gem fetch malice
Fetching: malice-13.gem (100%)
Downloaded malice-13

$ gem unpack malice-13.gem
Fetching: malice-13.gem (100%)
Unpacked gem: '.../malice-13'

$ more malice-13/README
Malice v. 13
DESCRIPTION
A small, malicious library.
[...]

$ rm -r malice-13*
```

You can also `unpack` a gem you have installed, modify a few files, then use the modified gem in place of the installed one:

```sh
$ gem unpack rake
Unpacked gem: '.../rake-10.1.0'

$ vim rake-10.1.0/lib/rake/...

$ ruby -I rake-10.1.0/lib -S rake some_rake_task
[...]
```

- The `-I` argument adds your unpacked rake to the ruby `$LOAD_PATH` which prevents RubyGems from loading the gem version (or the default version).
- The `-S` argument finds `rake` in the shell's `$PATH` so you don't have to type out the full path.

## Structure of a gem

Each gem has a *name*, *version*, and *platform*.

For example, the [rake](https://rubygems.org/gems/rake) gem has a `13.0.6` version (Released on July 09, 2021). `rake`'s *platform* is `ruby`, which means it works on *any* platform Ruby runs on.

Platforms are based on the *CPU architecture*, *operating system type* and sometimes the *operating system version*.  Examples include "x86-mingw32" or "java".  The platform indicates the gem only works with a ruby built for the same platform.

RubyGems will automatically download the correct version for your platform.  See `gem help platform` for full details.

Inside gems are the following components:

- Code (including tests and supporting utilities)
- Documentation
- gemspec

Each gem follows the same standard structure of code organization:

```sh
$ tree freewill
freewill/
├── bin/
│   └── freewill
├── lib/
│   └── freewill.rb
├── test/
│   └── test_freewill.rb
├── README
├── Rakefile
└── freewill.gemspec
```

Here, you can see the major components of a gem:

- The `lib` directory contains the code for the gem
- The `test` or `spec` directory contains tests, depending on which test framework the developer uses
- A gem usually has a `Rakefile`, which the [rake](https://rubygems.org/gems/rake) program uses to automate tests, generate code, and perform other tasks.
- This gem also includes an executable file in the `bin` directory, which will be loaded into the user's `PATH` when the gem is installed.
- Documentation is usually included in the `README` and inline with the code.
  - When you install a gem, documentation is generated automatically for you.
  - Most gems include [RDoc](https://ruby.github.io/rdoc/) documentation, but some use [YARD](https://yardoc.org/) docs instead.
- The final piece is the `gemspec`, which contains information about the gem.
  - The gem's files, test information, platform, version number and more are all laid out here along with the author's email and name.

## The `gemspec`

The `gemspec` specifies the information about a gem such as its name, version, description, authors and homepage.

Here's an example of a `gemspec` file.

```sh
$ cat freewill.gemspec

Gem::Specification.new do |s|
    s.name        = 'freewill'
    s.version     = '1.0.0'
    s.summary     = "Freewill!"
    s.description = "I will choose Freewill!"
    s.authors     = ["Nick Quaranto"]
    s.email       = 'nick@quaran.to'
    s.homepage    = 'http://example.com/freewill'
    s.files       = ["lib/freewill.rb", ...]
end
```
