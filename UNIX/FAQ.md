# FAQ for UNIX<!-- omit in toc -->

- [1. Arguments in `if` Statement](#1-arguments-in-if-statement)
  - [1.1. File](#11-file)
  - [1.2. String](#12-string)
  - [1.3. Number](#13-number)
- [2. `shift` variables](#2-shift-variables)
  - [2.1. shift one parameter](#21-shift-one-parameter)
  - [2.2. shift multiple parameters](#22-shift-multiple-parameters)
- [3. Special variables in Bash](#3-special-variables-in-bash)
  - [3.1. `$?`](#31-)
  - [3.2. `$0`](#32-0)
  - [3.3. `$#` and `${!#}`](#33--and-)
  - [3.4. `$*` and `$@`](#34--and-)
- [4. How to display `$PATH` as one directory per line?](#4-how-to-display-path-as-one-directory-per-line)
- [5. What's the difference between `<<` and `<<<`](#5-whats-the-difference-between--and-)
  - [5.1. Here Document: output multi lines](#51-here-document-output-multi-lines)
  - [5.2. Here String Usage](#52-here-string-usage)
- [6. Process Substitution](#6-process-substitution)
  - [6.1. Introduction](#61-introduction)
  - [6.2. Difference between Process Substitution and Pipe](#62-difference-between-process-substitution-and-pipe)
- [7. Process Status](#7-process-status)
  - [7.1. `ps aux`](#71-ps-aux)

## 1. Arguments in `if` Statement

### 1.1. File

| Option | Explain                       |
| ------ | ----------------------------- |
| `-e`   | The given path exists         |
| `-d`   | The given path is a directory |
| `-f`   | The given path is a file      |
| `-r`   | The given path is readable    |
| `-w`   | The given path is writable    |
| `-x`   | The given path is executable  |

### 1.2. String

| Option | Explain             |
| ------ | ------------------- |
| `==`   | string equal        |
| `!=`   | string not equal    |
| `-z`   | string is empty     |
| `-n`   | string is not empty |

### 1.3. Number

| Option | Explain                  |
| ------ | ------------------------ |
| `-eq`  | equal to                 |
| `-ne`  | not equal to             |
| `-gt`  | greater than             |
| `-ge`  | greater than or equal to |
| `-lt`  | less than                |
| `-le`  | less than or equal to    |

## 2. `shift` variables

> Note: `$0` won't be changed by `shift` command.

The `shift` command literally shifts the command-line parameters in their relative positions.

When you use the shift command, it moves each parameter variable one position to the left by default. Thus, the value for variable $3 is moved to $2 , the value for variable $2 is moved to $1 , and the value for variable $1 is discarded (note that the value for variable $0 , the program name, remains unchanged).

This is another great way to iterate through command-line parameters. You can just operate on the first parameter, shift the parameters over, and then operate on the first parameter again.

### 2.1. shift one parameter

Here's a short demonstration of how this works:

**shift-params.sh**:

```bash
#!/bin/bash

# Shifting through the parameters
echo
echo "Using the shift method:"
count=1
while [ -n "$1" ]
do
     echo "Parameter #$count = $1"
     count=$[ $count + 1 ]
     shift
done
echo
exit
```

```bash
$ ./shift-params.sh alpha bravo charlie delta
 
Using the shift method:
Parameter #1 = alpha
Parameter #2 = bravo
Parameter #3 = charlie
Parameter #4 = delta
```

> **NOTE**: Be careful when working with the shift command. When a parameter is shifted out, its value is lost and can't be recovered.

### 2.2. shift multiple parameters

Alternatively, you can perform a multiple location shift by providing a parameter to the shift command. Just provide the number of places you want to shift:

**big-shift-params.sh**:

```bash
#!/bin/bash

# Shifting multiple positions through the parameters
echo
echo "The original parameters: $*"
echo "Now shifting 2..."
shift 2
echo "Here's the new first parameter: $1"
echo
exit
```

```bash
$ ./big-shift-params.sh alpha bravo charlie delta
 
The original parameters: alpha bravo charlie delta
Now shifting 2...
Here's the new first parameter: charlie
```

By using values in the shift command, you can easily skip over parameters you don't need in certain situations.

## 3. Special variables in Bash

### 3.1. `$?`

Exit status of a command

- `0`: Command run **success**
- `1`: Command **failed** during run
- `2`: Incorrect command usage
- `127`: Command not found

### 3.2. `$0`

You can use `$0` to obtain the corresponding program name which is executed in shell scripts:

- If you use *relative path*, for example, `./test.sh`, then `$0` equals to `./test.sh`;
- If you use *absolute path*, for example, `/User/username/test.sh`, then `$0` equals to `/User/username/test.sh`.

So, if you just want to get the program file name without path, you can use `basename` command in shell script:

```bash
script_file_name=$(basename $0)
```

### 3.3. `$#` and `${!#}`

`$#` is used for getting the number of parameters.

If you need to get the *last* parameter, you **cannot** use `${$#}`, because you shouldn't use `$` sign inside the `{}` pair. You have two choices:

1. Use a temp parameter:

    ```bash
    param_count=$#
    last_param=${param_count}
    ```

2. Use `${!#}` (change `$` to `!` inside the `{}` pair).

### 3.4. `$*` and `$@`

Both `$*` and `$@` variables provide quick access to all parameters. [The difference appears when the special parameters are quoted](https://stackoverflow.com/a/28099707):

| Syntax | Effective Result          |
| ------ | :------------------------ |
| `$*`   | `$1 $2 $3 … ${N}`         |
| `$@`   | `$1 $2 $3 … ${N}`         |
| `"$*"` | `"$1c$2c$3c…c${N}`"       |
| `"$@"` | `"$1" "$2" "$3" … "${N}"` |

where `c` in the third row is the first character of `$IFS`, the *Input Field Separator*, a shell variable.

## 4. How to display `$PATH` as one directory per line?

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

## 5. What's the difference between `<<` and `<<<`

> From [ask ubuntu](https://askubuntu.com/questions/678915/whats-the-difference-between-and-in-bash)

### 5.1. Here Document: output multi lines

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

### 5.2. Here String Usage

`<<<` is known as **here-string**. Instead of typing in text, you give a pre-made string of text to a program. For example, with such program as `bc` we can do `bc <<< 5*4` to just get output for that specific case, no need to run `bc` interactively. Think of it as the equivalent of `echo '5*4' | bc`.

## 6. Process Substitution

### 6.1. Introduction

> [Wikipedia: Process substitution
](https://en.wikipedia.org/wiki/Process_substitution)

*Process substitution* is a form of *inter-process communication(IPC)* that **allows the input or output of a command to appear as a file**. The command is substituted in-line, where a file name would normally occur, by the command shell. This allows programs that normally only accept files to directly read from or write to another program.

**e.g.1**

> Reference: [shellcheck/SC2031](https://www.shellcheck.net/wiki/SC2031)

There are many ways of accidentally creating **subshells**, but a common one is **piping** to a loop:

**Problematic code**:

```bash
n=0
printf "%s\n" {1..10} | while read i; do (( n+=i )); done
echo $n
```

**Correct code**:

```bash
n=0
while read i; do (( n+=i )); done < <(printf "%s\n" {1..10})
echo $n
```

**Rationale**:

Variables set in subshells are not available outside the subshell.

**e.g.2**

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

### 6.2. Difference between Process Substitution and Pipe

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

## 7. Process Status

### 7.1. `ps aux`

The `ps aux` command is a common and powerful way to list information about processes in Unix-like operating systems.

`ps`: This is the command itself and it stands for "**process status**". It is used to view information about running processes.

- `a`: This option tells ps to list information about **all** processes associated with terminals. It includes processes from all users.
- `u`: This option provides a more detailed output, including the user and other additional information about each process.
- `x`: This option adds processes not attached to a terminal. It includes background processes and daemons.

When you combine these options with `ps aux`, you're asking the system to list detailed information about all processes, including those of other users, both attached and not attached to a terminal.
