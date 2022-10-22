
<!-- README.md is generated from README.Rmd. Please edit that file -->

# checker

<!-- badges: start -->
<!-- badges: end -->

One of the challenges with teaching R is that some students come to
practicals with very old versions of R, or without critical packages
installed, despite instructions.

The `checker` package check whether the recommended version of R,
RStudio and packages are installed. Information on what versions are
required is specified in yaml file. A yaml file is included in the
installation, and can also be supplied with a URL.

## Installation

You can install the development version of checker from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("richardjtelford/checker")
```

## Usage

The function `chk_requirements()` is the only function the user needs to
run.

``` r
library(checker)
chk_requirements()
#> ℹ Date = 2022-10-22 21:46:34
#> ℹ os = Ubuntu 18.04.6 LTS
#> ✔ RStudio version 2022.7.1.554 is installed
#> ✔ R version 4.2.1 is installed
#> ✔ quarto version 1.2.198 is installed
#> ✔ tidyverse version 1.3.1 is installed
#> ✔ Everything appears to be installed correctly
```
