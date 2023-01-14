# FAQ for PlantUML<!-- omit in toc -->

- [1. How to integrate UML diagrams into GitLab or GitHub](#1-how-to-integrate-uml-diagrams-into-gitlab-or-github)
  - [1.1. Option 1: Using `mermaid`](#11-option-1-using-mermaid)
  - [1.2. Option 2: Using PlantUML Server](#12-option-2-using-plantuml-server)

## 1. How to integrate UML diagrams into GitLab or GitHub

> Reference: [stackoverflow](https://stackoverflow.com/a/32771815)

### 1.1. Option 1: Using `mermaid`

> Note: This tool works in both *GitHub* and *VS Code*, but **doesn't work in *GitBook***.
> **Tool**: [Mermaid Live Editor](https://mermaid.live/)

**Source**:

```uml
sequenceDiagram
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response
Alice -> Bob:Another authentication Response
Bob --> Alice: Another authentication Response
```

**Preview** by using [mermaid](https://mermaid-js.github.io/):

```mermaid
sequenceDiagram
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response
Alice -> Bob:Another authentication Response
Bob --> Alice: Another authentication Response
```

### 1.2. Option 2: Using PlantUML Server

> Documentation: [PlantUML Server](http://plantuml.com/server.html)
> **Tool**: [PlantUML Web Server](http://www.plantuml.com/plantuml)

**Source**:

```markdown
![alternative text](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.github.com/plantuml/plantuml-server/master/src/main/webapp/resource/test2diagrams.txt)
```

**Preview** by using PlantUML server:

![alternative text](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.github.com/plantuml/plantuml-server/master/src/main/webapp/resource/test2diagrams.txt)
