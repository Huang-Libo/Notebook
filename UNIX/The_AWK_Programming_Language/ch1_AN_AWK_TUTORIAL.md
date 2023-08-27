# Chapter 1: AN AWK TUTORIAL <!-- omit in toc -->

- [1. Getting Started](#1-getting-started)
  - [1.1. The Structure of an AWK Program](#11-the-structure-of-an-awk-program)
  - [1.2. Running an AWK Program](#12-running-an-awk-program)
  - [1.3. Errors](#13-errors)
- [2. Simple Output](#2-simple-output)
  - [2.1. Printing Every Line](#21-printing-every-line)
  - [2.2. Printing Certain Fields](#22-printing-certain-fields)
  - [2.3. NF, the Number of Fields](#23-nf-the-number-of-fields)
  - [2.4. NR, the Number of Records](#24-nr-the-number-of-records)
  - [2.5. Putting Text in the Output](#25-putting-text-in-the-output)
- [3. Fancier Output](#3-fancier-output)
  - [3.1. Lining Up Fields](#31-lining-up-fields)
  - [3.2. Sorting the Output](#32-sorting-the-output)
- [4. Selection](#4-selection)
  - [4.1. Selection by Comparison](#41-selection-by-comparison)
  - [4.2. Selection by Computation](#42-selection-by-computation)
  - [4.3. Selection by Text Content](#43-selection-by-text-content)
  - [4.4. Combinations of Patterns](#44-combinations-of-patterns)
  - [4.5. Data Validation](#45-data-validation)
  - [4.6. BEGIN and END](#46-begin-and-end)
- [5. Computing with AWK](#5-computing-with-awk)
  - [5.1. Counting](#51-counting)
  - [5.2. Computing Sums and Averages](#52-computing-sums-and-averages)
  - [5.3. Handling Text](#53-handling-text)
  - [5.4. String Concatenation](#54-string-concatenation)
  - [5.5. Printing the Last Input Line](#55-printing-the-last-input-line)
  - [5.6. Built-in Functions](#56-built-in-functions)
  - [5.7. Counting Lines, Words, and Characters](#57-counting-lines-words-and-characters)
- [6. Control-Flow Statements](#6-control-flow-statements)
  - [6.1. if-else Statement](#61-if-else-statement)
  - [6.2. while Statement](#62-while-statement)
  - [6.3. for Statement](#63-for-statement)
- [7. Arrays](#7-arrays)
- [8. A Handful of Useful "One-liners"](#8-a-handful-of-useful-one-liners)

## 1. Getting Started

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

### 1.1. The Structure of an AWK Program

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

### 1.2. Running an AWK Program

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

### 1.3. Errors

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

## 2. Simple Output

The rest of this chapter contains a collection of short, typical awk programs based on manipulation of the `emp.data` file above.

There are only two types of data in awk: **numbers** and **strings** of characters. The `emp.data` file is typical of this kind of information - a mixture of words and numbers separated by *blanks* and/or *tabs*.

Awk reads its input one line at a time and splits each line into fields, where, by default, a field is a sequence of characters that doesn't contain any blanks or tabs. The first field in the current input line is called `$1`, the second `$2`, and so forth. The entire line is called `$0`. The number of fields can vary from line to line.

### 2.1. Printing Every Line

If an action has no pattern, the action is performed for all input lines. The statement `print` by itself prints the current input line, so the program

```awk
{ print }
```

prints all of its input on the **standard output**. Since `$0` is the whole line,

```awk
{ print $0 }
```

does the same thing.

### 2.2. Printing Certain Fields

More than one item can be printed on the same output line with a single print statement. The program to print the *first* and *third* fields of each input line is

```awk
{ print $1, $3 }
```

- Expressions separated by a *comma* in a `print` statement are, by default, separated by a single *blank* when they are printed.
- Each line produced by print ends with a *newline character*(`\n`).

Both of these defaults can be changed; we'll show how in Chapter 2.

### 2.3. NF, the Number of Fields

It might appear you must always refer to fields as `$1`, `$2`, and so on, but any *expression* can be used after `$` to **denote** a field number, *the expression is evaluated and its numeric value is used as the field number*.

Awk counts the number of fields in the current input line and stores the count in *a built-in variable* called `NF`(*Number of Fields*). Thus, the program

```awk
{ print NF, $1, $NF }
```

prints *the number of fields* and the *first and last fields* of each input line.

### 2.4. NR, the Number of Records

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

### 2.5. Putting Text in the Output

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

## 3. Fancier Output

The `print` statement is meant for quick and easy output. To format the output exactly the way you want it, you may have to use the `printf` statement. As we shall see in **Section 2.4**, `printf` can produce almost any kind of output, but in this section we'll only show a few of its capabilities.

### 3.1. Lining Up Fields

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

### 3.2. Sorting the Output

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

## 4. Selection

Awk patterns are good for selecting interesting lines from the input for further processing.

Since **a pattern without an action prints all lines matching the pattern**, many awk programs consist of nothing more than a single pattern.

### 4.1. Selection by Comparison

This program uses a comparison pattern to select the records of employees who earn $5.00 or more per hour, that is, lines in which the second field is greater than or equal to `5`:

```awk
$2 >= 5
```

It selects these lines from `emp.data`:

```console
Mark    5.00    20
Mary    5.50    22
```

### 4.2. Selection by Computation

The program

```awk
$2 * $3 > 50 { printf("$%6.2f for %s\n", $2 * $3, $1) }
```

prints the pay of those employees whose total pay exceeds $50:

```console
$100.00 for Mark
$121.00 for Mary
$ 76.50 for Susie
```

### 4.3. Selection by Text Content

Besides numeric tests, you can select input lines that contain specific words or phrases. This program prints all lines in which the first field is *Susie*:

```awk
$1 == " Susie"
```

The operator `==` tests for equality. You can also look for text containing any of a set of letters, words, and phrases by using patterns called *regular expressions*.

This program prints all lines that contain *Susie* anywhere:

```awk
/Susie/
```

The output is this line:

```console
Susie   4.25    18
```

*Regular expressions* can be used to specify much more elaborate patterns; **Section 2.1** contains a full discussion.

### 4.4. Combinations of Patterns

Patterns can be combined with parentheses and the logical operators `&&`, `||`, and `!`, which stand for *AND*, *OR*, and *NOT*. The program

```awk
$2 >= 4 || $3 >= 20
```

prints those lines where `$2` is at least 4 or `$3` is at least 20:

```console
Beth    4.00    0
Kathy   4.00    10
Mark    5.00    20
Mary    5.50    22
Susie   4.25    18
```

Lines that satisfy both conditions are printed only **once**.

Contrast this with the following program, which consists of **two patterns**:

```awk
$2 >= 4
$3 >= 20
```

This program prints an input line **twice** if it satisfies both conditions:

```console
Beth    4.00    0
Kathy   4.00    10
Mark    5.00    20
Mark    5.00    20
Mary    5.50    22
Mary    5.50    22
Susie   4.25    18
```

### 4.5. Data Validation

There are always errors in real data. Awk is an excellent tool for checking that data has reasonable values and is in the right format, a task that is often called *data validation*.

Data validation is essentially negative: instead of printing lines with desirable properties, one prints lines that are suspicious. The following program uses comparison patterns to apply five plausibility tests to each line of `emp.data`:

```awk
NF != 3   { print $0, "number of fields is not equal to 3" }
$2 < 3.35 { print $0, "rate is below minimum wage" }
$2 > 10   { print $0, "rate exceeds $10 per hour" }
$3 < 0    { print $0, "negative hours worked"}
$3 > 60   { print $0, "too many hours worked" }
```

If there are no errors, there's no output.

### 4.6. BEGIN and END

The special pattern `BEGIN` matches before the first line of the first input file is read, and `END` matches after the last line of the last file has been processed.

This program uses `BEGIN` to print a heading:

```awk
BEGIN { print "NAME    RATE    HOURS"; print "" }
      { print }
```

The output is:

```console
NAME    RATE    HOURS
 
Beth    4.00    0
Dan     3.75    0
Kathy   4.00    10
Mark    5.00    20
Mary    5.50    22
Susie   4.25    18
```

- You can put several statements on a single line if you separate them by semicolons(`;`).
- Notice that `print ""` prints a blank line, quite different from just plain `print`, which prints the current input line.

## 5. Computing with AWK

An action is a sequence of statements separated by *newlines* or *semicolons*.

This section provides examples of statements for performing simple *numeric* and *string* computations. In these statements you can use not only the *built-in variables* like `NF`, but you can create your own variables for performing calculations, storing data, and the like.

In awk, **user-created variables are *not* declared**.

### 5.1. Counting

This program uses a variable `emp` to count employees who have worked more than 15 hours:

```awk
$3 > 15 { emp = emp + 1 }
END { print emp, " employees worked more than 15 hours" }
```

For every line in which the third field exceeds 15, the previous value of `emp` is incremented by 1. With `emp.data` as input, this program yields:

```console
3  employees worked more than 15 hours
```

Awk variables used as numbers begin life with the value `0`, so we didn't need to initialize `emp`.

### 5.2. Computing Sums and Averages

To count the number of employees, we can use the *built-in variable* `NR`, which holds the number of lines read so far; its value at the end of all input is the total number of lines read.

```awk
END { print NR, " employees" }
```

The output is:

```console
6  employees
```

Here is a program that uses `NR` to compute the average pay:

```awk
    { pay = pay + $2 * $3 }
END { print NR, " employees"
      print "total pay is" , pay
      print "average pay is" , pay/NR
    }
```

The `END` action prints

```console
6  employees
total pay is 337.5
average pay is 56.25
```

### 5.3. Handling Text

One of the strengths of awk is its ability to handle strings of characters as conveniently as most languages handle numbers. Awk variables can hold strings of characters as well as numbers. This program finds the employee who is paid the most per hour:

```awk
$2 > max_rate { max_rate = $2; max_emp = $1 }
END { print "highest hourly rate:", max_rate, "for", max_emp }
```

It prints

```console
highest hourly rate: 5.50 for Mary
```

In this program the variable `max_rate` holds a numeric value, while the variable `max_emp` holds a string.

### 5.4. String Concatenation

New strings may be created by combining old ones; this operation is called concatenation. The program

```awk
    { names = names $1 " " }
END { print names }
```

collects all the employee names into a single string, by appending each *name* and a *blank* to the previous value in the variable names. The value of names is printed by the `END` action:

```console
Beth Dan Kathy Mark Mary Susie 
```

The concatenation operation is represented in an awk program by *writing string values one after the other*.

Variables used to store strings begin life holding the `null` string (that is, the string containing no characters), so in this program `names` did not need to be explicitly initialized.

### 5.5. Printing the Last Input Line

Although `NR` retains its value in an `END` action, `$0` does not. The program

```awk
    { last = $0 }
END { print last }
```

is one way to print the last input line:

```console
Susie   4.25    18
```

### 5.6. Built-in Functions

There are *built-in functions* for computing other useful values. One of these is `length`, which counts the number of characters in a string. For example, this program computes the length of each person's name:

```awk
{ print $1, length($1) }
```

The result:

```console
Beth 4
Dan 3
Kathy 5
Mark 4
Mary 4
Susie 5
```

### 5.7. Counting Lines, Words, and Characters

This program uses `length`, `NF`, and `NR` to count the number of *lines*, *words*, and *characters* in the input. For convenience, we'll treat each field as a word.

```awk
    {
      nc = nc + length($0) + 1
      nw = nw + NF
    }
END { print NR, "lines,", nw, "words," , nc, "Characters" }
```

The file `emp.data` has

```console
6 lines, 18 words, 77 Characters
```

We have added `1` for the *newline character*(`\n`) at the end of each input line, since `$0` doesn't include it.

## 6. Control-Flow Statements

Awk provides an `if-else` statement for making decisions and several statements for writing *loops*, all modeled on those found in the *C programming language*. **They can only be used in actions.**

### 6.1. if-else Statement

The following program computes the total and average pay of employees making more than $6.00 an hour. It uses an `if` to defend against division by `0` in computing the average pay.

```awk
$2 > 6 { n = n + 1; pay = pay + $2 * $3 }
END { if (n > 0)
          print n, "employees, total pay is", pay,
                   "average pay is", pay/n
      else
          print "no employees are paid more than $6/hour"
    }
```

The output for `emp.data` is:

```console
no employees are paid more than $6/hour
```

Note that we can continue a long statement over several lines by breaking it after a comma.

### 6.2. while Statement

A `while` statement has a condition and a body. The statements in the body are performed repeatedly while the condition is true.

This program shows how the value of an amount of money invested at a particular interest rate grows over a number of years, using the formula `value = amount * (1 + rate) ^ years`.

```awk
# interest1 - compute compound interest
#   input: amount rate years
#   output: compounded value at the end of each year
{
    i = 1
    while (i <= $3) {
        printf("\t%.2f\n" , $1 * (1 + $2) ^ i)
        i =i + 1
    }
}
```

The condition is the parenthesized expression after the `while`; the loop body is the two statements enclosed in braces after the condition. The `\t` in the `printf` specification string stands for a *tab* character; the `^` is the *exponentiation* operator.

You can type triplets of numbers at this program to see what various amounts, rates, and years produce. For example, this transaction shows how $1000 grows at 6% and 12% compound interest for 5 years:

```bash
$ awk -f interest1
1000 .06 5
        1060.00
        1123.60
        1191.02
        1262.48
        1338.23
1000 .12 5
        1120.00
        1254.40
        1404.93
        1573.52
        1762.34
```

### 6.3. for Statement

Another statement, `for`, compresses into a single line the initialization, test, and increment that are part of most loops. Here is the previous interest computation with a for:

```awk
# interest2 - compute compound interest
#   input: amount rate years
#   output: compounded value at the end of each year
{
    for (i = 1; i <= $3; i = i + 1)
        printf("\t%.2f\n" , $1 * (1 + $2) ^ i)
}
```

## 7. Arrays

Awk provides arrays for storing groups of related values. Although arrays give awk considerable power, we will show only a simple example here.

The following program prints its input in reverse order by line. The first action puts the input lines into successive elements of the array `line`;

- that is, the first line goes into `line[1]` , the second line into `line[2]`, and so on.
- The `END` action uses a `while` statement to print the lines from the array from last to first:

```awk
# reverse - print input in reverse order by line
    { line[NR] = $0 } # remember each input line
END {
      i = NR            # print lines in reverse order
      while (i > 0) {
          print line[i]
          i = i - 1
      }
    }
```

With `emp.data`, the output is

```console
Susie   4.25    18
Mary    5.50    22
Mark    5.00    20
Kathy   4.00    10
Dan     3.75    0
Beth    4.00    0
```

Here is the same example with a `for` statement:

```awk
# reverse - print input in reverse order by line
    { line[NR] = $0 } # remember each input line
END {
      for (i = NR; i > 0; i = i - 1)
          print line[i]
    }
```

## 8. A Handful of Useful "One-liners"

Although awk can be used to write programs of some complexity, many useful programs are not much more complicated than what we've seen so far. Here is a collection of short programs that you might find handy and instructive. Most are variations on material already covered.

1. Print the total number of input lines:

    ```awk
    END { print NR }
    ```

    > NOTE: In bash you can also use `line_count=$(wc -l < filename)`.

2. Print the tenth input line:

    ```awk
    NR == 10
    ```

3. Print the last field of *every* input line:

    ```awk
    { print $NF }
    ```

4. Print the last field of the *last* input line:

    ```awk
        { field = $NF}
    END { print field }
    ```

5. Print every input line with more than 4 fields:

    ```awk
    NF > 4
    ```

6. Print every input line in which the last field is more than 4:

    ```awk
    $NF > 4
    ```

7. Print the total number of fields in all input lines:

    ```awk
        { nf = nf + NF }
    END { print nf }
    ```

8. Print the total number of lines that contain *Beth*:

    ```awk
    /Beth/ { n_lines = n_lines + 1 }
    END    { print n_lines }
    ```

9. Print the largest first field and the line that contains it (assumes some `$1` is positive):

    ```awk
    $1 > max { max = $1; max_line = $0 }
    END { print max, max_line }
    ```

10. Print every line that has at least one field:

    ```awk
    NF > 0
    ```

11. Print every line longer than 80 characters:

    ```awk
    length($0) > 80
    ```

12. Print the number of fields in every line followed by the line itself:

    ```awk
    { print NF, $0 }
    ```

13. Print the first two fields, in opposite order, of every line:

    ```awk
    { print $2, $1 }
    ```

14. Exchange the first two fields of every line and then print the line:

    ```awk
    { temp = $1; $1 = $2; $2 = temp; print }
    ```

15. Print every line with the first field replaced by the line number:

    ```awk
    { $1 = NR; print }
    ```

16. Print every line after erasing the second field:

    ```awk
    { $2 = "" ; print }
    ```

17. Print in reverse order the fields of every line:

    ```awk
    {
      for (i = NF; i > 0; i = i - 1) printf("%s ", $i)
      printf("\n")
    }
    ```

18. Print the sums of the fields of every line:

    ```awk
    {
      sum = 0
      for (i = 1; i <= NF; i = i + 1) sum = sum + $i
      print sum
    }
    ```

19. Add up all fields in all lines and print the sum:

    ```awk
        { for (i = 1; i <= NF; i = i + 1) sum = sum+ $i }
    END { print sum }
    ```

20. Print every line after replacing each field by its absolute value:

    ```awk
    {
      for (i = 1; i <= NF; i = i + 1)
          if ($i < 0) $i = -$i
      print
    }
    ```
