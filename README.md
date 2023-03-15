
<!-- README.md is generated from README.Rmd. Please edit that file -->

# checker

<!-- badges: start -->

[![R-CMD-check](https://github.com/richardjtelford/checker/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/richardjtelford/checker/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/checker)](https://CRAN.R-project.org/package=checker)
<!-- badges: end -->

One of the challenges with teaching R is that some students come to
practicals with very old versions of R, or without critical packages
installed. There are several solutions to this:

- use [posit cloud](https://posit.cloud/) (formerly RStudio cloud),
  where the instructor can control the versions of software and packages
  used
- have the class install a package that has all necessary packages for
  the course as dependencies
- use the `renv` package to install packages listed in a lockfile
- use a [rocker container](https://rocker-project.org/)

One problem with these options is that they take control of package
installation, rather than giving the student practice installing
packages.

The `checker` attempts to be an alternative solution. It checks whether
the recommended (or more recent) versions of R, RStudio and packages, as
specified in a yaml file, are installed and that recommended RStudio
options are set. A sample yaml file is included in the installation. One
can also be supplied with a URL or path.

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
#> → Date = 2023-03-15 16:28:14
#> → os = Ubuntu 18.04.6 LTS
#> ✖ Are you using RStudio?
#> ✔ R version 4.2.2 is installed
#> ✔ quarto version 1.3.262 is installed
#> ✔ git version 2.17.1 is installed
#> ✔ tidyverse version 2.0.0 is installed
#> ✔ here version 1.0.1 is installed
#> ✔ quarto version 1.2 is installed
#> ✖ You have some issues that need addressing
```

By default, `chk_requirements()` uses a yaml file included in the
installation. To run `chk_requirements()` with your own set of
requirements, you can use a URL or file path.

``` r
chk_requirements(path = url("https://raw.githubusercontent.com/richardjtelford/checker/main/inst/default.yaml"))
```

## The yaml file

Below is the yaml file included in the installation. It can be edited to
meet your requirements by hand or with the function `chk_make()` which
takes data.frames of recommended programs, packages, and RStudio options
as arguments. Recommended and/or minimum version and any message can be
included in these data.frames.

    ---
    R:
      recommended: 4.2.2
      minimum: 4.1.0
    packages:
      tidyverse:
        recommended: 2.0.0
      here: NA
      quarto: NA
    rstudio:
      recommended: 2022.12.0
      options:
        save_workspace:
          value: never
          message: >
            Improve reproducibility by never saving the workspace.
            Menu tools > Global options > General
        load_workspace:
          value: FALSE
          message: >
            Set load workspace to FALSE to improve reproducibility.
            Menu tools > Global options > General
        rainbow_parentheses:
          value: TRUE
          message: >
            Rainbow parentheses make it easier to spot missing parentheses.
            Menu tools > Global options > Code > Display
        soft_wrap_r_files:
          value: TRUE
          message: >
            Soft wrap files so you do not need to scroll sideways.
            Menu tools > Global options > Code > Editing
        insert_native_pipe_operator:
          value: TRUE
          message: >
            Use the native pipe operator '|>'.
            Menu tools > Global options > Code > Editing
    quarto:
      recommended: 1.2.198
    git: NA
    ---

The accepted keys are

- r_version
- rstudio
- quarto
- git
- packages

All keys are optional. The first four take “recommended” and “minimum”
to specify the recommended and minimum versions (if only one of
“recommended” and “minimum” is set, they are treated in the same). If
any version is acceptable, use NA.

The “rstudio” key also accepts an options field, which takes the name
with value set to the recommended value and an optional message. A list
of RStudio options can be found with `usethis:::rstudio_prefs_read()`.

The “packages” key has an element for each package installed. These take
the same recommended” and “minimum” fields as above, and also a
“message” field which is printed in the package is not installed (the
“\>” lets the message span several lines). The message could be used to
point to the location of packages not available on CRAN.

The dashes denote the start and end of the yaml are optional. The
formatting with white space must be followed.
