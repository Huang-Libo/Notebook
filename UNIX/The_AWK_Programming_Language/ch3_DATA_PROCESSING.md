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
  - [2.3. Generating Data-Validation Programs](#23-generating-data-validation-programs)
  - [2.4. Which Version of AWK?](#24-which-version-of-awk)
- [3. Bundle and Unbundle](#3-bundle-and-unbundle)
- [4. Multiline Records](#4-multiline-records)
  - [4.1. Records Separated by Blank Lines](#41-records-separated-by-blank-lines)
  - [4.2. Processing Multiline Records](#42-processing-multiline-records)
  - [4.3. Records with Headers and Trailers](#43-records-with-headers-and-trailers)

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

The password file(`/etc/passwd`) on a Unix system contains the name of and other information about authorized users. Each line of the password file has `7` fields, separated by *colons*:

```plaintext
root:qyxRi2uhuVjrg:0:2::/:
bwk:1L./v6iblzzNE:9:1:Brian Kernighan:/usr/bwk:
ava:otxs1oTVoyvMQ:15:1:Al Aho:/usr/ava:
uucp:xutiBs2hKtcls:48:1:uucp daemon:/usr/lib/uucp:uucico
pjw:xNqy//GDc8FFg:170:2:Peter Weinberger:/usr/pjw:
mark:jOz1fuQmqivdE:374:1:Mark Kernighan:/usr/bwk/mark:
...
```

- The *first* field is the user's login name, which should be **alphanumeric**.
- The *second* is an encrypted version of the password; if this field is empty, anyone can log in pretending to be that user, while if there is a password, only people who know the password can log in.
- The *third* and *fourth* fields are supposed to be numeric.
- The *sixth* field should begin with `/`.

The following program prints all lines that fail to satisfy these criteria, along with the number of the **erroneous** line and an appropriate diagnostic message. Running this program every night is a small part of keeping a system healthy and safe from intruders.

> **Note**: The `/etc/passwd` file has changed a lot over the last 30 years, so the program below may not be correct on the UNIX as of the year 2023. But it's still a good example for validation.

```awk
# passwd - check password file

BEGIN {
    FS = ":"
}
NF != 7 {
    printf("line %d, does not have 7 fields: %s\n", NR, $0) }
$1 ~ /[^A-Za-z0-9]/ {
    printf("line %d, non-alphanumeric user id: %s\n", NR, $0) }
$2 == "" {
    printf("line %d, no password: %s\n", NR, $0) }
$3 ~ /[^0-9]/ {
    printf("line %d, nonnumeric user id: %s\n", NR, $0) }
$4 ~ /[^0-9]/ {
    printf("line %d, nonnumeric group id: %s\n", NR, $0) }
$6 !~ /^\// {
    printf("line %d, invalid login directory: %s\n", NR, $0) }
```

This is a good example of a program that can be developed incrementally: each time someone thinks of a new condition that should be checked, it can be added, so the program steadily becomes more thorough.

### 2.3. Generating Data-Validation Programs

We constructed the password-file checking program by hand, but a more interesting approach is to convert a set of conditions and messages into a checking program automatically. Here is a small set of error conditions and messages, where each condition is a pattern from the program above. The error message is to be printed for each input line where the condition is true.

`checkgen.data`:

```plaintext
NF != 7			does not have 7 fields
$1 ~ /[^A-Za-z0-9]/	non-alphanumeric user id
$2 == ""		no password
```

The following program converts these condition-message pairs into a checking program:

`checkgen.awk`:

```awk
# checkgen - generate data-checking program
#     input:  expressions of the form: pattern tabs message
#     output: program to print message when pattern matches

BEGIN { FS = "\t+" }
{ printf("%s {\n\tprintf(\"line %%d, %s: %%s\\n\",NR,$0) }\n",
      $1, $2)
}
```

The output is a sequence of conditions and the actions to print the corresponding messages:

```awk
NF != 7 {
        printf("line %d, does not have 7 fields: %s\n",NR,$0) }
$1 ~ /[^A-Za-z0-9]/ {
        printf("line %d, non-alphanumeric user id: %s\n",NR,$0) }
$2 == "" {
        printf("line %d, no password: %s\n",NR,$0) }
```

When the resulting checking program is executed, each condition will be tested on each line, and if it is satisfied, the line number, error message, and input line will be printed. Note that in `checkgen`, some of the special characters in the `printf` format string must be *quoted* to produce a valid generated program. For example, `%` is preserved by writing `%%` and `\n` is created by writing `\\n`.

This technique in which one awk program creates another is broadly applicable (and of course it's not restricted to awk programs). We will see several more examples of its use throughout this book.

**Exercise 3-14**. Add a facility to `checkgen` so that pieces of code can be passed through verbatim, for example, to create a `BEGIN` action to set the field separator.

### 2.4. Which Version of AWK?

Awk is often useful for inspecting programs, or for organizing the activities of other testing programs. This section contains a somewhat incestuous example: a program that examines awk programs.

The new version of the language has more *built-in variables and functions*, so there is a chance that an old program may inadvertently include one of these names, for example, by using as a variable name a word like `sub` that is now a *built-in function*. The following program does a reasonable job of detecting such problems in old programs:

```awk
# compat - check if awk program uses new built-in names

BEGIN { asplit("close system atan2 sin cos rand srand " \
               "match sub gsub", fcns)
        asplit("ARGC ARGV FNR RSTART RLENGTH SUBSEP", vars)
        asplit("do delete function return", keys)
      }

      { line = $0 }

/"/   { gsub(/"([^"]|\\")*"/, "", line) }     # remove strings,
/\//  { gsub(/\/([^\/]|\\\/)+\//, "", line) } # reg exprs,
/#/   { sub(/#.*/, "", line) }                # and comments

      { n = split(line, x, "[^A-Za-z0-9_]+")  # into words
        for (i = 1; i <= n; i++) {
            if (x[i] in fcns)	
                warn(x[i] " is now a built-in function")
            if (x[i] in vars)
                warn(x[i] " is now a built-in variable")
            if (x[i] in keys)
                warn(x[i] " is now a keyword")
        }
      }

function asplit(str, arr) {  # make an assoc array from str
    n = split(str, temp)
    for (i = 1; i <= n; i++)
        arr[temp[i]]++
    return n
}

function warn(s) {
    sub(/^[ \t]*/, "")
    printf("file %s, line %d: %s\n\t%s\n", FILENAME, FNR, s, $0)
}
```

> **Note**: Difference between `\/` and `\\\/` in the regex above,
>
> - `\/` represents a single forward slash `/`
> - `\\\/` represents a literal backslash `\` followed by a forward slash `/`. It can be understood easier by split it to two parts:
>   1. `\\` represents a literal backslash `\`
>   2. `\/` represents a forward slash `/`

The only real complexity in this program is in the *substitution* commands that attempt to *remove quoted strings, regular expressions, and comments* before an input line is checked. This job isn't done perfectly, so some lines may not be properly processed.

The third argument of the first `split` function(`split(line, x, "[^A-Za-z0-9_]+")`) is a string that is interpreted as a *regular expression*. The leftmost longest substrings matched by this regular expression in the input line become the field separators. **The `split` command divides the resulting input line into alphanumeric strings by using non-alphanumeric strings as the field separator**; this removes all the operators and punctuation at once.

The function `asplit` is just like `split`, except that it creates an array whose subscripts are the words within the string. Incoming words can then be tested for membership in this array.

This is the output of `compat` on itself:

```console
file awk-demo.awk, line 12: gsub is now a built-in function
        /\//  { gsub(/\/([^\/]|\\\/)+\//, "", line) } # reg exprs,
file awk-demo.awk, line 13: sub is now a built-in function
        /\#/   { sub(/#.*/, "", line) }                # and comments
file awk-demo.awk, line 26: function is now a keyword
        function asplit(str, arr) {  # make an assoc array from str
file awk-demo.awk, line 30: return is now a keyword
        return n
file awk-demo.awk, line 33: function is now a keyword
        function warn(s) {
file awk-demo.awk, line 34: sub is now a built-in function
        sub(/^[ \t]*/, "")
file awk-demo.awk, line 35: FNR is now a built-in variable
        printf("file %s, line %d: %s\n\t%s\n", FILENAME, FNR, s, $0)
```

**Exercise 3-15**. Rewrite `compat` to identify keywords, etc., with regular expressions instead of the function `asplit`. Compare the two versions on complexity and speed.

**Exercise 3-16**. Because awk variables are not declared, a misspelled name will not be detected. Write a program to identify names that are used only once. To make it truly useful, you will have to handle function declarations and variables used in functions.

## 3. Bundle and Unbundle

Before discussing multiline records, let's consider a special case. The problem is to combine ("bundle") a set of `ASCII` files into one file in such a way that they can be easily separated ("unbundled") into the original files. This section contains two tiny awk programs that do this pair of operations. They can be used for bundling small files together to save disk space, or to package a collection of files for convenient electronic mailing.

The bundle program is trivial, so short that you can just type it on a command line. All it does is prefix each line of the output with the name of the file, which comes from the built-in variable `FILENAME`.

```awk
# bundle - combine multiple files into one
{ print FILENAME, $0 }
```

The matching unbundle is only a little more elaborate:

```awk
# unbundle - unpack a bundle into separate files

$1 != prev { close(prev); prev = $1 }
           { print substr($0, index($0, " ") + 1) > $1 }
```

The first line of unbundle closes the previous file when a new one is encountered; if bundles don't contain many files (less than the limit on the number of open files), this line isn't necessary.

There are other ways to write bundle and unbundle, but the versions here are the easiest, and for short files, reasonably space efficient. Another organization is to add a distinctive line with the filename before each file, so the filename appears only once.

**Exercise 3-17**. Compare the speed and space requirements of these versions of bundle and unbundle with variations that use headers and perhaps trailers. Evaluate the tradeoff between performance and program complexity.

## 4. Multiline Records

The examples so far have featured data where each record fits neatly on one line. Many other kinds of data, however, come in multiline chunks. Examples include address lists:

```plaintext
Adam Smith
1234 Wall St., Apt. 5C
New York, NY 10021
212 555-4321
```

or bibliographic citations:

```plaintext
Donald E. Knuth
The Art of Computer Programming
Volume 2: Seminumerical Algorithms, Second Edition
Addison-Wesley, Reading, Mass.
1981
```

or personal databases:

```plaintext
Chateau Lafite Rothschild 1947
12 bottles @ 12.95
```

It's easy to create and maintain such information if it's of modest size and regular structure; in effect, each record is the equivalent of an index card. Dealing with such data in awk requires only a bit more work than single-line data does; we'll show several approaches.

### 4.1. Records Separated by Blank Lines

Imagine an address list, where each record contains on the first four lines a name, street address, city and state, and phone number; after these, there may be additional lines of other information. blank line:

```plaintext
Adam Smith
1234 Wall St., Apt. 5C
New York, NY 10021
212 555-4321

David W. Copperfield
221 Dickens Lane
Monterey, CA 93940
408 555-0041
work phone 408 555-6532
Mary, birthday January 30

Canadian Consulate
555 Fifth Ave
New York, NY
212 586-2400
```

When records are separated by *blank lines*, they can be manipulated directly: if the record separator variable `RS` is set to *null string* (`RS=""`), each multiline group becomes a record. Thus

```awk
BEGIN { RS = "" }
/New York/
```

will print each record that contains New York, regardless of how many lines it has:

```plaintext
Adam Smith
1234 Wall St., Apt. 5C
New York, NY 10021
212 555-4321
Canadian Consulate
555 Fifth Ave
New York, NY
212 586-2400
```

When several records are printed in this way, there is no blank line between them, so the input format is not preserved. The easiest way to fix this is to set the output record separator `ORS` to a double newline `\n\n`:

```awk
BEGIN { RS = ""; ORS = "\n\n" }
/New York/
```

Output:

```plaintext
Adam Smith
1234 Wall St., Apt. 5C
New York, NY 10021
212 555-4321

Canadian Consulate
555 Fifth Ave
New York, NY
212 586-2400
```

Suppose we want to print the *names* and *phone numbers* of all Smith's, that is, the *first* and *fourth* lines of all records in which the first line ends with Smith. That would be easy if each line were a field. This can be arranged by setting `FS` to `\n`:

```awk
BEGIN         { RS = ""; FS = "\n" }
$1 ~ /Smith$/ { print $1, $4 }   # name, phone
```

This produces

```plaintext
Adam Smith 212 555-4321
```

Recall that newline is always a field separator for multiline records, regardless of the value of `FS`.

- When `RS` is set to `""`, the field separator `FS` *by default* is any sequence of *blanks* and *tabs*, or *newline*.
- When `FS` is set to `\n`, only a newline acts as a field separator.

### 4.2. Processing Multiline Records

If an existing program can process its input only by lines, we may still be able to use it for multiline records by writing two awk programs.

- The first combines the multiline records into single-line records that can be processed by the existing program.
- Then, the second transforms the processed output back into the original multiline format. (We'll assume that limits on line lengths are not a problem.)

To illustrate, let's sort our address list with the Unix `sort` command. The following pipeline sorts the address list by *last name*:

```bash
# pipeline to sort address list by last names

awk '
BEGIN { RS = ""; FS = "\n" }
      { printf("%s!!#", x[split($1, x, " ")])
        for (i = 1; i <= NF; i++)
            printf("%s%s", $i, i < NF ? "!!#" : "\n")
      }
' |
sort |
awk '
BEGIN { FS = "!!#" }
      { for (i = 2; i <= NF; i++)
            printf("%s\n", $i)
        printf("\n")
      }
'
```

In the first program, the function `split($1, x, " ")` splits *the first line of each record* into the array `x` and returns the number of elements created; thus, `x[split($1, x, " ")]` is the entry for the *last name*. (This assumes that the last word on the first line really is the last name.) For each multiline record the first program creates a single line consisting of the last name, followed by the string `!!#`, followed by all the fields in the record separated by this string. Any other separator that does not occur in the data and that sorts earlier than the data could be used in place of the string `!!#`. The program after the `sort` reconstructs the multiline records using this separator to identify the original fields.

**Exercise 3-18.** Modify the first awk program to detect occurrences of the magic string `!!#` in the data.

### 4.3. Records with Headers and Trailers
