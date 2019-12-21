### Combines new format HR with old format and corrupted HR

library(xlsx)
library(tidyverse)


new <- read.xlsx("/Volumes/storage_seo-72707-psychiatry/Ryan_HR/PulsOxRMSSDCutMaster.xlsx", 1)
old <- read.xlsx("/Volumes/storage_seo-72707-psychiatry/Ryan_HR/old_format_HR.xlsx", 1)
corrupt <- read.xlsx("/Volumes/storage_seo-72707-psychiatry/Ryan_HR/corrupted_hr.xlsx", 1, header = FALSE)
kubios <- read.csv("/Users/DyanRouglas/Documents/Yale_data/Kubios/KubiosOutliersRemoved.csv", stringsAsFactors = FALSE)

demog <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 1)
demog2 <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 2)


outputNew <- select(new, SubjectID, SecondID, ScanID, Eprime, PrePost, Sex, Age, Education, 
                    Drink_Gp, ScanType, ScanLength, HR, SignalQuality, Run, Scan, Condition)
outputNew$Format <- "New"

outputOld <- data.frame(SubjectID = character(nrow(old)),
                     SecondID = character(nrow(old)), 
                     ScanID = character(nrow(old)),
                     Eprime = character(nrow(old)),
                     PrePost = character(nrow(old)),
                     Sex = character(nrow(old)),
                     Age = numeric(nrow(old)),
                     Education = numeric(nrow(old)),
                     Drink_Gp = character(nrow(old)),
                     ScanType = character(nrow(old)),
                     ScanLength = numeric(nrow(old)), 
                     HR = numeric(nrow(old)),
                     SignalQuality = numeric(nrow(old)),
                     Run = numeric(nrow(old)),
                     Scan = character(nrow(old)), 
                     Condition = character(nrow(old)),
                     Format = character(nrow(old)), 
                     stringsAsFactors = FALSE)

outputCorrupt <- data.frame(SubjectID = character(nrow(corrupt)),
                        SecondID = character(nrow(corrupt)), 
                        ScanID = character(nrow(corrupt)),
                        Eprime = character(nrow(corrupt)),
                        PrePost = character(nrow(corrupt)),
                        Sex = character(nrow(corrupt)),
                        Age = numeric(nrow(corrupt)),
                        Education = numeric(nrow(corrupt)),
                        Drink_Gp = character(nrow(corrupt)),
                        ScanType = character(nrow(corrupt)),
                        ScanLength = numeric(nrow(corrupt)), 
                        HR = numeric(nrow(corrupt)),
                        SignalQuality = numeric(nrow(corrupt)),
                        Run = numeric(nrow(corrupt)),
                        Scan = character(nrow(corrupt)), 
                        Condition = character(nrow(corrupt)),
                        Format = character(nrow(corrupt)), 
                        stringsAsFactors = FALSE)




for (i in 1:nrow(old)) {
  scan <- as.character(old$Subject[i])
  if (is_empty(scan)) next
  outputOld$ScanID[i] <- scan
  index <- grep(scan, demog$ScanID)
  
    
  if (is_empty(index)) {
      index <- grep(scan, demog2$ScanID)
      # If not in scan 2 sheet, skip
      if (is_empty(index)) {
        print(paste0("Missing data for old scan: ", scan))
        next
      }
      
      outputOld$SubjectID[i] <- as.character(demog2$MM_ID[index])
      outputOld$SecondID[i] <- as.character(demog2$Second_ID[index])
      eprime <- as.character(demog2$Eprime.ID[index])
      outputOld$Eprime[i] <- eprime
      type <- as.numeric(substr(eprime, 1, 1))
      if (type == 2 | type == 4) {
        outputOld$PrePost[i] <- "Post"
      } else {
        outputOld$PrePost[i] <- "Pre"
      }
      
      outputOld$Sex[i] <- as.character(demog2$Sex[index])
      outputOld$Age[i] <- as.numeric(demog2$Age[index])
      outputOld$Education[i] <- as.numeric(demog2$Education[index])
      outputOld$Drink_Gp[i] <- as.character(demog2$Drink_Gp[index])
      
      condition <- as.character(old$Condition[i])
      if (condition == "Rest") {
        outputOld$ScanType[i] <- "REST"
      } else {
        outputOld$ScanType[i] <- "BOLD"
      }
      outputOld$ScanLength[i] <- as.numeric(as.character(old$run_time[i]))
      outputOld$HR[i] <- as.numeric(as.character(old$puls_freq[i]))
      #outputOld$Run[i] <- as.numeric(as.character(old$file_num[i]))
      outputOld$Condition[i] <- condition
      outputOld$Format[i] <- "Old"
      
      next
      
  }

  
  outputOld$SubjectID[i] <- as.character(demog$MM_ID[index])
  outputOld$SecondID[i] <- as.character(demog$Second_ID[index])
  eprime <- as.character(demog$Eprime.ID[index])
  outputOld$Eprime[i] <- eprime
  type <- as.numeric(substr(eprime, 1, 1))
  if (type == 2 | type == 4) {
    outputOld$PrePost[i] <- "Post"
  } else {
    outputOld$PrePost[i] <- "Pre"
  }
  
  outputOld$Sex[i] <- as.character(demog$Sex[index])
  outputOld$Age[i] <- as.numeric(demog$Age[index])
  outputOld$Education[i] <- as.numeric(demog$Education[index])
  outputOld$Drink_Gp[i] <- as.character(demog$Drink_Gp[index])
  
  condition <- as.character(old$Condition[i])
  if (!is.na(condition)) {
    outputOld$Condition[i] <- condition
    if (condition == "Rest") {
      outputOld$ScanType[i] <- "REST"
    } else {
      outputOld$ScanType[i] <- "BOLD"
    }
  }
  
  outputOld$ScanLength[i] <- as.numeric(as.character(old$run_time[i]))
  outputOld$HR[i] <- as.numeric(as.character(old$puls_freq[i]))
  #outputOld$Run[i] <- as.numeric(as.character(old$file_num[i]))
  outputOld$Format[i] <- "Old"
  
}



outputOld <- data.frame(outputOld %>% group_by(ScanID, Condition) %>% mutate(Run = row_number()))
for (i in 1:nrow(outputOld)) {
  if (outputOld$Condition[i] == "Rest") {
    outputOld$Run[i] <- NA
  }
}



for (i in 1:nrow(corrupt)) {
  scan <- as.character(corrupt[i,1])
  scan <- substr(scan, 1, 6)
  outputCorrupt$ScanID[i] <- scan
  condition <- as.character(corrupt[i,1])
  condition <- substr(condition, 8, nchar(condition))
  if (condition == "alcohol") {
    outputCorrupt$Condition[i] <- "A"
  } else if (condition == "neutral") {
    outputCorrupt$Condition[i] <- "N"
  } else {
    outputCorrupt$Condition[i] <- "S"
  }
  
  outputCorrupt$HR[i] <- as.numeric(corrupt[i,2])
  outputCorrupt$Format[i] <- "Corrupted"
  
  index <- grep(scan, demog$ScanID)
  if (length(index) > 1) {
    index <- index[1]
    print(paste0(scan, " listed twice, using first occurrence"))
  }
  if (is_empty(index)) {
    index <- grep(scan, demog2$ScanID)
    if (is_empty(index)) {
      print(paste0("Missing demog for corrupted scan: ", scan))
      next
    }
    
    outputCorrupt$SubjectID[i] <- as.character(demog2$MM_ID[index])
    outputCorrupt$SecondID[i] <- as.character(demog2$Second_ID[index])
    eprime <- as.character(demog2$Eprime.ID[index])
    outputCorrupt$Eprime[i] <- eprime
    type <- as.numeric(substr(eprime, 1, 1))
    if (type == 2 | type == 4) {
      outputCorrupt$PrePost[i] <- "Post"
    } else {
      outputCorrupt$PrePost[i] <- "Pre"
    }
    
    outputCorrupt$Sex[i] <- as.character(demog2$Sex[index])
    outputCorrupt$Age[i] <- as.numeric(demog2$Age[index])
    outputCorrupt$Education[i] <- as.numeric(demog2$Education[index])
    outputCorrupt$Drink_Gp[i] <- as.character(demog2$Drink_Gp[index])
    
    next
  }
  
  outputCorrupt$SubjectID[i] <- as.character(demog$MM_ID[index])
  outputCorrupt$SecondID[i] <- as.character(demog$Second_ID[index])
  eprime <- as.character(demog$Eprime.ID[index])
  outputCorrupt$Eprime[i] <- eprime
  type <- as.numeric(substr(eprime, 1, 1))
  if (type == 2 | type == 4) {
    outputCorrupt$PrePost[i] <- "Post"
  } else {
    outputCorrupt$PrePost[i] <- "Pre"
  }
  outputCorrupt$Sex[i] <- as.character(demog$Sex[index])
  outputCorrupt$Age[i] <- as.numeric(demog$Age[index])
  outputCorrupt$Education[i] <- as.numeric(demog$Education[index])
  outputCorrupt$Drink_Gp[i] <- as.character(demog$Drink_Gp[index])
  
}

output <- rbind(outputNew, outputOld, outputCorrupt)
output$Kubios <- NA

for (i in 1:nrow(output)) {
  scan <- as.character(output$ScanID[i])
  if ((scan %in% kubios$ScanID)) {
    output$Kubios[i] <- 1
  } else {
    output$Kubios[i] <- 0
  }
}

write.xlsx(output, file = "/Users/DyanRouglas/Documents/Yale_data/PulseOximeter/PulseOximeter_Master.xlsx", row.names = FALSE, showNA = FALSE)
