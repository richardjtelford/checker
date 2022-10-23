chk_git_version <- function(){
  git_version <- tryCatch(
    system("git --version", intern = TRUE, ignore.stderr = TRUE),
    error = function(cond){return(NULL)}
  )
  git_version <- gsub("[a-z]", "", tolower(git_version))
  git_version <- trimws(git_version)
  git_version
}

chk_quarto_version <- function() {
  quarto_version <- system("quarto --version", intern = TRUE)
  quarto_version
}

chk_version <- function(what, yam, version){
  outcome <- c(good = 0, ok = 0, bad = 0)
  if (compareVersion(version, yam$recommended) >= 0) {
    chk_cat(message = paste(what, "version", version, "is installed"), status = "success")
    outcome["good"] <- 1

  } else if (!is.null(yam$minimum) && compareVersion(version, yam$minimum)) {
    chk_cat(message = paste("You have", what, "version", version, "installed. We recommend you upgrade to version", yam$recommended, "or newer"), status = "warning")
    outcome["ok"] <- 1
  } else {
    chk_cat(message = paste("You have", what, " version", version, "installed. Please upgrade to version", yam$recommended, "or newer"), status = "danger")
    outcome["bad"] <- 1
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

chk_cat <- function(message, status = "info") {
  has_cli <- requireNamespace("cli", quietly = TRUE)
  if (has_cli) {
    chk_status(status)(message, wrap = TRUE)
  } else {
    message(message)
  }
}
