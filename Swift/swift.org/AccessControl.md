# Access Control

> Version: *Swift 5.5*  
> Source: [*swift-book: Structures and Classes*](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html)  
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


