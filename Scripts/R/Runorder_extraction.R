### Extracts ratings and run order from Eprime Files and either appends the
### extracted information to an existing file or creates a new file if that file
### does not exist.

library(tidyverse)
library(xlsx)

# Initialize filepath to Eprime files
proj_dir <- "/Volumes/727k/"
eprime_predir <- paste0(proj_dir, "Multi\ Modal/fMRI_scan/fMRI/Eprime\ Task\ Files/Baseline/")
eprime_postdir <- paste0(proj_dir, "Multi\ Modal/fMRI_scan/fMRI/Eprime\ Task\ Files/Post/")

# Load current Eprime run order if it exists to append new data 
currEprime <- "/Users/DyanRouglas/Documents/Yale_data/Eprime/Eprime_Ratings.csv"
if (file.exists(currEprime)) {
  currEprime <- read.csv(currEprime, stringsAsFactors = FALSE)
  appendFile <- TRUE
} else {
  appendFile <- FALSE
  # Create empty data frame so later check doesn't break script
  currEprime <- data.frame(EprimeID = character())
}


# Initialize Eprime directories
pre_dir <- dir(eprime_predir)
post_dir <- dir(eprime_postdir)

# define sequence of scans, ratings
run_seq <- c('NA', rep('gray',3), 'Stim1', 'Stim2', 'Stim3', 'Stim4', 'Stim5', 'Stim6', 'NA')
rat_seq <- c('Pre', 'Run1', 'Run2', 'Run3', 'Run4', 'Run5', 'Run6', 'Run7', 'Run8', 'Run9', 'Post')

# Extract pre scan Eprime data
count <- 1
for (i in 1:length(pre_dir)) {
  if (!(pre_dir[i] %in% currEprime$Eprime_ID)) {
    file <- paste0(eprime_predir, pre_dir[i], '/', pre_dir[i], '_merged.xlsx')
    if (file.exists(file)) {
      
      print(paste0("Extracting run order for ", pre_dir[i]))
      eprime <- read.xlsx(file, 1)
      
      run1 <- grep("1", eprime$Session)
      run1 <- as.character(eprime$Condi[run1[10]])
      if (is.na(run1)) {
        run1 <- ""
      }
      
      run2 <- grep("2", eprime$Session)
      run2 <- as.character(eprime$Condi[run2[10]])
      if (is.na(run2)) {
        run2 <- ""
      }
      
      run3 <- grep("3", eprime$Session)
      run3 <- as.character(eprime$Condi[run3[10]])
      if (is.na(run3)) {
        run3 <- ""
      }
      
      conds <- c(run1, run2, run3)
      
      # get pre/post scan ratings
      arous_pre <- c(subset(eprime, `Procedure.Block.`=='ArousalPre')$Arouse1Choice)
      stress_pre <- c(subset(eprime, `Procedure.Block.`=='StressPre')$Stress1Choice)
      crav_pre <- c(subset(eprime, `Procedure.Block.`=='CravPre')$Craving1Choice)
      mood_pre <- c(subset(eprime, `Procedure.Block.`=='MoodPre')$Like1Choice)
      
      arous_post <- c(subset(eprime, `Procedure.Trial.`=='ArousPost')$Arouse2Choice)
      stress_post <- c(subset(eprime, `Procedure.Trial.`=='StressPost')$Stress2Choice)
      crav_post <- c(subset(eprime, `Procedure.Trial.`=='CravPost')$Craving2Choice)
      mood_post <- c(subset(eprime, `Procedure.Trial.`=='MoodPost')$Like2Choice)
      
      
      # get within scan ratings, separtely for each scan type (alc/neut/str)
      for (cnum in c(1:length(conds))) {
        cname <- conds[cnum]
        stress_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Stress')$StressSlideChoice
        arous_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Arousal')$ArouSlideChoice
        crav_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Craving')$CravSlideChoice
        focus_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Focus')$FocusSlideChoice
        
        # for incomplete scans
        if (length(stress_scan)==1) {
          stress_scan <- rep(NA, 9)
          arous_scan <- rep(NA, 9)
          crav_scan <- rep(NA, 9)
          focus_scan <- rep(NA, 9)
        }
        
        num_obs <- sum(2 + length(stress_scan))
        
        # create dataframe to save out info per condition
        cond_dat <- data.frame(Eprime_ID = rep(pre_dir[i], num_obs),
                               Task = rep(cname, num_obs), 
                               Task_num = rep(cnum, num_obs), Scan = rat_seq[c(1:num_obs)], 
                               Stim = run_seq[c(1:num_obs)], 
                               Crav = c(crav_pre[cnum], crav_scan, crav_post[cnum]),
                               Like = c(mood_pre[cnum], rep(NA, (num_obs-2)), mood_post[cnum]), 
                               Arous = c(arous_pre[cnum], arous_scan, arous_post[cnum]),
                               Stress = c(stress_pre[cnum], stress_scan, stress_post[cnum]),
                               Focus = c('NA', focus_scan, 'NA'), 
                               stringsAsFactors = FALSE)
        
        # merge across conditions within subject
        if (cnum==1) {
          rating_sub <- cond_dat
        } else {
          rating_sub <- rbind(rating_sub, cond_dat)
        }
      } # condition
      
      # merge across subjects
      if (count == 1) {
        pre_scan <- rating_sub
      } else {
        pre_scan <- rbind(pre_scan, rating_sub)
      }
      count <- count + 1
    } else {
      next
    }
    
    
  }
  
  
}

# Extract post scan Eprime data
count <- 1
for (i in 1:length(post_dir)) {
  if (!(post_dir[i] %in% currEprime$Eprime_ID)) {
    file <- paste0(eprime_postdir, post_dir[i], '/', post_dir[i], '_merged.xlsx')
    if (file.exists(file)) {
      
      print(paste0("Extracting run order for ", post_dir[i]))
      eprime <- read.xlsx(file, 1)
      
      run1 <- grep("1", eprime$Session)
      run1 <- as.character(eprime$Condi[run1[10]])
      if (is.na(run1)) {
        run1 <- ""
      }
      
      run2 <- grep("2", eprime$Session)
      run2 <- as.character(eprime$Condi[run2[10]])
      if (is.na(run2)) {
        run2 <- ""
      }
      
      run3 <- grep("3", eprime$Session)
      run3 <- as.character(eprime$Condi[run3[10]])
      if (is.na(run3)) {
        run3 <- ""
      }
      
      conds <- c(run1, run2, run3)
      
      # get pre/post scan ratings
      arous_pre <- c(subset(eprime, `Procedure.Block.`=='ArousalPre')$Arouse1Choice)
      stress_pre <- c(subset(eprime, `Procedure.Block.`=='StressPre')$Stress1Choice)
      crav_pre <- c(subset(eprime, `Procedure.Block.`=='CravPre')$Craving1Choice)
      mood_pre <- c(subset(eprime, `Procedure.Block.`=='MoodPre')$Like1Choice)
      
      arous_post <- c(subset(eprime, `Procedure.Trial.`=='ArousPost')$Arouse2Choice)
      stress_post <- c(subset(eprime, `Procedure.Trial.`=='StressPost')$Stress2Choice)
      crav_post <- c(subset(eprime, `Procedure.Trial.`=='CravPost')$Craving2Choice)
      mood_post <- c(subset(eprime, `Procedure.Trial.`=='MoodPost')$Like2Choice)
      
      
      # get within scan ratings, separtely for each scan type (alc/neut/str)
      for (cnum in c(1:length(conds))) {
        cname <- conds[cnum]
        stress_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Stress')$StressSlideChoice
        arous_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Arousal')$ArouSlideChoice
        crav_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Craving')$CravSlideChoice
        focus_scan <- subset(eprime, Condi==cname & `Procedure.LogLevel5.`=='Focus')$FocusSlideChoice
        
        # for incomplete scans
        if (length(stress_scan)==1) {
          stress_scan <- rep(NA, 9)
          arous_scan <- rep(NA, 9)
          crav_scan <- rep(NA, 9)
          focus_scan <- rep(NA, 9)
        }
        
        num_obs <- sum(2 + length(stress_scan))
        
        # create dataframe to save out info per condition
        cond_dat <- data.frame(Eprime_ID = rep(post_dir[i], num_obs),
                               Task = rep(cname, num_obs), 
                               Task_num = rep(cnum, num_obs), Scan = rat_seq[c(1:num_obs)], 
                               Stim = run_seq[c(1:num_obs)], 
                               Crav = c(crav_pre[cnum], crav_scan, crav_post[cnum]),
                               Like = c(mood_pre[cnum], rep(NA, (num_obs-2)), mood_post[cnum]), 
                               Arous = c(arous_pre[cnum], arous_scan, arous_post[cnum]),
                               Stress = c(stress_pre[cnum], stress_scan, stress_post[cnum]),
                               Focus = c('NA', focus_scan, 'NA'), 
                               stringsAsFactors = FALSE)
        
        # merge across conditions within subject
        if (cnum==1) {
          rating_sub <- cond_dat
        } else {
          rating_sub <- rbind(rating_sub, cond_dat)
        }
      } # condition
      
      # merge across subjects
      if (count == 1) {
        post_scan <- rating_sub
      } else {
        post_scan <- rbind(post_scan, rating_sub)
      }
      count <- count + 1
    } else {
      next
    }
    
  }
  
  
}

# Bind pre and post data together into single dataframe
eprime_runorder <- rbind(pre_scan, post_scan)
eprime_runorder <- data.frame(eprime_runorder)
if (appendFile) {
  currEprime <- rbind(currEprime, eprime_runorder)
  eprime_runorder <- currEprime
}

# Write Eprime data into csv file
write.csv(eprime_runorder, file = "/Users/DyanRouglas/Documents/Yale_data/Eprime/Eprime_Ratings.csv", row.names = FALSE)
