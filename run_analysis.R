
# Getting and Cleaning Data Course Project
# Created by: Tucker Doud

library(dplyr)
setwd("~/GitHub/GetCleanData")

# Get feature labels
featLab <- read.table(file = "./UCI_HAR_Dataset/features.txt", stringsAsFactors = F)
featLab <- unlist(x = featLab[2], use.names = F)
index <- grep("mean|std", featLab) #create index to subset mean and sd (includes meanFreq)

# Get activity lookup table
actLab <- read.table(file = "./UCI_HAR_Dataset/activity_Labels.txt")
names(actLab) <- c("id", "activity")  #rename cols

# Make test table ----------------------------------------

# Read in subject and activity data (the row labels)
testSub <- read.table(file = "./UCI_HAR_Dataset/test/subject_test.txt")
testAct <- read.table(file = "./UCI_HAR_Dataset/test/y_test.txt")
testLab <- cbind(testSub, testAct); rm(testAct, testSub) #combine
names(testLab) <- c("subject", "actID") #Rename cols

# Merge activity lables from lookup data
testLab <- left_join(x = testLab, y = actLab, by = c("actID"="id"))

# Read in sensor data, add labels and subset
test <- read.table(file = "./UCI_HAR_Dataset/test/X_test.txt")
names(test) <- featLab
test <- test[index] #Subset for only mean & sd
test <- cbind(testLab, test); rm(testLab)

# Make training table ------------------------------------

# Read in subject and activity data (the row labels)
trainSub <- read.table(file = "./UCI_HAR_Dataset/train/subject_train.txt")
trainAct <- read.table(file = "./UCI_HAR_Dataset/train/y_train.txt")
trainLab <- cbind(trainSub, trainAct); rm(trainAct, trainSub) #combine
names(trainLab) <- c("subject", "actID") #Rename cols

# Merge activity lables from lookup data
trainLab <- left_join(x = trainLab, y = actLab, by = c("actID"="id"))

# Read in sensor data, add labels and subset
train <- read.table(file = "./UCI_HAR_Dataset/train/X_train.txt")
names(train) <- featLab
train <- train[index] #Subset for only mean & sd
train <- cbind(trainLab, train); rm(trainLab)

# Combine data set to create final data and summarize into new data set -------

dat <- rbind(test, train); rm(test, train, actLab, featLab, index)

sum <- select(dat, -actID) %>%
    group_by(subject, activity) %>%
    summarise_each(funs(mean)) %>%
    arrange(subject, activity)

# Write data file for submission
write.table(x = sum, file = "./tidy_data.txt", row.names = F)
