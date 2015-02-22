

#Download  data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile <- "getdata-projectfiles-UCI-HAR-Dataset.zip"
download.file(fileUrl, destfile=paste("data", destfile, sep="/"))
unzip(paste("data", destfile, sep="/"), exdir="data")
data_folder <- setdiff(dir("data"), destfile)


labels <- read.table(paste("data", data_folder, "activity_labels.txt", sep="/"), col.names=c("labelcode","label"))
features <- read.table(paste("data", data_folder, "features.txt", sep="/"))
req_feature <-  grep("-(mean|std)\\(\\)", features[, 2])

# training set
training_folder <- paste("data", data_folder, "train", sep="/")
training_subject <- read.table(paste(training_folder, "subject_train.txt", sep="/"), col.names = "subject")
training_data <- read.table(paste(training_folder, "X_train.txt", sep="/"),col.names = features[,2], check.names=FALSE)
training_data <- training_data[,req_feature]
training_labels <- read.table(paste(training_folder, "y_train.txt", sep="/"),col.names = "labelcode")
dftraining = cbind(training_labels, training_subject, training_data)

#test set
test_folder <- paste("data", data_folder, "test", sep="/")
test_subject <- read.table(paste(test_folder, "subject_test.txt", sep="/"), col.names = "subject")
test_data <- read.table(paste(test_folder, "X_test.txt", sep="/"), col.names = features[,2], check.names=FALSE)
test_data <- test_data[,req_feature]
test_labels <- read.table(paste(test_folder, "y_test.txt", sep="/"), col.names = "labelcode")
dftest = cbind(test_labels, test_subject, test_data)

## merge 
df <- rbind(dftraining, dftest)

## replace label codes with the label
df = merge(labels, df, by.x="labelcode", by.y="labelcode")
df <- df[,-1]

## reshape the array
library(reshape2)
molten <- melt(df, id = c("label", "subject"))

## Data with mean of each variable for each activyt and each subject
tidy <- dcast(molten, label + subject ~ variable, mean)

## write tidyData
write.table(tidy, file="tidyData.txt",row.names=FALSE)
# write codebook
write.table(paste(names(tidy), sep=""), file="CodeBook.md",row.names=FALSE, col.names=FALSE)