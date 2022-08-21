# Frequently Used Commands

- [Frequently Used Commands](#frequently-used-commands)
  - [tr](#tr)
  - [cut](#cut)
  - [tee](#tee)

## tr

`tr` – translate characters

**e.g.**

```bash
tr ':' '\n' <<< "$PATH"
```

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
