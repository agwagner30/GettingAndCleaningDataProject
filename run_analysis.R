
### Load in libraries needed and bring in the data zip files
library(data.table)
library(dplyr)
doc = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(doc,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

### Read different features in features.txt file
cat <- read.table('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
cat <- as.character(cat[,2])


#read the training data
data_train_x <- read.table('./UCI HAR Dataset/train/X_train.txt')
data_train_y <- read.table('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
data_train_subject <- read.table('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

###Put training data into a data frame
data_train <-  data.frame(data_train_subject, data_train_y, data_train_x)
names(data_train) <- c(c('subject', 'y'), cat)

###read the testing data
data_test_x <- read.table('./UCI HAR Dataset/test/X_test.txt')
data_test_y <- read.table('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
data_test_subject <- read.table('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

###Put testing data into a data frame
data_test <-  data.frame(data_test_subject, data_test_y, data_test_x)
names(data_test) <- c(c('subject', 'y'), cat)

### Combine the testing and training data
data_combined <- rbind(data_train, data_test)

###find all of the mean and standard deviation files in the combined data set
mean_std_dev <- grep('mean|std', cat)
data_sect <- data_combined[,c(1,2,mean_std_dev + 2)]

###Determine activity labels
activity_labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity_labels <- as.character(activity_labels[,2])
data_sect$activity <- activity_labels[data_sect$activity]

###Rename a few categories for the headings to make more sense
newname <- names(data_sect)
newname <- gsub("[(][)]", "", newname)
newname <- gsub("^t", "TimeDomain_", newname)
newname <- gsub("^f", "FrequencyDomain_", newname)
newname <- gsub("Acc", "Accelerometer", newname)
newname <- gsub("Gyro", "Gyroscope", newname)
newname <- gsub("Mag", "Magnitude", newname)
newname <- gsub("-mean-", "_Mean_", newname)
newname <- gsub("-std-", "_StandardDeviation_", newname)
newname <- gsub("-", "_", newname)
names(data_sect) <- newname

###Create the final data set
final_dataset <- aggregate(data_sect[,3:81], by = list(y = data_sect$y, subject = data_sect$subject),FUN = mean)

###Write the final data table
write.table(x = final_dataset, file = "tidy_dataset.txt", row.names = FALSE)



