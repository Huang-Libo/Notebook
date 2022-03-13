# Introduction

In Apple’s words, Combine is:

> a declarative Swift API for processing values over time.

Combine is Apple’s take on a functional reactive programming library, akin to [RxSwift](https://github.com/ReactiveX/RxSwift). RxSwift itself is a port of [ReactiveX](http://reactivex.io/). Combine uses many of the same functional reactive concepts that can be found in other languages and libraries, applying the staticly typed nature of Swift to their solution.

> If you are already familiar with RxSwift there is [a good collected cheat-sheet](https://github.com/CombineCommunity/rxswift-to-combine-cheatsheet) for how to map concepts and APIs from RxSwift to Combine.

## Functional reactive programming

[Functional reactive programming](https://en.wikipedia.org/wiki/Functional_reactive_programming), also known as data-flow programming, builds on the concepts of [functional programming](https://en.wikipedia.org/wiki/Functional_programming).

- *Functional programming* applies to *lists of elements*
- *Functional reactive programming* is applied to *streams of elements*

The kinds of functions in *functional programming*, such as `map`, `filter`, and `reduce` have analogues that can be applied to streams. In addition to *functional programming* primitives, *functional reactive programming* includes functions to `split` and `merge` streams. Like *functional programming*, you may create *operations* to transform the data flowing through the stream.

There are many parts of the systems we program that can be viewed as asynchronous streams of information: *events*, *objects*, or *pieces of data*. The *observer pattern* watches a single object, providing notifications of changes and updates. If you view these notifications over time, they make up *a stream of objects*.

Functional reactive programming, Combine in this case, allows you to create code that describes what happens when getting data in a stream.

- You may want to create logic to watch more than one element that is changing.
- You may also want to include logic that does additional asynchronous operations, some of which may fail.
- You may want to change the content of the streams based on timing, or change the timing of the content.

Handling the flow of these *event streams*, the timing, errors when they happen, and coordinating how a system responds to all those events is at the heart of *functional reactive programming*.

A solution based on *functional reactive programming* is particularly effective when programming user interfaces. Or more generally for creating pipelines that process data from external sources or rely on asynchronous APIs.

## Combine specifics


