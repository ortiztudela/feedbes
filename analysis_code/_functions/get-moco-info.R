## Get the following info from the shell call
sub_code <- commandArgs()[6]
run_nbr <- commandArgs()[7]

# Path to preproc data
data_dir <- commandArgs()[8]

if(run_nbr < 3){
	ses_nbr <- 1
}else {
	ses_nbr <- 2
}
print("yaya")
##
#install.packages("scales")
library(scales)
# Read in confounds files
conf_data <- read.delim(paste(data_dir, "/func/", sub_code, "_ses-0", ses_nbr, "_task-feedBES_run-",run_nbr,  "_desc-confounds_regressors.tsv", sep=""), sep="\t")

## First ouput moco info as a text file for AROMA
# Select the columns with moco info
moco <- cbind(conf_data$rot_x, conf_data$rot_y, conf_data$rot_z, conf_data$trans_x, conf_data$trans_y, conf_data$trans_z)

# Write moco info to txt file
write.table(moco, col.names=F,row.names=F,
            file=paste(data_dir, "/func/", sub_code, "_ses-0", ses_nbr, "_task-feedBES_run-", run_nbr, "_moco.txt", sep=""))

# Get non linear trends from run files
dummy <- rep(0,4)
n <- (length(conf_data$cosine00)-4)*2
cos1 <- conf_data$cosine00
cos2 <- conf_data$cosine01

# Compute manually
a <- sin(2*pi/n*c(1:n))
a <- a[1:(length(a)/2)]
sin1 <-c(dummy,rescale(a, to=c(min(cos1), max(cos1))))

a <- sin(4*pi/n*c(1:n))
a <- a[1:(length(a)/2)]
sin2 <-c(dummy,rescale(a, to=c(min(cos1), max(cos1))))

a <- cos(8*pi/n*c(1:n))
a <- a[1:(length(a)/2)]
cos3 <-c(dummy,rescale(a, to=c(min(cos1), max(cos1))))
 
a <- sin(8*pi/n*c(1:n))
a <- a[1:(length(a)/2)]
sin3 <-c(dummy,rescale(a, to=c(min(cos1), max(cos1))))

# Plot for inspection
plot(cos1, type="b", col="red")
lines(cos2, type="b", col="green")
lines(sin1, type="b", col="blue")
lines(sin2, type="b", col="black")
# lines(cos3, type="b", col="yellow")
# lines(sin3, type="b", col="pink")

## Now combine different confounds into a single file for SPM
csf <- conf_data$csf
wm <- conf_data$white_matter
global <- conf_data$global_signal
output <- cbind(moco, csf, wm, global, sin1, cos1, sin2, cos2)


## Load eye info as well
eye_data <- read.delim(paste(data_dir, "/../../../../eye_movements_analyses/",sub_code,"/run", run_nbr, "/eyes_mov_data.csv", sep=""), sep=",",  header = F)
output <- cbind(output, eye_data)

# Write output info to txt file
write.table(output, col.names=F,row.names=F,
            file=paste(data_dir, "/func/", sub_code, "_task-feedBES_run-", run_nbr, "_covar.txt", sep=""))
