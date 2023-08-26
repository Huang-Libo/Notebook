# The AWK Programming Language  <!-- omit in toc -->

- [1. Chapter 1: AN AWK TUTORIAL](#1-chapter-1-an-awk-tutorial)
  - [1.1. Getting Started](#11-getting-started)
    - [1.1.1. The Structure of an AWK Program](#111-the-structure-of-an-awk-program)
    - [1.1.2. Running an AWK Program](#112-running-an-awk-program)
    - [1.1.3. Errors](#113-errors)
  - [1.2. Simple Output](#12-simple-output)
    - [1.2.1. Printing Every Line](#121-printing-every-line)
    - [1.2.2. Printing Certain Fields](#122-printing-certain-fields)
    - [1.2.3. NF, the Number of Fields](#123-nf-the-number-of-fields)
    - [1.2.4. NR, the Number of Records](#124-nr-the-number-of-records)
    - [1.2.5. Putting Text in the Output](#125-putting-text-in-the-output)
  - [1.3. Fancier Output](#13-fancier-output)
    - [1.3.1. Lining Up Fields](#131-lining-up-fields)
    - [1.3.2. Sorting the Output](#132-sorting-the-output)
  - [1.4. Selection](#14-selection)

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

```bash
awk 'program' input files
```

to run the *program* on each of the specified input files. For example, you could type

```bash
awk '$3 == 0 { print $1 }' file1 file2
```

You can omit the input files from the command line and just type

```awk
awk 'program'
```

In this case awk will apply the program to whatever you type next on your terminal until you type an end-of-file signal (`Control-D` on Unix systems).

Here is a sample of a session on Unix:

```bash
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

```bash
awk -f <progfile> <optional list of input files>
```

The `-f` option instructs awk to fetch the program from the named file. Any filename can be used in place of *progfile*.

#### 1.1.3. Errors

If you make an error in an awk program, awk will give you a diagnostic message. For example, if you mistype a brace, like this:

```bash
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

The rest of this chapter contains a collection of short, typical awk programs based on manipulation of the `emp.data` file above.

There are only two types of data in awk: **numbers** and **strings** of characters. The `emp.data` file is typical of this kind of information - a mixture of words and numbers separated by *blanks* and/or *tabs*.

Awk reads its input one line at a time and splits each line into fields, where, by default, a field is a sequence of characters that doesn't contain any blanks or tabs. The first field in the current input line is called `$1`, the second `$2`, and so forth. The entire line is called `$0`. The number of fields can vary from line to line.

#### 1.2.1. Printing Every Line

If an action has no pattern, the action is performed for all input lines. The statement `print` by itself prints the current input line, so the program

```awk
{ print }
```

prints all of its input on the **standard output**. Since `$0` is the whole line,

```awk
{ print $0 }
```

does the same thing.

#### 1.2.2. Printing Certain Fields

More than one item can be printed on the same output line with a single print statement. The program to print the *first* and *third* fields of each input line is

```awk
{ print $1, $3 }
```

- Expressions separated by a *comma* in a `print` statement are, by default, separated by a single *blank* when they are printed.
- Each line produced by print ends with a *newline character*(`\n`).

Both of these defaults can be changed; we'll show how in Chapter 2.

#### 1.2.3. NF, the Number of Fields

It might appear you must always refer to fields as `$1`, `$2`, and so on, but any *expression* can be used after `$` to **denote** a field number, *the expression is evaluated and its numeric value is used as the field number*.

Awk counts the number of fields in the current input line and stores the count in *a built-in variable* called `NF`(*Number of Fields*). Thus, the program

```awk
{ print NF, $1, $NF }
```

prints *the number of fields* and the *first and last fields* of each input line.

#### 1.2.4. NR, the Number of Records

Awk provides another *built-variable*, called `NR`(*Number of Records*), that counts the *number of lines* read so far. We can use `NR` and `$0` to prefix each line of `emp.data` with its line number:

```awk
{ print NR, $0 }
```

The output looks like this:

```console
1 Beth  4.00    0
2 Dan   3.75    0
3 Kathy 4.00    10
4 Mark  5.00    20
5 Mary  5.50    22
6 Susie 4.25    18
```

#### 1.2.5. Putting Text in the Output

You can also print words in the midst of fields and computed values:

```awk
{ print "total pay for", $1, "is", $2 * $3 }
```

prints

```console
total pay for Beth is 0
total pay for Dan is 0
total pay for Kathy is 40
total pay for Mark is 100
total pay for Mary is 121
total pay for Susie is 76.5
```

In the `print` statement, the text inside the *double quotes* is printed along with the fields and computed values.

### 1.3. Fancier Output

The `print` statement is meant for quick and easy output. To format the output exactly the way you want it, you may have to use the `printf` statement. As we shall see in **Section 2.4**, `printf` can produce almost any kind of output, but in this section we'll only show a few of its capabilities.

#### 1.3.1. Lining Up Fields

The `printf` statement has the form

```awk
printf(format, value_1, value_2, ..., value_n)
```

Here's a program that uses `printf` to print the total pay for every employee:

```awk
{ printf("total pay for %s is $%.2f\n", $1, $2 * $3) }
```

With `emp.data` as input, this program yields:

```console
total pay for Beth is $0.00
total pay for Dan is $0.00
total pay for Kathy is $40.00
total pay for Mark is $100.00
total pay for Mary is $121.00
total pay for Susie is $76.50
```

With `printf`, no *blanks* or *newlines* are produced automatically; you must create them yourself. Don't forget the `\n`.

Here's another program that prints each employee's *name* and *pay*:

```awk
{ printf("%-8s $%6.2f\n", $1, $2 * $3) }
```

- The first specification, `%-8s`, prints a name as a string of characters **left** justified in a field **8** characters wide.
- The second specification, `%6.2f`, prints the pay as a number with two digits after the decimal point, in a field **6** characters wide:

```console
Beth     $  0.00
Dan      $  0.00
Kathy    $ 40.00
Mark     $100.00
Mary     $121.00
Susie    $ 76.50
```

#### 1.3.2. Sorting the Output

Suppose you want to print all the data for each employee, along with his or her pay, *sorted in order of increasing pay*.

The easiest way is to use awk to prefix the total pay to each employee record, and run that output through a sorting program. On Unix, the command line

```bash
awk '{ printf("%6.2f  %s\n", $2 * $3, $0) }' emp.data | sort
```

pipes the output of `awk` into the `sort` command, and produces:

```console
  0.00  Beth    4.00    0
  0.00  Dan     3.75    0
 40.00  Kathy   4.00    10
 76.50  Susie   4.25    18
100.00  Mark    5.00    20
121.00  Mary    5.50    22
```

### 1.4. Selection
