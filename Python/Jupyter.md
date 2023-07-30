# Project Jupyter <!-- omit in toc -->

- [1. Overview of Project Jupyter](#1-overview-of-project-jupyter)
  - [1.1. History](#11-history)
  - [1.2. Differences between Sub-projects](#12-differences-between-sub-projects)
- [2. Introduction of Sub-projects](#2-introduction-of-sub-projects)
  - [2.1. IPython](#21-ipython)
  - [2.2. Jupyter Notebook](#22-jupyter-notebook)
  - [2.3. JupyterLab (Recommended)](#23-jupyterlab-recommended)
    - [2.3.1. Features of JupyterLab](#231-features-of-jupyterlab)
- [3. Install](#3-install)
  - [3.1. Jupyter Notebook](#31-jupyter-notebook)
  - [3.2. JupyterLab (Recommended)](#32-jupyterlab-recommended)
  - [3.3. Voilà](#33-voilà)

## 1. Overview of Project Jupyter

| Name               | URL                             |
|--------------------|---------------------------------|
| Website            | <https://jupyter.org>           |
| Discourse          | <https://discourse.jupyter.org> |
| Documentation      | <https://docs.jupyter.org>      |
| Try Jupyter Online | <https://jupyter.org/try>       |
| GitHub Group       | <https://github.com/jupyter>    |
| **nbviewer**       | <https://nbviewer.org>          |

### 1.1. History

- *IPython Notebook* (2011)
  - Only support *Python*
- *Jupyter Notebook* (2014)
  - Supporting *Python*, *R* and *Julia* languages, etc.
- *JupyterLab* (2018)
  - Extensions supported (2019)
  - Added IDE features, e.g. Debugger (2021)

### 1.2. Differences between Sub-projects

- **IPython** is an interactive shell for Python and **a kernel for Jupyter**.
- **IPython Notebook** Predecessor of *Jupyter Notebook*, only support *Python*.
- **Jupyter Notebook** is a web-based interactive computing environment for creating and sharing documents containing code and text, supports multiple languages.
- **JupyterLab** is the *next-generation* user interface for *Jupyter Notebook*, offering enhanced features and flexibility for interactive computing workflows.

## 2. Introduction of Sub-projects

### 2.1. IPython

| Name          | URL                               |
|---------------|-----------------------------------|
| Website       | <https://ipython.org/>            |
| Documentation | <https://ipython.readthedocs.io/> |
| GitHub Group  | <https://github.com/ipython>      |

### 2.2. Jupyter Notebook

The Classic Notebook Interface.

| Name          | URL                                        |
|---------------|--------------------------------------------|
| Documentation | <https://jupyter-notebook.readthedocs.io/> |
| GitHub        | <https://github.com/jupyter/notebook>      |

### 2.3. JupyterLab (Recommended)

A Next-Generation Notebook Interface.

| Name          | URL                                 |
|---------------|-------------------------------------|
| Documentation | <https://jupyterlab.readthedocs.io> |
| GitHub Group  | <https://github.com/jupyterlab>     |

#### 2.3.1. Features of JupyterLab

- It provides an enhanced and more flexible environment for working with notebooks, text files, terminals, and other interactive features.
- JupyterLab offers a **multi-tabbed** interface, allowing you to work with multiple notebooks and files simultaneously. It also includes a flexible layout system, enabling you to arrange and organize various components within the user interface.
- JupyterLab retains all the features of Jupyter Notebook and introduces additional capabilities, making it a more powerful and extensible environment for interactive computing.

## 3. Install

> <https://jupyter.org/install>

### 3.1. Jupyter Notebook

Install the classic Jupyter Notebook with:

```sh
pip install notebook
```

To run the notebook:

```sh
jupyter notebook
```

### 3.2. JupyterLab (Recommended)

Install JupyterLab with pip:

```sh
pip install jupyterlab
```

Once installed, launch JupyterLab with:

```sh
jupyter lab
```

### 3.3. Voilà

Install Voilà with:

```sh
pip install voila
```

Once installed, launch Voilà with:

```sh
voila
```
