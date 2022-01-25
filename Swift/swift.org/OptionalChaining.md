# Optional Chaining

> Version: *Swift 5.5*  
> Source: [*swift-book: Optional Chaining*](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html)  
> Digest Date: *January 24, 2022*  

*Optional chaining* is a process for querying and calling properties, methods, and subscripts on an optional that might currently be `nil`.  Multiple queries can be chained together, and the entire chain fails gracefully if any link in the chain is `nil`.

- [Optional Chaining](#optional-chaining)
  - [Optional Chaining as an Alternative to Forced Unwrapping](#optional-chaining-as-an-alternative-to-forced-unwrapping)

## Optional Chaining as an Alternative to Forced Unwrapping


