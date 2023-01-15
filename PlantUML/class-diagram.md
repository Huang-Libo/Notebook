# Class Diagram<!-- omit in toc -->

> Source: [*PlantUML: Class Diagram*](https://plantuml.com/en/class-diagram)  
> Digest Date: *January 15, 2023*  

**Note**: The UML preview of this documentation is powered by **mermaid**, some PlantUML symbols are not supported by mermaid(e.g. `#--`), so I didn't record these special symbols.

- [1. Declaring Element](#1-declaring-element)
- [2. Relations between classes](#2-relations-between-classes)
- [3. Label on relations](#3-label-on-relations)

## 1. Declaring Element

![declaring-elements](../media/PlantUML/declaring-elements.png)

**Note**: `protocol` and `struct` was added in [PR-1028](https://github.com/plantuml/plantuml/pull/1028).

## 2. Relations between classes

Relations between classes are defined using the following symbols :

| Type        | Symbol | Drawing                               |
|-------------|--------|---------------------------------------|
| Extension   | `<|--` | ![sym01](../media/PlantUML/sym01.png) |
| Composition | `*--`  | ![sym02](../media/PlantUML/sym02.png) |
| Aggregation | `o--`  | ![sym03](../media/PlantUML/sym03.png) |

It is possible to replace `--` by `..` to have a dotted line.

Knowing those rules, it is possible to draw the following drawings:

**Source**:

```uml
@startuml
Class01 <|-- Class02
Class03 *-- Class04
Class05 o-- Class06
Class07 .. Class08
Class09 -- Class10
@enduml
```

**Preview by using mermaid**:

```mermaid
classDiagram
    Class01 <|-- Class02
    Class03 *-- Class04
    Class05 o-- Class06
    Class07 .. Class08
    Class09 -- Class10
```

---

**Source**:

```uml
@startuml
Class11 <|.. Class12
Class13 --> Class14
Class15 ..> Class16
Class17 ..|> Class18
Class19 <--* Class20
@enduml
```

**Preview by using mermaid**:

```mermaid
classDiagram
Class11 <|.. Class12
Class13 --> Class14
Class15 ..> Class16
Class17 ..|> Class18
Class19 <--* Class20
```

## 3. Label on relations
