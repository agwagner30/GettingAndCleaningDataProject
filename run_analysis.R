library(data.table)
doc = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(doc,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

cat <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
cat <- as.character(cat[,2])

data_train_x <- read.table('./UCI HAR Dataset/train/X_train.txt')
data_train_y <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
data_train_subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

data_train <-  data.frame(data_train_subject, data_train_y, data_train_x)
names(data_train) <- c(c('subject', 'y'), cat)

data_test_x <- read.table('./UCI HAR Dataset/test/X_test.txt')
data_test_y <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
data_test_subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

data_test <-  data.frame(data_test_subject, data_test_y, data_test_x)
names(data_test) <- c(c('subject', 'y'), cat)

data_combined <- rbind(data_train, data_test)

mean_std_dev <- grep('mean|std', cat)
data_sect <- data_combined[,c(1,2,mean_std_dev + 2)]

activity_labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity_labels <- as.character(activity_labels[,2])
data_sect$activity <- activity_labels[data_sect$activity]

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

final_dataset <- aggregate(data_sect[,3:81], by = list(y = data_sect$y, subject = data_sect$subject),FUN = mean)
write.table(x = final_dataset, file = "tidy_dataset.txt", row.names = FALSE)



