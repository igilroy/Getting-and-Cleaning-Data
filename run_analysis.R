# Script: run_analysis.R

# The purpose of this script is to create "tidy data" for use in further analysis, from raw data files of 
# human activity as measured by the embedded gyroscope and accelerometer in a Smartphone.

# The data covers various time domain measurements made as 30 subjects performed each of 6 activities.

# The data set was ramdomly divided into a "test" data set (9 subjects) and a "training" data set (subjects).

# This script merges the test and training data sets, adds meaningful variable names and converts the numeric 
# classification for the activities into more descriptive values.

# To create the tidy data, only mean and standard deviation variables for the time domain measurements (not the data that \
# has been modified using Fourier transformation).

# This subset of the data is then grouped by subject number and activity performed.  Finally this data is summarised by taking 
# the mean of each data variable, per activity, per subject.

# Details of the data set can be found in the accompanying CodeBook for this script.
#  Note: Script assumes data is stored in a "/data" directory under the working directory

## load packages and libraries
install.packages("dplyr")
library(dplyr)

### Read in required files

#### Read the list of variable names from Features.txt
variables<- read.table("data/features.txt", colClasses = "character", header=FALSE)
####  Create a vector of variable names that can be added to the data table when the data files are read in
variables.vector<-variables[,2]

### Replace "non-valid" characters in the variable names.  
### The order is important as it will eliminate the occurance of consecutive "." characters in variable names
variables.vector<-gsub("()-",".",variables.vector,fixed=TRUE)
variables.vector<-gsub("()",".",variables.vector,fixed=TRUE)
variables.vector<-gsub("(",".",variables.vector,fixed=TRUE)
variables.vector<-gsub(")",".",variables.vector,fixed=TRUE)
variables.vector<-gsub("-",".",variables.vector,fixed=TRUE)
variables.vector<-gsub(",",".",variables.vector,fixed=TRUE)

#### Read the list of activity labels from activity_labels.txt
activities<- read.table("data/activity_labels.txt", colClasses = "character", header=FALSE)

#### Read in Training Data Set files
##### Read in Training Subject data
subject.train<- read.table("data/train/subject_train.txt", sep="", colClasses = "integer", header=FALSE)

##### Read in Training Activity data
activity.train<- read.table("data/train/y_train.txt",sep="", colClasses = "integer", header=FALSE)

##### Read in Training set data. Replace the default variable names with more descriptive names from Features.txt
dataset.train<- read.table("data/train/X_train.txt",sep="", colClasses = "numeric", header=FALSE,
                           col.names = variables.vector)
##### Extract only the measurements on the mean and standard deviation for each time 
##### domain measurement (i.e. variabls begining with "t"). 
dataset.train <- select(dataset.train, starts_with("t"))
dataset.train <- select(dataset.train, matches('mean|std'))

#### Read in Test Data Set
##### Read in Test Subject data
subject.test<- read.table("data/test/subject_test.txt", colClasses = "integer", header=FALSE)

##### Read in Test Activity data
activity.test<- read.table("data/test/y_test.txt", colClasses = "integer", header=FALSE)

##### Read in Test  set data. Replace the default variable names with more descriptive names from Features.txt
dataset.test<- read.table("data/test/X_test.txt", colClasses = "numeric", header=FALSE,
                          col.names = variables.vector)
##### Extract only the measurements on the mean and standard deviation for each time 
##### domain measurement (i.e. variables begining with "t"). 
dataset.test <- select(dataset.test, starts_with("t"))
dataset.test <- select(dataset.test, matches('mean|std'))

#### Rename columns in Subject and Activity tables for Train and Test data
subject.train <- rename(subject.train,Subject=V1)
activity.train <- rename(activity.train,Activity=V1)
subject.test <- rename(subject.test,Subject=V1)
activity.test <- rename(activity.test,Activity=V1)

##### Merge the columns into one Train data set
rawdata.train<-cbind(subject.train,activity.train,dataset.train)

##### Merge the columns into one Test data set
rawdata.test<-cbind(subject.test,activity.test,dataset.test)

#### Combine the "Training" and "Test"  Data Sets into a single raw data table
rawdata.full<-rbind(rawdata.train,rawdata.test)

### Use descriptive activity names to name the activities in the data set
for (i in nrow(rawdata.full)) {
        activity.code <- rawdata.full$Activity
        rawdata.full$Activity <- activities[activity.code,2]
}



#### Group the data by Subject and then Activity
rawdata.group<-group_by(rawdata.full,Subject,Activity)

### Create a second, independent tidy data set by summarising themean of each variable for 
### each activity and each subject.
tidy.data<-summarise_each(rawdata.group,funs(mean))

#### Write to a "tidy data" file as a text file
write.table(tidy.data,file="data/Tidy_Data.txt")
#### Write to a "tidy data" file as a .csv file
write.csv(tidy.data,file="data/Tidy_Data.csv")




