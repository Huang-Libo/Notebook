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

A regular expression is a notation for specifying and matching strings.

---

**Regular Expressions**

1. The regular expression metacharacters are:

    `.` `*` `+` `?` `^` `$` `\` `|` `(` `)` `[` `]` `{` `}`

2. A basic regular expression is one of the following:

    - a non-metacharacter, such as *A*. that matches itself.
    - an escape sequence that matches a special symbol: `\t` matches a *tab*
    - a *quoted* metacharacter, such as `\*`, that matches the metacharacter literally.
    - `^`, which matches the *beginning* of a string.
    - `$`, which matches the *end* of a string.
    - `.`, which matches *any* single character *except* `\n`.
    - *a character class*: `[ABC]` matches any of the characters *A*, *B*, or *C*.
    - *character classes* may include abbreviations: `[A-Za-z]` matches any single letter.
    - *a complemented character class*: `[^0-9]` matches any character except a digit.

3. These operators combine regular expressions into larger ones:

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

To preserve the *literal* meaning of a *metacharacter* in a regular expression, precede it by a *backslash*. Thus, the regular expression `\$` matches the character `$`. If a character is preceded by a single `\`, we'll say that character is **quoted**.

A regular expression consisting of a group of characters enclosed in *brackets*(`[]`) is called a *character class*; it matches any one of the enclosed characters. For example, `[AEIOU]` matches any of the characters *A*, *E*, *I*, *O*, or *U*.

Ranges of characters can be abbreviated in a *character class* by using a hyphen(`-`).

- The character immediately to the left of the hyphen defines the beginning of the range;
- the character immediately to the right defines the end.

Thus, `[0-9]` matches any digit, and `[a-zA-Z][0-9]` matches a letter followed by a digit.

**Without both a left and right operand, a hyphen(`-`) in a character class denotes itself**,

- so the character classes `[+-]` and `[-+]` match either a `+` or a `-`.
- The character class `[A-Za-z-]+` matches words that include hyphens.

A *complemented* character class is one in which the first character after the `[` is a `^` . Such a class matches any character *not* in the group following the caret. Thus, `[^0-9]` matches any character except a digit; `[^a-zA-Z]` matches any character except an upper or lower-case letter.

| Pattern    | Meaning                                                                    |
|------------|----------------------------------------------------------------------------|
| `^[ABC]`   | matches an *A*, *B* or *C* at the beginning of a string                    |
| `^[^ABC]`  | matches any character at the beginning of a string. except *A*, *B* or *C* |
| `[^ABC]`   | matches any character other than an *A*, *B* Or *C*                        |
| `^[^a-z]$` | matches any single-character string. except a lower-case letter            |

Inside a *character class*, all characters have their literal meaning, except for the quoting character `\`, `^` at the beginning, and `-` between two characters. Thus, **`[.]` matches a period(`.`)** and `^[^^]` matches any character except a caret at the beginning of a string.

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

Since `+` and `.` are *metacharacters*, they have to be preceded by *backslashes*(`\`) in the first example to match *literal* occurrences. These backslashes are *not* needed within *character classes*, so the second example shows an alternate way to describe the same numbers.

### 1.5. Compound Patterns

A *compound pattern* is an expression that combines other patterns, using parentheses and the logical operators `||` (OR), `&&` (AND), and `!` (NOT). A compound pattern matches the current input line if the expression evaluates to `true`.

The program

```awk
$4 == "Asia" || $4 == "Europe"
```

uses the `OR` operator to select lines with either *Asia* or *Europe* as the fourth field. Because the latter query is a test on string values, another way to write it is to use a regular expression with the alternation operator `|`:

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

| Variable | Meaning                                         |
|----------|-------------------------------------------------|
| FNR      | Record number within the *current* input file     |
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
- `for` (*variable in array*) *statement*
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
