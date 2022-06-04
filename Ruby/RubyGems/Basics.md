# RubyGems Basics

> Use of common RubyGems commands

The `gem` command allows you to interact with RubyGems. *Ruby 1.9* and newer ships with RubyGems built-in.

- [RubyGems Basics](#rubygems-basics)
  - [Finding Gems](#finding-gems)
  - [Installing Gems](#installing-gems)
  - [Requiring code](#requiring-code)
  - [Listing Installed Gems](#listing-installed-gems)
  - [Uninstalling Gems](#uninstalling-gems)
  - [Viewing Documentation](#viewing-documentation)
  - [Fetching and Unpacking Gems](#fetching-and-unpacking-gems)

## Finding Gems

The `search` command lets you find remote gems by name.  You can use *regular expression characters* in your query:

```console
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

```console
$ gem search ^rails$ -d

*** REMOTE GEMS ***

rails (7.0.3)
    Author: David Heinemeier Hansson
    Homepage: https://rubyonrails.org

    Full-stack web application framework.
```

You can also search for gems on [rubygems.org](rubygems.org) such as [this search for `rake`](https://rubygems.org/search?query=rake).

## Installing Gems

The `install` command downloads and installs the gem and any necessary dependencies then builds documentation for the installed gems.

```console
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

## Requiring code

RubyGems modifies your Ruby *load path*, which controls how your Ruby code is found by the `require` statement. When you `require` a gem, really you're just placing that gem's `lib` directory onto your `$LOAD_PATH`.

Let's try this out in `irb` and get some help from the `pretty_print` library included with Ruby:

> Tip: Passing `-r` to `irb` will automatically require a library when irb is loaded.

```console
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

```console
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

```console
% tree freewill/
freewill/
└── lib/
    ├── freewill/
    │   ├── user.rb
    │   ├── widget.rb
    │   └── ...
    └── freewill.rb
```

## Listing Installed Gems

The `list` command shows your locally installed gems:

```console
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

## Uninstalling Gems

The `uninstall` command removes the gems you have installed:

```console
$ gem uninstall drip
Successfully uninstalled drip-0.0.2
```

If you uninstall a *dependency* of a gem RubyGems will ask you for confirmation:

```
$ gem uninstall rbtree

You have requested to uninstall the gem:
    rbtree-0.4.1

drip-0.0.2 depends on rbtree (>= 0)
If you remove this gem, these dependencies will not be met.
Continue with Uninstall? [yN]  n
ERROR:  While executing gem ... (Gem::DependencyRemovalException)
    Uninstallation aborted due to dependent gem(s)
```

## Viewing Documentation

You can view the documentation for your installed gems with `ri`:

```console
$ ri RBTree
RBTree < MultiRBTree

(from gem rbtree-0.4.0)
-------------------------------------------
A sorted associative collection that cannot
contain duplicate keys. RBTree is a
subclass of MultiRBTree.
-------------------------------------------
```

## Fetching and Unpacking Gems

If you wish to audit a gem's contents without installing it you can use the `fetch` command to download the `.gem` file then extract its contents with the `unpack` command.

```console
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

```console
$ gem unpack rake
Unpacked gem: '.../rake-10.1.0'

$ vim rake-10.1.0/lib/rake/...

$ ruby -I rake-10.1.0/lib -S rake some_rake_task
[...]
```

- The `-I` argument adds your unpacked rake to the ruby `$LOAD_PATH` which prevents RubyGems from loading the gem version (or the default version).
- The `-S` argument finds `rake` in the shell's `$PATH` so you don't have to type out the full path.
