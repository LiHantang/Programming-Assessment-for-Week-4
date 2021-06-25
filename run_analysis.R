library(reshape2)
library(dplyr)
library(tidyr)
library(utils)

#Through information given in README file of the data set, there are basically three
#types of data: 1. triaxial readings from cell phone sensor (128 readings). 2. 561-feature vector that contains pre-calculated variables
#3.labeling data that contains information of subject and his/her activity
#To create a tidy data set, we should first set the working directroy in our data folder
#and then load all the data of test set into R using read.table()
setwd("./dataset/UCI HAR Dataset")

test_subject<-read.table("./test/subject_test.txt")
test_set<-read.table("./test/X_test.txt")
test_labels<-read.table("./test/y_test.txt")

test_body_acc_x<-read.table("./test/Inertial Signals/body_acc_x_test.txt")
test_body_acc_y<-read.table("./test/Inertial Signals/body_acc_y_test.txt")
test_body_acc_z<-read.table("./test/Inertial Signals/body_acc_z_test.txt")

test_body_gyro_x<-read.table("./test/Inertial Signals/body_gyro_x_test.txt")
test_body_gyro_y<-read.table("./test/Inertial Signals/body_gyro_y_test.txt")
test_body_gyro_z<-read.table("./test/Inertial Signals/body_gyro_z_test.txt")

test_total_acc_x<-read.table("./test/Inertial Signals/total_acc_x_test.txt")
test_total_acc_y<-read.table("./test/Inertial Signals/total_acc_y_test.txt")
test_total_acc_z<-read.table("./test/Inertial Signals/total_acc_z_test.txt")

#Put all the data in a list to facilitate later work
listofnames<-list("body_acc_x","body_acc_y","body_acc_z", "body_gyro_x","body_gyro_y","body_gyro_z","total_acc_x","total_acc_y","total_acc_z","labels","subject","set")
listofdataframes<-list(test_body_acc_x,test_body_acc_y,test_body_acc_z,test_body_gyro_x,test_body_gyro_y,test_body_gyro_z,test_total_acc_x,test_total_acc_y,test_total_acc_z, test_labels,test_subject,test_set)

#Before merging all three types of data in one data.frame, it's better to first clean them separately
#1. Cleaning the data of triaxial readings from sensor:
#As we can see, there are 128 columns for each row, and that means there are 128 different readings
#for every row. It also means that we should put number of reading in rows as different observations
#instead of in the columns as different variables.

for (i in 1:9){
  print(i)
  name = paste(listofnames[[i]], "_gathered",sep = "")
  nameofvalue = paste(listofnames[[i]], "_value", sep="")
  y<-prepare(listofdataframes[[i]])
  colnames(y)<-c("id","reading",nameofvalue)
  if(!exists("test_sensor_reading")){
    test_sensor_reading<-y
  }
  else{
    test_sensor_reading<-inner_join(test_sensor_reading, y)
  }
}

prepare<-function(x){
  x<-cbind(1:2947,x)
  colnames(x)<-c("id",1:128)
  y<-x %>% gather(reading,value, -id) %>% arrange(id)
  print(head(y))
  y
}

#2. Matching all the names of 561 features columns in test_set.txt to make the data set more readable
#and then extract all the means and standard deviations.
#load the list of 561 features
features<-read.table("features.txt")
#rename columns of test_set with feature names
colnames(test_set)<-features$V2
selection<-grep("mean\\()|std\\()",names(test_set))
test_set_selected<-test_set[selection]

#3. Merging subject label, activity label and test set data.
testsheet<-data.frame(id = 1:2947, subjects = test_subject$V1, activities = test_labels$V1, test_set_selected)

#4. Merging test sheet with our cleaned sensor readings
testsheet<-left_join(testsheet, test_sensor_reading)
testsheet<-testsheet %>% select(1:3,70:79,4:69)

#5. Make the data set more readable by using descriptive names for activities, then marking all the rows with "test", indicating it's the test group.
testsheet$activities<-factor(testsheet$activities, levels=c(1,2,3,4,5,6), labels =c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))
testsheet<-cbind(testsheet,group="test")


#After created testsheet, a data frame containing all the data for test group, we shall now start
#working on training group. The process is similar.
#The first step is still loading all the data.
train_subject<-read.table("./train/subject_train.txt")
train_set<-read.table("./train/X_train.txt")
train_labels<-read.table("./train/y_train.txt")

train_body_acc_x<-read.table("./train/Inertial Signals/body_acc_x_train.txt")
train_body_acc_y<-read.table("./train/Inertial Signals/body_acc_y_train.txt")
train_body_acc_z<-read.table("./train/Inertial Signals/body_acc_z_train.txt")

train_body_gyro_x<-read.table("./train/Inertial Signals/body_gyro_x_train.txt")
train_body_gyro_y<-read.table("./train/Inertial Signals/body_gyro_y_train.txt")
train_body_gyro_z<-read.table("./train/Inertial Signals/body_gyro_z_train.txt")

train_total_acc_x<-read.table("./train/Inertial Signals/total_acc_x_train.txt")
train_total_acc_y<-read.table("./train/Inertial Signals/total_acc_y_train.txt")
train_total_acc_z<-read.table("./train/Inertial Signals/total_acc_z_train.txt")

#Create two list tlistofnames and tlistofdataframes for later
tlistofnames<-list("body_acc_x","body_acc_y","body_acc_z","body_gyro_x","body_gyro_y","body_gyro_z", "total_acc_x", "total_acc_y","total_acc_z", "labels","set")
tlistofdataframes<-list(train_body_acc_x,train_body_acc_y,train_body_acc_z,train_body_gyro_x,train_body_gyro_y,train_body_gyro_z, train_total_acc_x, train_total_acc_y,train_total_acc_z, train_labels,train_set)

#1. Cleaning the data of triaxial readings from sensor and store them in train_sensor_reading:

for (i in 1:9){
  print(i)
  name = paste(tlistofnames[[i]], "_gathered",sep = "")
  nameofvalue = paste(tlistofnames[[i]], "_value", sep="")
  y<-tprepare(tlistofdataframes[[i]])
  colnames(y)<-c("id","reading",nameofvalue)
  if(!exists("train_sensor_reading")){
    train_sensor_reading<-y
  }
  else{
    train_sensor_reading<-inner_join(train_sensor_reading, y)
  }
}

tprepare<-function(x){
  x<-cbind(1:7352,x)
  colnames(x)<-c("id",1:128)
  y<-x %>% gather(reading,value, -id) %>% arrange(id)
  y
}

#2. Matching all the names of 561 features in test_set.txt and then extract all the means and standard deviations.
#load the list of 561 features
features<-read.table("features.txt")
#rename columns of test_set with feature names
colnames(train_set)<-features$V2
selection<-grep("mean\\()|std\\()",names(train_set))
train_set_selected<-train_set[selection]

#3. Matching subject label, activity label
trainsheet<-data.frame(id = 1:7352, subjects = train_subject$V1, activities = train_labels$V1, train_set_selected)

#4. Merging test sheet with our cleaned sensor readings
trainsheet<-left_join(trainsheet, train_sensor_reading)
trainsheet<-trainsheet %>% select(1:3,70:79,4:69)

#5. Make the data set more readable by using descriptive names for activities, then marking all the observations with "train" to indicate that it's the training group 
trainsheet$activities<-factor(trainsheet$activities, levels=c(1,2,3,4,5,6), labels =c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))
trainsheet<-cbind(trainsheet,group="train")


#After cleaning data for test group and train group separately, it's time to merge them.
#Knowing that a subject is either in test group or train group and not both. It's possible
#to combine two sheets directly by rows. Then we can rank them with the subjects' number
Dataset<-rbind(trainsheet,testsheet)
Dataset<-Dataset %>% arrange(subjects)

#Since now the ids of two sheets are overlapped, we can give the Dataset a new set of id
Dataset$id<-1:nrow(Dataset)

#After obtaining a clean data set, it is now possible to create another tidy data set
#containing the average of of each variable for each activity and subject combination
for(i in 1:30){
  for(j in lactivites){
    if(!exists("Datasetmean")){
      Datasetmean<-data.frame()
    }
    mean<-avg(subject = i, activity = j)
    Datasetmean<-rbind(Datasetmean,mean)
  }
}

avg<-function(subject = NULL, activity = NULL){
  Datasetfilt<-filter(Dataset,subjects == subject, activities == activity)
  means<-colMeans(Datasetfilt[,5:79])
  setmean<-cbind(subject,activity,t(means))
  setmean
}

#Store the final data set as Dataset_mean.csv
write.csv(Datasetmean,"Dataset_mean.csv")
