# FAQ for *NIX

- [FAQ for *NIX](#faq-for-nix)
  - [Arguments in `if` Statement](#arguments-in-if-statement)
    - [String](#string)
    - [Number](#number)
  - [`$0`](#0)
  - [How to display `$PATH` as one directory per line?](#how-to-display-path-as-one-directory-per-line)
  - [What's the difference between `<<` and `<<<`](#whats-the-difference-between--and-)
    - [Here Document: output multi lines](#here-document-output-multi-lines)
    - [Here String Usage](#here-string-usage)
  - [Process Substitution](#process-substitution)
    - [Introduction](#introduction)
    - [Difference between Process Substitution and Pipe](#difference-between-process-substitution-and-pipe)
  - [Exit status of a command](#exit-status-of-a-command)

## Arguments in `if` Statement

### String

| Option | Explain             |
|--------|---------------------|
| `==`   | string equal        |
| `!=`   | string not equal    |
| `-z`   | string is empty     |
| `-n`   | string is not empty |

### Number

| Option | Explain                  |
|--------|--------------------------|
| `-eq`  | equal to                 |
| `-ne`  | not equal to             |
| `-gt`  | greater than             |
| `-ge`  | greater than or equal to |
| `-lt`  | less than                |
| `-le`  | less than or equal to    |

## `$0`

You can use `$0` to obtain the corresponding program name which is executed in shell scripts:

- If you use *relative path*, for example, `./test.sh`, then `$0` equals to `./test.sh`;
- If you use *absolute path*, for example, `/User/username/test.sh`, then `$0` equals to `/User/username/test.sh`.

So, if you just want to get the program file name without path, you can use `basename` command in shell script:

```bash
script_file_name=$(basename $0)
```

## How to display `$PATH` as one directory per line?

> From [ask ubuntu](https://askubuntu.com/a/600019).

**Question**:

By default, the output of `PATH` is separated by colon:

```plaintext
$ echo $PATH
/bin:/usr/bin:/usr/local/bin
```

The above display style is hard for human to read, it will be better if directories in `PATH` is displayed in single lines:

```plaintext
/bin
/usr/bin
/usr/local/bin
```

**Solution**:

You can do this with any one of the following commands, which substitutes all occurrences of `:` with new lines `\n`.

`sed`:

```sh
sed 's/:/\n/g' <<< "$PATH"
```

`tr`:

```sh
tr ':' '\n' <<< "$PATH"
```

`python`:

```sh
python -c "print(r'$PATH'.replace(':', '\n'))"
```

**Add function to ~/.zshrc**:

```sh
function mypath() { tr ':' '\n' <<< "$PATH" }
```

Then you can use `mypath` to display directories in `PATH` in single lines.

## What's the difference between `<<` and `<<<`

> From [ask ubuntu](https://askubuntu.com/questions/678915/whats-the-difference-between-and-in-bash)

### Here Document: output multi lines

`<<` is known as **here-document** structure. You let the program know what will be the ending text, and whenever that delimiter is seen, the program will read all the stuff you've given to the program as input and perform a task upon it.

**e.g. 1**

> `wc`: The wc utility displays the number of *lines*, *words*, and *bytes* contained in each input file, or standard input (if no file is specified) to the standard output.

```bash
$ wc << EOF
> one two three
> four five
> EOF
```

Output:

```console
       2       5      24
```

**e.g. 2**

```bash
$ cat << EOF
> Line 1
> Line 2
> Line 3
> EOF
```

Output:

```console
Line 1
Line 2
Line 3
```

### Here String Usage

`<<<` is known as **here-string**. Instead of typing in text, you give a pre-made string of text to a program. For example, with such program as `bc` we can do `bc <<< 5*4` to just get output for that specific case, no need to run `bc` interactively. Think of it as the equivalent of `echo '5*4' | bc`.

## Process Substitution

### Introduction

> [Wikipedia](https://en.wikipedia.org/wiki/Process_substitution)

*Process substitution* is a form of *inter-process communication(IPC)* that **allows the input or output of a command to appear as a file**. The command is substituted in-line, where a file name would normally occur, by the command shell. This allows programs that normally only accept files to directly read from or write to another program.

**e.g.**

The Unix `diff` command normally accepts the names of two files to compare, or one file name and standard input. *Process substitution* allows one to compare the output of two programs directly:

```bash
diff <(sort file1) <(sort file2)
```

The `<(command)` expression tells the command interpreter to run *command* and **make its output appear as a file**. The *command* can be any arbitrarily complex shell command.

Without *process substitution*, the alternatives are save the output of the command(s) to a temporary file, then read the temporary file(s):

```bash
sort file2 > /tmp/file2.sorted
sort file1 | diff - /tmp/file2.sorted
rm /tmp/file2.sorted
```

### Difference between Process Substitution and Pipe

> From [Stack Exchange](https://unix.stackexchange.com/questions/17107/process-substitution-and-pipe)

Let's use the `date` command for testing.

```bash
$ date | cat
Thu Jul 21 12:39:18 EEST 2011
```

This is a pointless example but it shows that `cat` accepted the output of `date` on STDIN and spit it back out. The same results can be achieved by *process substitution*:

```bash
$ cat <(date)
Thu Jul 21 12:40:53 EEST 2011
```

However what just happened behind the scenes was different. Instead of being given a STDIN stream, `cat` was actually passed the **name of a file** that it needed to go open and read. You can see this step by using `echo` instead of `cat`.

```bash
$ echo <(date)
/proc/self/fd/11
```

When `cat` received the file name, it read the file's content for us. On the other hand, `echo` just showed us the file's name that it was passed. This difference becomes more obvious if you add more substitutions:

```bash
$ cat <(date) <(date) <(date)
Thu Jul 21 12:44:45 EEST 2011
Thu Jul 21 12:44:45 EEST 2011
Thu Jul 21 12:44:45 EEST 2011

$ echo <(date) <(date) <(date)
/proc/self/fd/11 /proc/self/fd/12 /proc/self/fd/13
```

It is possible to combine *process substitution* (**which generates a file**) and *input redirection* (which connects a file to STDIN):

```bash
$ cat < <(date)
Thu Jul 21 12:46:22 EEST 2011
```

It looks pretty much the same but this time **cat was passed STDIN stream instead of a file name**. You can see this by trying it with echo:

```bash
$ echo < <(date)
<blank>
```

Since `echo` doesn't read STDIN and no argument was passed, we get nothing.

Pipes and input redirects shove content onto the STDIN stream. *Process substitution* runs the commands, saves their output to a **special temporary file** and then passes that file name in place of the command. **Whatever command you are using treats it as a file name**. Note that the file created is not a regular file but a named pipe that gets removed automatically once it is no longer needed.

## Exit status of a command

- value of `$?`
  - `0`: Command run **success**
  - `1`: Command **failed** during run
  - `2`: Incorrect command usage
  - `127`: Command not found
