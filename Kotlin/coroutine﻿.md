# coroutine <!-- omit in toc -->

> Version: *Kotlin 1.9.23*  
> Source: [*Official libraries / Coroutines (kotlinx.coroutines) / Coroutines basics*](https://kotlinlang.org/docs/coroutines-basics.html)  
> Digest Date: *April 21, 2024*  

- [1. Introduction](#1-introduction)
  - [1.1. import `kotlinx.coroutines` library](#11-import-kotlinxcoroutines-library)
  - [1.2. Your first coroutine](#12-your-first-coroutine)
  - [1.3. Structured concurrency](#13-structured-concurrency)

## 1. Introduction

A *coroutine* is an instance of a suspendable computation. It is conceptually similar to a thread, in the sense that it takes a block of code to run that works concurrently with the rest of the code. **However, a coroutine is not bound to any particular thread. It may suspend its execution in one thread and resume in another one.**

Coroutines can be thought of as **light-weight threads**, but there is a number of important differences that make their real-life usage very different from threads.

### 1.1. import `kotlinx.coroutines` library

You need to import the `kotlinx.coroutines` library to use coroutines in Kotlin.

If you're using *Gradle* with *Kotlin*, you can add the dependency to your `build.gradle.kts` file:

```kotlin
dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.0")
}
```

If you're using *Gradle* with *Groovy*, you can add the dependency to your `build.gradle` file:

```groovy
dependencies {
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.0'
}
```

If you're using *Maven*, add this to your `pom.xml`:

```xml
<dependency>
    <groupId>org.jetbrains.kotlinx</groupId>
    <artifactId>kotlinx-coroutines-core</artifactId>
    <version>1.6.0</version>
</dependency>
```

After adding the dependency, you can use coroutines in your Kotlin code by importing the necessary classes:

```kotlin
import kotlinx.coroutines.*
```

### 1.2. Your first coroutine

Run the following code to get to your first working coroutine:

```kotlin
import kotlinx.coroutines.*

fun main() = runBlocking { // this: CoroutineScope
    launch { // launch a new coroutine and continue
        delay(1000L) // non-blocking delay for 1 second (default time unit is ms)
        println("World!") // print after delay
    }
    println("Hello") // main coroutine continues while a previous one is delayed
}
```

You will see the following result:

```console
Hello
World!
```

Let's dissect what this code does.

- `launch` is a **coroutine builder**. It launches a new coroutine concurrently with the rest of the code, which continues to work independently. That's why "Hello" has been printed first.

- `delay` is a special **suspending function**. It **suspends** the coroutine for a specific time. Suspending a coroutine does *not* block the underlying thread, but allows other coroutines to run and use the underlying thread for their code.

- `runBlocking` is also a coroutine builder that bridges the non-coroutine world of a regular `fun main()` and the code with coroutines inside of `runBlocking { ... }` curly braces. This is highlighted in an IDE by `this: CoroutineScope` hint right after the `runBlocking` opening curly brace.

If you remove or forget `runBlocking` in this code, you'll get an error on the launch call, since `launch` is declared only on the `CoroutineScope`:

```console
Unresolved reference: launch
```

The name of `runBlocking` means that the thread that runs it (in this case — the main thread) gets **blocked** for the duration of the call, until all the coroutines inside `runBlocking { ... }` complete their execution. You will often see `runBlocking` used like that at the very *top-level of the application* and quite rarely inside the real code, as threads are expensive resources and blocking them is inefficient and is often not desired.

### 1.3. Structured concurrency

Coroutines follow a principle of structured concurrency which means that new coroutines can only be launched in a specific `CoroutineScope` which delimits the lifetime of the coroutine. The above example shows that `runBlocking` establishes the corresponding scope and that is why the previous example waits until "World!" is printed after a second's delay and only then exits.

In a real application, you will be launching a lot of coroutines. Structured concurrency ensures that they are *not lost* and do *not leak*. An outer scope cannot complete until all its children coroutines complete. Structured concurrency also ensures that any errors in the code are properly reported and are never lost.
