# Introduction

In Apple’s words, Combine is:

> A unified, declarative API for processing values over time.

Combine is Apple’s take on a functional reactive programming library, akin to [RxSwift](https://github.com/ReactiveX/RxSwift). RxSwift itself is a port of [ReactiveX](http://reactivex.io/). Combine uses many of the same functional reactive concepts that can be found in other languages and libraries, applying the staticly typed nature of Swift to their solution.

> If you are already familiar with RxSwift there is [a good collected cheat-sheet](https://github.com/CombineCommunity/rxswift-to-combine-cheatsheet) for how to map concepts and APIs from RxSwift to Combine.

## Functional reactive programming

[Functional reactive programming](https://en.wikipedia.org/wiki/Functional_reactive_programming), also known as *data-flow programming*, builds on the concepts of [functional programming](https://en.wikipedia.org/wiki/Functional_programming).

- *Functional programming* applies to *lists of elements*
- *Functional reactive programming* is applied to *streams of elements*

The kinds of functions in *functional programming*, such as `map`, `filter`, and `reduce` have analogues that can be applied to streams.

- In addition to *functional programming* primitives, *functional reactive programming* includes functions to `split` and `merge` streams.
- Like *functional programming*, you may create *operations* to transform the data flowing through the stream.

There are many parts of the systems we program that can be viewed as asynchronous streams of information: *events*, *objects*, or *pieces of data*. The *observer pattern* watches a single object, providing notifications of changes and updates. If you view these notifications over time, they make up *a stream of objects*.

Functional reactive programming, Combine in this case, allows you to create code that describes what happens when getting data in a stream.

- You may want to create logic to watch more than one element that is changing.
- You may also want to include logic that does additional asynchronous operations, some of which may fail.
- You may want to change the content of the streams based on timing, or change the timing of the content.

Handling the flow of these *event streams*, the timing, errors when they happen, and coordinating how a system responds to all those events is at the heart of *functional reactive programming*.

- A solution based on *functional reactive programming* **is particularly effective when programming user interfaces**.
- Or more generally for creating *pipelines* that **process data from external sources or rely on asynchronous APIs**.

## Combine specifics

Applying these concepts to a *strongly typed language* like Swift is part of what Apple has created in Combine.

Combine extends *functional reactive programming* by embedding the concept of back-pressure. Back-pressure is the idea that the *subscriber* should control how much information it gets at once and needs to process. This leads to efficient operation with the added notion that the volume of data processed through a stream is *controllable* as well as *cancellable*.

Combine elements are set up to be composed, including affordances to integrate existing code to incrementally support adoption.

Combine is leveraged by some of Apple’s other frameworks. *SwiftUI* is the obvious example that has the most attention, with both *subscriber* and *publisher* elements. *RealityKit* also has *publishers* that you can use to react to events. And Foundation has a number of Combine specific additions including `NotificationCenter`, `URLSession`, and `Timer` as *publishers*.

**Any asynchronous API can be leveraged with Combine.** For example, you could use some of the APIs in the *Vision framework*, composing data flowing to it, and from it, by leveraging Combine.

> In this work, I’m going to call **a set of composed operations** in Combine a **pipeline**. Pipeline is not a term that Apple is (yet?) using in its documentation.

## When to use Combine

Combine fits most naturally when you want to set up something that reacts to a variety of inputs. *User interfaces* fit very naturally into this pattern.

The classic examples using *functional reactive programming* in user interfaces frequently show *form validation*, where user events such as changing text fields, taps, or mouse-clicks on UI elements make up the data being streamed.

Combine takes this further, enabling *watching* of properties, *binding* to objects, *sending* and *receiving* higher level events from UI controls, and supporting integration with almost all of Apple’s existing API ecosystem.

Some things you can do with Combine include:

- You can set up *pipelines* to enable a button for submission only when values entered into the fields are valid.
- A *pipeline* can also do asynchronous actions (such as checking with a network service) and using the values returned to choose how and what to update within a view.
- *Pipelines* can also be used to react to a user typing dynamically into a text field and updating the user interface view based on what they’re typing.

Combine is not limited to user interfaces. Any sequence of asynchronous operations can be effective as a pipeline, especially when the results of each step flow to the next step.

- An example of such might be a series of network service requests, followed by decoding the results.

Combine can also be used to define how to handle errors from asynchronous operations. Combine supports doing this by setting up *pipelines* and *merging* them together.

- One of Apple’s examples with Combine include a *pipeline* to fall back to getting a lower-resolution image from a network service when the local network is constrained.

Many of the *pipelines* you create with Combine will only be a few operations. Even with just a few operations, Combine can still make it much easier to view and understand what’s happening when you compose a *pipeline*. Combine *pipelines* are a declarative way to define what processing should happen to a stream of values over time.

## Apple’s Combine Documentation

- [Framework: Combine](https://developer.apple.com/documentation/combine)
- [Apple’s developer documentation](https://developer.apple.com/documentation/)

## WWDC 2019 content

[WWDC 2019](https://developer.apple.com/videos/play/wwdc2019)

> Combine has evolved since its initial release at WWDC 2019. Some of the content in these presentations are now slightly dated or changed from what currently exists. The majority of this content is still immensely valuable in getting an introduction or feel for what Combine is and can do.

A number of these introduce and go into some depth on Combine:

- [Introducing Combine](https://developer.apple.com/videos/play/wwdc2019/722/)
  - [PDF](https://devstreaming-cdn.apple.com/videos/wwdc/2019/722l6blhn0efespfgx/722/722_introducing_combine.pdf?dl=1)
- [Combine in Practice](https://developer.apple.com/videos/play/wwdc2019/721/)
  - [PDF](https://devstreaming-cdn.apple.com/videos/wwdc/2019/721ga0kflgr4ypfx/721/721_combine_in_practice.pdf?dl=1)

A number of additional WWDC19 sessions mention Combine:

- [Modern Swift API Design](https://developer.apple.com/videos/play/wwdc2019/415/)
- [Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226)
- [Introducing Combine and Advances in Foundation](https://developer.apple.com/videos/play/wwdc2019/711)
- [Advances in Networking, Part 1](https://developer.apple.com/videos/play/wwdc2019/712/)
