# Access Control

> Version: *Swift 5.5*  
> Source: [*swift-book: Access Control*](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html)  
> Digest Date: *January 28, 2022*  

*Access control* restricts access to parts of your code from code in other source files and modules.

> **NOTE**: The various aspects of your code that can have access control applied to them (properties, types, functions, and so on) are referred to as “**entities**” in the sections below, for brevity.

- [Access Control](#access-control)
  - [Modules and Source Files](#modules-and-source-files)
  - [Access Levels](#access-levels)
    - [Guiding Principle of Access Levels](#guiding-principle-of-access-levels)
    - [Default Access Levels](#default-access-levels)
    - [Access Levels for Single-Target Apps](#access-levels-for-single-target-apps)
    - [Access Levels for Frameworks](#access-levels-for-frameworks)
    - [Access Levels for Unit Test Targets](#access-levels-for-unit-test-targets)
  - [Access Control Syntax](#access-control-syntax)
  - [Custom Types](#custom-types)
    - [Tuple Types](#tuple-types)
    - [Function Types](#function-types)
    - [Enumeration Types](#enumeration-types)
    - [Raw Values and Associated Values](#raw-values-and-associated-values)
    - [Nested Types](#nested-types)
  - [Subclassing](#subclassing)
  - [Constants, Variables, Properties, and Subscripts](#constants-variables-properties-and-subscripts)
    - [Getters and Setters](#getters-and-setters)
  - [Initializers](#initializers)
    - [Default Initializers](#default-initializers)
    - [Default Memberwise Initializers for Structure Types](#default-memberwise-initializers-for-structure-types)
  - [Protocols](#protocols)

## Modules and Source Files

Swift’s access control model is based on the concept of modules and source files.

- A `module` is a single unit of code distribution, a *framework* or *application* that’s built and shipped as a single unit and that can be imported by another module with Swift’s `import` keyword.
- A *source file* is a single Swift source code file within a module (in effect, a single file within an *App* or *framework*).

## Access Levels

Swift provides *five* different *access levels* for entities within your code. These access levels are relative to the source file in which an entity is defined, and also relative to the module that source file belongs to.

- *Open access* and *public access* enable entities to be used within any source file from their defining module, and also in a source file from another module that imports the defining module.
  - You typically use *open or public access* when specifying the public interface to a framework.
  - The difference between open and public access is described below.
- *Internal access* enables entities to be used within any source file from their defining module, but *not* in any source file outside of that module. You typically use internal access when defining an *App*’s or a *framework*’s internal structure.
- *File-private access* restricts the use of an entity to its own defining source file. Use file-private access to hide the implementation details of a specific piece of functionality when those details are used within an entire file.
- *Private access* restricts the use of an entity to the enclosing declaration, and to `extension`s of that declaration that are in the same file. Use private access to hide the implementation details of a specific piece of functionality when those details are used only within a single declaration.

*Open access* is the **highest** (least restrictive) access level and *private access* is the **lowest** (most restrictive) access level.

*Open access* applies only to *classes* and *class members*, and it differs from *public access* by allowing code outside the module to *subclass* and *override*.

### Guiding Principle of Access Levels

Access levels in Swift follow an overall guiding principle: *No entity can be defined in terms of another entity that has a lower (more restrictive) access level*.

For example:

- A *public variable* can’t be defined as having an *internal*, *file-private*, or *private* type, because the type might not be available everywhere that the public variable is used.
- A *function* can’t have a higher access level than its parameter types and return type, because the function could be used in situations where its constituent types are unavailable to the surrounding code.

The specific implications of this guiding principle for different aspects of the language are covered in detail below.

### Default Access Levels

All entities in your code (with a few specific exceptions, as described later in this chapter) have a default access level of *internal* if you don’t specify an explicit access level yourself. As a result, in many cases you *don’t* need to specify an explicit access level in your code.

### Access Levels for Single-Target Apps

When you write a simple *single-target app*, the code in your app is typically self-contained within the app and doesn’t need to be made available outside of the app’s module. The default access level of internal already matches this requirement.

Therefore, you don’t need to specify a custom access level. You may, however, want to mark some parts of your code as *file private* or *private* in order to hide their implementation details from other code within the app’s module.

### Access Levels for Frameworks

When you develop a framework, mark the public-facing interface to that framework as *open* or *public* so that it can be viewed and accessed by other modules, such as an app that imports the framework. This public-facing interface is the application programming interface (or API) for the framework.

### Access Levels for Unit Test Targets

When you write an app with a unit test target, the code in your app needs to be made available to that module in order to be tested. By default, only entities marked as *open* or *public* are accessible to other modules.

However, a unit test target can access any internal entity, if you mark the import declaration for a product module with the `@testable` attribute and compile that product module with testing enabled.

## Access Control Syntax

Define the access level for an entity by placing one of the `open`, `public`, `internal`, `fileprivate`, or `private` modifiers at the beginning of the entity’s declaration.

```swift
public class SomePublicClass {}
internal class SomeInternalClass {}
fileprivate class SomeFilePrivateClass {}
private class SomePrivateClass {}

public var somePublicVariable = 0
internal let someInternalConstant = 0
fileprivate func someFilePrivateFunction() {}
private func somePrivateFunction() {}
```

Unless otherwise specified, the default access level is `internal`, as described in [Default Access Levels](#default-access-levels). This means that `SomeInternalClass` and `someInternalConstant` can be written *without* an explicit access-level modifier, and will still have an access level of internal:

```swift
class SomeInternalClass {}              // implicitly internal
let someInternalConstant = 0            // implicitly internal
```

## Custom Types

If you want to specify an explicit access level for a custom type, do so at the point that you define the type. The new type can then be used wherever its access level permits.

For example, if you define a file-private class, that class can only be used as the type of a *property*, or as a *function parameter* or *return type*, in the source file in which the file-private class is defined.

The access control level of a type also affects the default access level of that type’s members (its *properties*, *methods*, *initializers*, and *subscripts*).

> **IMPORTANT**: A *public type* defaults to having *internal members*, not public members. If you want a type member to be public, you must explicitly mark it as such. This requirement ensures that the public-facing API for a type is something you opt in to publishing, and avoids presenting the internal workings of a type as public API by mistake.

```swift
public class SomePublicClass {                  // explicitly public class
    public var somePublicProperty = 0            // explicitly public class member
    var someInternalProperty = 0                 // implicitly internal class member
    fileprivate func someFilePrivateMethod() {}  // explicitly file-private class member
    private func somePrivateMethod() {}          // explicitly private class member
}

class SomeInternalClass {                       // implicitly internal class
    var someInternalProperty = 0                 // implicitly internal class member
    fileprivate func someFilePrivateMethod() {}  // explicitly file-private class member
    private func somePrivateMethod() {}          // explicitly private class member
}

fileprivate class SomeFilePrivateClass {        // explicitly file-private class
    func someFilePrivateMethod() {}              // implicitly file-private class member
    private func somePrivateMethod() {}          // explicitly private class member
}

private class SomePrivateClass {                // explicitly private class
    func somePrivateMethod() {}                  // implicitly private class member
}
```

### Tuple Types

The access level for a tuple type is the most restrictive access level of all types used in that tuple. For example, if you compose a tuple from two different types, one with *internal* access and one with *private* access, the access level for that compound tuple type will be *private*.

> **NOTE**: Tuple types don’t have a standalone definition in the way that classes, structures, enumerations, and functions do. A tuple type’s access level is determined automatically from the types that make up the tuple type, and can’t be specified explicitly.

### Function Types

The access level for a function type is calculated as the most restrictive access level of the function’s parameter types and return type. You must specify the access level explicitly as part of the function’s definition if the function’s calculated access level doesn’t match the contextual default.

The example below defines a global function called `someFunction()`, without providing a specific access-level modifier for the function itself. You might expect this function to have the default access level of “*internal*”, but this *isn’t* the case. In fact, `someFunction()` won’t compile as written below:

```swift
func someFunction() -> (SomeInternalClass, SomePrivateClass) {
    // function implementation goes here
}
```

The function’s return type is a *tuple type* composed from two of the custom classes defined above in [Custom Types](#custom-types). One of these classes is defined as *internal*, and the other is defined as *private*. Therefore, the overall access level of the compound tuple type is *private* (the minimum access level of the tuple’s constituent types).

Because the function’s return type is *private*, you must mark the function’s overall access level with the private modifier for the function declaration to be valid:

```swift
private func someFunction() -> (SomeInternalClass, SomePrivateClass) {
    // function implementation goes here
}
```

It’s not valid to mark the definition of *someFunction()* with the *public* or *internal* modifiers, or to use the default setting of *internal*, because public or internal users of the function might *not* have appropriate access to the private class used in the function’s return type.

### Enumeration Types

The individual cases of an enumeration *automatically* receive the same access level as the enumeration they belong to. You can’t specify a different access level for individual enumeration cases.

In the example below, the *CompassPoint* enumeration has an explicit access level of *public*. The enumeration cases *north*, *south*, *east*, and *west* therefore also have an access level of public:

```swift
public enum CompassPoint {
    case north
    case south
    case east
    case west
}
```

### Raw Values and Associated Values

The types used for any *raw values* or *associated values* in an enumeration definition must have an access level at least as high as the enumeration’s access level. For example, you can’t use a private type as the raw-value type of an enumeration with an internal access level.

### Nested Types

The access level of a nested type is the same as its containing type, unless the containing type is public. *Nested types defined within a public type have an automatic access level of internal.* If you want a nested type within a public type to be publicly available, you must explicitly declare the nested type as public.

## Subclassing

**Subclassing**:

- You can subclass any class that can be accessed in the current access context and that’s defined in the *same module* as the subclass.
- You can also subclass any `open` class that’s defined in a *different module*.

A subclass can’t have a higher access level than its superclass—for example, you can’t write a public subclass of an internal superclass.

**Override**:

- In addition, for classes that are defined in the *same module*, you can override any class member (method, property, initializer, or subscript) that’s visible in a certain access context.
- For classes that are defined in *another module*, you can override any `open` class member.

*An override can make an inherited class member more accessible than its superclass version.*

In the example below, class `A` is a *public* class with a *file-private* method called `someMethod()`. Class `B` is a subclass of `A`, with a reduced access level of “*internal*”. Nonetheless, class `B` provides an override of `someMethod()` with an access level of “*internal*”, which is higher than the original implementation of `someMethod()`:

```swift
public class A {
    fileprivate func someMethod() {}
}

internal class B: A {
    override internal func someMethod() {}
}
```

It’s even valid for a subclass member to call a superclass member that has lower access permissions than the subclass member, as long as the call to the superclass’s member takes place within an allowed access level context (that is, within the same source file as the superclass for a file-private member call, or within the same module as the superclass for an internal member call):

```swift
public class A {
    fileprivate func someMethod() {}
}

internal class B: A {
    override internal func someMethod() {
        super.someMethod()
    }
}
```

Because superclass `A` and subclass `B` are defined in the same source file, it’s valid for the `B` implementation of `someMethod()` to call `super.someMethod()`.

## Constants, Variables, Properties, and Subscripts

- A *constant*, *variable*, or *property* can’t be more public than its type. It’s *not* valid to write a public property with a private type, for example.
- Similarly, a *subscript* can’t be more public than either its *index type* or *return type*.

If a *constant*, *variable*, *property*, or *subscript* makes use of a private type, the constant, variable, property, or subscript *must* also be marked as private:

```swift
private var privateInstance = SomePrivateClass()
```

### Getters and Setters

Getters and setters for *constants*, *variables*, *properties*, and *subscripts* automatically receive the *same* access level as the constant, variable, property, or subscript they belong to.

You can give a setter a *lower* access level than its corresponding getter, to restrict the read-write scope of that variable, property, or subscript. You assign a lower access level by writing `fileprivate(set)`, `private(set)`, or `internal(set)` before the `var` or `subscript` introducer.

> **NOTE**: This rule applies to stored properties as well as computed properties. Even though you don’t write an explicit getter and setter for a stored property, Swift still *synthesizes* an implicit getter and setter for you to provide access to the stored property’s backing storage. Use `fileprivate(set)`, `private(set)`, and `internal(set)` to change the access level of this synthesized setter in exactly the same way as for an explicit setter in a computed property.

The example below defines a structure called TrackedString, which keeps track of the number of times a string property is modified:

```swift
struct TrackedString {
    private(set) var numberOfEdits = 0
    var value: String = "" {
        didSet {
            numberOfEdits += 1
        }
    }
}

```

The `TrackedString` structure defines a stored string property called `value`, with an initial value of `""` (an empty string). The structure also defines a stored integer property called `numberOfEdits`, which is used to track the number of times that `value` is modified. This modification tracking is implemented with a `didSet` property observer on the `value` property, which increments `numberOfEdits` every time the `value` property is set to a new value.

If you create a `TrackedString` instance and modify its string value a few times, you can see the `numberOfEdits` property value update to match the number of modifications:

```swift
var stringToEdit = TrackedString()
stringToEdit.value = "This string will be tracked."
stringToEdit.value += " This edit will increment numberOfEdits."
stringToEdit.value += " So will this one."
print("The number of edits is \(stringToEdit.numberOfEdits)")
// Prints "The number of edits is 3"
```

Note that you can assign an explicit access level for both a getter and a setter if required. The example below shows a version of the `TrackedString` structure in which the structure is defined with an explicit access level of `public`. The structure’s members (including the `numberOfEdits` property) therefore have an *internal* access level by default. You can make the structure’s `numberOfEdits` property getter *public*, and its property setter *private*, by combining the *public* and *private(set)* access-level modifiers:

```swift
public struct TrackedString {
    public private(set) var numberOfEdits = 0
    public var value: String = "" {
        didSet {
            numberOfEdits += 1
        }
    }
    public init() {}
}

```

## Initializers

Custom initializers can be assigned an access level *less than or equal to* the type that they initialize. The only exception is for required initializers (as defined in [Required Initializers](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID231)). A required initializer must have the *same* access level as the class it belongs to.

As with function and method parameters, the types of an initializer’s parameters can’t be more private than the initializer’s own access level.

### Default Initializers

As described in [Default Initializers](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID213), Swift automatically provides a *default initializer* without any arguments for any structure or base class that provides default values for all of its properties and doesn’t provide at least one initializer itself.

A default initializer has the same access level as the type it initializes, unless that type is defined as `public`. For a type that’s defined as public, the default initializer is considered `internal`. If you want a public type to be initializable with a no-argument initializer when used *in another module*, you must *explicitly* provide a public no-argument initializer yourself as part of the type’s definition.

### Default Memberwise Initializers for Structure Types

The default memberwise initializer for a structure type is considered private if any of the structure’s stored properties are private. Likewise, if any of the structure’s stored properties are file private, the initializer is file private. Otherwise, the initializer has an access level of internal.

As with the default initializer above, if you want a public structure type to be initializable with a memberwise initializer when used *in another module*, you must provide a public memberwise initializer yourself as part of the type’s definition.

## Protocols


