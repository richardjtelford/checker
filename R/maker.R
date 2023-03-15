#' Makes a yaml file with required packages etc
#' @param path File name and path. If missing will print to screen.
#' @param programs data.frame of required programs.
#' @param packages data.frame of required packages
#' @param options data.frame of recommended 'RStudio' options
#' @details Programs are checked against names of programs known by checker.
#' Unknown programs are ignored with a message. packages are checked against
#' installed packages. A message is given if there are any unknown packages.
#' options are checked against a curated list of 'RStudio' options taken
#' from `usethis:::rstudio_prefs_read()`.
#' See also [https://docs.posit.co/ide/server-pro/session_user_settings/session_user_settings.html](https://docs.posit.co/ide/server-pro/session_user_settings/session_user_settings.html).
#' A message is given if any are not recognised.
#' @return Returns a the yaml, invisibly, as a character vector.
#' Main purpose is to write the yaml to a file.
#' @examples
#' pak <- read.csv(
#'   text = "package, recommended, minimum, message
#'         dplyr, 1.0.9, NA, NA
#'         ggplot2, 3.3.5, 3.3.1, NA",
#'   strip.white = TRUE
#' )
#'

#' prog <- read.csv(text = 'program, recommended, minimum, message
#'              rstudio, 2022.12.0.353, NA, NA
#'              R, "4.2.2", "4.1.1", NA
#'              git, NA, NA, NA',
#'              strip.white = TRUE)

#' opt <- read.csv(text = 'option, value, message
#'              "save_workspace", "never", NA
#'              "load_workspace", "FALSE", "For reproducibility"',
#'              strip.white = TRUE)
#'
#' f  <- tempfile(fileext = ".yaml")
#' (chk_make(path = f, programs = prog, packages = pak, options = opt))
#' #chk_requirements(f)
#' unlink(f)
#' @importFrom stats setNames
#' @importFrom yaml as.yaml
#' @importFrom utils installed.packages
#' @export

chk_make <- function(path, programs, packages, options) {
  if (!missing(programs)) {
    chk_sanity_programs(programs)
  }
  if (!missing(packages)) {
    chk_sanity_packages(packages)
  }
  if (!missing(options)) {
    chk_sanity_options(options)
  }
  lst <- c(chk_df_list(programs), chk_df_list(packages))
  if (!missing(options)) {
    lst$rstudio$options <- chk_df_list(options)
  }
  yam <- as.yaml(lst)
  if (!missing(path)) {
    writeLines(yam, con = path)
    invisible(yam)
  } else {
    cat(yam)
    invisible(yam)
  }
}

chk_df_list <- function(p) {
  x <- lapply(seq_len(nrow(p)), function(i) {
    l <- p[i, -1]
    l <- l[, !is.na(unlist(l)), drop = FALSE]
    if (length(l) > 0) {
      l <- setNames(as.list(l), names(l))
    } else {
      l <- "NA"
    }
    l
  })
  x <- setNames(x, p[, 1, drop = TRUE])
  x
}


chk_sanity_programs <- function(programs) {
  known_programs <- tolower(c("R", "RStudio", "git", "quarto"))
  chk_sanity(
    actual = tolower(programs$program),
    expected = known_programs,
    message = "Unknown programs {unknown} will be ignored."
  )
}

chk_sanity_packages <- function(packages) {
  has_package <- vapply(packages$package,
    FUN = requireNamespace,
    FUN.VALUE = TRUE,
    quietly = TRUE
  )
  installed <- packages$package[has_package]
  chk_sanity(
    actual = packages$package,
    expected = installed,
    message = "Packages {unknown} are not installed. Please check spelling/capitalisation."
  )
}

chk_sanity_options <- function(options) {
  # edited from names(usethis:::rstudio_prefs_read())
  # see also https://docs.rstudio.com/ide/server-pro/session_user_settings/session_user_settings.html
  available <- c(
    "show_margin", "soft_wrap_r_files", "save_workspace",
    "reuse_sessions_for_project_links", "jobs_tab_visibility",
    "posix_terminal_shell", "load_workspace",
    "save_files_before_build", "rainbow_parentheses",
    "source_with_echo", "insert_native_pipe_operator",
    "show_hidden_files", "visual_markdown_editing_wrap",
    "new_proj_git_init"
  )
  chk_sanity(
    actual = options$options,
    expected = available,
    message = "RStudio options {unknown} are not recognised."
  )
}

chk_sanity <- function(actual, expected, message) {
  unknown <- actual[!actual %in% expected]
  if (length(unknown) > 0) {
    unknown <- glue::glue_collapse(unknown, sep = ", ", last = " and ")
    cli::cli_alert_warning(text = message)
  }
}
