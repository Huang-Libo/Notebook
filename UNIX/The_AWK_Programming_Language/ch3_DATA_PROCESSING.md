# DATA PROCESSING <!-- omit in toc -->

- [1. Data Transformation and Reduction](#1-data-transformation-and-reduction)
  - [1.1. Summing Columns](#11-summing-columns)
  - [1.2. Computing Percentages and Quantiles](#12-computing-percentages-and-quantiles)
  - [1.3. Numbers with Commas](#13-numbers-with-commas)
  - [1.4. Fixed-Field Input](#14-fixed-field-input)
  - [1.5. Program Cross-Reference Checking](#15-program-cross-reference-checking)
  - [1.6. Formatted Output](#16-formatted-output)
- [2. Data Validation](#2-data-validation)
  - [2.1. Balanced Delimiters](#21-balanced-delimiters)
  - [2.2. Password-File Checking](#22-password-file-checking)

Awk was originally intended for everyday data-processing tasks, such as information retrieval, data validation, and data transformation and reduction. We have already seen simple examples of these in Chapters 1 and 2. In this chapter, we will consider more complex tasks of a similar nature.

- Most of the examples deal with the usual line-at-a-time processing,
- but the final section describes how to handle data where an input record may occupy several lines (*Multiline Records*).

Awk programs are often developed incrementally: a few lines are written and tested, then a few more added, and so on. Many of the longer programs in this book were developed in this way.

It's also possible to write awk programs in the traditional way, sketching the outline of the program, consulting the language manual, and so forth. But modifying an existing program to get the desired effect is frequently easier. The programs in this book thus serve another purpose, providing useful models for programming by example.

## 1. Data Transformation and Reduction

- One of the most common uses of awk is to transform data from one form to another, usually from the form produced by one program to a different form required by some other program.

- Another use is selection of relevant data from a larger data set, often with reformatting and the preparation of summary information.

This section contains a variety of examples of these topics.

### 1.1. Summing Columns

We have already seen several variants of the two-line awk program that adds up all the numbers in a single field. The following program performs a somewhat more complicated but still representative data-reduction task. Every input line has several fields, each containing numbers, and the task is to compute the sum of each column of numbers, regardless of how many columns there are.

```awk
# sum1 - print column sums
#   input:  rows of numbers
#   output: sum of each column
#     missing entries are treated as zeros

    { for (i = 1; i <= NF; i++)
          sum[i] += $i
      if (NF > maxfld)
          maxfld = NF
    }
END { for (i = 1; i <= maxfld; i++) {
          printf("%g", sum[i])
          if (i < maxfld)
              printf("\t")
          else
              printf("\n")
      }
    }
```

Automatic initialization is convenient here since `maxfld`, *the largest number of fields seen so far in any row*, starts off at `0` automatically, as do all of the entries in the `sum` array, even though it's not known until the end how many there are. It's also worth noting that the program prints nothing if the input file is empty.

It's convenient that the program doesn't need to be told how many fields a row has, but it doesn't check that the entries are all numbers, nor that each row has the same number of entries. The following program does the same job, but also checks that each row has the same number of entries as the first:

```awk
# sum2 - print column sums
#     check that each line has the same number of fields
#        as line one

NR==1 { nfld = NF }
      { for (i = 1; i <= NF; i++)
            sum[i] += $i
        if (NF != nfld)
            print "line " NR " has " NF " entries, not " nfld
      }
END   { for (i = 1; i <= nfld; i++)
            printf("%g%s", sum[i], i < nfld ? "\t" : "\n")
      }
```

We also revised the output code in the `END` action, to show how a *conditional expression* can be used to put *tabs* between the column sums and a *newline* after the last sum.

Now suppose that some of the fields are *nonnumeric*, so they shouldn't be included in the `sums`. The strategy is to add an array `numcol` to *keep track of which fields are numeric*, and a function `isnum` to check if an entry is a number. This is made a function so the test is only in one place, in anticipation of future changes. If the program can trust its input, it need only look at the first line to tell if a field will be numeric. The variable `nfld` is needed because `NF` is `0` inside the `END` action.

```awk
# sum3 - print sums of numeric columns
#     input:  rows of integers and strings
#     output: sums of numeric columns
#       assumes every line has same layout

NR==1 { nfld = NF
        for (i = 1; i <= NF; i++)
            numcol[i] = isnum($i)
      }

      { for (i = 1; i <= NF; i++)
            if (numcol[i])
                sum[i] += $i
      }

END   { for (i = 1; i <= nfld; i++) {
            if (numcol[i])
                printf("%g", sum[i])
            else
                printf("--")
            printf(i < nfld ? "\t" : "\n")
        }
      }

function isnum(n) { return n ~ /^[+-]?[0-9]+$/ }
```

> NOTE: `isnum` return `1` if matched, `0` otherwise.

The function `isnum` defines a number as one or more digits, perhaps preceded by a sign. A more general definition for numbers can be found in the discussion of regular expressions in *Section 2.1*.

**Exercise 3-1.** Modify the program `sum3` to ignore blank lines.

**Exercise 3-2.** Add the more general regular expression for a number. How does it affect the running time?

**Exercise 3-3.** What is the effect of removing the test of `numcol` in the second for statement?

**Exercise 3-4.** Write a program that reads a list of item and quantity pairs and for each item on the list accumulates the total quantity; at the end, it prints the items and total quantities, sorted alphabetically by item.

### 1.2. Computing Percentages and Quantiles

Suppose that we want not the sum of a column of numbers but what **percentage** each is of the total. This requires two passes over the data. If there's *only one column of numbers* and not too much data, the easiest way is to store the numbers in an array on the first pass, then compute the percentages on the second pass as the values are being printed:

```awk
# percent
#   input:  a column of nonnegative numbers
#   output: each number and its percentage of the total

    { x[NR] = $1; sum += $1 }

END { if (sum != 0)
          for (i = 1; i <= NR; i++)
              printf("%10.2f %5.1f\n", x[i], 100*x[i]/sum)
    }
```

This same approach, though with a more complicated transformation, could be used, for example, in adjusting student grades to fit some curve. Once the grades have been computed (as numbers between `0` and `100`), it might be interesting to see a *histogram*:

```awk
# histogram.awk
#   input:  numbers between 0 and 100
#   output: histogram of deciles

    { x[int($1/10)]++ }

END { for (i = 0; i < 10; i++)
          printf(" %2d - %2d: %3d %s\n",
              10*i, 10*i+9, x[i], rep(x[i],"*"))
      printf("100:      %3d %s\n", x[10], rep(x[10],"*"))
    }

function rep(n,s,   t) {  # return string of n s's
    while (n-- > 0)
        t = t s
    return t
}
```

Note how the *postfix decrement operator* `--` is used to control the `while` loop.

We can test `histogram.awk` with some randomly generated grades. The first program in the pipeline below generates *200* random numbers between `0` and `100`, and pipes them into the histogram maker.

```console
awk '
# generate random integers
BEGIN { for (i = 1; i <= 200; i++)
            print int(101*rand())
      }
' |
awk -f histogram.awk
```

It produces this output:

```console
  0 -  9:  17 *****************
 10 - 19:  23 ***********************
 20 - 29:  20 ********************
 30 - 39:  15 ***************
 40 - 49:  15 ***************
 50 - 59:  21 *********************
 60 - 69:  19 *******************
 70 - 79:  19 *******************
 80 - 89:  22 **********************
 90 - 99:  25 *************************
100:        4 ****
```

**Exercise 3-5.** Scale the rows of stars so they don't overflow the line length when there's a lot of data.

**Exercise 3-6.** Make a version of the histogram code that divides the input into a specified number of buckets, adjusting the ranges according to the data seen.

### 1.3. Numbers with Commas

Suppose we have a list of numbers that contain commas and decimal points, like `12,345.67`. **Since awk thinks that the first comma terminates a number**(The value of `12,345.67` will be treated as `12` when converting from *string* to *number*), these numbers cannot be summed directly. The commas must first be erased:

```awk
# sumcomma - add up numbers containing commas

    { gsub(/,/, ""); sum += $0 }
END { print sum }
```

**The effect of `gsub(/,/, "")` is to replace every comma with the *null string*, that is, to delete the commas.**

This program doesn't check that the commas are in the right places, nor does it print commas in its answer. Putting commas into numbers requires only a little effort, as the next program shows. It formats numbers with commas and two digits after the decimal point. The structure of this program is a useful one to emulate: it contains a function that only does the new thing, with the rest of the program just reading and printing. After it's been tested and is working, the new function can be included in the final program.

The basic idea is to insert commas from the decimal point to the left in a loop; each iteration puts a comma in front of the leftmost three digits that are followed by a comma or decimal point, provided there will be at least one additional digit in front of the comma. The algorithm uses recursion to handle negative numbers: if the input is negative, the function `addcomma` calls itself with the positive value, tacks on a leading minus sign, and returns the result.

```awk
# addcomma - put commas in numbers
#   input:  a number per line
#   output: the input number followed by
#      the number with commas and two decimal places 

    { printf("%-12s %20s\n", $0, addcomma($0)) }

function addcomma(x,   num) {
    if (x < 0)
        return "-" addcomma(-x)
    num = sprintf("%.2f", x)   # num is dddddd.dd
    while (num ~ /[0-9][0-9][0-9][0-9]/)
        sub(/[0-9][0-9][0-9][,.]/, ",&", num)
    return num
}
```

Note the use of the `&` in the replacement text for `sub` to add a comma *before* each triplet of numbers.

Here are the results for some test data:

```console
0                            0.00
-1                          -1.00
-12.34                     -12.34
12345                   12,345.00
-1234567.89         -1,234,567.89
-123.                     -123.00
-123456               -123,456.00
```

**Exercise 3-7.** Modify `sumcomma`, the program that adds numbers with commas, to check that the commas in the numbers are properly positioned.

### 1.4. Fixed-Field Input

Information appearing in *fixed-width fields* often requires some kind of preprocessing before it can be used directly. Some programs, such as spreadsheets, put out numbers in fixed columns, rather than with field separators; if the numbers are too wide, the columns abut. Fixed-field data is best handled with `substr`, which can be used to pick apart any combination of columns. For example, suppose the first `6` characters of each line contain a date in the form `mmddyy`. The easiest way to sort this by date is to convert the dates into the form `yymmdd`:

```awk
# date convert - convert mmddyy into yymmdd in $1

{ $1 = substr($1,5,2) substr($1,1,2) substr($1,3,2); print }
```

On input sorted by month, like this:

```plaintext
013042 mary's birthday
032772 mark's birthday
052470 anniversary
061209 mother's birthday
110175 elizabeth's birthday
```

it produces the output

```console
420130 mary's birthday
720327 mark's birthday
700524 anniversary
090612 mother's birthday
751101 elizabeth's birthday
```

which is ready to be sorted by year, month and day.

**Exercise 3-8**. How would you convert dates into a form in which you can do arithmetic like computing the number of days between two dates?

### 1.5. Program Cross-Reference Checking

Awk is often used to extract information from the output of other programs. Sometimes that output is merely a set of **homogeneous** lines, in which case field-splitting or `substr` operations are quite adequate. Sometimes, however, the upstream program thinks its output is intended for people. In that case, the task of the awk program is to undo careful formatting, so as to extract the information from the irrelevant. The next example is a simple instance.

Large programs are built from many files. *It is convenient (and sometimes vital) to know which file defines which function, and where the function is used.* To that end, the Unix program `nm` prints a neatly formatted list of the names, definitions, and uses of the names in a set of *object files*(`*.o` files). A typical fragment of its output looks like this:

```console
file.o:
00000c80 T _addroot
00000b30 T _checkdev
00000a3c T _checkdupl
         U _chown
         U _client
         U _close
funmount.o:
00000000 T _funmount
         U cerror
```

- Lines with *one* field (e.g., `file.o`) are filenames,
- lines with *two* fields (e.g., `U` and `_close`) are uses of names,
- lines with *three* fields are *definitions* of names.

`T` indicates that a definition is a text symbol (*function*) and `U` indicates that the name is undefined.

Using this raw output to determine what file defines or uses a particular symbol can be a nuisance, since the filename is not attached to each symbol. For a C program the list can be long - it's 850 lines for the nine files of source that make up awk itself. A three-line awk program, however, can add the name to each item, so subsequent programs can retrieve the useful information from one line:

```awk
# nm.format - add filename to each line

NF == 1 { file = $1 }
NF == 2 { print file, $1, $2 }
NF == 3 { print file, $2, $3 }
```

The output from `um.format` on the data shown above is

```console
file.o: T _addroot
file.o: T _checkdev
file.o: T _checkdupl
file.o: U _chown
file.o: U _client
file.o: U _close
funmount.o: T _funmount
funmount.o: U cerror
```

Now it is easy for other programs to search this output or process it further.

This technique does not provide line number information nor tell how many times a name is used in a file, but these things can be found by a text editor or another awk program. Nor does it depend on which language the programs are written in, so it is much more flexible than the usual run of cross-referencing tools, and shorter and simpler too.

### 1.6. Formatted Output

As another example we'll use awk to make money, or at least to print checks. The input consists of lines, each containing

- a check number,
- an amount,
- a payee

separated by *tabs*.

The output goes on check forms, `8` lines high.

- The *second* and *third* lines have the *check number* and *date* indented `45` spaces,
- the *fourth* line contains the *payee* in a field `45` characters long, followed by `3` blanks, followed by the *amount*.
- The *fifth* line contains the amount in *words*, and the other lines are blank.

A check looks like this:

```console
1 
2                                              1026
3                                              Sep 10, 2023
4 Pay to Mary R. Worth--------------------------------   $123.45
5 the sum of one hundred twenty three dollars and 45 cents exactly
6
7                                --------------------------------
8
```

> **Note**: The *line number* above is added by me manually, just for readers to identify each line easier.

`prchecks.awk`:

```awk
# prchecks - print formatted checks
#   input:  number \t amount \t payee
#   output: eight lines of text for preprinted check forms

BEGIN {
    FS = "\t"
    dashes = sp45 = sprintf("%45s", " ")
    gsub(/ /, "-", dashes)        # to protect the payee
    "date" | getline date         # get today's date
    split(date, d, " ")
    date = d[2] " " d[3] ", " d[6]
    initnum()    # set up tables for number conversion
}
NF != 3 || $2 >= 1000000 {        # illegal data
    printf("\nline %d illegal:\n%s\n\nVOID\nVOID\n\n\n", NR, $0)
    next                          # no check printed
}
{   printf("\n")                  # nothing on line 1
    printf("%s%s\n", sp45, $1)    # number, indented 45 spaces
    printf("%s%s\n", sp45, date)  # date, indented 45 spaces
    amt = sprintf("%.2f", $2)     # formatted amount
    printf("Pay to %45.45s   $%s\n", $3 dashes, amt)  # line 4
    printf("the sum of %s\n", numtowords(amt))        # line 5
    printf("\n\n\n")              # lines 6, 7 and 8
}

function numtowords(n,   cents, dols) { # n has 2 decimal places
    cents = substr(n, length(n)-1, 2)
    dols = substr(n, 1, length(n)-3)
    if (dols == 0)
        return "zero dollars and " cents " cents exactly"
    return intowords(dols) " dollars and " cents " cents exactly"
}

function intowords(n) {
    n = int(n)
    if (n >= 1000)
        return intowords(n/1000) " thousand " intowords(n%1000)
    if (n >= 100)
        return intowords(n/100) " hundred " intowords(n%100)
    if (n >= 20)
        return tens[int(n/10)] " " intowords(n%10)
    return nums[n]
}

function initnum() {
    split("one two three four five six seven eight nine " \
          "ten eleven twelve thirteen fourteen fifteen " \
          "sixteen seventeen eighteen nineteen", nums, " ")
    split("ten twenty thirty forty fifty sixty " \
          "seventy eighty ninety", tens, " ")
}
```

The program contains several interesting constructs.

- First, notice how we generate a long string of blanks in the `BEGIN` action with `sprintf`, and then convert them to *dashes* by *substitution*.
- Note also how we combine *line continuation* and *string concatenation* to create the *string argument* to `split` in the function `initnum`; this is a useful idiom.

The date comes from the system by the line

```awk
"date" | getline date # get today's date
```

which runs the `date` command and *pipes* its output into `getline`. A little processing converts the date from

```console
Wed Jun 17 13:39:36 EDT 1987
```

into

```console
Jun 17, 1987
```

(This may need revision on non-Unix systems that do not support pipes.)

The functions `numtowords` and `intowords` convert *numbers* to *words*. They are straightforward, although about half the program is devoted to them. The function `intowords` is recursive: it calls itself to deal with a simpler part of the problem. This is the second example of recursion in this chapter, and we will see others later on. In each case, recursion is an effective way to break a big job into smaller, more manageable pieces.

**Exercise 3-9**. Use the function addcomma from a previous example to include commas in the printed amount.

**Exercise 3-10**. The program prchecks does not deal with negative quantities or very long amounts in a graceful way. Modify the program to reject requests for checks for negative amounts and to split very long amounts onto two lines.

**Exercise 3-11**. The function numtowords sometimes puts out two blanks in a row. It also produces blunders like "one dollars." How would you fix these defects?

**Exercise 3-12**. Modify the program to put hyphens into the proper places in spelled-out amounts, as in "twenty-one dollars."

## 2. Data Validation

Another common use for awk programs is data validation: making sure that data is legal or at least **plausible**. This section contains several small programs that check input for validity.

For example, consider the column-summing programs in the previous section. Are there any numeric fields where there should be nonnumeric ones, or vice versa? Such a program is very close to one we saw before, with the summing removed:

```awk
# colcheck - check consistency of columns
#   input:  rows of numbers and strings
#   output: lines whose format differs from first line

NR == 1	{
    nfld = NF
    for (i = 1; i <= NF; i++)
       type[i] = isnum($i)
}
{   if (NF != nfld)
       printf("line %d has %d fields instead of %d\n",
          NR, NF, nfld)
    for (i = 1; i <= NF; i++)
       if (isnum($i) != type[i])
          printf("field %d in line %d differs from line 1\n",
             i, NR)
}

function isnum(n) { return n ~ /^[+-]?[0-9]+$/ }
```

The test for numbers is again just a sequence of digits with an optional sign; see the discussion of *regular expressions* in *Section 2.1* for a more complete version.

### 2.1. Balanced Delimiters

In the machine-readable text of this book, each program is introduced by a line beginning with `.P1` and is terminated by a line beginning with `.P2`. These lines are text-formatting commands that make the programs come out in their distinctive font when the text is typeset. Since programs cannot be nested, these text-formatting commands must form an alternating sequence

```plaintext
.P1 .P2 .P1 .P2 ... .P1 .P2
```

If one or the other of these delimiters is omitted, the output will be badly **mangled** by our text formatter. To make sure that the programs would be typeset properly, we wrote this tiny delimiter checker, which is typical of a large class of such programs:

```awk
# p12check - check input for alternating .P1/.P2 delimiters

/^\.P1/ { if (p != 0)
              print ".P1 after .P1, line", NR
          p = 1
        }
/^\.P2/ { if (p != 1)
              print ".P2 with no preceding .P1, line", NR
          p = 0
        }
END     { if (p != 0) print "missing .P2 at end" }
```

If the delimiters are in the right order, the variable `p` silently goes through the sequence of values 0 1 0 1 0 ... 1 0. Otherwise, the appropriate error messages are printed.

**Exercise 3-13**. What is the best way to extend this program to handle multiple sets of delimiter pairs?

### 2.2. Password-File Checking
