# Frequently Used Commands

- [Frequently Used Commands](#frequently-used-commands)
  - [tr](#tr)
  - [cut](#cut)
  - [tee](#tee)
  - [`grep`](#grep)

## tr

`tr` – translate characters

**e.g.**

```bash
tr ':' '\n' <<< "$PATH"
```

- `-d`: Delete characters in string from the input.

## cut

> The default *field delimiter* for `cut` is *tab*.

`cut` – cut out selected portions of each line of a file

e.g.

```bash
cut -d ":" -f 1,4 /etc/passwd
```

- `-d delim`: Use delim as the *field delimiter* character instead of the tab character.
- `-f list`: The list specifies fields, separated in the input by the *field delimiter* character (see the `-d` option).  Output fields are separated by a single occurrence of the *field delimiter* character.

## tee

`tee` – duplicate standard input

The `tee` utility copies standard input to standard output, making a copy in zero or more files.  The output is unbuffered.

**e.g.**

Send the echoed message *both* to **stdout** and to the **greetings.txt** file:

```bash
$ echo "Hello" | tee greetings.txt
Hello
```

## `grep`

- `-i, --ignore-case`: Perform case insensitive matching.  By default, grep is case sensitive.
- `-E, --extended-regexp`: Interpret pattern as an *extended regular expression* (i.e., force `grep` to behave as `egrep`).

**Use pattern**:

```bash
$ grep -E "pyenv" .zshrc
# pyenv
eval "$(pyenv init -)"
```

```bash
$ grep -E "pyenv$" .zshrc
# pyenv
```

Match empty lines:

```bash
grep -E "^$" .zshrc
```
