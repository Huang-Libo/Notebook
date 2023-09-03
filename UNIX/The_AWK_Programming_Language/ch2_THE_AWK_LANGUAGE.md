# Chapter 2: THE AWK LANGUAGE <!-- omit in toc -->

- [1. Patterns](#1-patterns)
  - [1.1. BEGIN and END](#11-begin-and-end)
  - [1.2. Expressions as Patterns](#12-expressions-as-patterns)
  - [1.3. String-Matching Patterns](#13-string-matching-patterns)
  - [1.4. Regular Expressions](#14-regular-expressions)
  - [1.5. Compound Patterns](#15-compound-patterns)
  - [1.6. Range Patterns](#16-range-patterns)
- [2. Actions](#2-actions)
  - [2.1. Expressions](#21-expressions)
    - [2.1.1. Constants](#211-constants)
    - [2.1.2. Variables](#212-variables)
    - [2.1.3. Built-In Variables](#213-built-in-variables)
      - [2.1.3.1. The difference between `%.6g` and `%.6f`](#2131-the-difference-between-6g-and-6f)
    - [2.1.4. Field Variables](#214-field-variables)
    - [2.1.5. Arithmetic Operators](#215-arithmetic-operators)
    - [2.1.6. Comparison Operators](#216-comparison-operators)
    - [2.1.7. Logical Operators](#217-logical-operators)
    - [2.1.8. Conditional Expressions](#218-conditional-expressions)
    - [2.1.9. Assignment Operators](#219-assignment-operators)
    - [2.1.10. Increment and Decrement Operators](#2110-increment-and-decrement-operators)
    - [2.1.11. Built-In Arithmetic Functions](#2111-built-in-arithmetic-functions)
    - [2.1.12. String Operators](#2112-string-operators)
    - [2.1.13. Strings as Regular Expressions](#2113-strings-as-regular-expressions)
    - [2.1.14. Built-In String Functions](#2114-built-in-string-functions)
      - [2.1.14.1. `index(s, t)`](#21141-indexs-t)
      - [2.1.14.2. `match(s, r)`](#21142-matchs-r)
      - [2.1.14.3. `split(s, a, fs)`](#21143-splits-a-fs)
      - [2.1.14.4. `sprintf(format, expr_1 , expr_2 , ... , expr_n)`](#21144-sprintfformat-expr_1--expr_2----expr_n)
      - [2.1.14.5. `sub(r, s, t)`](#21145-subr-s-t)
      - [2.1.14.6. `gsub(r, s, t)`](#21146-gsubr-s-t)
      - [2.1.14.7. Special Meaning of `&` Symbol in `sub()` and `gsub()`](#21147-special-meaning-of--symbol-in-sub-and-gsub)
      - [2.1.14.8. `substr(s, p)`](#21148-substrs-p)
      - [2.1.14.9. Concatenation of Strings](#21149-concatenation-of-strings)
    - [2.1.15. Number or String?](#2115-number-or-string)
    - [2.1.16. Summary of Operators](#2116-summary-of-operators)
  - [2.2. Control-Flow Statements](#22-control-flow-statements)
    - [2.2.1. `if-else`](#221-if-else)
    - [2.2.2. `while`](#222-while)
    - [2.2.3. `for`](#223-for)
    - [2.2.4. `do-while`](#224-do-while)
    - [2.2.5. `break` and `continue`](#225-break-and-continue)
    - [2.2.6. `next` and `exit`](#226-next-and-exit)
  - [2.3. Empty Statement](#23-empty-statement)
  - [2.4. Arrays](#24-arrays)
    - [2.4.1. Introduction](#241-introduction)
    - [2.4.2. The delete Statement](#242-the-delete-statement)
    - [2.4.3. The split Function](#243-the-split-function)
    - [2.4.4. Multidimensional Arrays](#244-multidimensional-arrays)
- [3. User-Defined Functions](#3-user-defined-functions)
- [4. Output](#4-output)
  - [4.1. The `print` Statement](#41-the-print-statement)
  - [4.2. Output Separators (`OFS` and `ORS`)](#42-output-separators-ofs-and-ors)
  - [4.3. The printf Statement](#43-the-printf-statement)
  - [4.4. Output Into Files](#44-output-into-files)
  - [4.5. Output Into Pipes](#45-output-into-pipes)
  - [4.6. Closing Flies and Pipes](#46-closing-flies-and-pipes)
- [5. Input](#5-input)
  - [5.1. Input Separators](#51-input-separators)
  - [5.2. Multiline Records](#52-multiline-records)
  - [5.3. The `getline` Function](#53-the-getline-function)
  - [5.4. Command-Line Variable Assignments](#54-command-line-variable-assignments)
  - [5.5. Command-Line Arguments](#55-command-line-arguments)
- [6. Interaction with Other Programs](#6-interaction-with-other-programs)
  - [6.1. The `system` Function](#61-the-system-function)
  - [6.2. Making a Shell Command from an AWK Program](#62-making-a-shell-command-from-an-awk-program)

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

The string `""`, which contains no characters, is called the *null string*. The term *substring* means a contiguous sequence of zero or more characters within a string. **In every string, the *null string* appears as a *substring* of length zero before the first character, between every pair of adjacent characters, and after the last character.**

Any expression can be used as an operand of any operator.

- If an expression has a numeric value but an operator requires a string value, the numeric value is automatically transformed into a string;
- similarly, a string is converted into a number when an operator demands a numeric value.

**Any expression can be used as a pattern. If an expression used as a pattern has a *nonzero* or *nonnull* value at the current input line, then the pattern matches that line.** The typical expression patterns are those involving comparisons between numbers or strings.

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

The simplest *regular expression* is a string of letters and numbers, like Asia, that matches itself. To turn a *regular expression* into a *string-matching pattern*, just enclose it in slashes(`/`):

```awk
/Asia/
```

This pattern matches when the current input line contains the substring *Asia*, either as *Asia* by itself or as some part of a larger word like *Asian* or *Pan-Asiatic*. Note that *blanks* are significant within *regular expressions*: the string-matching pattern

```awk
/ Asia /
```

matches only when *Asia* is surrounded by *blanks*.

The pattern above is one of **3** types of *string-matching patterns*. Its form is a *regular expression* `r` enclosed in slashes:

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

- The first pattern matches when the *string value of expression* contains a substring matched by the *regular expression* `r`;
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

A *regular expression* is a notation for specifying and matching strings.

---

**Regular Expressions**

1. The *regular expression metacharacters* are:

    `.` `*` `+` `?` `^` `$` `\` `|` `(` `)` `[` `]` `{` `}`

2. A basic *regular expression* is one of the following:

    - a non-metacharacter, such as *A*. that matches itself.
    - an escape sequence that matches a special symbol: `\t` matches a *tab*
    - a *quoted* metacharacter, such as `\*`, that matches the metacharacter literally.
    - `^`, which matches the *beginning* of a string.
    - `$`, which matches the *end* of a string.
    - `.`, which matches *any* single character *except* `\n`.
    - *a character class*: `[ABC]` matches any of the characters *A*, *B*, or *C*.
    - *character classes* may include abbreviations: `[A-Za-z]` matches any single letter.
    - *a complemented character class*: `[^0-9]` matches any character except a digit.

3. These operators combine *regular expressions* into larger ones:

    - alternation: `A|B` matches *A* or *B*.
    - concatenation: `AB` matches *A* immediately followed by *B*.
    - closure: `A*` matches zero or more *A*'s.
    - positive closure: `A+` matches one or more *A*'s.
    - zero or one: `A?` matches the *null string* or *A*.
    - parentheses: `(r)` matches the same strings as *r* does.

---

The characters

`.` `*` `+` `?` `^` `$` `\` `|` `(` `)` `[` `]` `{` `}`

are called *metacharacters* because they have special meanings.

To preserve the *literal* meaning of a *metacharacter* in a *regular expression*, precede it by a *backslash*. Thus, the *regular expression* `\$` matches the character `$`. If a character is preceded by a single `\`, we'll say that character is **quoted**.

A *regular expression* consisting of a group of characters enclosed in *brackets*(`[]`) is called a *character class*; it matches any one of the enclosed characters. For example, `[AEIOU]` matches any of the characters *A*, *E*, *I*, *O*, or *U*.

Ranges of characters can be abbreviated in a *character class* by using a hyphen(`-`).

- The character immediately to the left of the hyphen defines the beginning of the range;
- the character immediately to the right defines the end.

Thus, `[0-9]` matches any digit, and `[a-zA-Z][0-9]` matches a letter followed by a digit.

**Without both a left and right operand, a hyphen(`-`) in a character class denotes itself**,

- so the character classes `[+-]` and `[-+]` match either a `+` or a `-`.
- The character class `[A-Za-z-]+` matches words that include hyphens.

A *complemented character class* is one in which the first character after the `[` is a `^` . Such a class matches any character *not* in the group following the caret. Thus, `[^0-9]` matches any character except a digit; `[^a-zA-Z]` matches any character except an upper or lower-case letter.

| Pattern    | Meaning                                                                    |
|------------|----------------------------------------------------------------------------|
| `^[ABC]`   | matches an *A*, *B* or *C* at the beginning of a string                    |
| `^[^ABC]`  | matches any character at the beginning of a string. except *A*, *B* or *C* |
| `[^ABC]`   | matches any character other than an *A*, *B* Or *C*                        |
| `^[^a-z]$` | matches any single-character string, except a lower-case letter            |

**Inside a *character class*, all characters have their literal meaning, except for the quoting character `\`, `^` at the beginning, and `-` between two characters.** Thus, **`[.]` matches a period(`.`)** and `^[^^]` matches any character except a caret at the beginning of a string.

Parentheses are used in regular expressions to specify how components are grouped.

| Pattern  | Meaning                                          |
|----------|--------------------------------------------------|
| `AB+C`   | matches *ABC* or *ABBC* or *ABBBC*, and so on    |
| `(AB)+C` | matches *ABC* or *ABABC* or *ABABABC*, and so on |

In regular expressions, the *alternation* operator `|` has the *lowest* precedence, then *concatenation*, and finally the *repetition* operators `*`, `+`, and `?`. As in arithmetic expressions, operators of higher precedence are done before lower ones. These conventions often allow parentheses to be omitted: `ab|cd` is the same as `(ab)|(cd)`, and `^ab|cd*e$` is the same as `(^ab)|(c(d*)e$)`.

To finish our discussion of regular expressions, here are some examples of useful string-matching patterns containing regular expressions with *unary* and *binary* operators, along with a description of the kinds of input lines they match.

- `^(\+|-)?[0-9]+\.?[0-9]*$`
  - a decimal number with an optional sign and optional fraction
- `^[+-]?[0-9]+[.]?[0-9]*$`
  - also a decimal number with an optional sign and optional fraction

Since `+` and `.` are *metacharacters*, they have to be preceded by *backslashes*(`\`) in the first example to match *literal* occurrences. **These backslashes are *not* needed within *character classes*, so the second example shows an alternate way to describe the same numbers.**

### 1.5. Compound Patterns

A *compound pattern* is an expression that combines other patterns, using parentheses and the logical operators `||` (OR), `&&` (AND), and `!` (NOT). A compound pattern matches the current input line if the expression evaluates to `true`.

The program

```awk
$4 == "Asia" || $4 == "Europe"
```

uses the `OR` operator to select lines with either *Asia* or *Europe* as the fourth field. Because the latter query is a test on string values, another way to write it is to use a *regular expression* with the alternation operator `|`:

```awk
$4 ~ /^(Asia|Europe)$/
```

If there are no occurrences of *Asia* or *Europe* in other fields, this pattern could also be written as

```awk
/Asia/ || /Europe/
```

or even

```awk
/Asia|Europe/
```

The `||` operator has the *lowest* precedence, then `&&`, and finally `!`. The `&&` and `||` operators evaluate their operands from *left* to *right*; evaluation stops as soon as truth or falsehood is determined.

### 1.6. Range Patterns

A *range pattern* consists of two patterns separated by a comma, as in

```awk
pat1, pat2
```

A *range pattern* matches each line between an occurrence of `pat1` and the next occurrence of `pat2` inclusive; `pat2` may match the same line as `pat1` , making the range a single line. As an example, the pattern

```awk
/Canada/, /USA/
```

matches lines starting with the first line that contains *Canada* up through the next line that contains *USA*.

prints:

```console
Canada  3852    25      North America
China   3705    1032    Asia
USA     3615    237     North America
```

Matching begins whenever the first pattern of a range matches; if no instance of the second pattern is subsequently found, then all lines to the end of the input are matched:

```awk
/Europe/, /Africa/
```

prints

```console
France  211     55      Europe
Japan   144     120     Asia
Germany 96      61      Europe
England 94      56      Europe
```

In the next example

- `FNR`(*File Number of Record*) is *the number of the line just read from the current input file*
- `FILENAME` is the filename itself

both are *built-in variables*.

**Difference between `NR` and `FNR`**:

| Variable | Meaning                                             |
|----------|-----------------------------------------------------|
| FNR      | Record number within the *current* input file       |
| NR       | *Cumulative* record number across *all* input files |

Thus, the program

```awk
FNR == 1, FNR == 5 { print FILENAME ": " $0 }
```

prints the first five lines of *each input file* with the filename prefixed. Alternately, this program could be written as

```awk
FNR <= 5 { print FILENAME ": " $0 }
```

> Note: **A *range pattern* cannot be part of any other pattern.**

## 2. Actions

In a pattern-action statement, the pattern determines when the action is to be executed. Sometimes an action is very simple: a single print or assignment. Other times, it may be a sequence of several statements separated by *newlines* or *semicolons*.

---

**Actions**

The statements in actions can include:

- *expressions*, with constants, variables, assignments, function calls, etc.
- `print` *expression-list*
- `printf`(*format, expression-list*)
- `if` *(expression) statement*
- `if` *(expression) statement* `else` *statement*
- `while` *(expression) statement*
- `for` (*expression; expression; expression*) *statement*
- `for` (*key in array*) *statement*
- `do` *statement* `while` (*expression*)
- `break`
- `continue`
- `next`
- `exit`
- `exit` *expression*
- { *statements* }

---

### 2.1. Expressions

We begin with *expressions*, since expressions are the simplest *statements*, and most other statements are made up of expressions of various kinds. An expression is formed by combining *primary expressions* and other expressions with *operators*.

- The *primary expressions* are the primitive building blocks: they include constants, variables, array references, function invocations, and various built-ins, like field names.

---

**Expressions**

1. The primary expressions are:

    numeric and string constants, variables, fields, function calls, array elements.

2. These operators combine expressions:

    - *unary operator* `+` `-`
    - *arithmetic operators* `+` `-` `*` `/` `%` `^`
    - *assignment operators* `=` `+=` `-=` `*=` `/=` `%=` `^=`
    - *increment and decrement operators* `++` `--`
    - *relational operators* `<` `<=` `==` `!=` `>` `>=`
    - *logical operators* `||` `&&` `!`
    - *matching operators* `~` `!~`
    - *conditional expression operator* `?:`
    - *concatenation* (no explicit operator)
    - *parentheses for grouping*

---

#### 2.1.1. Constants

There are two types of constants, *string* and *numeric*.

- A *string constant* is created by enclosing a sequence of characters in quotation marks, as in `"Asia"` or `"hello, world"` or `""` . String constants may contain the *escape sequences*.
- A *numeric constant* can be an *integer* like `1127`, a *decimal* number like `3.14`, or a number in scientific (exponential) notation like `0.707E-1`.
  - Different representations of the same number have the same numeric value: the numbers `1e6`, `1.OOE6`, `10e5`, `0.1e7`, and `1000000` are numerically equal.
  - All numbers are stored in *floating point*, the precision of which is machine dependent.

#### 2.1.2. Variables

Expressions can contain several kinds of variables: *user-defined*, *built-in*, and *fields*.

- The names of *user-defined variables* are sequences of letters, digits, and underscores that do not begin with a digit;
- all *built-in variables* have UPPER-CASE names.

A variable has a value that is a string or a number or both. Since the type of a variable is not declared, awk *infers* the type from context. When necessary, awk will convert a string value into a numeric one, or vice versa. For example, in

```awk
$4 == "Asia" { print $1, 1000 * $2 }
```

`$2` is converted into a number if it is not one already, and `$1` and `$4` are converted into strings if they are not already.

An uninitialized variable has the string value `""` (the *null string*) and the numeric value `0`.

#### 2.1.3. Built-In Variables

*Built-In variables* can be used in all expressions, and may be reset by the user. `FILENAME` is set each time a new file is read. `NR`, `FNR` and `NF` are set each time a new record is read; additionally, `NF` is reset when `$0` changes or when a new field is created. `RLENGTH` and `RSTART` change as a result of invoking the `match` function.

**BUILT-IN VARIABLES**

| VARIABLE   | MEANING                                    | DEFAULT  |
|------------|--------------------------------------------|----------|
| `ARGC`     | number of command-line arguments           | -        |
| `ARGV`     | array of command-line arguments            | -        |
| `FILENAME` | name of current input file                 | -        |
| `NF`       | number of fields in current record         | -        |
| `NR`       | number of records read so far              | -        |
| `FNR`      | record number in current file              | -        |
| `FS`       | controls the input field separator         | `" "`    |
| `OFS`      | output field separator                     | `" "`    |
| `RS`       | controls the input record separator        | `"\n"`   |
| `ORS`      | output record separator                    | `"\n"`   |
| `OFMT`     | output format for numbers                  | `"%.6g"` |
| `SUBSEP`   | subscript separator                        | `\034`   |
| `RSTART`   | start of string matched by match function  | -        |
| `RLENGTH`  | length of string matched by match function | -        |

> Note: *FMT* in `OFMT` is short for *Format*.

##### 2.1.3.1. The difference between `%.6g` and `%.6f`

**The meaning of `%.6g`**:

- This format specifier specifies that the numeric value should be formatted with up to **6 significant digits** in a `g` format. The `g` format is used to print floating-point numbers in either fixed-point or scientific notation, depending on the magnitude of the value.

For example, consider the following awk code:

```awk
awk 'BEGIN { value = 123.456789; printf "%.6g\n", value }'
```

In this code, the printf function uses the format specifier `%.6g` to format the value `123.456789`. The output will be:

```console
123.457
```

**The meaning of `%.6f`**:

- This format specifier specifies that the numeric value should be formatted as a floating-point number with exactly **6 decimal places**. e.g.

```awk
awk 'BEGIN { value = 123.456789; printf "%.6f\n", value }'
```

prints

```console
123.456789
```

#### 2.1.4. Field Variables

The fields of the current input line are called `$1`, `$2`, through `$NF`; `$0` refers to the whole line.

One can assign a new string to a field:

```awk
BEGIN                   { FS = OFS = "\t" }
$4 == "North America"   { $4 = "NA" }
$4 == "South America"   { $4 = "SA" }
                        { print }
```

The `print` statement in the fourth line prints the value of `$0` after it has been modified by previous assignments. This is important:

- when `$0` is changed by assignment or substitution, **`$1`, `$2`, ..., and `NF` will be recomputed**;
- likewise, when one of `$1`, `$2`, ..., is changed, **`$0` is reconstructed using `OFS` to separate fields**.

Fields can also be specified by expressions. For example, `$(NF-1)` is the next-to-last field of the current line. *The parentheses are needed*: `$NF-1` is one less than the numeric value of the last field.

A field variable referring to a nonexistent field, e.g., `$(NF+1)` , has as its initial value the *null string*.

**A new field can be created by assigning a value to it**. For example, the following program creates a fifth field containing the population density:

```awk
BEGIN { FS = OFS = "\t" }
      { $5 = 1000 * $3 / $2; print }
```

The number of fields can vary from line to line, but there is usually an implementation **limit of 100 fields per line**.

#### 2.1.5. Arithmetic Operators

Awk provides the usual `+`, `-`, `*`, `/`, `%`, and `^` arithmetic operators.

- The `%` operator computes remainders: `x%y` is the remainder when `x` is divided by `y`; its behavior depends on the machine if `x` or `y` is negative.
- The `^` operator is exponentiation.

All arithmetic is done in *floating point*.

#### 2.1.6. Comparison Operators

Comparison expressions are those containing either a *relational operator* or a *regular expression matching operator*.

- The *relational operators* are `<`, `<=`, `==`, `!=`, `>=`, `>`.
- The *regular expression matching operators* are `~` (is matched by) and `!~` (is not matched by).

The value of a comparison expression is `1` if it is true and `0` otherwise. Similarly, the value of a matching expression is `1` if true, `0` if false.

#### 2.1.7. Logical Operators

The logical operators `&&` `||` `!` are used to create logical expressions by combining other expressions.

The operands of expressions separated by `&&` or `||` are *evaluated from left to right*, and evaluation ceases as soon as the value of the complete expression can be determined. This means that in

```awk
expr1 && expr2
```

`expr2` is not evaluated if `expr1` is *false*, while in

```awk
expr3 || expr4
```

`expr4` is not evaluated if `expr3` is *true*.

#### 2.1.8. Conditional Expressions

A conditional expression has the form

```awk
expr1 ? expr2 : expr3
```

The following program uses a conditional expression to print the reciprocal of `$1`, or a warning if `$1` is `0`:

```awk
{ print ($1 != 0 ? 1/$1 : "$1 is zero, line " NR) }
```

#### 2.1.9. Assignment Operators

There are **7** assignment operators that can be used in expressions called assignments, `=` `+=` `-=` `*=` `/=` `%=` `^=`.

An assignment is an expression; its value is the new value of the left side. Thus assignments can be used inside any expression. In the *multiple assignment*

```awk
FS = OFS = "\t"
```

both the *field separator* and the *output field separator* are set to *tab*. Assignment expressions are also common within tests, such as:

```awk
if ((n = length($0)) > 0) ...
```

#### 2.1.10. Increment and Decrement Operators

The assignment

```awk
n = n + 1
```

is usually written `++n` or `n++` using the *unary increment operator* `++`, which adds `1` to a variable.

The prefix and postfix decrement operator `--`, which subtracts `1` from a variable, works the same way.

#### 2.1.11. Built-In Arithmetic Functions

The *built-in arithmetic functions* are shown in Table below, `x` and `y` are arbitrary expressions.

| FUNCTION     | VALUE RETURNED                                          |
|--------------|---------------------------------------------------------|
| `sqrt(x)`    | square root of `x`                                      |
| `int(x)`     | integer part of `x`; truncated towards `0` when `x > 0` |
| `log(x)`     | natural (base `e`) logarithm of `x`                     |
| `exp(x)`     | exponential function of `x`, `e^x`                      |
| `sin(x)`     | sine of `x`, with `x` in radians                        |
| `cos(x)`     | cosine of `x`, with `x` in radians                      |
| `atan2(y,x)` | arctangent of `y/x` in the range `-π` to `π`            |
| `rand()`     | random number `r`, where `0 ≤ r < 1`                    |
| `srand(x)`   | `x` is new seed for `rand()`                            |

Useful constants can be computed with these functions:

- `atan2(0,-1)` gives `π`
- `exp(1)` gives `e`, the base of the natural logarithms

To compute the `base-10` logarithm of `x`, use `log(x)/log(10)`.

The function `rand()` returns a *pseudo-random* floating point number greater than or equal to `0` and less than `1`.

- Calling `srand(x)` sets the starting point of the generator from `x`.
- Calling `srand()`(*without parameter*) sets the starting point from the time of day.
- If `srand` is not called, `rand` starts with the same value each time the program is run.

The assignment

```awk
rand_int = int(n * rand()) + 1
```

sets `rand_int` to a random integer between `1` and `n` inclusive.

Here we are using the `int` function to discard the fractional part. The assignment

```awk
x = int(x + 0.5)
```

rounds the value of `x` to the nearest integer when `x` is positive.

#### 2.1.12. String Operators

There is only one string operation, **concatenation**. It has no explicit operator: string expressions are created by writing *constants*, *variables*, *fields*, *array elements*, *function values*, and *other expressions* next to one another. The program

```awk
{ print NR ":" $0 }
```

prints each line preceded by its line number and a colon, with no blanks. The number `NR` is converted to its string value (and so is `$0` if necessary); then the three strings are concatenated and the result is printed.

#### 2.1.13. Strings as Regular Expressions

So far, in all of our examples of matching expressions, the right-hand operand of `~` and `!~` has been a *regular expression* enclosed in slashes. But, in fact, *any expression can be used as the right operand of these operators*. Awk evaluates the expression, converts the value to a string if necessary, and interprets the string as a regular expression. For example, the program

```awk
BEGIN { digits = "^[0-9]+$" }
$2 ~ digits
```

will print all lines in which the second field is a string of digits.

Since expressions can be concatenated, a *regular expression* can be built up from components. The following program echoes input lines that are valid floating point numbers:

```awk
BEGIN {
    sign = "[+-]?"
    decimal = "[0-9]+[.]?[0-9]*"
    fraction = "[.][0-9]+"
    exponent = "([eE]" sign "[0-9]+)?"
    number = "^" sign "(" decimal "|" fraction ")" exponent "$"
}
$0 ~ number
```

In a matching expression, a quoted string like `"^[0-9]+$"` can normally be used *interchangeably* with a *regular expression* enclosed in slashes, such as `/^[0-9]+$/`. There is **one exception**, however. If the string in quotes is to match a *literal* occurrence of a *regular expression metacharacter*, one extra backslash is needed to protect the protecting backslash itself. That is,

```awk
$0 ~ /(\+|-)[0-9]+/
```

and

```awk
$0 ~ "(\\+|-)[0-9]+"
```

are equivalent.

This behavior may seem *arcane*, but it arises because **one level of protecting backslashes is removed when a quoted string is parsed by awk**. If a backslash is needed in front of a metacharacter to turn off its special meaning in a regular expression, then that *backslash needs a preceding backslash to protect it in a string*. If the right operand of a matching operator is a *variable* or *field variable*, as in

```awk
x ~ $1
```

**then the additional level of backslashes is not needed in the first field because backslashes have no special meaning in data.**

As an aside, it's easy to test your understanding of regular expressions interactively: the program

```awk
$1 ~ $2
```

lets you type in a string and a regular expression; it echoes the line back if the string matches the regular expression.

#### 2.1.14. Built-In String Functions

Awk provides the built-in string functions shown in Table below.

| FUNCTION                  | DESCRIPTION                                                                                                        |
|---------------------------|--------------------------------------------------------------------------------------------------------------------|
| `length(s)`               | return number of characters in `s`                                                                                 |
| `substr(s, p)`            | return *suffix* of `s` starting at position `p`                                                                    |
| `substr(s, p, n)`         | return substring of s of length `n` starting at position `p`                                                       |
| `sub(r, s)`               | substitute `s` for the leftmost longest substring of `$0` matched by `r`, <br> return number of substitutions made |
| `sub(r, s, t)`            | substitute `s` for the leftmost longest substring of `t` matched by `r`, <br> return number of substitutions made  |
| `gsub(r,s)`               | substitute `s` for `r` globally in `$0`, <br> return number of substitutions made                                  |
| `gsub(r ,s ,t)`           | substitute `s` for `r` globally in string `t`, <br> return number of substitutions made                            |
| `split(s ,a)`             | split `s` into array `a` on `FS`, <br> *return number of fields*                                                   |
| `split(s ,a ,fs)`         | split `s` into array `a` on field separator `fs`, <br> return number of fields                                     |
| `index(s ,t)`             | return first position(start from `1`) of string `t` in `s`, or `0` if `t` is not present                           |
| `match(s ,r)`             | test whether `s` contains a substring matched by `r`, <br> return index or `0`; sets `RSTART` and `RLENGTH`        |
| `sprintf(fmt, expr-list)` | return *expr-list* formatted according to format string `fmt`                                                      |

> In this table, `r` represents a *regular expression* (either as a string or enclosed in slashes), `s` and `t` are string expressions, and `n` and `p` are integers.

##### 2.1.14.1. `index(s, t)`

The function `index(s, t)` returns the *leftmost position* where the string `t` begins in `s`, or `0` if t does not occur in `s`. The first character in a string is at position `1`:

```awk
index("banana", "an")
```

returns `2`.

##### 2.1.14.2. `match(s, r)`

The function `match(s, r)` finds the *leftmost longest substring* in the strings that is matched by the *regular expression* `r`. It returns the index where the substring begins or `0` if there is no matching substring. It also sets the *built-in variables* `RSTART` to this index and `RLENGTH` to the length of the matched substring.

##### 2.1.14.3. `split(s, a, fs)`

The function `split(s, a, fs)` splits the string `s` into the array `a` according to the separator `fs` and returns the number of elements. It is described after arrays, at the end of this section.

##### 2.1.14.4. `sprintf(format, expr_1 , expr_2 , ... , expr_n)`

The string function `sprintf(format, expr_1 , expr_2 , ... , expr_n)` returns(*without printing*) a string containing `expr_1`, `expr_2` , ... , `expr_n` formatted according to the `printf` specifications in the string value of the expression `format`. Thus, the statement

```awk
x = sprintf("%10s %6d", $1, $2)
```

assigns to `x` the string produced by formatting the values of `$1` and `$2` as a ten-character string and a decimal number in a field of width at least six. **Section 2.4** contains a complete description of the format-conversion characters.

##### 2.1.14.5. `sub(r, s, t)`

The functions `sub` and `gsub` are patterned after the substitute command in the Unix text editor `ed`. The function `sub(r, s, t)` first finds the **leftmost longest substring** matched by the *regular expression* `r` in the target string `t`; it then replaces the substring by the substitution string `s`. As in `ed`, **"leftmost longest" means that the leftmost match is found first, then extended as far as possible.**

- In the target string `banana`, for example, `anan` is the leftmost longest substring matched by the *regular expression* `(an)+`.
- **By contrast, the leftmost longest match of `(an)*` is the *null string* before `b`.**

The `sub` function returns the number of substitutions made. The function `sub(r,s)` is a synonym for `sub(r, s, $0)`.

##### 2.1.14.6. `gsub(r, s, t)`

The function `gsub(r, s, t)` is similar, except that it *successively* replaces the *leftmost longest non-overlapping substrings* matched by `r` with `s` in `t`; it returns the number of substitutions made. (The "g" is for "global", meaning everywhere.) For example, the program

```awk
{ gsub(/USA/, "United States" ); print }
```

will transcribe its input, replacing all occurrences of *"USA"* by *"United States"*. (In such examples, when `$0` changes, the fields and `NF` change too.) And

```awk
gsub(/ana/, "anda", "banana")
```

will replace *banana* by *bandana*; matches are non-overlapping.

##### 2.1.14.7. Special Meaning of `&` Symbol in `sub()` and `gsub()`

In a substitution performed by either `sub(r , s, t)` or `gsub(r, s, t)`, any occurrence of the character `&` in `s` will be replaced by the substring matched by `r`. Thus

```awk
gsub(/a/, "aba", "banana")
```

replaces *banana* by *babanabanaba*; so does

```awk
gsub(/a/, "&b&", "banana")
```

The special meaning of `&` in the substitution string can be turned off by preceding it with a backslash, as in `\&`.

##### 2.1.14.8. `substr(s, p)`

The function `substr(s, p)` returns the suffix of `s` that begins at position `p`. If `substr(s, p, n)` is used, only the first `n` characters of the suffix are returned; if the suffix is shorter than `n`, then the entire suffix is returned. For example, we could abbreviate the country names in countries to their first three characters by the program

```awk
{ $1 = substr($1, 1, 3); print $0 }
```

to produce

```console
USS 8649 275 Asia
Can 3852 25 North America
Chi 3705 1032 Asia
USA 3615 237 North America
Bra 3286 134 South America
Ind 1267 746 Asia
Mex 762 78 North America
Fra 211 55 Europe
Jap 144 120 Asia
Ger 96 61 Europe
Eng 94 56 Europe
```

**Setting `$1` forces awk to recompute `$0` and thus the fields are now separated by a blank (the default value of `OFS`), no longer by a tab.**

##### 2.1.14.9. Concatenation of Strings

Strings are concatenated merely by writing them one after another in an expression. For example, on the countries file,

```awk
    { s = s substr($1, 1, 3) " " }
END { print s }
```

prints

```console
USS Can Chi USA Bra Ind Mex Fra Jap Ger Eng
```

by building `s` up a piece at a time starting with an initially empty string. (If you are worried about the extra blank on the end, use

```awk
print substr(s, 1, length(s)-1)
```

instead of print `s` in the `END` action.)

#### 2.1.15. Number or String?

The value of an expression may be automatically converted from a *number* to a *string* or vice versa, depending on what operation is applied to it. In an arithmetic expression like

```awk
pop + $3
```

the operands `pop` and `$3` must be numeric, so their values will be forced or *coerced* to numbers if they are not already. Similarly, in the assignment expression

```awk
pop += $3
```

`pop` and `$3` must be numbers.

In a string expression like

```awk
$1 $2
```

the operands `$1` and `$2` must be strings to be *concatenated*, so they will be coerced to strings if necessary.

In contexts where the same operator applies to both numbers and strings, there are special rules. In the assignment `v = e`, both the assignment and the variable `v` acquire the type of the expression `e`. In a comparison expression like

```awk
x == y
```

- if **both** operands have a numeric type, the comparison is numeric;
- otherwise, any numeric operand is coerced to a string and the comparison is made on the string values.

Let us examine what this rule means for a comparison like

```awk
$1 == $2
```

that involves *fields variables*. Here, the type of the comparison depends on whether the *fields variables* contain *numbers* or *strings*, and this can only be determined when the program runs; the type of the comparison may differ from input line to input line.

- When awk creates a field at run time, it automatically sets its type to *string*;
- in addition,if the field contains a *machine-representable number*, it **also** gives the field a *numeric type*.

For example, the comparison `$1 == $2` will be numeric and succeed if `$1` and `$2` have any of the values

`1` `1.0` `+1` `1e0` `0.1e+1` `10E-1` `001`

because all these values are different representations of the number `1`. However, this same expression will be a string comparison and hence fail on each of these pairs:

| `$1`  | `$2`    |
|-------|---------|
| 0     | (null)  |
| 0.0   | (null)  |
| 0     | 0a      |
| 1e500 | 1.0e500 |

- In the first three pairs, the second field is *not* a number.
- The last pair will be compared as *strings* on machines where the values are **too large** to be represented as numbers.

The print statement

```awk
print $1
```

prints the string value of the first field; thus, the output is identical to the input.

Uninitialized variables are created with the *numeric value* `0` and the *string value* `""` . **Nonexistent fields and fields that are explicitly null have only the string value `""` ; they are not numeric, but when coerced to numbers they acquire the numeric value `0`.** As we will see at the end of this section, *array subscripts* are strings.

There are two idioms for coercing an expression of one type to the other:

| Expression   | Explanation                                                    |
|--------------|----------------------------------------------------------------|
| *number* ""  | concatenate a *null string* to number to coerce it to a string |
| *string* + 0 | add `0` to string to coerce it to a number                     |

Thus, to force a string comparison between two fields, coerce one field to string:

```awk
$1 "" == $2
```

To force a numeric comparison, coerce **both** fields to numeric:

```awk
$1 + 0 == $2 + 0
```

This works regardless of what the fields contain.

**The numeric value of a string is the value of the longest prefix of the string that looks numeric**. Thus

```awk
BEGIN { print "1E2"+0, "12E"+0, "E12"+0, "1X2Y3"+0 }
```

yields

```console
100 12 0 1
```

The string value of a number is computed by formatting the number with the output format conversion `OFMT`. `OFMT` also controls the conversion of numeric values to strings for *concatenation*, *comparison*, and *creation of array subscripts*. The default value of `OFMT` is `%.6g`. Thus

```awk
BEGIN { print 1E2 "", 12E-2 "", E12 "", 1.23456789 "" }
```

gives

```console
100 0.12  1.23457
```

The default value of `OFMT` can be changed by assigning it a new value. If `OFMT` were changed to `%.2f`, for example, numbers would be printed, and coerced numbers would be compared, with two digits after the decimal point.

#### 2.1.16. Summary of Operators

The operators that can appear in expressions are summarized in Table below. Expressions can be created by applying these operators to *constants*, *variables*, *field names*, *array elements*, *functions*, and *other expressions*.

| OPERATION             | OPERATORS                                       | EXAMPLE      | MEANING OF EXAMPLE                     |
|-----------------------|-------------------------------------------------|--------------|----------------------------------------|
| assignment            | `=`<br>`+=` `-=`<br>`*=` `/=`<br>`%=` `^=`      | `x *= 2`     |                                        |
| conditional           | `?:`                                            | `x ? y : z`  |                                        |
| logical OR            | `||`                                            | `x || y`     |                                        |
| logical AND           | `&&`                                            | `x && y`     |                                        |
| array membership      | `in`                                            | `i in a`     | `1` if `a[i]` exists,<br>`0` otherwise |
| matching              | `~` `!~`                                        | `$1 ~ /x/`   |                                        |
| relational            | `<` `<=`<br>`==` `!=`<br>`>=` `>`               | `x == y`     |                                        |
| concatenation         | (There is *no* explicit concatenation operator) | `"a" "bc"`   | `abc`                                  |
| add, subtract         | `+` `-`                                         | `x + y`      |                                        |
| multiply, divide, mod | `*` `/` `%`                                     | `x % y`      |                                        |
| unary plus and minus  | `+` `-`                                         | `-x`         |                                        |
| logical NOT           | `!`                                             | `!$1`        |                                        |
| exponentiation        | `^`                                             | `x ^ y`      |                                        |
| increment, decrement  | `++` `--`                                       | `x++`        |                                        |
| field                 | `$`                                             |              |                                        |
| grouping              | `()`                                            | ~~`($i)++`~~ | Incorrect example                      |

> Note: The last example is incorrect, awk will report syntax error - *illegal statement*.

The operators are listed in order of **increasing precedence**. Operators of higher precedence are evaluated before lower ones; this means, for example, that `*` is evaluated before `+` in an expression.

All operators are left associative except the *assignment operators*, the *conditional operator*, and *exponentiation*, which are right associative. Left associativity means that operators of the same precedence are evaluated left to right; thus `3-2-1` is `(3-2)-1`, not `3-(2-1)`.

Since there is no explicit operator for *concatenation*, it is wise to *parenthesize* expressions involving other operators in concatenations. the program

```awk
$1 < 0 { print "abs($1) = " -$1 }
```

**The expression following print seems to use concatenation, but is actually a subtraction.** (The precedence of *concatenation operator* is lower than *unary minus operator*)

The programs

```awk
$1 < 0 { print "abs($1) = " (-$1) }
```

and

```awk
$1 < 0 { print "abs($1) =", -$1 }
```

both do what was intended.

### 2.2. Control-Flow Statements

---

**Control-Flow Statements**

- `{ statements }`
  - statement grouping
- `if (expression) statement`
  - if *expression* is `true`, execute *statement*
- `if (expression) statement_1 else statement_2`
  - if *expression* is `true`, execute *statement_1* otherwise execute *statement_2*
- `while (expression) statement`
  - if *expression* is `true`, execute *statement*, then repeat
- `for (expression_1; expression_2; expression_3) statement`
  - equivalent to `expression_1; while (expression_2 ) { statement; expression_3 }`
- `for (key in array) statement`
  - execute *statement* with variable set to each *subscript* (**key**) in array in turn
- `do statement while (expression)`
  - execute *statement*; if *expression* is `true`, repeat
- `break`
  - immediately leave innermost enclosing `while`, `for` or `do-while` loop
- `continue`
  - start next iteration of innermost enclosing `while`, `for` or `do-while` loop
- `next`
  - start `next` iteration of main input loop
- `exit`
- `exit expression`
  - go immediately to the `END` action; if within the `END` action, exit program entirely. Return *expression* as program status. If the *expression* doesn't exit, then return status `0`.

---

#### 2.2.1. `if-else`

Awk provides braces(`{}`) for grouping statements, an `if-else` statement for decision-making, and `while`, `for`, and `do` statements for looping. All of these statements were adopted from *C Programming Language*.

A single statement can always be replaced by a list of statements enclosed in braces. The statements in the list are separated by *newlines* or *semicolons*.

The `if-else` statement has the form

```awk
if (expression)
    statement_1
else
    statement_2
```

In an `if-else` statement, the test expression is evaluated first.

- If it is `true`, that is, either *nonzero* or *nonnull*, *statement_1* is executed.
- If expression is `false`, that is, either *zero* or *null*(**e.g. null string `""`**), and `else` *statement_2* is present, then *statement_2* is executed.

To eliminate any ambiguity, we adopt the rule that each `else` is associated with the *closest* previous unassociated `if`. For example, the `else` in the statement

```awk
if (e1) if (e2) s=1; else s=2
```

is associated with the second `if`. (The semicolon after `s= 1` is required, since the `else` appears on the same line.)

#### 2.2.2. `while`

The `while` statement repeatedly executes a statement while a condition is `true`:

```awk
while (expression)
    statement
```

For example, this program prints all input fields, one per line:

```awk
{
    i = 1
    while (i <= NF) {
        print $i
        i++
    }
}
```

#### 2.2.3. `for`

The `for` statement is a more general form of `while`:

```awk
for (expression_1; expression_2; expression_3)
    statement
```

The `for` statement has the same effect as

```awk
expression_1
while (expression_2) {
    statement
    expression_3
}
```

so

```awk
{
    for (i = 1; i <= NF; i++)
        print $1
}
```

does the same loop over the fields as the while example above. In the `for` statement, all three expressions are *optional*. If *expression_2* is missing, the condition is taken to be always `true`, so `for(;;)` is an *infinite loop*.

An alternate version of the `for` statement that loops over *array subscripts* is described in the section on arrays.

#### 2.2.4. `do-while`

The `do-while` statement has the form

```awk
do
    statement
while (expression)
```

The `do-while` loop executes statement once, then repeats statement as long as expression is `true`. It differs from the `while` and `for` in a critical way: *its test for completion is at the bottom instead of the top, so it always goes through the loop at least once*.

#### 2.2.5. `break` and `continue`

There are two statements for modifying how loops cycle: `break` and `continue`.

- The `break` statement causes an exit from the immediately enclosing  `for` or `while` or `do-while`.
- The `continue` statement causes the *next* iteration to begin; it causes execution to go to the test expression in the `while` and `do-while`, and to *expression_3* in the `for` statement.

#### 2.2.6. `next` and `exit`

The `next` and `exit` statements *control the outer loop that reads the input lines* in an awk program.

- `next` statement:
  - The `next` statement causes awk to *fetch the next input line* and begin matching patterns starting from the first *pattern-action* statement.
- `exit` statement:
  - In an `END` action, the `exit` statement causes the program to terminate.
  - In any other action, it causes the program to behave as if the end of the input had occurred; no more input is read, and the `END` actions, if any, are executed.

If an `exit` statement contains an expression

```awk
exit expr
```

it causes awk to return the value of `expr` as its *exit status* unless overridden by a subsequent error or exit. If there is no `expr`, the exit status is `0`. In some operating systems, including Unix, the exit status may be tested by the program that invoked awk (Can be checked with the UNIX built-in variable `$?`).

### 2.3. Empty Statement

A semicolon(`;`) by itself denotes the *empty statement*. In the following program, the body of the `for` loop is an *empty statement*.

```awk
BEGIN { FS = "\t" }
      { 
        for (i = 1; i <= NF && $i != ""; i++)
            ;
        if (i <= NF)
            print
      }
```

The program prints all lines that contain an empty field.

### 2.4. Arrays

#### 2.4.1. Introduction

Awk provides one-dimensional arrays for storing *strings* and *numbers*. Arrays and array elements need *not* be declared, nor is there any need to specify how many elements an array has. Like variables, array elements spring into existence by being mentioned; at birth, they have the *numeric value* `0` and the *string value* `""`.

As a simple example, the statement

```awk
x[NR] = $0
```

assigns the current input line to element `NR` of the array `x`. In fact, it is easy (though perhaps slow) to read the entire input into an array, then process it in any convenient order. For example, this variant of the program from *Section 1.7* prints its input in reverse line order:

```awk
    { x[NR] = $0 }
END { for (i = NR; i > 0; i--) print x[i] }
```

The first action merely records each input line in the array `x`, using the *line number* as a *subscript*; the real work is done in the `END` statement.

**The characteristic that sets awk arrays apart from those in most other languages is that subscripts are strings**. This gives awk a capability like the associative memory of `SNOBOL4` tables, and for this reason, arrays in awk are called **associative arrays**.

The following program accumulates the populations of *Asia* and *Europe* in the array `pop`. The `END` action prints the total populations of these two continents.

```awk
/Asia/   { pop["Asia"] += $3 }
/Europe/ { pop["Europe"] += $3 }
END      { print "Asian population is",
               pop["Asia"], "million."
           print "European population is",
               pop["Europe"], "million."
         }
```

On countries, this program generates

```console
Asian population is 2173 million.
European population is 172 million.
```

Note that the *subscripts* are the *string constants* *"Asia"* and *"Europe"*. If we had written `pop[Asia]` instead of `pop["Asia"]`, the expression would have used the value of the *variable* `Asia` as the subscript, and since the variable is uninitialized, the values would have been accumulated in `pop[""]`.

This example doesn't really need an *associative array* since there are only two elements, both named explicitly. Suppose instead that our task is to determine the total population for each continent. *Associative arrays* are ideally suited for this kind of aggregation. Any expression can be used as a subscript in an array reference, so

```awk
pop[$4] += $3
```

uses the string in the fourth field of the current input line to index the array `pop` and in that entry accumulates the value of the third field:

```awk
BEGIN { FS = "\t" }
      { pop[$4] += $3 }
END   { for (name in pop)
            print name, pop[name]
      }
```

The *subscripts* (**keys**) of the array `pop` are the continent names; the values are the accumulated populations. This code works regardless of the number of continents; the output from the countries file is

```console
South America 134
North America 340
Asia 2173
Europe 172
```

The last program used a form of the for statement that loops over all subscripts of an array:

```awk
for (key in array)
    statement
```

This loop executes *statement* with *variable* set in turn to each different *subscript* (**key**) in the array. **The order in which the subscripts are considered is implementation dependent. Results are unpredictable if new elements are added to the array by *statement*.**

You can determine whether a particular subscript occurs in an array with the expression

```awk
subscript in A
```

This expression has the value `1` if `A[subscript]` already exists, and `0` otherwise. Thus, to test whether `"Africa"` is a subscript of the array `pop` you can say

> **NOTE: The example below is testing if a *key* already exists in the array `pop`, it's not testing if a *value* exists in the array `pop`.**

```awk
if ("Africa" in pop) ...
```

This condition performs the test *without* the side effect of creating `pop["Africa"]`, which would happen if you used

```awk
if (pop["Africa"] != "") ...
```

Note that neither (of the two examples above) is a test of whether the array `pop` contains an element with *value* `"Africa"`. (It's testing whether a *key* named "Africa" exists in the array `pop`)

#### 2.4.2. The delete Statement

An array element may be deleted with

```awk
delete array[subscript]
```

For example, this loop removes all the elements from the array `pop`:

```awk
for (i in pop)
    delete pop[i]
```

#### 2.4.3. The split Function

The function `split(str, arr, fs)` splits the string value of `str` into fields and stores them in the array `arr`. The number of fields produced is returned as the value of `split`. The string value of the third argument, `fs`, determines the *field separator*. If there is no third argument, `FS` is used. In either case, the rules are as for input field splitting, which is discussed in *Section 2.5*. The function

```awk
split("7/4/76", arr, "/")
```

splits the string `"7/4/76"` into three fields using `/` as the separator; it stores `7` in `arr["1"]` , `4` in `arr["2"]`, and `76` in `arr["3"]`.

Strings are versatile array subscripts, but the behavior of numeric subscripts as strings may sometimes appear counterintuitive. Since the string values of `1` and `"1"` are the same, `arr[1]` is the same as `arr["1"]`. But notice that `"01"` is not the same string as `"1"` and *the string `"10"` comes before the string `"2"`.* ❓

#### 2.4.4. Multidimensional Arrays

Awk does not support *multidimensional arrays* directly but it provides a simulation using one-dimensional arrays. Although you can write multidimensional subscripts like `i,j` or `s,p,q,r`, awk concatenates the components of the subscripts (with a *separator* between them) to synthesize a single subscript out of the multiple subscripts you write. For example,

```awk
for (i = 1; i <= 10; i++)
    for (j = 1; j <= 10; j++)
        arr[i, j] = 0
```

creates an array of *100* elements whose subscripts appear to have the form `1,1`, `1,2`, and so on. Internally, however, these subscripts are stored as strings of the form `1 SUBSEP 1`, `1 SUBSEP 2`, and so on. The *built-in variable* `SUBSEP` contains the value of the *subscript-component separator*; its default value is not a comma but `"\034"`, a value that is unlikely to appear in normal text.

The test for array membership with multidimensional subscripts uses a parenthesized list of subscripts, such as

```awk
if ((i,j) in arr)
...
```

and use `split(str, arr, SUBSEP)` if access to the individual *subscript components* is needed.

**Array elements cannot themselves be arrays.**

## 3. User-Defined Functions

In addition to *built-in functions*, an awk program can contain *user-defined functions*. Such a function is defined by a statement. of the form

```awk
function name(parameter-list) {
    statements
}
```

The body of a function definition may contain a `return` statement that returns control and perhaps a value to the caller. It has the form

```awk
return expression
```

The *expression* is *optional*, and so is the `return` statement itself, but the returned value is undefined if none is provided or if the last statement executed is not a return.

For example, this function computes the maximum of its arguments:

```awk
function max(m, n) {
    return m > n ? m : n
}
```

The variables `m` and `n` belong to the function `max`; they are unrelated to any other variables of the same names elsewhere in the program.

If a user-defined function is called in the body of its own definition, that function is said to be *recursive*.

For example, the `max` function might be called like this:

```awk
{ print max($1,max($2,$3)) }  # print maximum of $1, $2, $3

function max(m, n) {
    return m > n ? m : n
}
```

- When a function is called with an argument like `$1`, which is just an **ordinary variable**, the function is given a *copy* of the value of the variable, so the function manipulates the copy, not the variable itself. This means that the function cannot affect the value of the variable outside the function. (The jargon is that such variables, called "scalars," are **passed "by value."**)
- **Arrays** are not copied, however, so it is possible for the function to alter array elements or create new ones. (This is called **passing "by reference."**)
- The name of a function may not be used as a parameter.

To repeat,

- within a function definition, the **parameters are local variables** they last only as long as the function is executing, and they are unrelated to variables of the same name elsewhere in the program.
- **But all other variables are global; if a variable is not named in the parameter list, it is visible and accessible throughout the program**.

This means that the way to provide *local variables* for the *private* use of a function is to include them at the end of the parameter list in the function definition. **Any variable in the parameter list for which no actual parameter is supplied in a call is a local variable**, with *null* initial value. This is not a very elegant language design but it at least provides the necessary facility. We put *several blanks* between the arguments and the local variables so they can be distinguished.

> Tips:
>
> - A more elegant approach - you can create a workaround by using variable *naming conventions* to simulate local scope:
>   - By convention, an underscore `_` is often used as a **prefix** to indicate that a variable is intended to be "*private*" or "*local*" to a function.

## 4. Output

The `print` and `printf` statements generate output.

- The `print` statement is used for simple output;
- `printf` is used when careful *formatting* is required.

Output from `print` and `printf` can be directed into *files* and *pipes* as well as to the *terminal(Standard Output)*. These statements can be used in any mixture; the output comes out in the order in which it is generated.

---

**Output Statements**

**Ⅰ. print**

- `print`
  - print `$0` on *standard output*
- `print expression, expression, ...`
  - print *expression*'s, separated by `OFS`, terminated by `ORS`
- `print expression, expression, ... > filename`
  - print on file *filename* instead of *standard output*
- `print expression, expression, ... >> filename`
  - append to file *filename* instead of overwriting previous contents
- `print expression, expression, ... | command`
  - print to *standard input* of *command*

**Ⅱ. printf**

- `printf(format, expression, expression, ... )`
- `printf(format, expression, expression, ... ) > filename`
- `printf(format, expression, expression, ... ) >> filename`
- `printf(format, expression, expression, ... ) | command`
  - `printf` statements are like `print` but the first argument specifies *output format*

**Ⅲ. Others**

- `close(filename)`, `close(command)`
  - break connection between `print` and *filename* or *command*
- `system(command)`
  - execute *command*; value is *status* return of command

The argument list of a `printf` statement does not need to be enclosed in parentheses. But if an expression in the argument list of a `print` or `printf` statement contains a *relational operator*, either the *expression* or the *argument list* must be enclosed in parentheses.

*Pipes* and *system* may not be available on non-Unix systems.

---

### 4.1. The `print` Statement

The `print` statement has two forms:

- `print expr_1, expr_2, expr_3, ... , expr_n`
- `print(expr_1, expr_2, expr_3, ... , expr_n)`

Both forms print the string value of each *expression* separated by the *output field separator(OFS)* followed by the *output record separator(ORS)*. The statement

```awk
print
```

is an abbreviation for

```awk
print $0
```

To print a blank line. that is, a line with only a newline, use

```awk
print ""
```

The second form parentheses, as in

```awk
print($1 ":", $2)
```

Both forms of the print statement generate the same output but, as we will see, **parentheses are necessary for arguments containing *relational operators***.

### 4.2. Output Separators (`OFS` and `ORS`)

The *output field separator* and *output record separator* are stored in the *built-in variables* `OFS` and `ORS`. Initially, `OFS` is set to *a single blank* and `ORS` to *a single newline*, but these values can be changed at any time. For example, the following program prints the first and second fields of each line with a colon between the fields and two newlines after the second field:

```awk
BEGIN { OFS = ":"; ORS = "\n\n" }
      { print $1, $2 }
```

By contrast,

```awk
{ print $1 $2 }
```

prints the first and second fields with **no** intervening *output field separator(OFS)*, because `$1 $2` is a string consisting of the **concatenation** of the two fields.

### 4.3. The printf Statement

> NOTE: Output produced by `printf` does not contain any *newlines* unless you put them in explicitly.

The `printf` statement is used to generate *formatted* output. It is similar to that in `C` except that the `*` *format specifier* is not supported in awk's `printf`.

Like `print`, it has both an un-parenthesized and parenthesized form:

- `printf format, expr_1, expr_2, ... , expr_n`
- `printf(format, expr_1, expr_2, ... , expr_n)`

The *format argument* is always required; it is an expression whose string value contains both *literal text* to be printed and *specifications* of how the expressions in the argument list are to be formatted. Each *specification* begins with a `%`, ends with a character that determines the conversion, and may include **3** modifiers:

| Modifier Type | Explain                                                           |
|---------------|-------------------------------------------------------------------|
| `-`           | **left-justify** expression in its field                          |
| *width*       | pad field to this width as needed;<br>leading `0` pads with zeros |
| *.prec*       | maximum string width,<br>or digits to right of decimal point      |

**Ⅰ. PRINTF FORMAT-CONTROL CHARACTERS**

| CHARACTER | PRINT EXPRESSION AS                                                                   |
|-----------|---------------------------------------------------------------------------------------|
| `c`       | ASCII character                                                                       |
| `d`       | decimal integer                                                                       |
| `e`       | [-]d.ddddddE[+-]dd                                                                    |
| `f`       | [-]ddd.dddddd                                                                         |
| `g`       | `e` or `f` conversion, whichever is shorter,<br>with non-significant zeros suppressed |
| `o`       | unsigned octal number                                                                 |
| `s`       | string                                                                                |
| `x`       | unsigned hexadecimal number                                                           |
| `%`       | print a `%`; no argument is consumed                                                  |

**Ⅱ. EXAMPLES OF PRINTF SPECIFICATIONS**

| fmt         | $1      | printf(fmt, $1)           |
|-------------|---------|---------------------------|
| `%c`        | 97      | <pre>a</pre>              |
| `%d`        | 97.5    | <pre>97</pre>             |
| `%5d`       | 97.5    | <pre>   97</pre>          |
| `%e`        | 97.5    | <pre>9.750000e+01</pre>   |
| `%f`        | 97.5    | <pre>97.500000</pre>      |
| `%7.2f`     | 97.5    | <pre>  97.50</pre>        |
| `%g`        | 97.5    | <pre>97.5</pre>           |
| `%.6g`      | 97.5    | <pre>97.5</pre>           |
| `%o`        | 97      | <pre>141</pre>            |
| `%06o`      | 97      | <pre>000141</pre>         |
| `%x`        | 97      | <pre>61</pre>             |
| `|%s|`      | January | <pre>\|January\|</pre>    |
| `|%10s|`    | January | <pre>\|   January\|</pre> |
| `|%-10s|`   | January | <pre>\|January   \|</pre> |
| `|%.3s|`    | January | <pre>\|Jan\|</pre>        |
| `|%10.3s|`  | January | <pre>\|       Jan\|</pre> |
| `|%-10.3s|` | January | <pre>\|Jan       \|</pre> |
| `%%`        | January | <pre>%</pre>              |

### 4.4. Output Into Files

The redirection operators `>` and `>>` are used to put output into *files* instead of the *standard output*. The following program will put the first and third fields of all input lines into two files: `big-pop` if the third field is greater than `100`, and `small-pop` otherwise:

```awk
$3 > 100   { print $1, $3 > "big-pop" }
$3 <= 100  { print $1, $3 > "small-pop" }
```

Notice that the *filenames* have to be quoted.

Filenames can be variables or expressions as well:

```awk
{ print($1, $3) > ($3 > 100 ? "big-pop" : "small-pop") }
```

does the same job, and the program

```awk
{ print > $1 }
```

puts every input line into a file named by the first field.

In `print` and `printf` statements, if an expression in the *argument list* contains a *relational operator*, then either that expression or the argument list needs to be parenthesized. This rule eliminates any potential ambiguity arising from the *redirection operator* `>`. In

```awk
{ print $1, $2 > $3 }
```

`>` is the *redirection operator*, and hence not part of the second expression, so the values of the first two fields are written to the file named in the third field. If you want the second expression to include the `>` operator, use parentheses:

```awk
{ print $1, ($2 > $3) }
```

It is also important to note that a *redirection operator* opens a file only once; each successive `print` or `printf` statement adds more data to the open file.

- When the *redirection operator* `>` is used, the file is initially cleared before any output is written to it.
- If `>>` is used instead of `>`, the file is not initially cleared; output is *appended* after the original contents.

### 4.5. Output Into Pipes

It is also possible to direct output into a *pipe* instead of a *file* on systems that support pipes. The statement

```awk
print | command
```

causes the output of `print` to be piped into the *command*.

Suppose we want to create a list of continent-population pairs, sorted in reverse numeric order by population. The program below accumulates in an array `pop` the population values in the third field for each of the distinct continent names in the fourth field. The `END` action prints each continent name and its population, and pipes this output into a suitable `sort` command.

```awk
# print continents and populations, sorted by population

BEGIN { FS = "\t" }
      { pop[$4] += $3 }
END   { for (c in pop)
          printf("%15s\t%6d\n", c, pop[c]) | "sort -t'\t' +1rn"
      }
```

This yields

```awk
           Asia   2173
  North America    340
         Europe    172
  South America    134
```

Another use for a pipe is writing onto the *standard error file* on Unix systems; output written there appears on the user's terminal instead of the *standard output*. There are several idioms for writing on the *standard error file*:

> Note: The `message` below is a variable in awk.

```awk
print message | "cat 1>&2"            # redirect cat to stderr
system("echo '" message "' 1>&2")     # redirect echo to stderr
print message > "/dev/tty"            # write directly on terminal
```

> Tips: In shell scripting,
>
> - `1` represents *standard output (stdout)*
> - `2` represents *standard error (stderr)*
> - `1>&2` is used to redirect the output of the `echo` command to *stderr* instead of the default *stdout*

e.g.

```awk
# Assuming "message" holds the text "Error: Something went wrong!"
message = "Error: Something went wrong!"
system("echo '" message "' 1>&2")
```

prints

```console
Error: Something went wrong!
```

Although most of our examples show literal strings enclosed in quotes, *command lines and filenames can be specified by any expression*. In `print` statements involving redirection of output, the files or pipes are identified by their names; that is, the pipe in the program above is literally named

```awk
sort -t'\t' +1rn
```

Normally, a *file* or *pipe* is created and opened only once during the run of a program. If the *file* or *pipe* is explicitly closed and then reused, it will be reopened.

### 4.6. Closing Flies and Pipes

The statement `close(expr)` closes a *file* or *pipe* denoted by *expr*; the string value of *expr* must be the same as the string used to create the file or pipe in the first place. Thus

```awk
close("sort -t'\t' +1rn" )
```

closes the `sort` pipe opened above.

**close is necessary if you intend to write a file, then read it later in the same program.** There are also system-defined limits on the number of files and pipes that can be open at the same time.

## 5. Input

There are several ways of providing input to an awk program. The most common arrangement is to put input data in a file, say data-file, and then type

```awk
awk 'program' data-file
```

Awk reads its *standard input* if no filenames are given; thus, a second common arrangement is to have another program pipe its output into awk. For example, **the program `egrep` selects input lines containing a specified regular expression, but it does this much faster than awk does**. We could therefore type the command

```awk
egrep 'Asia' countries | awk 'program'
```

`egrep` finds the lines containing *Asia* and passes them on to the awk program for subsequent processing.

### 5.1. Input Separators

The **default value** of the *built-in variable* `FS` is `" "`, that is, *a single blank*.

- When `FS` has this specific value, input fields are **separated by blanks and/or tabs**,
- and **leading blanks and tabs are discarded, so each of the following lines has the same first field**:

```plaintext
field_1
  field_1
    field_1         field_2
```

**When `FS` has any other value, however, leading blanks and tabs are *not* discarded.**

The *field separator* can be changed by assigning a string to the *built-in variable* `FS`.

- **If the string is longer than one character, it is taken to be a regular expression.**
- **The leftmost longest nonnull and non-overlapping substrings matched by that regular expression become the *field separators* in the current input line.**

For example,

```awk
BEGIN { FS = ",[ \t]*|[ \t]+" }
```

makes every string consisting of a *comma* followed by *blanks* and *tabs*, and every string of *blanks* and *tabs* without a *comma*, into *field separators*.

**When `FS` is set to a single character other than blank, that character becomes the *field separator*. This convention makes it easy to use *regular expression metacharacters* as *field separators***:

```awk
FS = "|"
```

makes `｜` a *field separator*. But note that something indirect like

> Rule mentioned above: *If the string is longer than one character, it is taken to be a regular expression.*

```awk
FS = "[ ]"
```

is required to set the *field separator* to a single blank.

`FS` can also be set on the command line with the `-F` argument. The command line

```awk
awk -F ',[ \t]*|[ \t]+' 'program'
```

sets the *field separator* to the same strings as the `BEGIN` action shown above.

### 5.2. Multiline Records

By default, records are separated by newlines, so the terms "line" and "record" are normally synonymous. The default *record separator(`RS`)* can be changed in a limited way, however, by assigning a new value to the built-in *record-separator variable* `RS`. If `RS` is set to the *null string*, as in

```awk
BEGIN { RS = "" }
```

then records are separated by one or more blank lines and each record can therefore occupy several lines. Setting RS back to newline with the assignment `RS = "\n"` restores the default behavior. With multiline records, no matter what value `FS` has, newline is always one of the field separators.

A common way to process multiline records is to use

```awk
BEGIN { RS = ""; FS = "\n" }
```

- to set the *record separator(`RS`)* to *one or more blank lines*
- and the *field separator(`FS`)* to *a newline* alone;

**each line is thus a separate field**. There is a limit on how long a record can be, usually about **3000** characters. *Chapter 3* contains more discussion of how to handle multiline records.

### 5.3. The `getline` Function

The function `getline` can be used to read input either from the *current input* or from a *file* or *pipe*. By itself, `getline` fetches the next input record and performs the normal field-splitting operations on it. It sets `NF`, `NR`, and `FNR`;

it returns

- `1` if there was a record present,
- `0` if end-of-file was encountered,
- `-1` if some error occurred (such as failure to open a file).

The expression `getline x` reads the next record into the variable `x` and increments `NR` and `FNR`. No splitting is done; `NF` is not set.

The expression

```awk
getline < "file"
```

reads from *file* instead of the current input. It has no effect on `NR` or `FNR`, but field splitting is performed and `NF` is set.

The expression

```awk
getline x < "file"
```

gets the next record from *file* into `x`; no splitting is done, and `NF`, `NR`, and `FNR` are untouched.

The table below summarizes the forms of the `getline` function. The value of each expression is the value returned by `getline`.

| EXPRESSION           | SETS                     |
|----------------------|--------------------------|
| `getline`            | `$0`, `NF`,  `NR`, `FNR` |
| `getline var`        | `var`, `NR`, `FNR`       |
| `getline < file`     | `$0`, `NF`               |
| `getline var < file` | `var`                    |
| `cmd | getline`      | `$0`, `NF`               |
| `cmd | getline var`  | `var`                    |

As an example, this program copies its input to its output, except that each line like

```awk
#include "filename"
```

is replaced by the contents of the file *filename*.

```awk
# include - replace `#include "filename"` by contents of the file which is named *filename*

/^#include/ {
    gsub(/"/, "", $2)
    while ((getline x < $2) > 0)
        print x
    next
}
{ print }
```

It is also possible to pipe the output of another *command* directly into `getline`. For example, the statement

```awk
while("who" | getline)
    n++
```

executes the Unix program `who` (once only) and pipes its output into `getline`. The output of `who` is a **list** of the users logged in. Each iteration of the `while` loop reads one more line from this list and increments the variable `n`, so after the `while` loop terminates, `n` contains a count of the number of users. Similarly, the expression

```awk
"date" | getline d
```

pipes the output of the `date` command into the variable `d`, thus setting `d` to the current date. Again, input pipes may not be available on non-Unix systems.

In all cases involving `getline`, you should be aware of the possibility of an *error* return if the file can't be accessed. Although it's appealing to write

```awk
while (getline < "file") ...        # Dangerous
```

that's an infinite loop if file doesn't exist, because with a nonexistent file `getline` returns `-1`, a *nonzero* value that represents `true`. The preferred way is

```awk
while (getline < "file" > 0) ...    # Safe
```

Here the loop will be executed only when getline returns `1`.

### 5.4. Command-Line Variable Assignments

As we have seen, an awk command line can have several forms:

```awk
awk 'program' f1 f2
awk -f progfile f1 f2
awk -Fsep 'program' f1 f2
awk -Fsep -f progfile f1 f2
```

In these command lines, `f1`, `f2`, etc., are *command-line arguments* that normally represent *filenames*. If a filename has the form `var==text`, however, it is treated as an assignment of `text` to `var`, performed at the time when that argument would otherwise be accessed as a file (Usecase❓). This type of assignment allows variables to be changed before and after a file is read.

### 5.5. Command-Line Arguments

- The *command-line arguments* are available to the awk program in a *built-in array* called `ARGV`.
- The value of *the built-in variable* `ARGC` is *one more than the number of arguments*. With the command line

```awk
awk -f progfile a v=1 b
```

`ARGC` has the value **4**,

- `ARGV[0]` contains `awk`,
- `ARGV[1]` contains `a`,
- `ARGV[2]` contains `v= 1`,
- `ARGV[3]` contains `b`.

**`ARGC` is one more than the number of arguments because `awk`, the name of the command, is counted as argument `0`, as it is in C programs.** If the awk *program* appears on the command line, however, the *program* is not treated as an argument, nor is `-f filename` or any `-F` option. For example, with the command line

```awk
awk -F'\t' '$3 > 100' countries.txt
```

`ARGC` is **2** and `ARGV[1]` is `countries.txt`.

The following program echoes its *command-line arguments*:

```awk
# echo - print command-line arguments

BEGIN {
    for (i = 1; i < ARGC; i++)
        printf "%s ", ARGV[i]
    printf "\n"
}
```

Notice that everything happens in the `BEGIN` action: because there are no other *pattern-action* statements, the arguments are never treated as filenames, and no input is read.

Another program using *command-line arguments* is `seq`, which generates sequences of integers:

```awk
# seq - print sequences of integers
#   input:  arguments q, p q, or p q r;  q >= p; r > 0
#   output: integers 1 to q, p to q, or p to q in steps of r

BEGIN {
    if (ARGC == 2)
        for (i = 1; i <= ARGV[1]; i++)
            print i
    else if (ARGC == 3)
        for (i = ARGV[1]; i <= ARGV[2]; i++)
            print i
    else if (ARGC == 4)
        for (i = ARGV[1]; i <= ARGV[2]; i += ARGV[3])
            print i
}
```

The commands

```bash
awk -f seq 10
awk -f seq 1 10
awk -f seq 1 10 1
```

all generate the integers `1` through `10`.

The arguments in `ARGV` may be modified or added to; `ARGC` may be altered. As each input file ends, awk treats the next *non-null* element of `ARGV` (up through the current value of `ARGC-1`) as the name of the next input file. Thus setting an element of `ARGV` to *null* means that it will not be treated as an input file. The name `"-"` may be used for the standard input.

## 6. Interaction with Other Programs

This section describes some of the ways in which awk programs can cooperate with other commands. The discussion applies primarily to the Unix operating system; the examples here may fail or work differently on non-Unix systems.

### 6.1. The `system` Function

The *built-in function* `system(expression)` executes the command given by the *string value* of *expression*. The value returned by `system` is the *status* returned by the *command* executed.

For example, we can build another version of the *file-inclusion program* of *Section 2.5* like this,

From

```awk
# include - replace `#include "filename"` by contents of the file which is named *filename*

/^#include/ {
    gsub(/"/, "", $2)
    while ((getline x < $2) > 0)
        print x
    next
}
{ print }
```

To

> Note: `gsub(/"/, "", $2)` is also not necessary in the example below, so `$2` is still equal to `"filename"`, but after concatenating in `system("cat " "filename")`, the result is `system("cat filename")`.

```awk
$1 == "#include" { system("cat " $2); next }
                 { print }
```

If the first field is `#include`, quotes are removed, and the Unix command `cat` is called to print the file named in the second field. Other lines are just copied.

### 6.2. Making a Shell Command from an AWK Program

In all of the examples so far, the awk program was in a *file* and fetched with the `-f` flag, or it appeared on the *command line* enclosed in single quotes, like this:

```bash
awk '{ print $1 }' ...
```

Since awk uses many of the same characters as the shell does, such as `$` and `"`, **surrounding the program with *single quotes* ensures that the shell will pass the entire program unchanged to awk**.(And *single quotes* also allow us to put awk program in multiline without using backslashes)

Both methods of invoking the awk program require some typing. To reduce the number of keystrokes, **we might want to put both the command and the program into an executable file, and invoke the command by typing just the name of the file**. Suppose we want to create a command `field1` that will print the first field of each line of input. This is easy: we put

> **Note**: In Bash, `$*` is a special variable that represents *all of the command-line arguments* passed to a *script* or *function* as a single string. **It treats all the arguments as a space-separated list within a single string**.

```bash
awk '{ print $1 }' $*
```

into the file `field1`, and make the file executable by typing the Unix command

```bash
chmod +x field1
```

We can now print the first field of each line of a set of files by typing

```bash
./field1 filenames ...
```

Now, consider writing a more general command `field` that will print an arbitrary combination of fields from each line of its input; in other words, the command

```bash
field n_1, n_2 ... file_1 file_2 ...
```

will print the specified fields in the specified order. How do we get the value of each `n_i` into the awk program each time it is run and how do we distinguish the `n_i`'s from the *filename* arguments?

There are several ways to do this if one is adept in shell programming. The simplest way that uses only awk, however, is to scan through the built-in array `ARGV` to process the `n_i`'s, **resetting each such argument to the *null string* so that it is not treated as a filename**.

The content of `Field` script:

```bash
#!/usr/bin/env bash

# field - print named fields of each input line
#   usage:  field n n n ... file file file ...

awk '
BEGIN {
    for (i = 1; ARGV[i] ~ /^[0-9]+$/; i++) { # collect numbers
        fld[++nf] = ARGV[i]
        ARGV[i] = ""
    }
    if (i >= ARGC)   # no file names so force stdin
        ARGV[ARGC++] = "-"
}
{   
    for (i = 1; i <= nf; i++)
        printf("%s%s", $fld[i], i < nf ? " " : "\n")
}
' $*
```

Here is the highlighted code which is convenient for reading:

```awk
BEGIN {
    for (i = 1; ARGV[i] ~ /^[0-9]+$/; i++) { # collect numbers
        fld[++nf] = ARGV[i]
        ARGV[i] = ""
    }
    if (i >= ARGC)   # no file names so force stdin
        ARGV[ARGC++] = "-"
}
{   
    for (i = 1; i <= nf; i++)
        printf("%s%s", $fld[i], i < nf ? " " : "\n")
}
```

This version can deal with either standard input or a list of filename arguments, and with any number of fields in any order.

**Example 1**, print the first filed and the second field of the `countries.txt` file:

```bash
$ ./Field 1 2 countries.txt

USSR 8649
Canada 3852
China 3705
USA 3615
Brazil 3286
India 1267
Mexico 762
France 211
Japan 144
Germany 96
England 94
```

**Example 2**, there aren't any filename being provided in the command line, so the `STDIN` is being used:

```bash
$ ./Field 1 2

abc 123 xyz 456
-> abc 123
```
