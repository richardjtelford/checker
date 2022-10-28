chk_has_version <- function(yam) {
  !(is.null(yam$recommended) && !is.null(yam$minimum))
}

chk_git_version <- function() {
  git_version <- tryCatch(
    system("git --version", intern = TRUE, ignore.stderr = TRUE),
    error = function(cond) {
      return(NULL)
    }
  )
  git_version <- gsub("[a-z]", "", tolower(git_version))
  git_version <- trimws(git_version)
  git_version
}

chk_quarto_version <- function() {
  quarto_version <- system("quarto --version", intern = TRUE)
  quarto_version
}

chk_rstudio_options <- function(yam) {
  outcome <- character(length(yam))
  for (i in seq_along(yam)) {
    current <- rstudioapi::readRStudioPreference(
      name = names(yam)[i],
      default = "Not recognised"
    )
    if (current == "Not recognised") {
      outcome[i] <- chk_cat(
        message = paste0(
          "Unrecognised RStudio option '", names(yam)[i],
          "' - check YAML"
        ),
        status = "info"
      )
    } else if (current == yam[[i]]$value) {
      outcome[i] <- chk_cat(
        message = paste0("RStudio option '", names(yam)[i], "' set correctly"),
        status = "success"
      )
    } else {
      if (!is.null(yam[[i]]$message)) {
        outcome <- chk_cat(yam[[i]]$message, status = "warning")
      } else {
        outcome[i] <- chk_cat(
          message = paste0(
            "RStudio option '", names(yam)[i],
            "' should be set to ", yam[[i]]$value
          ),
          status = "warning"
        )
      }
    }
  }
  if (any(outcome == "warning")) {
    chk_cat(
      message = "Configuring the options in RStudio can make it easier and safer to use.",
      status = "info"
    )
  }
  outcome
}

chk_get_versions <- function(yam) {
  c(recommended = yam$recommended, minimum = yam$minimum)
}

chk_version <- function(what, yam, version) {
  # => recommended            s
  # => minimum < recommended  w
  # => minimum                s
  # < recommended no minimum  d
  # < minimum                 d
  version_rm <- chk_get_versions(yam)
  version_status <- vapply(version_rm,
    function(v) compareVersion(version, v),
    FUN.VALUE = 1
  )

  if (all(version_status >= 0)) {
    # >= recommended and minimum
    outcome <- chk_cat(
      message = paste(what, "version", version, "is installed"),
      status = "success"
    )
  } else if (all(version_status < 0)) {
    # < recommended and minimum
    outcome <- chk_cat(
      message = paste(
        "You have", what, " version", version,
        "installed. Please upgrade to version",
        version_rm[1], "or newer"
      ),
      status = "danger"
    )
  } else {
    # beats only one (presumable minimum)
    outcome <- chk_cat(
      message = paste(
        "You have", what, "version", version,
        "installed. We recommend you upgrade to version",
        version_rm[1], "or newer"
      ),
      status = "warning"
    )
  }
  outcome
}




chk_status <- function(status) {
  switch(status,
    info = cli::cli_alert_info,
    success = cli::cli_alert_success,
    warning = cli::cli_alert_warning,
    danger = cli::cli_alert_danger,
    cli::cli_alert # default value
  )
}

chk_cat <- function(message, status = "none") {
  has_cli <- requireNamespace("cli", quietly = TRUE)
  if (has_cli) {
    chk_status(status)(message, wrap = TRUE)
  } else {
    message(message)
  }
  status
}
