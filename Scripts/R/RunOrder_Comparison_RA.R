### This script extracts run order from Eprime files and compares it to 
### Cheryl's runorder

### It does this by outputting a csv file with Eprime runorder attached to Cheryl's file
### and creating a variable "mismatch" that contains a list of mismatched run orders.
### Use it to compare and see if there is an actual mismatch. 
### For example, there are instances when the scan was cut short and the Eprime 
### run order will only show two conditions but Cheryl included all three. 
### This will show up as a mismatch even though the run order is likely correct.

library(tidyverse)
library(readxl)

### Change to K drive directory
eprime_dir <- "/Volumes/727k"
### Change to directory containing Eprime files
eprime_predir <- paste0(eprime_dir, "/Multi\ Modal/fMRI_scan/fMRI/Eprime\ Task\ Files/Baseline/")
eprime_postdir <- paste0(eprime_dir, "/Multi\ Modal/fMRI_scan/fMRI/Eprime\ Task\ Files/Post/")

pre_dir <- dir(eprime_predir)
post_dir <- dir(eprime_postdir)

### Change to directory containing Run order from Cheryl
### The column name for the Eprime ID in Cheryl's file must be named "EprimeID" 
### for the script to work. Change the column name if necessary.
cheryl_runorder <- read_excel('/Users/DyanRouglas/Documents/Yale_data/MultiModal_SubjectList_Cheryl.xls')

### Extracts run order from Eprime files in the Baseline directory
for (i in 1:length(pre_dir)) {
  file <- paste0(eprime_predir, pre_dir[i], '/', pre_dir[i], '_merged.xlsx')
  if (file.exists(file)) {
    eprime <- read_excel(file)
    
    run1 <- grep("1", eprime$Session)
    run1 <- eprime$Condi[run1[10]]
    run1 <- substr(run1, 0, 1)
    
    run2 <- grep("2", eprime$Session)
    run2 <- eprime$Condi[run2[10]]
    run2 <- substr(run2, 0, 1)
    
    run3 <- grep("3", eprime$Session)
    run3 <- eprime$Condi[run3[10]]
    run3 <- substr(run3, 0, 1)
    
    run_order <- c(pre_dir[i], paste0(run1, run2, run3))
    
    if (i == 1) {
      pre_scan <- run_order
    } else {
      pre_scan <- rbind(pre_scan, run_order)
    }
  } else {
    next
  }
  
}

### Extracts run order from the Eprime files in the Post directory
for (i in 1:length(post_dir)) {
  file <- paste0(eprime_postdir, post_dir[i], '/', post_dir[i], '_merged.xlsx')
  if (file.exists(file)) {
    eprime <- read_excel(file)
    
    run1 <- grep("1", eprime$Session)
    run1 <- eprime$Condi[run1[10]]
    run1 <- substr(run1, 0, 1)
    
    run2 <- grep("2", eprime$Session)
    run2 <- eprime$Condi[run2[10]]
    run2 <- substr(run2, 0, 1)
    
    run3 <- grep("3", eprime$Session)
    run3 <- eprime$Condi[run3[10]]
    run3 <- substr(run3, 0, 1)
    
    run_order <- c(post_dir[i], paste0(run1, run2, run3))
    
    
    if (i == 1) {
      post_scan <- run_order
    } else {
      post_scan <- rbind(post_scan, run_order)
    }
  } else {
    next
  }
  
}

### Combines run order from Baseline and Post directory
eprime_runorder <- rbind(pre_scan, post_scan)
eprime_runorder <- data.frame(eprime_runorder)
colnames(eprime_runorder) <- c("EprimeID", "RunOrder_eprime")

runOrder_compare <- merge(cheryl_runorder, eprime_runorder, by = "EprimeID")

mismatch <- list()

for (i in 1:nrow(runOrder_compare)) {
  if (runOrder_compare$RunOrder[i] != runOrder_compare$RunOrder_eprime[i]) {
    mismatch[i] <- runOrder_compare$EprimeID[i]
  } else {
    mismatch[i] <- "Match"
  }
}

### The variable "mismatch" will contain a list of Eprime IDs with run orders
### that do not match between the Eprime files and Cheryl's run order
mismatch <- unique(mismatch)

### Change filepath to desired output directory and filename
write.csv(runOrder_compare, file = "/Users/DyanRouglas/Documents/Yale_data/Eprime/RunOrder_comparison.csv", row.names = FALSE)

