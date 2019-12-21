# Master MSB file
msb <- read.csv2("/Users/DyanRouglas/Documents/Yale_data/BioImageSuite/Multimodal_AllSubjects_singleruns_n210.msb", 
                 col.names = FALSE, header = FALSE, stringsAsFactors = FALSE)
# File with desired Scan IDs in the FIRST COLUMN 
IDFile <- "/Users/DyanRouglas/Documents/Yale_data/BioImageSuite/Final_MMKD_2.csv"

# Desired output directory
output <- "/Users/DyanRouglas/Documents/Yale_data/BioImageSuite/"

# Desired output file name
filename <- "Multimodal_singleruns.msb"


#### DO NOT NEED TO MODIFY ANYTHING BEYOND THIS POINT UNLESS YOU WANT TO CHANGE THE OUTPUT FILE NAME AT THE END ###


if (grepl('.xlsx$', IDFile)) {
  stop("ID input required to be a csv file")
} else {
  ID <-  read.csv(IDFile)
}

msb <- data.frame(msb) #Convert to dataframe to facilitate combining pieces later

# Get first and last section to paste together later
topIndex <- grep("Subjects", unlist(msb))
top <- msb[seq(1, topIndex+2),]
top <- data.frame(top, stringsAsFactors = FALSE)

bottomIndex <- grep("Reference/Output Images", unlist(msb))
bottom <- msb[seq(bottomIndex-1,nrow(msb)),]
bottom <- data.frame(bottom, stringsAsFactors = FALSE)

# Ensure correct column name
colnames(ID)[1] <- "Scan_ID"

# Loop through Scan IDs and extract sections from .msb file for each scan
count <- 1
nsubj <- nrow(ID)

for (i in 1:nrow(ID)) {
  scan <- as.character(ID$Scan_ID[i])
  index <- grep(scan, unlist(msb))
  if (identical(index, integer(0))) {
    nsubj <- nsubj - 1
    print(paste0("Cannot find ", scan, " in .msb file.")) # Prints if scan ID cannot be found in .msb file
    next
  }
  if (count > 1 && paste0('Subject Id : ', scan) %in% unlist(Subject)) {
    nsubj <- nsubj - 1
    print(paste0("Skipped scan ", scan, ", already in output file."))
    next
  }
  
  subject <- msb[(index[1]-2):index[length(index)]+1,]
  subject <- data.frame(subject)

  if (count == 1) {
    subject <- subject[-1,] # Remove border separator of top file in order to paste together later
    Subject <- data.frame(subject)
  } else {
    Subject <- rbind(Subject, subject)
  }
  
  count <- count + 1
}
top[nrow(top)-1,] <- as.character(nsubj)

colnames(top) <- 'combine'
colnames(Subject) <- 'combine'
colnames(bottom) <- 'combine'
MSB <- rbind(top, Subject, bottom)

if (substr(output, nchar(output), nchar(output)) == "/") {
  file = paste0(output, filename)
} else {
  file = paste0(output, "/", filename)
}

if (exists('MSB')) {
  write.table(MSB, file, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = ",")
  print(paste0("Success! Output file located in: ", output))
} else {
  stop("Unable to write file")
}


