# Takes SCID summary export from REDcap

library(tidyverse)
library(xlsx)

scid <- read.csv("/Users/DyanRouglas/Documents/Yale_data/SCID/RajitasMultiModalStu-SCID5Summary_DATA_2019-11-26_1608.csv", stringsAsFactors = FALSE)
identifier <- read.xlsx("/Users/DyanRouglas/Documents/Yale_data/SCID/SCID_identifier.xlsx", 1)
demog <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 1)
demog2 <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 2)

output <- data.frame(MMID = character(nrow(scid)),
                     MMK = character(nrow(scid)),
                     ScanID = character(nrow(scid)),
                     Group = character(nrow(scid)),
                     Completed = numeric(nrow(scid)),
                     lif = character(nrow(scid)),
                     mon = character(nrow(scid)),
                     cur = character(nrow(scid)),
                     stringsAsFactors = FALSE)
header <- colnames(identifier)
for (i in 1:nrow(scid)) {
  id <- as.character(scid$autonumber[i])
  if (!startsWith(id, 'M')) next
  output$MMID[i] <- id
  
  hasDemog <- FALSE
  if (id %in% demog$MM_ID) {
    hasDemog <- TRUE
    Demog <- demog
  } else if (id %in% demog2$MM_ID) {
    hasDemog <- TRUE
    Demog <- demog2
  } else {
    print(paste0("Missing demographic information for: ", id))
  }
  
  if (hasDemog) {
    demogIndex <- grep(id, Demog$MM_ID)
    output$MMK[i] <- as.character(Demog$Second_ID[demogIndex])
    output$ScanID[i] <- as.character(Demog$ScanID[demogIndex])
    output$Group[i] <- as.character(Demog$Drink_Gp[demogIndex])
  }
  
  
  row <- scid[i,]
  output$Completed[i] <- as.numeric(row$scid_dsm5_summary_complete)
  
  disorder <- vector("list", length = ncol(scid))
  for (j in 1:length(row)) {
    if (suppressWarnings(is.na(as.numeric(row[j]))) |
        colnames(row[j]) == "scid_dsm5_summary_complete" | colnames(row[j]) == "scid5e14" | colnames(row[j]) == "scid5e34") next
    
    if (as.numeric(row[j]) > 1) {
      name <- colnames(row[j])
      type <- substr(name, nchar(name)-2, nchar(name))
      
      disorder_name <- as.character(strsplit(name, type))
      index <- grep(paste0('^', disorder_name, '$'), identifier$Header)

      disorder_name <- as.character(identifier$Disorder[index])
      if (disorder_name == "Alcohol") {
        if (substr(id, 1, 3) == "MSD") {
          disorder_name <- paste0(disorder_name, " Mild")
        } else {
          severity <- scid[i, 'scid5e14']
          if (is.na(severity)) {
            severity <- scid[i, 'scid5e34']
            if (is.null(severity) || is.na(severity)) {
              print(paste0("Missing AUD severity info for ", id))
            }
          } else if (severity == 1) {
            disorder_name <- paste0(disorder_name, " Mild")
          } else if (severity == 2) {
            disorder_name <- paste0(disorder_name, " Moderate")
          } else if (severity == 3) {
            disorder_name <- paste0(disorder_name, " Severe")
          }
        }
      }

      
      col <- grep(paste0('^', type, '$'), header)
      num <- as.numeric(row[j])
      
      endIndex <- index + 1
      while (is.na(identifier$Disorder[endIndex+1])) {
        endIndex <- endIndex + 1
      }
      
      section <- identifier[index:endIndex,]
      spot <- grep(num ,section[,col])
      subtype <- as.character(section[spot, col+1])
      
      disorder_name <- paste0(disorder_name, ' (', subtype, ')')
      if (nchar(output[i, type]) == 0) {
        output[i, type] <- disorder_name
      } else {
        previous <- output[i, type]
        output[i, type] <- paste0(previous, ', ', disorder_name)
      }
    }
    
  }
  
}

write.csv(output, file = "/Users/DyanRouglas/Documents/Yale_data/SCID/SCID_breakdown.csv", row.names = FALSE, na="")
