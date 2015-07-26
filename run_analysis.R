# assignment script
if(!require(LaF, quietly = TRUE)) {
        useLaF <- FALSE
} else {
        useLaF <- TRUE
}
require(data.table)
require(dplyr)
require(tidyr)
#TODO: - download and extract the source data - possibly with check to see whether it already exists

# first 
# read in the files we're interested in
# labels
actLabels <- fread('UCI HAR Dataset/activity_labels.txt',data.table = FALSE)
featLabels <- fread('UCI HAR Dataset/features.txt',data.table = FALSE)

# row labels for row labels (subject & activity)
subjecttrain <- fread('UCI HAR Dataset/train/subject_train.txt',data.table = FALSE)
subjecttest <- fread('UCI HAR Dataset/test/subject_test.txt',data.table = FALSE)
ytrain <- fread('UCI HAR Dataset/train/y_train.txt',data.table = FALSE)
ytest <- fread('UCI HAR Dataset/test/y_test.txt',data.table = FALSE)
# convert single column dataframes to factors
subjecttest <- factor(subjecttest$V1,levels=1:30,labels=paste0('subject',1:30))
subjecttrain <- factor(subjecttrain$V1,levels=1:30,labels=paste0('subject',1:30))


# determine which features/columns we're interested in
if(useLaF == TRUE) {
        widths <- rep(16, 561)
        col.types <- rep('string',561)
        col.names <- gsub('(m|s)(ean|td)','\\U\\1\\E\\2',
                          gsub('([-()])','',featLabels[[2]]),perl=T)
        whichCols <- grep('(mean|std)\\(',featLabels[[2]])
        laftest <- laf_open_fwf('UCI HAR Dataset/test/X_test.txt', col.types,
                                widths, col.names)
        laftrain <- laf_open_fwf('UCI HAR Dataset/train/X_train.txt', col.types,
                                widths, col.names)
        testdf <- laftest[,whichCols]
        traindf <- laftrain[,whichCols]
        testdf <- as.data.frame(lapply(testdf,as.numeric))
        traindf <- as.data.frame(lapply(traindf,as.numeric))
} else { # LaF package is unavailable - do things the slow way
        widths <- ifelse(grepl('(mean|std)\\(',featLabels[[2]]),16,-16)
        col.names <- grep('(mean|std)\\(',featLabels[[2]],value = TRUE)
        col.names <- gsub('(m|s)(ean|td)','\\U\\1\\E\\2',
                          gsub('([-()])','',col.names),perl=T)
        testdf <- read.fwf('UCI HAR Dataset/test/X_test.txt', widths,
                             col.names = col.names, buffersize = 100,
                             colClasses = 'numeric')
        traindf <- read.fwf('UCI HAR Dataset/train/X_train.txt', widths,
                              col.names = col.names, buffersize = 100,
                              colClasses = 'numeric')
}
# convert data.frame to data.table
testdt <- data.table(testdf)
traindt <- data.table(traindf)

# remove unneeded data.frames
rm(testdf)
rm(traindf)

# add columns for subject and activity
testdt$subject <- subjecttest
testdt$activity <- ytest$V1
traindt$subject <- subjecttrain
traindt$activity <- ytrain$V1

# rbind both sets together
fulldt <- rbind(testdt,traindt)




