#!/usr/bin/env Rscript

#install R packages
args = commandArgs(T)
instLib = args[1] 
r = getOption("repos") # hard code the UK repo for CRAN
r["CRAN"] = "http://cran.uk.r-project.org"
options(repos = r)
rm(r)
install.packages("optparse", lib=instLib, repos = "http://cran.r-project.org")
install.packages("XML", lib=instLib, repos = "http://cran.r-project.org")

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    biocLite(new.pkg, ask=FALSE, lib=instLib, lib.loc=instLib)
  sapply(pkg, library, character.only = TRUE)
}

ipak_bioc <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    BiocManager::install(new.pkg, ask=FALSE, lib=instLib, lib.loc=instLib)
  sapply(pkg, library, character.only = TRUE)
}

if( (version$major == 3 && version$minor >=5) || version$major > 3) {
  # biocmanager versions of R
  if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
  BiocManager::install(ask=FALSE, lib=instLib, lib.loc=instLib)
  ipak_bioc(c("NOISeq"))
  ipak_bioc(c("Repitools"))
  ipak_bioc(c("Rsamtools"))
} else {
  # OLD versions of R
  stop("Must update to R v3.5.0 or greater")
}
