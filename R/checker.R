#' Check R setup before a class
#'
#' @param path path to yaml file

#' @importFrom yaml read_yaml
#' @importFrom utils compareVersion osVersion packageVersion
#'
#' @export

chk_requirements <- function(path = system.file("default.yaml", package = "checker")){
  outcome <- c(good = 0, ok = 0, bad = 0)
  yam <- read_yaml(file = path)
  names(yam) <- tolower(names(yam))
  yam <- lapply(yam, as.list)

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

  if(!is.null(yam$git)) {
    outcome<- outcome + chk_git(yam$git)
  }

  if(!is.null(yam$packages)){
    yam$packages <- lapply(yam$packages, as.list)
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
   outcome <- chk_version(what = "RStudio", yam = yam, version = rstudio_version)
  }
  outcome
}

chk_rversion <- function(yam){
  rversion <- paste(R.version$major, R.version$minor, sep = ".")
  outcome <- chk_version(what = "R", yam = yam, version = rversion)
  outcome
}



chk_git <- function(yam){
  git_version <- chk_git_version()

  if(is.null(git_version)){
    chk_cat(message = "git not installed", status = "danger")
    outcome <- c(good = 0, ok = 0, bad = 1)
    return(outcome)
  }


  if(!is.null(yam$recommended)) {

    outcome <- chk_version(what = "git", yam = yam, version = git_version)
  } else{
    chk_cat("git is installed", status = "success")
    outcome <- c(good = 1, ok = 0, bad = 0)

  }
  outcome
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
    outcome <- chk_version(what = names(yam), yam = yam[[1]], version = as.character(packageVersion(names(yam))))
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
    quarto_version <- chk_quarto_version()
    outcome <- chk_version(what = "quarto", yam = yam, version = quarto_version)
    outcome
  } else{
    chk_cat("quarto is installed", status = "success")
    outcome <- c(good = 1, ok = 0, bad = 0)
    outcome
  }
}

