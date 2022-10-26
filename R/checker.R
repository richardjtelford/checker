#' Check R setup before a class
#'
#' @param path path to yaml file

#' @importFrom yaml read_yaml
#' @importFrom utils compareVersion osVersion packageVersion
#'
#' @export

chk_requirements <- function(path = system.file("default.yaml", package = "checker")) {
  outcome <- character()
  yam <- read_yaml(file = path)
  names(yam) <- tolower(names(yam))
  yam <- lapply(yam, as.list)

  # metadata
  chk_cat(paste0("Date = ", Sys.time()))
  chk_cat(paste0("os = ", osVersion))

  if (!is.null(yam$rstudio)) {
    outcome <- c(outcome, chk_rstudio(yam = yam$rstudio))
  }

  if (!is.null(yam$r)) {
    outcome <- c(outcome, chk_rversion(yam = yam$r_version))
  }

  if (!is.null(yam$quarto)) {
    outcome <- c(outcome, chk_quarto(yam$quarto))
  }

  if (!is.null(yam$git)) {
    outcome <- c(outcome, chk_git(yam$git))
  }

  if (!is.null(yam$packages)) {
    yam$packages <- lapply(yam$packages, as.list)
    out <- character(length(yam$packages))
    for (i in seq_along(yam$packages)) {
      out[i] <- chk_package(yam$packages[i])
    }
    outcome <- c(outcome, out)
  }

  # outcomes
  if (any(outcome == "danger")) {
    chk_cat("You have some issues that need addressing", status = "danger")
  } else if (any(outcome == "warning")) {
    chk_cat(
      message = "You have some issues that you should consider addressing",
      status = "warning"
    )
  } else {
    chk_cat("Everything appears to be installed correctly", status = "success")
  }
  invisible()
}


chk_rstudio <- function(yam) {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    outcome <- chk_cat("Are you using RStudio?", status = "danger")
  } else {
    rstudio_version <- rstudioapi::versionInfo()$version
    rstudio_version <- as.character(rstudio_version)
    outcome <- chk_version(
      what = "RStudio",
      yam = yam,
      version = rstudio_version
    )
  }
  if (!is.null(yam$options)) {
    outcome <- c(outcome, chk_rstudio_options(yam = yam$options))
  }
  outcome
}

chk_rversion <- function(yam) {
  rversion <- paste(R.version$major, R.version$minor, sep = ".")
  outcome <- chk_version(what = "R", yam = yam, version = rversion)
  outcome
}



chk_git <- function(yam) {
  git_version <- chk_git_version()

  if (is.null(git_version)) {
    outcome <- chk_cat(message = "git not installed", status = "danger")
    return(outcome)
  }

  if (chk_has_version(yam)) {
    outcome <- chk_version(what = "git", yam = yam, version = git_version)
  } else {
    outcome <- chk_cat("git is installed", status = "success")
  }
  outcome
}


chk_package <- function(yam) {
  if (!requireNamespace(names(yam), quietly = TRUE)) {
    if (is.null(yam[[1]]$message)) {
      message <- paste("Please install package", names(yam))
    } else {
      message <- yam[[1]]$message
    }
    outcome <- chk_cat(message = message, status = "danger")
    return(outcome)
  }

  if (chk_has_version(yam[[1]])) {
    outcome <- chk_version(
      what = names(yam), yam = yam[[1]],
      version = as.character(packageVersion(names(yam)))
    )
    outcome
  } else {
    outcome <- chk_cat(
      message = paste("Package", names(yam), "is installed"),
      status = "success"
    )
    outcome
  }
}

chk_quarto <- function(yam) {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    outcome <- chk_cat(
      message = "Please install quarto R package",
      status = "danger"
    )
    return(outcome)
  }
  if (is.null(quarto::quarto_path())) {
    outcome <- chk_cat(
      message = "quarto not found. Please install quarto",
      status = "danger"
    )
    return(outcome)
  }

  if (chk_has_version(yam)) {
    quarto_version <- chk_quarto_version()
    outcome <- chk_version(what = "quarto", yam = yam, version = quarto_version)
  } else {
    outcome <- chk_cat("quarto is installed", status = "success")
  }
  outcome
}
