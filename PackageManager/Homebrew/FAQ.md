# FAQ

- [FAQ](#faq)
  - [Common Knowledge](#common-knowledge)
    - [How do I update my local packages?](#how-do-i-update-my-local-packages)
    - [Where does stuff get downloaded?](#where-does-stuff-get-downloaded)
    - [Why should I install Homebrew in the default location?](#why-should-i-install-homebrew-in-the-default-location)
    - [Why is the default installation prefix `/opt/homebrew` on Apple Silicon?](#why-is-the-default-installation-prefix-opthomebrew-on-apple-silicon)
    - [Why was a formula deleted or disabled?](#why-was-a-formula-deleted-or-disabled)
    - [What does "keg-only" mean?](#what-does-keg-only-mean)
    - [How do I stop certain formulae from being updated?](#how-do-i-stop-certain-formulae-from-being-updated)
    - [How do I keep old versions of a formula when upgrading?](#how-do-i-keep-old-versions-of-a-formula-when-upgrading)
  - [Philosophy](#philosophy)
    - [Why does Homebrew say sudo is bad?](#why-does-homebrew-say-sudo-is-bad)
    - [Why do you compile everything?](#why-do-you-compile-everything)
    - [Why does `brew upgrade <formula>` or `brew install <formula>` also upgrade a bunch of other stuff?](#why-does-brew-upgrade-formula-or-brew-install-formula-also-upgrade-a-bunch-of-other-stuff)
  - [Customize](#customize)
    - [Can I edit formulae myself?](#can-i-edit-formulae-myself)
    - [Can I make new formulae?](#can-i-make-new-formulae)
    - [How do I get a formula from someone else’s pull request?](#how-do-i-get-a-formula-from-someone-elses-pull-request)
    - [How can I specify different configure arguments for a formula?](#how-can-i-specify-different-configure-arguments-for-a-formula)
  - [Troubles & Shooting](#troubles--shooting)
    - [Why isn’t a particular command documented?](#why-isnt-a-particular-command-documented)
    - [My Mac `.app`s don’t find Homebrew utilities?](#my-mac-apps-dont-find-homebrew-utilities)
    - [Why can’t I open a Mac app from an "unidentified developer"?](#why-cant-i-open-a-mac-app-from-an-unidentified-developer)
    - [Why aren’t some apps included during `brew upgrade`?](#why-arent-some-apps-included-during-brew-upgrade)

## Common Knowledge

### How do I update my local packages?

First update all package definitions (formulae) and Homebrew itself:

```sh
brew update
```

You can now list which of your installed packages are outdated with:

```sh
brew outdated
```

Upgrade everything with:

```sh
brew upgrade
```

Or upgrade a specific formula with:

```sh
brew upgrade <formula>
```

### Where does stuff get downloaded?

```sh
brew --cache
```

### Why should I install Homebrew in the default location?

Homebrew's pre-built binary packages (known as [bottles](https://github.com/Homebrew/brew/blob/master/docs/Bottles.md)) of many formulae can only be used if you install in the default installation prefix, otherwise they have to be built from source. Building from source takes a long time, is prone to failure, and is not supported. The default prefix is:

- `/usr/local` for macOS on Intel,
- `/opt/homebrew` for macOS on Apple Silicon/ARM, and

Do yourself a favour and install to the default prefix so that you can use our pre-built binary packages. *Pick another prefix at your peril!*

### Why is the default installation prefix `/opt/homebrew` on Apple Silicon?

### Why was a formula deleted or disabled?

Use `brew log <formula>` to find out! Likely because it had [unresolved issues](Acceptable-Formulae.md) and/or [our analytics](https://formulae.brew.sh/analytics/) indicated it was not widely used.

For disabled and deprecated formulae, running `brew info <formula>` will also provide an explanation.

The prefix `/opt/homebrew` was chosen to allow installations in `/opt/homebrew` for Apple Silicon and `/usr/local` for **Rosetta 2** to coexist and use bottles.

### What does "keg-only" mean?

It means the formula is installed only into the *Cellar* and is not linked into the default prefix. This means most tools will not find it. You can see why a formula was installed as keg-only, and instructions for including it in your `PATH`, by running `brew info <formula>`.

You can [modify a tool's build configuration](https://github.com/Homebrew/brew/blob/master/docs/How-to-Build-Software-Outside-Homebrew-with-Homebrew-keg-only-Dependencies.md) to find keg-only dependencies. Or, you can link in the formula if you need to with `brew link <formula>`, though this can cause unexpected behaviour if you are shadowing macOS software.

### How do I stop certain formulae from being updated?

To stop something from being updated/upgraded:

```sh
brew pin <formula>
```

To allow that formulae to update again:

```sh
brew unpin <formula>
```

Note that pinned, outdated formulae that another formula depends on need to be upgraded when required, as we do not allow formulae to be built against outdated versions. If this is not desired, you can instead use `brew extract` to [maintain your own copy of the formula in a tap]([#howto](https://github.com/Homebrew/brew/blob/master/docs/How-to-Create-and-Maintain-a-Tap.md)).

### How do I keep old versions of a formula when upgrading?

Homebrew automatically uninstalls old versions of each formula that is upgraded with `brew upgrade`, and periodically performs additional cleanup every 30 days.

To **disable** automatic `brew cleanup`:

```sh
export HOMEBREW_NO_INSTALL_CLEANUP=1
```

To disable automatic `brew cleanup` only for formulae `foo` and `bar`:

```sh
export HOMEBREW_NO_CLEANUP_FORMULAE=foo,bar
```

When automatic `brew cleanup` is disabled, if you uninstall a formula, it will only remove the latest version you have installed. It will not remove all versions of the formula that you may have installed in the past. Homebrew will continue to attempt to install the newest version it knows about when you run `brew upgrade`. This can be surprising.

In this case, to remove a formula entirely, you may run `brew uninstall --force <formula>`. Be careful as this is a destructive operation.

## Philosophy

### Why does Homebrew say sudo is bad?

**tl;dr** Sudo is dangerous, and you installed *TextMate.app* without sudo anyway.

Homebrew refuses to work using sudo.

You should only ever sudo a tool you trust. Of course, you can trust Homebrew 😉 — but do you trust the multi-megabyte Makefile that Homebrew runs? Developers often understand C++ far better than they understand `make` syntax. It’s too high a risk to sudo such stuff. It could modify (or upload) any files on your system. And indeed, we’ve seen some build scripts try to modify `/usr` even when the prefix was specified as something else entirely.

We use the macOS sandbox to stop this but this doesn't work when run as the `root` user (which also has read and write access to almost everything on the system).

Did you `chown root /Applications/TextMate.app`? Probably not. So is it that important to `chown root wget`?

If you need to run Homebrew in a multi-user environment, consider creating a separate user account specifically for use of Homebrew.

### Why do you compile everything?

Homebrew provides pre-built binary packages for many formulae. These are referred to as [bottles](https://github.com/Homebrew/brew/blob/master/docs/Bottles.md) and are available at <https://github.com/Homebrew/homebrew-core/packages>.

If available, bottled binaries will be used by default except under the following conditions:

- Options were passed to the install command, i.e. `brew install <formula>` will use a bottled version of the formula, but `brew install --enable-bar <formula>` will trigger a source build.
- The `--build-from-source` option is invoked.
- No bottle is available for the machine's currently running OS version. (Bottles for macOS are generated only for supported macOS versions.)
- Homebrew is installed to a prefix other than the default (although some bottles support this).

We aim to bottle everything.

### Why does `brew upgrade <formula>` or `brew install <formula>` also upgrade a bunch of other stuff?

Homebrew doesn't support arbitrary mixing and matching of formula versions, so everything a formula depends on, and everything that depends on it in turn, needs to be upgraded to the latest version as that's the only combination of formulae we test. As a consequence any given `upgrade` or `install` command can upgrade many other (seemingly unrelated) formulae, especially if something important like `python` or `openssl` also needed an upgrade.

Which is usually: `~/Library/Caches/Homebrew`

## Customize

### Can I edit formulae myself?

Yes! It’s easy! Just `brew edit <formula>`. You don’t have to submit modifications back to `homebrew/core`, just edit the formula to what you personally need and `brew install <formula>`.

As a bonus, `brew update` will **merge** your changes with upstream so you can still keep the formula up-to-date **with** your personal modifications!

### Can I make new formulae?

Yes! It’s easy! Just `brew create URL`. Homebrew will then open the formula in `EDITOR` so you can edit it, but it probably already installs; try it: `brew install <formula>`. If you encounter any issues, run the command with the `--debug` switch like so: `brew install --debug <formula>`, which drops you into a debugging shell.

If you want your new formula to be part of `homebrew/core` or want to learn more about writing formulae, then please read the [Formula Cookbook](Formula-Cookbook.md).

### How do I get a formula from someone else’s pull request?

```sh
brew install hub
brew update
cd "$(brew --repository homebrew/core)"
hub fetch github_username
hub pr checkout pull_request_number
```

### How can I specify different configure arguments for a formula?

`brew edit <formula>` and edit the formula directly. Currently there is no other way to do this.

## Troubles & Shooting

### Why isn’t a particular command documented?

If it’s not in [`man brew`](https://github.com/Homebrew/brew/blob/master/docs/Manpage.md), it’s probably an [external command](https://github.com/Homebrew/brew/blob/master/docs/External-Commands.md) with documentation available using `--help`.

### My Mac `.app`s don’t find Homebrew utilities?

*GUI apps* on macOS don’t have Homebrew's prefix in their `PATH` by default. If you're on Mountain Lion or later, you can fix this by running `sudo launchctl config user path "$(brew --prefix)/bin:${PATH}"` and then rebooting, as documented in `man launchctl`.

Note that this sets the `launchctl` `PATH` for *all users*.

### Why can’t I open a Mac app from an "unidentified developer"?

Chances are that certain apps will give you a popup message like this:

<img src="https://i.imgur.com/CnEEATG.png" width="532" alt="Gatekeeper message">

This is a [security feature from Apple](https://support.apple.com/en-us/HT202491). The single most important thing to know is that **you can allow individual apps to be exempt from this feature.** This allows the app to run while the rest of the system remains under protection.

**Always leave system-wide protection enabled,** and disable it only for specific apps as needed.

If you're sure you want to trust the app, you can disable protection for it by right-clicking its icon and choosing *Open*:

<img src="https://i.imgur.com/69xc2WK.png" width="312" alt="Right-click the app and choose Open">

In the resulting dialog, click the *Open* button to have macOS permanently allow the app to run on this Mac. **Don’t do this unless you’re sure you trust the app.**

<img src="https://i.imgur.com/xppa4Qv.png" width="532" alt="Gatekeeper message">

Alternatively, you may provide the [`--no-quarantine` flag](https://github.com/Homebrew/homebrew-cask/blob/HEAD/USAGE.md#options) at install time to not add this feature to a specific app.

### Why aren’t some apps included during `brew upgrade`?

After running `brew upgrade`, you may notice some *casks* you think should be upgrading, aren’t.

As you’re likely aware, a lot of macOS software can upgrade itself:

<img src="https://upload.wikimedia.org/wikipedia/commons/c/c0/Sparkle_Test_App_Software_Update.png" width="532" alt="Sparkle update window">

That could cause conflicts when used in tandem with Homebrew Cask’s `upgrade` mechanism.

When software uses its built-in mechanisms to upgrade itself, it happens without Homebrew Cask’s knowledge, causing both versions get out of sync. If you were to then upgrade through Homebrew Cask while we have a lower version of the software on record, you’d get a downgrade.

There are a few ideas to fix this problem:

- Try to prevent the software’s automated updates. It wouldn’t be a universal solution and may cause it to break. Most software on Homebrew Cask is closed-source, so we’d be guessing. **This is also why pinning casks to a version isn’t available.**
- Try to extract the installed software’s version and compare it to the cask, deciding what to do at that time. It’d be a complicated solution that would break other parts of our methodology, such as using versions to interpolate `url` values (a definite win for maintainability). This solution also isn’t universal, as many software developers are inconsistent in their versioning schemes (and app bundles are meant to have two version strings) and it doesn’t work for all types of software we support.

So we let software be. Anything installed with *Homebrew Cask* should behave the same as if it were installed manually. But since we also want to support software that doesn’t self-upgrade, we add [`auto_updates true`](https://github.com/Homebrew/homebrew-cask/blob/62c0495b254845a481dacac6ea7c8005e27a3fb0/Casks/alfred.rb#L10) to casks for software that does, which excludes them from `brew upgrade`.

Casks which use [`version :latest`](https://docs.brew.sh/Cask-Cookbook#version-latest) are also excluded, because we have no way to track their installed version. It helps to ask the developers of such software to provide versioned releases (i.e. include the version in the path of the download `url`).

If you still want to force software to be upgraded via Homebrew Cask, you can reference it specifically in the `upgrade` command:

```sh
brew upgrade <cask>
```

Or use the `--greedy` flag:

```sh
brew upgrade --greedy
```

Refer to the `upgrade` section of the [`brew` manual page](https://github.com/Homebrew/brew/blob/master/docs/Manpage.md) for more details.
