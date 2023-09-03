# DATA PROCESSING <!-- omit in toc -->

- [1. Data Transformation and Reduction](#1-data-transformation-and-reduction)

Awk was originally intended for everyday data-processing tasks, such as information retrieval, data validation, and data transformation and reduction. We have already seen simple examples of these in Chapters 1 and 2. In this chapter, we will consider more complex tasks of a similar nature.

- Most of the examples deal with the usual line-at-a-time processing,
- but the final section describes how to handle data where an input record may occupy several lines (*Multiline Records*).

Awk programs are often developed incrementally: a few lines are written and tested, then a few more added, and so on. Many of the longer programs in this book were developed in this way.

It's also possible to write awk programs in the traditional way, sketching the outline of the program, consulting the language manual, and so forth. But modifying an existing program to get the desired effect is frequently easier. The programs in this book thus serve another purpose, providing useful models for programming by example.

## 1. Data Transformation and Reduction
