# Codebook
The data set comes from the experiments that were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING,
WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, 3-axial linear 
accelerations and 3-axial angular velocities were captured at a constant rate of 50Hz. The experiments were video-recorded to label the data manually. The obtained dataset was randomly
partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 
The accelerometer and gyroscope 3-axial raw signals are time domain signals. (Prefix 't' to denote time) These signals were captured at a constant rate of 50 Hz. Then they were filtered 
using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. The acceleration signal was separated into body and gravity acceleration
signals (tBodyAcc and tGravityAcc) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. Subsequently, the body linear acceleration and angular velocity were derived 
in time to obtain the jerk signals (tBodyAccJerk and tBodyGyroJerk). Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing frequency domain signals. (Note the 
'f' to indicate frequency domain signals).
The train data and test data are row-binded to each other to form a single data set. Then, the features which represent the mean and the standard deviation of a measurement are kept and the 
rest of the features are discarded. That's the mean, the data for a specific measurement exists in a pair of mean feature and a standard deviation feature, for example: tBodyAccJerk-mean and 
tBodyAccJerk-std. The data set contains measurements with directions and without directions. The measurements with directions are in x, y and z directions and labelled accordingly.
"tBodyAcc-mean()-X", "tBodyAcc-mean()-Y" and "tBodyAcc-mean()-Z" can be stated as an example. The measurements without direction are magnitude measurements. "fBodyAccMag-mean()" is an example.
A new feature called "index" is introduced as a time or frequency stamp identity. For tidying the data set, three new features are introduced. These are "domain", "type" and "direction" 
features. "domain" feature represents the domain in which the measurement is made. It is either the time domain or the frequency domain. Hence, "domain" feature takes on two values, "t" for 
the time domain and "f" for the frequency domain. "type" feature indicates statistical measure of the feature, whether it is mean or standard deviation. Hence, it takes on two values, "mean" 
for the mean and "std" for the standard deviation. For the vector measurements, another new feature is introduced. "direction" feature indicates the direction of the measurement. It takes on 
three values, "X", "Y" and "Z". After the introduction of the new features, the tidy data set contains the following features: 
"index", "subject", "activity", "direction", "domain", "type", "BodyAcc", "BodyAccJerk", "BodyGyro", "BodyGyroJerk", "GravityAcc", "BodyAccJerkMag", "BodyAccMag", "BodyBodyAccJerkMag", 
"BodyBodyGyroJerkMag", "BodyBodyGyroMag", "BodyGyroJerkMag", "BodyGyroMag", "GravityAccMag"
In the above names, "Acc" stands for acceleration, "Mag" stands for magnitude, "Gyro" stands for gyroscope. "index" is the integer time stamp or integer frequency stamp depending on the domain
of the measurement. "subject" is the integer identity of the volunteer. "activity" is the activity for which the measurement is made.
For the tidy data set, a new independent data set is created by taking the mean of the measurements. This independent tidy set contains the following features: 
"subject", "activity", "domain", "type", "direction", "BodyAcc", "BodyAccJerk", "BodyGyro", "BodyGyroJerk", "GravityAcc", "BodyAccJerkMag", "BodyAccMag", "BodyBodyAccJerkMag", 
"BodyBodyGyroJerkMag", "BodyBodyGyroMag", "BodyGyroJerkMag", "BodyGyroMag", "GravityAccMag"
The above measurement values are obtained by taking the mean of the measurements over either the time index or frequency index depending on the measurement domain.
