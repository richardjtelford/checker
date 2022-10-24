
<!-- README.md is generated from README.Rmd. Please edit that file -->

# checker

<!-- badges: start -->

[![R-CMD-check](https://github.com/richardjtelford/checker/workflows/R-CMD-check/badge.svg)](https://github.com/richardjtelford/checker/actions)
<!-- badges: end -->

One of the challenges with teaching R is that some students come to
practicals with very old versions of R, or without critical packages
installed. One solution is to use [rstudio.cloud](rstudio.cloud), where
the instructor can control the versions of software and packages used.

The `checker` attempts to be an alternative solution. It checks whether
the recommended (or more recent) versions of R, RStudio and packages, as
specified in a yaml file, are installed. A sample yaml file is included
in the installation. One can also be supplied with a URL or path.

## Installation

You can install the development version of `checker` from
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
#> → Date = 2022-10-24 19:15:47
#> → os = Ubuntu 18.04.6 LTS
#> ✔ RStudio version 2022.7.1.554 is installed
#> ✔ RStudio option 'save_workspace' set correctly
#> ✔ RStudio option 'load_workspace' set correctly
#> ✔ R version 4.2.1 is installed
#> ✔ quarto version 1.2.198 is installed
#> ✔ git is installed
#> ✔ tidyverse version 1.3.1 is installed
#> ✔ Package here is installed
#> ✔ Package quarto is installed
#> ✔ Everything appears to be installed correctly
```

By default, `chk_requirements()` uses a yaml file included in the
installation. To run `chk_requirements()` with your own set of
requirements, you can use a URL or file path.

``` r
chk_requirements(path = url("https://raw.githubusercontent.com/richardjtelford/checker/main/inst/default.yaml"))
```

## The yaml file

Below is the yaml file included in the installation. It can be edited to
meet your requirements

    ---
    r_version:
      recommended: 4.2.1
      minimum: 4.1.0
    packages:
      tidyverse:
        recommended: 1.3.1
      here: NA
      quarto: NA
    rstudio:
      recommended: 2022.07.1
      options:
        save_workspace:
          value: never
        load_workspace:
          value: FALSE
          message: Set load workspace to FALSE to improve reproducibility
    quarto:
      recommended: 1.2.198
    git: NA
    ---

The accepted keys are

-   r_version
-   rstudio
-   quarto
-   git
-   packages

All keys are optional. The first four take “recommended” and “minimum”
to specify the recommended and minimum versions (if only one of
“recommended” and “minimum” is set, they are treated in the same). If
any version is acceptable, use NA.

The rstudio key also accepts an options field, which takes the name with
value set to the recommended value and an optional message. A list of
Rstudio options can be found with `usethis:::rstudio_prefs_read()`.

The “packages” key has an element for each package installed. These take
the same recommended” and “minimum” fields as above, and also a
“message” field which is printed in the package is not installed. This
could be used to point to the location of packages not available on
CRAN.

The dashes denote the start and end of the yaml. The formatting with
white space must be followed.
