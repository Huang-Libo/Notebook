# The AWK Programming Language  <!-- omit in toc -->

- [1. Chapter 1: AN AWK TUTORIAL](#1-chapter-1-an-awk-tutorial)
  - [1.1. Getting Started](#11-getting-started)
    - [1.1.1. The Structure of an AWK Program](#111-the-structure-of-an-awk-program)

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
