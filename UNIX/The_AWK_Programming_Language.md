# The AWK Programming Language  <!-- omit in toc -->

- [1. Chapter 1: AN AWK TUTORIAL](#1-chapter-1-an-awk-tutorial)
  - [1.1. Getting Started](#11-getting-started)
    - [1.1.1. The Structure of an AWK Program](#111-the-structure-of-an-awk-program)
    - [1.1.2. Running an AWK Program](#112-running-an-awk-program)
    - [1.1.3. Errors](#113-errors)
  - [1.2. Simple Output](#12-simple-output)

Computer users spend a lot of time doing simple, mechanical data manipulation - changing the format of data, checking its validity, finding items with some property, adding up numbers, printing reports, and the like. All of these jobs ought to be mechanized, but it's a real nuisance to have to write a special purpose program in a standard language like C or Pascal each time such a task comes up.

Awk is a programming language that makes it possible to handle such tasks with very short programs, often only one or two lines long. An awk program is **a sequence of patterns and actions** that tell what to look for in the input data and what to do when it's found. Awk searches a set of files for lines matched by any of the patterns; **when a matching line is found, the corresponding action is performed**.

- **Patterns** can select lines by combinations of regular expressions and comparison operations on strings, numbers, fields, variables, and array elements.
- **Actions** may perform arbitrary processing on selected lines; the action language looks like `C` but there are no declarations, and strings and numbers are built-in data types.

Awk scans the input files and splits each input line into fields automatically. Because so many things are automatic - input, field splitting, storage management, initialization - awk programs are usually much smaller than they would be in a more conventional language. Thus one common use of awk is for the kind of data manipulation suggested above. Programs, a line or two long, are composed at the keyboard, run once, then discarded. In effect, awk is a general-purpose programmable tool that can replace a host of specialized tools or programs.

## 1. Chapter 1: AN AWK TUTORIAL

### 1.1. Getting Started

Suppose you have a file called `emp.data` that contains the name, pay rate in dollars per hour, and number of hours worked for your employees, one employee record per line, like this:

```plaintext
Beth    4.00    0
Dan     3.75    0
Kathy   4.00    10
Mark    5.00    20
Mary    5.50    22
Susie   4.25    18
```

Now you want to print the name and pay (rate times hours) for everyone who worked more than zero hours:

```bash
$ awk '$3 > 0 { print $1, $2 * $3 }' emp.data

Kathy 40
Mark 100
Mary 121
Susie 76.5
```

The part inside the quotes is the complete awk program. It consists of a single **pattern-action** statement.

- The **pattern** `$3 > 0`, matches every input line in which the third column, or field, is greater than zero
- The **action** `{ print $1, $2 * $3 }` prints the first field and the product of the second and third fields of each matched line.

#### 1.1.1. The Structure of an AWK Program

In the command lines above, the parts between the quote characters are programs written in the *awk programming language*. Each awk program in this chapter is a sequence of one or more *pattern-action* statements:

```awk
pattern { action }
pattern { action }
...
```

The basic operation of awk is to scan a sequence of input lines one after another, searching for lines that are matched by any of the patterns in the program.

```awk
$3 == 0 { print $1 }
```

is a single pattern-action statement; for every line in which the third field is zero, the first field is printed.

Either the *pattern* or the *action* (but not both) in a pattern-action statement may be omitted.

- If a pattern has no action, for example,

  ```awk
  $3 == 0
  ```

  then each line that the pattern matches (that is, each line for which the condition is true) is printed.

- If there is an action with no pattern, for example,

  ```awk
  { print $1 }
  ```

  then the action, in this case printing the first field, is performed for every input line.

Since patterns and actions are both *optional*, actions are enclosed in *braces* to distinguish them from patterns.

#### 1.1.2. Running an AWK Program

There are several ways to run an awk program. You can type a command line of the form

```awk
awk 'program' input files
```

to run the *program* on each of the specified input files. For example, you could type

```awk
awk '$3 == 0 { print $1 }' file1 file2
```

You can omit the input files from the command line and just type

```awk
awk 'program'
```

In this case awk will apply the program to whatever you type next on your terminal until you type an end-of-file signal (`Control-D` on Unix systems).

Here is a sample of a session on Unix:

```console
$ awk '$3 == 0 { print $1 }'
Beth 4.00 0
-> Beth
Dan 3.75 0
-> Dan
Kathy 3.75 10
Kathy 3.75 0
-> Kathy
...
```

The characters after `->` are what the computer printed.

This behavior makes it easy to experiment with awk: type your program, then type data at it and see what happens.

Notice that the program is enclosed in **single quotes** on the command line.

- This protects characters like `$` in the program from being interpreted by the shell
- and also allows the program to be longer than one line.

This arrangement is convenient when the program is short (a few lines).

If the program is long, however, it is more convenient to put it into a separate file, say *progfile*, and type the command line

```console
awk -f <progfile> <optional list of input files>
```

The `-f` option instructs awk to fetch the program from the named file. Any filename can be used in place of *progfile*.

#### 1.1.3. Errors

If you make an error in an awk program, awk will give you a diagnostic message. For example, if you mistype a brace, like this:

```console
awk '$3 > 0 [ print $1, $2 * $3 }' emp.data
```

you will get a message like this:

```console
awk: syntax error at source line 1
 context is
        $3 > 0 >>>  [ <<< 
        extra }
        missing ]
awk: bailing out at source line 1
```

- *"Syntax error"* means that you have made a grammatical error that was detected at the place marked by `>>> <<<`.
- *"Bailing out"* means that no recovery was attempted.

### 1.2. Simple Output
