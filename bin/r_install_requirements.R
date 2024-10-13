#!/usr/bin/env Rscript

#### Description: Installs R packages
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

# Revision 2024-08-01

# https://www.r-project.org/
# https://cloud.r-project.org/

######################################
###        ###
######################################

rpath <- Sys.getenv("R_PATH")

setwd(rpath)

getwd()

libdir <- Sys.getenv("R_LIBS_USER")
java_home <- Sys.getenv("JAVA_HOME")


if (file.exists(libdir)) {
  print(paste(libdir, " already exists in", rpath))
} else {
  dir.create(libdir)
}

setwd(libdir)

gitignore_filename <- ".gitignore"

if (file.exists(gitignore_filename)) {
  print(paste(gitignore_filename, " already exists in", getwd()))
} else {
  file.create(gitignore_filename)
  gitignore_file <- file(gitignore_filename)
  writeLines(c("*"), gitignore_file)
  close(gitignore_file)
}

setwd(rpath)

requirements_filename <- "R_requirements.txt"
print(paste("Requirements file: ", requirements_filename))
requirements_file <- file(requirements_filename, open = "r")

requirements <- readLines(requirements_file)
len <- length(requirements)

for (line in 1:len){
    requirement <- requirements[line]
    if (requirement == "") {
      print(paste("Skipping empty requirement: ", requirement))
      next
    }
    print(paste("Processing requirement: ", requirement))
    install.packages(
      requirement, lib = libdir, repos = "https://cloud.r-project.org/")
}

close(requirements_file)