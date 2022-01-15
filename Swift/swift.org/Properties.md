# Properties

> Version: *Swift 5.5*  
> Source: [*swift-book: Properties*](https://docs.swift.org/swift-book/LanguageGuide/Properties.html)  
> Digest Date: *January 15, 2022*  

Properties associate values with a particular *class*, *structure*, or *enumeration*.

- *Stored properties* store constant and variable values as part of an instance. (Provided only by *classes* and *structures*.)
- *Computed properties* calculate (rather than store) a value. (Provided by *classes*, *structures*, and *enumerations*.)

Stored and computed properties are usually associated with *instances* of a particular type. However, properties can also be associated with the *type* itself. Such properties are known as *type properties*.

In addition, you can define *property observers* to monitor changes in a property’s value, which you can respond to with custom actions. Property observers can be added to stored properties you define yourself, and also to properties that a subclass inherits from its superclass.

You can also use a *property wrapper* to reuse code in the getter and setter of multiple properties.

- [Properties](#properties)
  - [Stored Properties](#stored-properties)

## Stored Properties


