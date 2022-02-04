# Enumerations

> Version: *Swift 5.6*  
> Source: [*swift-book: Enumerations*](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html)  
> Digest Date: *February 4, 2022*  

An `enumeration` defines a common type for a group of related values and enables you to work with those values in a type-safe way within your code.

If you are familiar with C, you will know that C enumerations assign related names to a set of integer values. Enumerations in Swift are much more flexible, and don’t have to provide a value for each case of the enumeration. If a value (known as a *raw value*) is provided for each enumeration case, the value can be a *string*, a *character*, or a value of any *integer* or *floating-point* type.

Alternatively, enumeration cases can specify associated values of *any* type to be stored along with each different case value, much as *unions* or *variants* do in other languages. You can define a common set of related cases as part of one enumeration, each of which has a different set of values of appropriate types associated with it.

Enumerations in Swift are *first-class types* in their own right. They adopt many features traditionally supported only by classes,

- such as *computed properties* to provide additional information about the enumeration’s current value,
- and *instance methods* to provide functionality related to the values the enumeration represents.
- Enumerations can also define *initializers* to provide an initial case value;
- can be extended to *expand* their functionality beyond their original implementation;
- and can conform to *protocols* to provide standard functionality.

---

- [Enumerations](#enumerations)
  - [Enumeration Syntax](#enumeration-syntax)

## Enumeration Syntax


