# Check R set up before a class

Checks that the required versions of 'R', 'RStudio', 'R' packages and
other dependencies are installed.

## Usage

``` r
chk_requirements(path = system.file("default.yaml", package = "checker"))
```

## Arguments

- path:

  path to yaml file. Defaults to a file that comes with the package.

## Value

No return value, output is printed

## Details

`chk_requirements()` checks that the computer set up before class. It
check

- 'R' version

- 'RStudio' version

- 'RStudio' options

- 'R' packages are installed (with version if necessary)

- 'git' version

- 'quarto' version

These requirements are specified in a yaml file specified by the `path`
argument which can be on the users computer or at a URL. If not set, the
function defaults to using a built-in yaml file, which may not require
the latest version.

## Examples

``` r
chk_requirements()
#> → Date = 2026-08-13 19:15:49.309343
#> → os = Ubuntu 24.04.4 LTS
#> ✖ Are you using RStudio?
#> ✔ R version 4.6.1 is installed
#> ✔ quarto version 1.10.18 is installed
#> ✔ git version 2.43.0 is installed
#> → Checking R packages
#> ✔ tidyverse version 2.0.0 is installed
#> ✖ Please install package here
#> ✖ You have some issues that need addressing
```
