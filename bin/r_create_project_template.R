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
if (length(args) == 0) {
  stop("At least one argument must be supplied (input file).n", call. = FALSE)
} else if (length(args) > 0) {
  # default output file
  ptname <- args[1]
}

rpath <- Sys.getenv("R_PATH")

setwd(rpath)

libdir <- "../packages"

if (!file.exists(libdir)) {
  stop(paste(libdir, "does not exist in", rpath))
}

path <- file.path(rpath, libdir)

.libPaths(path)

library("ProjectTemplate")

setwd("..")

create.project(ptname)

assets_path <- file.path(rpath, "assets")
pt_path <- file.path(getwd(), ptname)

templates <- list.files(path = assets_path,
            pattern = ".template", all.files = TRUE)

for (template in templates) {
  asset <- file.path(assets_path, template)
  file.copy(asset, pt_path)
  asset <- file.path(pt_path, template)
  file <- sub("\\.template$", "", asset)
  file.rename(asset, file)
}