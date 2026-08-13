# Makes a yaml file with required packages etc

Makes a yaml file with required packages etc

## Usage

``` r
chk_make(path, programs, packages, options)
```

## Arguments

- path:

  File name and path. If missing will print to screen.

- programs:

  data.frame of required programs.

- packages:

  data.frame of required packages

- options:

  data.frame of recommended 'RStudio' options

## Value

Returns a the yaml, invisibly, as a character vector. Main purpose is to
write the yaml to a file.

## Details

Programs are checked against names of programs known by checker. Unknown
programs are ignored with a message. packages are checked against
installed packages. A message is given if there are any unknown
packages. options are checked against a curated list of 'RStudio'
options taken from `usethis:::rstudio_prefs_read()`. See also
<https://docs.posit.co/ide/server-pro/session_user_settings/session_user_settings.html>.
A message is given if any are not recognised.

## Examples

``` r
pak <- read.csv(
  text = "package, recommended, minimum, message
        dplyr, 1.0.9, NA, NA
        ggplot2, 3.3.5, 3.3.1, NA",
  strip.white = TRUE
)

prog <- read.csv(text = 'program, recommended, minimum, message
             rstudio, 2022.12.0.353, NA, NA
             R, "4.2.2", "4.1.1", NA
             git, NA, NA, NA',
             strip.white = TRUE)
opt <- read.csv(text = 'option, value, message
             "save_workspace", "never", NA
             "load_workspace", "FALSE", "For reproducibility"',
             strip.white = TRUE)

f  <- tempfile(fileext = ".yaml")
(chk_make(path = f, programs = prog, packages = pak, options = opt))
#> [1] "rstudio:\n  recommended: 2022.12.0.353\n  options:\n    save_workspace:\n      value: never\n    load_workspace:\n      value: 'FALSE'\n      message: For reproducibility\nR:\n  recommended: 4.2.2\n  minimum: 4.1.1\ngit: NA\npackages:\n  dplyr:\n    recommended: 1.0.9\n  ggplot2:\n    recommended: 3.3.5\n    minimum: 3.3.1\n"
#chk_requirements(f)
unlink(f)
```
