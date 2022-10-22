#' Check R setup before a class
#'
#' @param path path to yaml file

#' @importFrom yaml read_yaml
#' @importFrom utils compareVersion osVersion packageVersion
#'
#' @export

chk_requirements <- function(path = "inst/default.yaml"){
  outcome <- c(good = 0, ok = 0, bad = 0)
  yam <- read_yaml(file = path)
  names(yam) <- tolower(names(yam))

  # metadata
  chk_cat(paste0("Date = ", Sys.time()))
  chk_cat(paste0("os = ", osVersion))

  if(!is.null(yam$rstudio)) {
    outcome <- outcome + chk_rstudio(yam = yam$rstudio)
  }

  if(!is.null(yam$r_version)) {
    outcome <- outcome + chk_rversion(yam = yam$r_version)
  }

  if(!is.null(yam$quarto)) {
    outcome<- outcome + chk_quarto(yam$quarto)
  }

  if(!is.null(yam$packages)){
    for(i in seq_along(yam$packages)) {
      outcome<- outcome + chk_package(yam$packages[i])
    }
  }

  # outcomes
  if(outcome["bad"] > 0) {
    chk_cat("You have some issues that need addressing", status = "danger")
  } else if(outcome["ok"] > 0) {
    chk_cat("You have some issues that you should consider addressing", status = "warning")
  } else {
    chk_cat("Everything appears to be installed correctly", status = "success")
  }
}


chk_rstudio <- function(yam) {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    chk_cat("Are you using RStudio?", status = "danger")
    outcome <- c(good = 0, ok = 0, bad = 1)
  } else {
    rstudio_version <- rstudioapi::versionInfo()$version
    rstudio_version <- as.character(rstudio_version)
   outcome <- chk_r(what = "RStudio", yam = yam, version = rstudio_version)
  }
  outcome
}

chk_rversion <- function(yam){
  rversion <- paste(R.version$major, R.version$minor, sep = ".")
  outcome <- chk_r(what = "R", yam = yam, version = rversion)
  outcome
}

chk_r <- function(what, yam, version){
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
         message # default value
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

chk_package <- function(yam) {
  if(!requireNamespace(names(yam), quietly = TRUE)) {
    if(is.null(yam$message)) {
      message <- paste("Please install package", names(yam))
    } else {
      message <- yam$message
    }
    chk_cat(message = message, status = "danger")
    outcome <- c(good = 0, ok = 0, bad = 1)
    return(outcome)
  }

  if(!is.null(yam[[1]]$recommended)) {
    outcome <- chk_r(what = names(yam), yam = yam[[1]], version = as.character(packageVersion(names(yam))))
    outcome
  } else{
    outcome <- c(good = 1, ok = 0, bad = 0)
    outcome
  }
}

chk_quarto <- function(yam){
  if(!requireNamespace("quarto", quietly = TRUE)) {
    chk_cat("Please install quarto R package", status = "danger")
    outcome <- c(good = 0, ok = 0, bad = 1)
    return(outcome)
  }
  if(is.null(quarto::quarto_path())) {
    chk_cat("quarto not found. Please install quarto", status = "danger")
    outcome <- c(good = 0, ok = 0, bad = 1)
    return(outcome)
  }

  if(!is.null(yam$recommended)) {
    quarto_version <- system("quarto --version", intern = TRUE)
    outcome <- chk_r(what = "quarto", yam = yam, version = quarto_version)
    outcome
  } else{
    chk_cat("quarto is installed", status = "success")
    outcome <- c(good = 1, ok = 0, bad = 0)
    outcome
  }
}

