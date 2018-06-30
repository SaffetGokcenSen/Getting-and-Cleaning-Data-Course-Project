library(data.table) # load data.table package
library(dplyr) # load dplyr package
library(tidyr) # load tidyr package

## this function downloads the data to the working directory with the specified
## file name and unzips the file
## inputs
## url: the character for the internet address of the file to be downloaded
## work_dir: the character for the path of the working directory
## file_name: the character for the name given to the downloaded file
download_data <- function(url, work_dir, file_name) {
      ## set the working directory
      setwd(work_dir)
      
      ## download the data set to the destination
      download.file(url = url, destfile = file_name)
      
      ## unzip the downloaded file
      the_command <- paste0("unzip ", file_name)
      system(the_command)
}


## this function reads in the data file. It merges the train data and test data
## to obtain a single data set.
## output: the data frame for the tidy data set
merge_data <- function() {
      ## read the feature names
      base_path <- "./UCI HAR Dataset/"
      file_path <- paste0(base_path, "features.txt")
      col_names <- c("index", "feature")
      features_df <- fread(file_path, data.table = FALSE, col.names = col_names)
      feature_names <- features_df$feature
      
      ## read the train data
      col_names <- feature_names
      base_path <- "./UCI HAR Dataset/train/"
      file_path <- paste0(base_path, "X_train.txt")
      x_trn <- fread(file_path, data.table = FALSE, col.names = col_names)
      file_path <- paste0(base_path, "y_train.txt")
      y_trn <- fread(file_path, data.table = FALSE, col.names = c("activity"))
      file_path <- paste0(base_path, "subject_train.txt")
      subj_trn <- fread(file_path, data.table = FALSE, col.names = c("subject"))
      ## put x, activity and subject data in a single data frame
      trn_data <- bind_cols(list(x_trn, y_trn, subj_trn))
      
      ## read the test data
      base_path <- "./UCI HAR Dataset/test/"
      file_path <- paste0(base_path, "X_test.txt")
      x_tst <- fread(file_path, data.table = FALSE, col.names = col_names)
      file_path <- paste0(base_path, "y_test.txt")
      y_tst <- fread(file_path, data.table = FALSE, col.names = c("activity"))
      file_path <- paste0(base_path, "subject_test.txt")
      subj_tst <- fread(file_path, data.table = FALSE, col.names = c("subject"))
      ## put x, activity and subject data in a single data frame
      tst_data <- bind_cols(list(x_tst, y_tst, subj_tst))
      
      ## merge the train and test data
      data_set <- bind_rows(trn_data, tst_data)
      
      ## discard any possible duplicate rows
      data_set <- unique(data_set)
      
      ## return the data set
      data_set
}


## this function creates a tidy data set either for a set of vector measurements
## or a set of scalar, i.e. magnitude, measurements
## inputs:
## data_set: the data frame from which the tidy data set is to be produced
## is_vector: the boolen indicating whether the vector measurements or magnitude
## measurements are to be processed
## gather_reg_exp: the regular expression character used to determine which 
## columns to gather
## join_col: the array of characters which are the newly introduced columns to 
## make the data set tidy
## extract_reg_exp: the regular expression character for automatically 
## separating the key column to the newly introduced columns
## output:
## the data frame for the tidy data set
create_tidy_data <- function(data_set, is_vector, gather_reg_exp, join_col, 
                             extract_reg_exp){
      ## column names of the data set
      col_names <- names(data_set)
      ## the columns to be gathered are determined
      col_to_be_gathered <- col_names[grep(gather_reg_exp, col_names)]
      ## the name of the columns to be gathered are ordered
      col_to_be_gathered <- col_to_be_gathered[order(col_to_be_gathered)]
      
      # columns to be gathered are grouped according to the root measurement
      the_list <- strsplit(col_to_be_gathered, "-")
      level_x <- function(x){
            substr(x[1], 2, nchar(x[1]))
      }
      the_levels <- sapply(the_list, level_x)
      fx <- function(x){x}
      the_groups <- tapply(col_to_be_gathered, the_levels, fx)
      group_names <- names(the_groups)
      
      ## default columns to be used in gathering
      base_col <- c("index", "subject", "activity")
      ## joining is to be made by these columns
      join_by_col <- c(base_col, join_col)
      ## initial empty tidy data set
      if (is_vector){
            tidy_data_set <- data.frame(index = numeric(),
                                        subject = numeric(), 
                                        activity = character(), 
                                        direction = character(),
                                        domain = character(), 
                                        type = character())
      } else{
            tidy_data_set <- data.frame(index = numeric(),
                                        subject = numeric(), 
                                        activity = character(), 
                                        domain = character(), 
                                        type = character())
      }
      for (gather_col in the_groups){
            ## array for the columns to be gathered
            col_selected <- c(base_col, gather_col)
            ## source data frame to be used in gathering
            source_df <- select(data_set, col_selected)
            ## tidy form of the source data frame
            tidy_source <- source_df %>% 
                  gather(key = "the_key", value = value, gather_col) %>% 
                  extract(the_key, join_col, extract_reg_exp) %>% 
                  mutate(domain = substr(domain,1,1))
            ## the name of the value column is set
            name_to_be_splitted <- gather_col[1]
            the_split <- strsplit(name_to_be_splitted, "-")
            first_part <- the_split[[1]][1]
            val_name <- substr(first_part, 2, nchar(first_part))
            ## value column is renamed
            colnames(tidy_source)[colnames(tidy_source) == "value"] <- val_name
            tidy_data_set <- full_join(tidy_data_set, tidy_source, 
                                       by = join_by_col)
      }
      tidy_data_set
}


## url of the data for the project
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## the working directory
work_dir <- "C:/Users/TOSHIBA/Documents/coursera"
## the name given to the downloaded file
file_name <- "data_set.zip"

## download the zipped data
download_data(url, work_dir, file_name)

## merge the training and the test sets to create one data set
whole_data_set <- merge_data()


## extract only the measurements on the mean and standard deviation for each 
## measurement.

## column names of the data set
col_names <- names(whole_data_set)
## regular expression for getting the column names containing std function
reg_std <- "[Ss]td.*\\(+\\)+.*"
## column names containing std function
features_std <- col_names[grep(reg_std, col_names)]
## column names containing mean function
features_mean <- gsub("std", "mean", features_std)
## features with both mean and std data
features <- c(features_mean, features_std)
## now, the data set contains only the measurements on the mean and standard 
## deviation for each measurement 
data_set <- select(whole_data_set, c("activity", "subject", features))


## set descriptive activity names for the activities in the data set

## dictionary for converting activity integers to activity labels
act_label <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING",
               "STANDING", "LAYING")
## activity integers are converted to activity labels
data_set <- mutate(data_set, activity = act_label[activity])


## appropriately label the data set with descriptive variable names and
## make the data set tidy

## add an index column to the data set to be used in joining
data_set$index <- 1:nrow(data_set)


## create a tidy data set for the vector measurements

## regular expression for determining the columns to be gathered
gather_reg_exp <- ".+-[XYZ]"
## the newly introduced columns to make the data set tidy
join_col <- c("domain", "type", "direction")
## the regular expression character for automatically separating the key column
## to the newly introduced columns
extract_reg_exp <- "(.+)-(mean|std)\\(\\)-([XYZ])"
## the tidy data set for the vector measurements is created
vec_tidy_data_set <- create_tidy_data(data_set, TRUE, gather_reg_exp, join_col,
                                      extract_reg_exp)


## create a tidy data set with the mean of each variable

## the column names whose means are to be calculated
group_names <- c("BodyAcc", "BodyAccJerk", "BodyGyro", "BodyGyroJerk", 
                 "GravityAcc")
## the tidy data set with the mean of each measurement variable
vec_ind_tidy_data_set <- vec_tidy_data_set %>% 
      group_by(subject, activity, domain, type, direction) %>% # form the groups
      summarize_at(group_names, mean) %>% # calculate means
      as.data.frame() # convert tibble to data frame


## create a tidy data set for the magnitude measurements

## regular expression for determining the columns to be gathered
gather_reg_exp <- "(\\(\\)$)"
## the newly introduced columns to make the data set tidy
join_col <- c("domain", "type")
## the regular expression character for automatically separating the key column
## to the newly introduced columns
extract_reg_exp <- "(.+)-(mean|std)\\(\\)"
## the tidy data set for the scalar, i.e. magnitude, measurements is created
mag_tidy_data_set <- create_tidy_data(data_set, FALSE, gather_reg_exp, join_col, 
                                      extract_reg_exp)


## create a tidy data set with the mean of each measurement variable

## the column names whose means are to be calculated
group_names <- c("BodyAccJerkMag", "BodyAccMag", "BodyBodyAccJerkMag", 
                 "BodyBodyGyroJerkMag","BodyBodyGyroMag", "BodyGyroJerkMag", 
                 "BodyGyroMag", "GravityAccMag")
## the tidy data set with the mean of each measurement variable
mag_ind_tidy_data_set <- mag_tidy_data_set %>% 
      group_by(subject, activity, domain, type) %>% # form the groups
      summarize_at(group_names, mean) %>% # calculate means
      as.data.frame() # convert tibble to data frame


## create the second independent tidy data set containing both the mean vector 
## and the mean magnitude measurements

## add a direction column to the tidy data set for the mean magnitude 
## measurements
mag_ind_tidy_data_set$direction <- "-"
## join the tidy data sets for the mean vector measurements and the mean
## magnitude measurements
join_col <- c("subject", "activity", "domain", "type", "direction")
ind_tidy_data_set <- full_join(vec_ind_tidy_data_set, mag_ind_tidy_data_set,
                               by = join_col)
## replace the NAs in the data frame with "-"
## the list for replacing NAs with
replace_list <- list(subject = "-", activity = "-", domain = "-", type = "-",
                     direction = "-", BodyAcc = "-", BodyAccJerk = "-",
                     BodyGyro = "-", BodyGyroJerk = "-", GravityAcc = "-",
                     BodyAccJerkMag = "-", BodyAccMag = "-", 
                     BodyBodyAccJerkMag = "-", BodyBodyGyroJerkMag = "-", 
                     BodyBodyGyroMag = "-", BodyGyroJerkMag = "-", 
                     BodyGyroMag = "-", GravityAccMag = "-")
ind_tidy_data_set <- replace_na(ind_tidy_data_set, replace_list)


## write the resulting data set to the disc
write.table(ind_tidy_data_set, "ind_tidy_data_set.txt", row.names = FALSE)
