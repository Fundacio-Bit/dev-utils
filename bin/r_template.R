#!/usr/bin/env Rscript

#### Description: Installs R packages
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

# https://www.r-project.org/
# https://cloud.r-project.org/

######################################
###        ###
######################################


args <- commandArgs(trailingOnly = TRUE)
ptname <- "ProjectTemplate"

# test if there is at least one argument: if not, return an error
#if (length(args) == 0) {
#  stop("At least one argument must be supplied (input file).n", call. = FALSE)
#} else if (length(args) > 0) {
#  # default output file
#  ptname <- args[1]
#}

rpath <- Sys.getenv("R_PATH")

setwd(rpath)

getwd()

libdir <- "../packages"

if (!file.exists(libdir)) {
  stop(paste(libdir, "does not exist in", rpath))
}

path <- file.path(rpath, libdir)

.libPaths(path)

library("tibble")
library("digest")
library("ProjectTemplate")
library("xlsx")
setwd("..")
setwd(ptname)

getwd()

load.project()

source("src/eda.R")

#message(paste(project.info))

# print(names(project.info$cache))

#for (dataset in project.info$data)
#{
#  message(paste('Showing top 5 rows of', dataset))
#  print(head(get(dataset)))
#}
