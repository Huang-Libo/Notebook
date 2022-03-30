# Publishers

For general information about publishers see [Publishers](https://heckj.github.io/swiftui-notes/#coreconcepts-publishers) and [Lifecycle of Publishers and Subscribers](https://heckj.github.io/swiftui-notes/#coreconcepts-lifecycle).

- [Publishers](#publishers)
  - [Just](#just)
  - [Future](#future)

## Just

`Just` provides a single result and then terminates, providing a publisher with a failure type of `<Never>`.

Often used within a closure to `flatMap` in error handling, it creates a single-response pipeline for use in error handling of continuous values.

## Future
