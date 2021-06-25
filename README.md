Everything starts with a close look at the README file of the original dataset.

Through information given in README file of the data set, there are basically three
types of data: 
1. triaxial readings from cell phone sensor (128 readings). 
2. 561-feature vector that contains pre-calculated variables
3. labeling data that contains information of subject and his/her activity

To create a tidy data set, we should first set the working directroy in our data folder
and then load all the data of test set into R using read.table()

After that, we can start to merge and transfer all the data frames step by step:
1. Cleaning the data of triaxial readings from sensor:
As we can see, there are 128 columns for each row, and that means there are 128 different readings
for every row. It also means that we should put number of reading in rows as different observations
instead of in the columns as different variables.

Therefore, we can write a function that realizes the transformation using gather() function from tidyr package

2. Matching all the names of 561 features columns in test_set.txt to make the data set more readable
and then extract all the means and standard deviations.

In this step we give all the 561 features a more comprehensible name from the features.txt.
And then we use regular expressions and grep() function to locate and extract all the
variables containing means and standard deviations.

3. Merging subject label, activity label and test set data.

4. Merging test sheet with our cleaned sensor readings

5. Make the data set more readable by using descriptive names for activities, then marking all the rows with "test", indicating it's the test group.

Basically, what we are going to do with training set is the same. So we will skip it here.

After we have two separated sheets, it's time to merge them.
Knowing that a subject is either in test group or train group and not both. It's possible
to combine two sheets directly by rows. Then we can rank them with the subjects' number

Since now the ids of two sheets are overlapped, we should give the Dataset a new set of id

After obtaining a clean data set, it is now possible to create another tidy data set
containing the average of of each variable for each activity and subject combination and store them.

