### This script takes a csv file with the subject scan ID and group in the 
### first two columns and any covariants in the next columns and a file 
### determining if a subject is missing any files. This script will output a 
### .sh file containing a table ready for LME analysis


# File with scan ID in the first column, group in the second column and any 
# covariates desired to be in the output
IDFile <- "/Users/DyanRouglas/Documents/Yale_data/BioImageSuite/Final_MMKD_2.csv"

# File containing information on whether files for a particular subject exist
checkFiles <- "/Users/DyanRouglas/Documents/Yale_data/BioImageSuite/list255.csv"
checkFiles <- read.csv(checkFiles, stringsAsFactors = FALSE)

# Desired file path to output directory
output_directory <- "/Users/DyanRouglas/Documents/Yale_data/BioImageSuite"

# Desired file name
output_filename <- "Example_Filename"

# For each covariate mark with 1 to include in the output or 0 to exclude from
# the output
Gender <- 1
Age <- 1
Education <- 0
IQ <- 0


###### Don't need to change anything below here #######






if (grepl('.xlsx$', IDFile)) {
  stop("ID input required to be a csv file")
} else {
  ID <-  read.csv(IDFile, stringsAsFactors = FALSE)
}

missingFileInformation <- ID[!(ID$Subj %in% checkFiles[,1]),]
if (nrow(missingFileInformation) > 0) {
  for (i in 1:nrow(missingFileInformation)) {
    print(paste0("Missing file information for scan: ", missingFileInformation$Subj[i]))
  }
}

subject <- data.frame(Subj = character(1),
                     Group = character(1),
                     Gender = character(1),
                     Age = numeric(1),
                     Education = numeric(1),
                     IQ = numeric(1),
                     Time = character(1),
                     Task = character(1),
                     InputFile = character(1),
                     stringsAsFactors = FALSE)


col <- 2
names <- colnames(checkFiles)
count <- 1
while (col <= ncol(checkFiles)) {
  for (i in 1:nrow(ID)) {
    scan <- ID$Subj[i]
    index <- grep(scan, checkFiles[,1])
    if (identical(index, integer(0))) {
      next
    }
    
    if (checkFiles[index, col] == 1) {
      subject$Subj <- scan
      subject$Group <- ID$Group[i]
      if (Gender == 1) {
        subject$Gender <- ID$Gender[i]
      }
      if (Age == 1) {
        subject$Age <- ID$Age[i]
      }
      if (Education == 1) {
        subject$Education <- ID$Education[i]
      }
      if (IQ == 1) {
        subject$IQ <- ID$IQ[i]
      }
      
      
      name <- names[col]
      if (name == "StrEarly") {
        time <- "early"
        task <- "stress"
        type <- "First2Runs"
      } else if (name == "StrLate") {
        time <- "late"
        task <- "stress"
        type <- "Last2Runs"
      } else if (name == "NeutEarly") {
        time <- "early"
        task <- "neutral"
        type <- "First2Runs"
      } else if (name == "NeutLate") {
        time <- "late"
        task <- "neutral"
        type <- "Last2Runs"
      } else if (name == "DrgEarly") {
        time <- "early"
        task <- "drug"
        type <- "First2Runs"
      } else if (name == "DrgLate") {
        time <- "late"
        task <- "drug"
        type <- "Last2Runs"
      } else {
        next
      }
      
      subject$Time <- time
      subject$Task <- task
      subject$InputFile <- paste0("../Common_", scan, "_", task, "_bis_Avg", type, "_beta_sm6_orig.nii.gz \\")
      
      if (count == 1) {
        Subject <- subject
      } else {
        Subject <- rbind(Subject, subject)
      }
      
      count <- count + 1
      
    }
  }
  
  col <- col + 1
}


covariates <- vector()
if (Gender == 0) {
  covariates <- c(covariates, "Gender")
}
if (Age == 0) {
  covariates <- c(covariates, "Age")
}
if (Education == 0) {
  covariates <- c(covariates, "Education")
}
if (IQ == 0) {
  covariates <- c(covariates, "IQ")
}

Subject <- Subject[,!(names(Subject) %in% covariates)]

filename <- paste0(output_directory, output_filename, ".sh")
if (substr(output_directory, nchar(output_directory), nchar(output_directory)) == "/") {
  filename <- paste0(output_directory, output_filename, ".sh")
} else {
  filename <- paste0(output_directory, "/", output_filename, ".sh")
}

if (exists('Subject')) {
  write.table(Subject, filename, row.names = FALSE, quote = FALSE, sep = "\t")
  print(paste0("Success! Output file located in: ", output_directory))
} else {
  stop("Unable to write file")
}

