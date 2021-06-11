# Repeated measures ANOVA
library(tidyverse)
library(ggpubr)
library(rstatix)
library(gridExtra)
# Where is the data and where do you want to generate the output?
if(Sys.info()['sysname'] == "Linux"){
  main_dir <- "/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES"
  data_dir <- paste(main_dir, "/outputs/group_level/behaviour/", sep="")
  out_dir <- paste(main_dir, "/figures/group_level/behaviour/", sep="")
  
}else {
  main_dir 
  data_dir 
  out_dir 
  scripts_dir 
}

# Read in data in short format
full_data <- read.csv2(paste(data_dir, "vivid_task.csv", sep=""), sep=",", header=F,stringsAsFactors=FALSE)

# Re-code ID
colnames(full_data)[1] <- "id"
colnames(full_data)[2] <- "score"

# Remove empty subjects
missing_subs <- full_data$score==0
full_data <- full_data[!missing_subs,]

# Convert id and time into factor variables
full_data$id <- as.factor(full_data$id)
full_data$score <- as.numeric(full_data$score)

# Arrange columns into long format
long_data <- full_data


# Visualize
bxp <- ggplot(full_data, aes(x=1, y=score)) + 
  geom_violin() + stat_summary(fun=median, geom="point", size=2, color="red")+scale_color_brewer(palette="Dark2")+
  theme(legend.position="none")
bxp

# open a file for ploting
figure_name=paste(out_dir, "vivid_task.png", sep="")
png(figure_name, width = 1000, height = 1000)

# Visualization: box plots with p-values
bxp + 
  labs(y="Score", x="") + theme(plot.subtitle=element_text(size=25, face="italic", color="black")) +
  theme(axis.text = element_text(size=20)) + theme(axis.text.x = element_blank())+
  theme(axis.title = element_text(size=20)) + ylim(0, 4)
dev.off() #close file


## Non parametric
kruskal.test(acc ~ Cycles, data = long_data)
pairwise.wilcox.test(long_data$acc, long_data$Cycles,
                     p.adjust.method = "bonf", exact=F)

