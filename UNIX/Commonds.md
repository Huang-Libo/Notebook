# Frequently Used Commands

- [Frequently Used Commands](#frequently-used-commands)
  - [tee](#tee)

## tee

`tee` – duplicate standard input

The `tee` utility copies standard input to standard output, making a copy in zero or more files.  The output is unbuffered.

**e.g.**

Send the echoed message *both* to **stdout** and to the **greetings.txt** file:

```bash
$ echo "Hello" | tee greetings.txt
Hello
```
