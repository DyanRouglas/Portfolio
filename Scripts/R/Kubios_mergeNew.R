library(tidyverse)
library(xlsx)

### Change directory filepath (line 12) to the directory in data drive containing Kubios data ###
### Change IDs filepath (line 14) to directory containing csv file from Redcap ###
### Change tracking filepath (line 15) to directory containing MM tracking sheet ###
### You might need to change filepath separator from "/" to "\" depending on operating system ###
### The only other thing you need to change is the ouput directory at the bottom of the script ###
### Highlight the entire script and select run ### 

directory <- "/Volumes/data-CC1486-Psychiatry/SFN_HRVAbstract/Filtered_MM_Kubios"
hr_dir <- dir(directory)
#IDs <- read.csv("/Users/DyanRouglas/Documents/Yale_data/Kubios/MultiModalFMRI-MMandEprimeID_DATA_LABELS_2019-08-27_1820.csv")
demog <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 1)
demog2 <- read.xlsx("/Volumes/727k/Multi\ Modal/Tracking_Sheets/MM_Complete_DataTracking_Sheet.xlsx", 2)
drinkInfo <- read.xlsx("/Volumes/data-CC1486-Psychiatry/SFN_HRVAbstract/Materials/MSD_MMK_Drinking_Categorization.xlsx", 1, startRow = 2)
count <- 1

for (i in 1:length(hr_dir)) {
  
  if (nchar(hr_dir[i]) > 15 | nchar(hr_dir[i]) < 9) {
    next
  }
  # # Special cases that we don't want to include in the ouput #
  # if (hr_dir[i] == "pa0631.csv" | hr_dir[i] == "pb7297_V2.csv" | hr_dir[i] == "Thumbs.db" | hr_dir[i] == "Kubios_Merged") {
  #   next
  # }
  
  hr <- read.csv(paste0(directory, "/", hr_dir[i]), skip = 1) 
  
  
  ### Excluding column for "S1_Artifact...." because it is missing from some scans
  HR <- select(hr, FileName, S1_Artifact...., S1_Mean.RR..ms., S1_SDNN..ms., S1_Mean.HR..bpm., S1_SD.HR..bpm., S1_RMSSD..ms.,
               S1_NNxx..beats., S1_pNNxx...., S1_TINN..ms., S1_VLFpeak_FFT..Hz., S1_LFpeak_FFT..Hz., S1_HFpeak_FFT..Hz., 
               S1_VLFpow_FFT..ms2., S1_LFpow_FFT..ms2., S1_HFpow_FFT..ms2., S1_VLFpow_FFT..log., S1_LFpow_FFT..log., S1_HFpow_FFT..log., S1_VLFpow_FFT....,
               S1_LFpow_FFT...., S1_HFpow_FFT...., S1_LFpow_FFT..n.u.., S1_HFpow_FFT..n.u.., S1_TOTpow_FFT..ms2., S1_LF_HF_ratio_FFT, S1_VLFpeak_AR..Hz.,
               S1_LFpeak_AR..Hz., S1_HFpeak_AR..Hz., S1_VLFpow_AR..ms2., S1_LFpow_AR..ms2., S1_HFpow_AR..ms2., S1_VLFpow_AR..log., S1_LFpow_AR..log.,
               S1_HFpow_AR..log., S1_VLFpow_AR...., S1_LFpow_AR...., S1_HFpow_AR...., S1_LFpow_AR..n.u.., S1_HFpow_AR..n.u.., S1_TOTpow_AR..ms2.,
               S1_LF_HF_ratio_AR, S1_EDR..Hz., S1_ApEn, S1_SampEn)
  ScanID <- substr(hr_dir[i], 0, 6)
  scan <- ScanID
  HR$SubjectID <- NA
  HR$SecondID <- NA
  HR$ScanID <- scan
  HR$Eprime <- NA
  HR$PrePost <- NA
  HR$Sex <- NA
  HR$Age <- NA
  HR$Education <- NA
  HR$Shipley <- NA
  HR$Race <- NA
  HR$Ethnicity <- NA
  HR$Drink_Gp <- NA
  HR$DC_9 <- NA
  
  
  print(paste0("Merging: ",  scan))
  index <- grep(scan, demog$ScanID)
  # Check if in scan 2 sheet
  if (is_empty(index)) {
    index <- grep(scan, demog2$ScanID)
    # If not in scan 2 sheet, skip
    if (is_empty(index)) {
      print(paste0("Cannot find demographic information for ", scan))
      next
    }
    for (j in 1:nrow(HR)) {
        
        HR$SubjectID[j] <- as.character(demog2$MM_ID[index])
        HR$SecondID[j] <- as.character(demog2$Second_ID[index])
        HR$Eprime[j] <- as.character(demog2$Eprime.ID[index])
        HR$PrePost[j] <- "Post"
        HR$Sex[j] <- as.character(demog2$Sex[index])
        HR$Age[j] <- as.numeric(demog2$Age[index])
        HR$Education[j] <- as.numeric(demog2$Education[index])
        HR$Shipley[j] <- as.numeric(demog2$Shipley[index])
        HR$Race[j] <- as.character(demog2$Race[index])
        HR$Ethnicity[j] <- as.character(demog2$Ethnicity[index])
        HR$Drink_Gp[j] <- as.character(demog2$Drink_Gp[index])
        HR$DC_9[j] <- 5
      
    }
    
    if (count == 1) {
      Kubios <- HR
    } else {
      Kubios <- rbind(Kubios, HR)
    }
    
    count <- count + 1
    next
  }
  
  
  for (j in 1:nrow(HR)) {

    HR$SubjectID[j] <- as.character(demog$MM_ID[index])
    HR$SecondID[j] <- as.character(demog$Second_ID[index])
    HR$Eprime[j] <- as.character(demog$Eprime.ID[index])
    HR$PrePost[j] <- "Pre"
    HR$Sex[j] <- as.character(demog$Sex[index])
    HR$Age[j] <- as.numeric(demog$Age[index])
    HR$Education[j] <- as.numeric(demog$Education[index])
    HR$Shipley[j] <- as.numeric(demog$Shipley[index])
    HR$Race[j] <- as.character(demog$Race[index])
    HR$Ethnicity[j] <- as.character(demog$Ethnicity[index])
    HR$Drink_Gp[j] <- as.character(demog$Drink_Gp[index])
    
    # Get DC_9 info from other sheet
    drinkIndex <- grep(scan, drinkInfo$ScanID)
    if (substr(HR$SubjectID[j], 0, 3) == "MAD" | substr(HR$SubjectID[j], 0, 3) == "MPR") {
      HR$DC_9[j] <- 5
    } else if (is_empty(drinkIndex)) {
      print(paste0("missing DC_9 info for ", scan))
    } else {
      HR$DC_9[j] <- as.numeric(drinkInfo$DC_9[drinkIndex])
    }
  }
  
  if (count == 1) {
    Kubios <- HR
  } else {
    Kubios <- rbind(Kubios, HR)
  }
  
  count <- count + 1
}

# Change column order for easier interpretation of data set
hrvCols <- Kubios[,1:45]
demogCols <- Kubios[,46:ncol(Kubios)]
Kubios <- cbind(demogCols, hrvCols)


 ### Change filepath to desired output directory ###
write.csv(Kubios, file = "/Users/DyanRouglas/Documents/Yale_data/Kubios/Kubios_merged.csv", row.names = FALSE)

