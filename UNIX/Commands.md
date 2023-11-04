# Frequently Used Commands <!-- omit in toc -->

- [1. `tr`](#1-tr)
- [2. `cut`](#2-cut)
- [3. `tee`](#3-tee)
- [4. `grep`](#4-grep)
- [5. `find`](#5-find)
  - [5.1. `find` + `-exec`](#51-find---exec)
  - [5.2. `find` + `xargs`](#52-find--xargs)

## 1. `tr`

`tr` – translate characters

**e.g.**

```bash
tr ':' '\n' <<< "$PATH"
```

- `-d`: Delete characters in string from the input.

## 2. `cut`

> The default *field delimiter* for `cut` is `\t`(tab).

`cut` – cut out selected portions of each line of a file

e.g.

```bash
cut -d ":" -f 1,4 /etc/passwd
```

- `-d delim`: Use delim as the *field delimiter* character instead of the tab character.
- `-f list`: The list specifies fields, separated in the input by the *field delimiter* character (see the `-d` option).  Output fields are separated by a single occurrence of the *field delimiter* character.

## 3. `tee`

`tee` – duplicate *standard input*

The `tee` command is used to read from *standard input* and write to both *standard output* and *one or more files* simultaneously.

**e.g.**

Send the echoed message to both *stdout* and to the *output.txt* file:

```bash
$ echo "Hello" | tee output.txt
Hello
```

## 4. `grep`

- `-v, --invert-match`: Selected lines are those not matching any of the specified patterns.
- `-r, -R, --recursive`: Recursively search subdirectories listed.  (i.e., force grep to behave as rgrep).
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

## 5. `find`

### 5.1. `find` + `-exec`

### 5.2. `find` + `xargs`

E.g.

```bash
find . -name "*.sh" -print0 | xargs -0 grep "<content>"
```
