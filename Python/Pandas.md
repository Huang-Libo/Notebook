# Pandas <!-- omit in toc -->

- [1. Overview](#1-overview)
- [2. Install](#2-install)
  - [2.1. PyPI](#21-pypi)
  - [2.2. Installing with Anaconda](#22-installing-with-anaconda)
  - [2.3. Installing with Miniconda](#23-installing-with-miniconda)

## 1. Overview

**pandas** is a fast, powerful, flexible and easy to use open source data analysis and manipulation tool,
built on top of the Python programming language.

| Name          | URL                              |
|---------------|----------------------------------|
| Website       | <https://pandas.pydata.org/>     |
| Documentation | <https://pandas.pydata.org/docs> |
| GitHub Group  | <https://github.com/pandas-dev>  |

## 2. Install

> <https://pandas.pydata.org/docs/getting_started/install.html>

### 2.1. PyPI

```sh
pip install pandas
```

pandas can also be installed with sets of optional dependencies to enable certain functionality. For example, to install pandas with the optional dependencies to read Excel files.

```sh
pip install "pandas[excel]"
```

All optional dependencies can be installed with `pandas[all]`:

```sh
pip install "pandas[all]"
```

The full list of extras that can be installed can be found in the [dependency section](http://pandas.pydata.org/docs/getting_started/install.html#install-optional-dependencies).

**Note**:

You are highly encouraged to install *performance dependencies*, as they provide speed improvements, especially when working with large data sets.

```sh
pip install "pandas[performance]"
```

### 2.2. Installing with Anaconda

> Anaconda: <https://docs.continuum.io/anaconda>

The simplest way to install not only *pandas*, but *Python* and the most popular packages that make up the [SciPy](https://scipy.org/) stack ([IPython](https://ipython.org/), [NumPy](https://numpy.org/), [Matplotlib](https://matplotlib.org/), ...) is with [Anaconda](https://docs.continuum.io/anaconda/), a cross-platform (Linux, macOS, Windows) Python distribution for data analytics and scientific computing.

### 2.3. Installing with Miniconda

> Miniconda: <https://docs.conda.io/en/latest/miniconda.html>

Miniconda is a free minimal installer for `conda`.

[Conda](https://conda.io/en/latest/) is the package manager that the Anaconda distribution is built upon. It is a package manager that is both cross-platform and language agnostic (it can play a similar role to a pip and virtualenv combination).
