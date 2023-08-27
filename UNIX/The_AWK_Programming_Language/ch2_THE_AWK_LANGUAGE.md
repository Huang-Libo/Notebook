# Chapter 2: THE AWK LANGUAGE <!-- omit in toc -->

- [1. Patterns](#1-patterns)
  - [1.1. BEGIN and END](#11-begin-and-end)
  - [1.2. Expressions as Patterns](#12-expressions-as-patterns)
  - [1.3. String-Matching Patterns](#13-string-matching-patterns)
  - [1.4. Regular Expressions](#14-regular-expressions)

This chapter explains, mostly with examples, the constructs that make up awk programs.

The simplest awk program is a sequence of *pattern-action* statements:

```awk
pattern { action }
pattern { action }
...
```

- In some statements, the *pattern* may be missing;
- in others, the *action* and its enclosing braces may be missing.

After awk has checked your program to make sure there are no syntactic errors, it reads the input a line at a time, and for each line, evaluates the patterns in order. For each pattern that matches the current input line, it executes the associated action.

- A missing pattern matches every input line, so every action with no pattern is performed at each line.
- A pattern-action statement consisting only of a pattern prints each input line matched by the pattern.

**The Input File** `countries.txt`

As input for many of the awk programs in this chapter, we will use a file called `countries.txt`.

```plaintext
USSR	8649	275	Asia
Canada	3852	25	North America
China	3705	1032	Asia
USA	3615	237	North America
Brazil	3286	134	South America
India	1267	746	Asia
Mexico	762	78	North America
France	211	55	Europe
Japan	144	120	Asia
Germany	96	61	Europe
England	94	56	Europe
```

Each line contains:

- the name of a country
- its area in thousands of square miles
- its population in millions
- the continent it is in.

The data is from 1984; the USSR has been arbitrarily placed in Asia.

- In the file, the four columns are separated by *tabs*;
- a single *blank* separates *North* and *South* from *America*.

**Program Format**

Pattern-action statements and the statements within an action are usually separated by newlines, but several statements may appear on one line if they are separated by semicolons. A semicolon may be put at the end of any statement.

*The opening brace of an action must be on the same line as the pattern it accompanies*; the remainder of the action, including the closing brace, may appear on the following lines.

Comments may be inserted at the end of any line. A comment starts with the character `#` and finishes at the end of the line, as in

```awk
{ print $1, $3 } # print country name and population
```

A long statement may be spread over several lines by inserting a *backslash*(`\`) and *newline* at each break:

```awk
{ print \
        $1,     # country name
        $2,     # area in thousands of square miles
        $3 }    # population in millions
```

As this example shows, *statements may also be broken after commas*, and a comment may be inserted at the end of each broken line.

## 1. Patterns

Patterns control the execution of actions: when a pattern matches, its associated action is executed. This section describes the **6** types of patterns and the conditions under which they match.

---

**Summary of Patterns**

1. `BEGIN { statements }`

    The *statements* are executed once *before* any input has been read.

2. `END { statements }`

    The *statements* are executed once *after* all input has been read.

3. `expression { statements }`

    The *statements* are executed at each input line where the *expression* is `true`, that is, *nonzero* or *nonnull*.

4. `/regular expression/ { statements }`

    The *statements* are executed at each input line that contains a string matched by the *regular expression*.

5. `compound pattern { statements }`

    A *compound pattern* combines expressions with `&&` (AND), `||` (OR), `!` (NOT), and parentheses; the *statements* are executed at each input line where the *compound pattern* is true.

6. `pattern1, pattern2 { statements }`

    A **range pattern** matches each input line from a line matched by *pattern1* to the next line matched by *pattern2* , inclusive; the *statements* are executed at each matching line.

NOTE:

- `BEGIN` and `END` do not combine with other patterns.
- `BEGIN` and `END` are the only patterns that require an action.
- A **range pattern** cannot be part of any other pattern.

---

### 1.1. BEGIN and END

The `BEGIN` and `END` patterns do not match any input lines. Rather,

- the statements in the `BEGIN` action are executed *before* awk reads any input;
- the statements in the `END` action are executed *after* all input has been read.

`BEGIN` and `END` thus provide a way to gain control for initialization and wrap-up.

If there is more than one `BEGIN`, the associated actions are executed in the order in which they appear in the program, and similarly for multiple `END`'s.

Although it's not mandatory, we put `BEGIN` first and `END` last.

**Field Separator**

One common use of a `BEGIN` action is to change the default way that input lines are split into fields. The *field separator* is controlled by a *built-in variable* called `FS`(*Field Separator*).

By default, fields are separated by ***blanks* and/or *tabs***; this behavior occurs when `FS` is set to a blank. Setting `FS` to any character other than a blank makes that character the *field separator*.

The following program uses the `BEGIN` action to set the *field separator* to a tab character (`\t`) and to put column headings on the output. The second `printf` statement, which is executed at each input line, formats the output into a table, neatly aligned under the column headings. The `END` action prints the totals.

```awk
# print countries with column headers and totals

BEGIN { 
        FS = "\t"   # make tab the field separator
        printf("%10s %6s %5s   %s\n\n",
              "COUNTRY", "AREA", "POP", "CONTINENT")
      }

      { 
        printf("%10s %6d %5d   %s\n", $1, $2, $3, $4)
        area = area + $2
        pop = pop + $3
      }

END   { printf("\n%10s %6d %5d\n", "TOTAL", area, pop) }
```

With the `countries.txt` file as input, this program produces

```console
   COUNTRY   AREA   POP   CONTINENT

      USSR   8649   275   Asia
    Canada   3852    25   North America
     China   3705  1032   Asia
       USA   3615   237   North America
    Brazil   3286   134   South America
     India   1267   746   Asia
    Mexico    762    78   North America
    France    211    55   Europe
     Japan    144   120   Asia
   Germany     96    61   Europe
   England     94    56   Europe

     TOTAL  25681  2819
```

### 1.2. Expressions as Patterns

Throughout this book, the term *string* means a sequence of zero or more characters. These may be stored in variables, or appear literally as string constants like `""` or `"Asia"`.

The string `""`, which contains no characters, is called the *null string*. The term *substring* means a contiguous sequence of zero or more characters within a string. In every string, the *null string* appears as a *substring* of length zero before the first character, between every pair of adjacent characters, and after the last character.

Any expression can be used as an operand of any operator.

- If an expression has a numeric value but an operator requires a string value, the numeric value is automatically transformed into a string;
- similarly, a string is converted into a number when an operator demands a numeric value.

Any expression can be used as a pattern. If an expression used as a pattern has a *nonzero* or *nonnull* value at the current input line, then the pattern matches that line. The typical expression patterns are those involving comparisons between numbers or strings.

A comparison expression contains one of the **6** relational operators, or one of the two *string-matching* operators `~`(tilde) and `!~` that will be discussed in the next section.

| OPERATOR | MEANING                  |
|----------|--------------------------|
| `==`     | equal to                 |
| `!=`     | not equal to             |
| `<`      | less than                |
| `<=`     | less than or equal to    |
| `>`      | greater than             |
| `>=`     | greater than or equal to |
| `~`      | matched by               |
| `!~`     | not matched by           |

- If the pattern is a *comparison expression* like `NF > 10`, then it matches the current input line when the condition is satisfied, that is, when the number of fields in the line is greater than 10.
- If the pattern is an *arithmetic expression* like `NF`, it matches the current input line when its numeric value is *nonzero*.
- If the pattern is a *string expression*, it matches the current input line when the string value of the expression is *nonnull*.

In a relational comparison,

- if both operands are numeric, a numeric comparison is made;
- otherwise, *any numeric operand is converted to a string*, and then the operands are compared as strings. The strings are compared character by character using the ordering provided by the machine, most often the `ASCII` character set. One string is said to be "less than" another if it would appear before the other according to this ordering, e.g., `"Canada" < "China"` and `"Asia" < "Asian"`.

The pattern

```awk
$3/$2 >= 0.5
```

selects lines where the value of the third field divided by the second is numerically greater than or equal to 0.5, while

```awk
$0 >= "M"
```

selects lines that begin with an M, N, O, etc.:

```console
USSR    8649    275     Asia
USA     3615    237     North America
Mexico  762     78      North America
```

Sometimes the type of a comparison operator cannot be determined solely by the syntax of the expression in which it appears. The program

```awk
$1 < $4
```

could compare the *first* and *fourth* fields of each input line either as numbers or as strings. Here, the type of the comparison depends on the values of the fields, and it may vary from line to line. In the `countries.txt` file, the *first* and *fourth* fields are always strings, so string comparisons are always made; the output is

```console
Canada  3852    25      North America
Brazil  3286    134     South America
Mexico  762     78      North America
England 94      56      Europe
```

### 1.3. String-Matching Patterns

A *string-matching pattern* tests whether a string contains a substring matched by a *regular expression*.

---

**String-Matching Patterns**

1. `/regexpr/`

    Matches when the *current input line* contains a substring matched by *regexpr*.

2. `expression ~ /regexpr/`

    Matches if the *string value of expression* contains a substring matched by *regexpr*.

3. `expression !~ /regexpr/`

    Matches if the *string value of expression* does not contain a substring matched by *regexpr*.

---

The simplest regular expression is a string of letters and numbers, like Asia, that matches itself. To turn a regular expression into a *string-matching pattern*, just enclose it in slashes(`/`):

```awk
/Asia/
```

This pattern matches when the current input line contains the substring *Asia*, either as *Asia* by itself or as some part of a larger word like *Asian* or *Pan-Asiatic*. Note that *blanks* are significant within regular expressions: the string-matching pattern

```awk
/ Asia /
```

matches only when *Asia* is surrounded by *blanks*.

The pattern above is one of **3** types of *string-matching patterns*. Its form is a regular expression `r` enclosed in slashes:

```awk
/r/
```

This pattern matches an input line if the line contains a substring matched by `r`.

The other two types of *string-matching patterns* use an explicit *matching operator*(`~`):

```awk
expression ~ /r/
expression !~ /r/
```

The *matching operator* `~` means "is matched by" and `!~` means "is not matched by."

- The first pattern matches when the *string value of expression* contains a substring matched by the regular expression `r`;
- the second pattern matches if there is no such substring.

The left operand of a matching operator is often a field: the pattern

```awk
$4 ~ /Asia/
```

matches all input lines in which the fourth field contains *Asia* as a substring, while

```awk
$4 !~ /Asia/
```

matches if the fourth field does not contain *Asia* anywhere.

Note that the string-matching pattern

```awk
/Asia/
```

is a shorthand for

```awk
$0 ~ /Asia/
```

### 1.4. Regular Expressions
