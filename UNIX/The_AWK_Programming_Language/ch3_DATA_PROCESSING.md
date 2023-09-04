# DATA PROCESSING <!-- omit in toc -->

- [1. Data Transformation and Reduction](#1-data-transformation-and-reduction)
  - [1.1. Summing Columns](#11-summing-columns)

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
