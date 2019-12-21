### This script takes a merged Kubios file and searches for the file name in 
### the Physio_MM folder. It then determines if a scan is bold or resting
### based on the acquisition file name.

hrv <- read.csv("/Users/DyanRouglas/Documents/Yale_data/Kubios/Kubios_refined.csv")
directory <- "/Volumes/data-CC1486-Psychiatry/Physio_MM"
hr_dir <- dir(directory)

hrv$Scan <- NA
for (i in 1:nrow(hrv)) {
  scan <- as.character(hrv$ScanID[i])
  file <- as.character(hrv$FileName[i])
  file <- substr(file, 0, 15)
  print(paste0("Processing: ", scan, "    File: ", file))
  
  scan_dir <- dir(paste0(directory, '/', scan))
  
  index <- grep(file, scan_dir)
  if (is_empty(index)) {
    print(paste0("Missing files for scan: ", scan, " file: ", file ))
    next
  }
  
  target <- scan_dir[index]
  target <- target[grep("AcquisitionInfo", target)]
  if (is_empty(target)) {
    hrv$Scan[i] <- "BOLD"
    next
  }
  
  if (grepl("rest", target)) {
    hrv$Scan[i] <- "RESTING"
  } else {
    hrv$Scan[i] <- "BOLD"
  }
  
}

write.csv(hrv, file = "/Users/DyanRouglas/Documents/Yale_data/Kubios/Kubios_refined.csv", row.names = FALSE)
