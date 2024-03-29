# ShellCheck <!-- omit in toc -->

> [ShellCheck](https://github.com/koalaman/shellcheck) is a shell script *static analysis* tool.

- [1. Overview](#1-overview)
- [2. How to use](#2-how-to-use)
  - [2.1. On the WEB](#21-on-the-web)
  - [2.2. From your terminal](#22-from-your-terminal)
  - [2.3. In your Editor](#23-in-your-editor)
  - [2.4. In your build or test suites](#24-in-your-build-or-test-suites)
- [3. Installing](#3-installing)
  - [3.1. Using Package Manager](#31-using-package-manager)
  - [3.2. pre-commit](#32-pre-commit)
  - [3.3. Travis CI](#33-travis-ci)
- [4. Ignoring issues](#4-ignoring-issues)
  - [4.1. Ignoring one specific instance in a file](#41-ignoring-one-specific-instance-in-a-file)
  - [4.2. Ignoring all instances in a file](#42-ignoring-all-instances-in-a-file)
  - [4.3. Ignoring all errors in a file](#43-ignoring-all-errors-in-a-file)
  - [4.4. Ignoring errors in one specific run](#44-ignoring-errors-in-one-specific-run)
  - [4.5. Ignoring one or more types of errors forever](#45-ignoring-one-or-more-types-of-errors-forever)
- [5. Gallery of bad code](#5-gallery-of-bad-code)
  - [5.1. Quoting](#51-quoting)
  - [5.2. Conditionals](#52-conditionals)
  - [5.3. Frequently misused commands](#53-frequently-misused-commands)
  - [5.4. Common beginner's mistakes](#54-common-beginners-mistakes)
  - [5.5. Style](#55-style)
  - [5.6. Data and typing errors](#56-data-and-typing-errors)
  - [5.7. Robustness](#57-robustness)
  - [5.8. Portability](#58-portability)
  - [5.9. Miscellaneous](#59-miscellaneous)
- [6. Other Resources](#6-other-resources)

## 1. Overview

ShellCheck is a GPLv3 tool that gives warnings and suggestions for `bash`/`sh` shell scripts:

The goals of ShellCheck are

- To point out and clarify typical beginner's syntax issues that cause a shell to give cryptic error messages.
- To point out and clarify typical intermediate level semantic problems that cause a shell to behave strangely and counter-intuitively.
- To point out subtle caveats, corner cases and pitfalls that may cause an advanced user's otherwise working script to fail under future circumstances.

See [the gallery of bad code](#5-gallery-of-bad-code) for examples of what ShellCheck can help you identify!

## 2. How to use

There are a number of ways to use ShellCheck!

### 2.1. On the WEB

Paste a shell script on <https://www.shellcheck.net> for instant feedback.

### 2.2. From your terminal

Run `shellcheck <your-script>` in your terminal for instant output.

### 2.3. In your Editor

You can see ShellCheck suggestions directly in a variety of editors.

- **VSCode**, through [vscode-shellcheck](https://github.com/timonwong/vscode-shellcheck).
- Vim, through [ALE](https://github.com/w0rp/ale), [Neomake](https://github.com/neomake/neomake), or [Syntastic](https://github.com/scrooloose/syntastic).
- Emacs, through [Flycheck](https://github.com/flycheck/flycheck) or [Flymake](https://github.com/federicotdn/flymake-shellcheck).
- Sublime, through [SublimeLinter](https://github.com/SublimeLinter/SublimeLinter-shellcheck).
- Atom, through [Linter](https://github.com/AtomLinter/linter-shellcheck).
- Most other editors, through [GCC error compatibility](shellcheck.1.md#user-content-formats).

### 2.4. In your build or test suites

While ShellCheck is mostly intended for interactive use, it can easily be added to builds or test suites.

It makes canonical use of exit codes, so you can just add a `shellcheck` command as part of the process.

For example, in a Makefile:

```Makefile
check-scripts:
    # Fail if any of these files have warnings
    shellcheck myscripts/*.sh
```

or in a Travis CI `.travis.yml` file:

```yaml
script:
  # Fail if any of these files have warnings
  - shellcheck myscripts/*.sh
```

Services and platforms that have ShellCheck pre-installed and ready to use:

- [Travis CI](https://travis-ci.org/)
- [Codacy](https://www.codacy.com/)
- [Code Climate](https://codeclimate.com/)
- [Code Factor](https://www.codefactor.io/)
- [CircleCI](https://circleci.com) via the [ShellCheck Orb](https://circleci.com/orbs/registry/orb/circleci/shellcheck)
- [Github](https://github.com/features/actions) (only Linux)

Most other services, including [GitLab](https://about.gitlab.com/), let you install ShellCheck yourself.

It's a good idea to manually install a specific ShellCheck version regardless. This avoids any surprise build breaks when a new version with new warnings is published.

For customized filtering or reporting, ShellCheck can output simple JSON, CheckStyle compatible XML, GCC compatible warnings as well as human readable text (with or without ANSI colors). See the [Integration](https://github.com/koalaman/shellcheck/wiki/Integration) wiki page for more documentation.

## 3. Installing

### 3.1. Using Package Manager

The easiest way to install ShellCheck locally is through your *package manager*.

On **macOS** with Homebrew:

```sh
brew install shellcheck
```

On **Debian** based distros:

```sh
sudo apt install shellcheck
```

On **Arch Linux** based distros:

```sh
pacman -S shellcheck
```

> or get the dependency free [shellcheck-bin](https://aur.archlinux.org/packages/shellcheck-bin/) from the AUR.

On **EPEL** based distros:

```sh
sudo yum -y install epel-release
sudo yum install ShellCheck
```

On **Fedora** based distros:

```sh
dnf install ShellCheck
```

On **FreeBSD**:

```sh
pkg install hs-ShellCheck
```

On **OpenBSD**:

```sh
pkg_add shellcheck
```

On **Windows**

- via [scoop](http://scoop.sh):

    ```cmd
    C:\> scoop install shellcheck
    ```

- via [chocolatey](https://chocolatey.org/packages/shellcheck):

    ```cmd
    C:\> choco install shellcheck
    ```

From [conda-forge](https://anaconda.org/conda-forge/shellcheck):

```sh
conda install -c conda-forge shellcheck
```

From **Snap Store**:

```sh
snap install --channel=edge shellcheck
```

From **Docker Hub**:

```sh
docker run --rm -v "$PWD:/mnt" koalaman/shellcheck:stable myscript
# Or :v0.4.7 for that version, or :latest for daily builds
```

Using the [nix package manager](https://nixos.org/nix):

```sh
nix-env -iA nixpkgs.shellcheck
```

### 3.2. pre-commit

To run ShellCheck via [pre-commit](https://pre-commit.com/), add the hook to your `.pre-commit-config.yaml`:

```yaml
repos:
-   repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.7.2
    hooks:
    -   id: shellcheck
#       args: ["--severity=warning"]  # Optionally only show errors and warnings
```

### 3.3. Travis CI

Travis CI has now integrated ShellCheck by default, so you don't need to manually install it.

## 4. Ignoring issues

> <https://github.com/koalaman/shellcheck/wiki/Ignore>

Issues can be ignored via environmental variable, command line, individually or globally within a file:

### 4.1. Ignoring one specific instance in a file

Use a [directive](https://github.com/koalaman/shellcheck/wiki/Directive) to disable a certain instance:

```sh
hexToAscii() {
  # shellcheck disable=SC2059
  printf "\x$1"
}
```

You can pass multiple errors to directive:

```sh
# shellcheck disable=SC2116,SC2086
hash=$(echo ${hash})    # trim spaces
```

### 4.2. Ignoring all instances in a file

Add a directive at the top of the file:

```sh
#!/bin/sh

# shellcheck disable=SC2059

...
```

Note that the directive must be on the first line after the shebang with versions before 0.4.6. As of 0.4.6 comments and **whitespace are allowed** before file-wide directives.

### 4.3. Ignoring all errors in a file

Add a directive at the top of the file:

```sh
#!/bin/sh

# shellcheck disable=all

...
```

Note that the directive must be on the first non-commented/non-whitespace line after the shebang with versions after 0.4.6.

### 4.4. Ignoring errors in one specific run

Use a `-e` flag to disable a specific error when running `shellcheck`:

```console
shellcheck -e SC2059 myscript
```

### 4.5. Ignoring one or more types of errors forever

You can create a file `.shellcheckrc` in your home directory (or your project's base directory), and add `disable` directives to it:

```sh
# ~/.shellcheckrc
disable=SC2059,SC2034 # Disable individual error codes
disable=SC1090-SC1100 # Disable a range of error codes
```

## 5. Gallery of bad code

So what kind of things does ShellCheck look for? Here is an incomplete list of detected issues.

### 5.1. Quoting

ShellCheck can recognize several types of incorrect quoting:

```sh
echo $1                           # Unquoted variables
find . -name *.ogg                # Unquoted find/grep patterns
rm "~/my file.txt"                # Quoted tilde expansion
v='--verbose="true"'; cmd $v      # Literal quotes in variables
for f in "*.ogg"                  # Incorrectly quoted 'for' loops
touch $@                          # Unquoted $@
echo 'Don't forget to restart!'   # Single-quote closed by apostrophe
echo 'Don\'t try this at home'    # Attempting to escape ' in ''
echo 'Path is $PATH'              # Variables in single quotes
trap "echo Took ${SECONDS}s" 0    # Prematurely expanded trap
unset var[i]                      # Array index treated as glob
```

### 5.2. Conditionals

ShellCheck can recognize many types of incorrect test statements.

```sh
[[ n != 0 ]]                      # Constant test expressions
[[ -e *.mpg ]]                    # Existence checks of globs
[[ $foo==0 ]]                     # Always true due to missing spaces
[[ -n "$foo " ]]                  # Always true due to literals
[[ $foo =~ "fo+" ]]               # Quoted regex in =~
[ foo =~ re ]                     # Unsupported [ ] operators
[ $1 -eq "shellcheck" ]           # Numerical comparison of strings
[ $n && $m ]                      # && in [ .. ]
[ grep -q foo file ]              # Command without $(..)
[[ "$$file" == *.jpg ]]           # Comparisons that can't succeed
(( 1 -lt 2 ))                     # Using test operators in ((..))
[ x ] & [ y ] | [ z ]             # Accidental backgrounding and piping
```

### 5.3. Frequently misused commands

ShellCheck can recognize instances where commands are used incorrectly:

```sh
grep '*foo*' file                 # Globs in regex contexts
find . -exec foo {} && bar {} \;  # Prematurely terminated find -exec
sudo echo 'Var=42' > /etc/profile # Redirecting sudo
time --format=%s sleep 10         # Passing time(1) flags to time builtin
while read h; do ssh "$h" uptime  # Commands eating while loop input
alias archive='mv $1 /backup'     # Defining aliases with arguments
tr -cd '[a-zA-Z0-9]'              # [] around ranges in tr
exec foo; echo "Done!"            # Misused 'exec'
find -name \*.bak -o -name \*~ -delete  # Implicit precedence in find
# find . -exec foo > bar \;       # Redirections in find
f() { whoami; }; sudo f           # External use of internal functions
```

### 5.4. Common beginner's mistakes

ShellCheck recognizes many common beginner's syntax errors:

```sh
var = 42                          # Spaces around = in assignments
$foo=42                           # $ in assignments
for $var in *; do ...             # $ in for loop variables
var$n="Hello"                     # Wrong indirect assignment
echo ${var$n}                     # Wrong indirect reference
var=(1, 2, 3)                     # Comma separated arrays
array=( [index] = value )         # Incorrect index initialization
echo $var[14]                     # Missing {} in array references
echo "Argument 10 is $10"         # Positional parameter misreference
if $(myfunction); then ..; fi     # Wrapping commands in $()
else if othercondition; then ..   # Using 'else if'
f; f() { echo "hello world; }     # Using function before definition
[ false ]                         # 'false' being true
if ( -f file )                    # Using (..) instead of test
```

### 5.5. Style

ShellCheck can make suggestions to improve style:

```sh
[[ -z $(find /tmp | grep mpg) ]]  # Use grep -q instead
a >> log; b >> log; c >> log      # Use a redirection block instead
echo "The time is `date`"         # Use $() instead
cd dir; process *; cd ..;         # Use subshells instead
echo $[1+2]                       # Use standard $((..)) instead of old $[]
echo $(($RANDOM % 6))             # Don't use $ on variables in $((..))
echo "$(date)"                    # Useless use of echo
cat file | grep foo               # Useless use of cat
```

### 5.6. Data and typing errors

ShellCheck can recognize issues related to data and typing:

```sh
args="$@"                         # Assigning arrays to strings
files=(foo bar); echo "$files"    # Referencing arrays as strings
declare -A arr=(foo bar)          # Associative arrays without index
printf "%s\n" "Arguments: $@."    # Concatenating strings and arrays
[[ $# > 2 ]]                      # Comparing numbers as strings
var=World; echo "Hello " var      # Unused lowercase variables
echo "Hello $name"                # Unassigned lowercase variables
cmd | read bar; echo $bar         # Assignments in subshells
cat foo | cp bar                  # Piping to commands that don't read
printf '%s: %s\n' foo             # Mismatches in printf argument count
eval "${array[@]}"                # Lost word boundaries in array eval
for i in "${x[@]}"; do ${x[$i]}   # Using array value as key
```

### 5.7. Robustness

ShellCheck can make suggestions for improving the robustness of a script:

```sh
rm -rf "$STEAMROOT/"*            # Catastrophic rm
touch ./-l; ls *                 # Globs that could become options
find . -exec sh -c 'a && b {}' \; # Find -exec shell injection
printf "Hello $name"             # Variables in printf format
for f in $(ls *.txt); do         # Iterating over ls output
export MYVAR=$(cmd)              # Masked exit codes
case $version in 2.*) :;; 2.6.*) # Shadowed case branches
```

### 5.8. Portability

ShellCheck will warn when using features not supported by the shebang. For example, if you set the shebang to `#!/bin/sh`, ShellCheck will warn about portability issues similar to `checkbashisms`:

```sh
echo {1..$n}                     # Works in ksh, but not bash/dash/sh
echo {1..10}                     # Works in ksh and bash, but not dash/sh
echo -n 42                       # Works in ksh, bash and dash, undefined in sh
expr match str regex             # Unportable alias for `expr str : regex`
trap 'exit 42' sigint            # Unportable signal spec
cmd &> file                      # Unportable redirection operator
read foo < /dev/tcp/host/22      # Unportable intercepted files
foo-bar() { ..; }                # Undefined/unsupported function name
[ $UID = 0 ]                     # Variable undefined in dash/sh
local var=value                  # local is undefined in sh
time sleep 1 | sleep 5           # Undefined uses of 'time'
```

### 5.9. Miscellaneous

ShellCheck recognizes a menagerie of other issues:

```sh
PS1='\e[0;32m\$\e[0m '            # PS1 colors not in \[..\]
PATH="$PATH:~/bin"                # Literal tilde in $PATH
rm “file”                         # Unicode quotes
echo "Hello world"                # Carriage return / DOS line endings
echo hello \                      # Trailing spaces after \
var=42 echo $var                  # Expansion of inlined environment
!# bin/bash -x -e                 # Common shebang errors
echo $((n/180*100))               # Unnecessary loss of precision
ls *[:digit:].txt                 # Bad character class globs
sed 's/foo/bar/' file > file      # Redirecting to input
var2=$var2                        # Variable assigned to itself
[ x$var = xval ]                  # Antiquated x-comparisons
ls() { ls -l "$@"; }              # Infinitely recursive wrapper
alias ls='ls -l'; ls foo          # Alias used before it takes effect
for x; do for x; do               # Nested loop uses same variable
while getopts "a" f; do case $f in "b") # Unhandled getopts flags
```

## 6. Other Resources

- The wiki has [long form descriptions](https://github.com/koalaman/shellcheck/wiki/Checks) for each warning, e.g. [SC2221](https://github.com/koalaman/shellcheck/wiki/SC2221).
- ShellCheck does not attempt to enforce any kind of formatting or indenting style, so also check out [shfmt](https://github.com/mvdan/sh).
