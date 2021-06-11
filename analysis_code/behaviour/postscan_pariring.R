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
full_data <- read.csv2(paste(data_dir, "postscan_pairing.csv", sep=""), sep=",", header=F,stringsAsFactors=FALSE)

# Re-code ID
colnames(full_data)[1] <- "id"
colnames(full_data)[2] <- "episem"
colnames(full_data)[3] <- "acc"

# Remove empty subjects
missing_subs <- full_data$acc==0
full_data <- full_data[!missing_subs,]
bad_subs <- c(12,16)
full_data <- full_data[full_data$id!=bad_subs[1],]
full_data <- full_data[full_data$id!=bad_subs[2],]
# Convert id and time into factor variables
full_data$id <- as.factor(full_data$id)

# Arrange columns into long format
long_data <- full_data
#long_data <- gather(data=learn, key="Cycles", value="acc", c1:c5)
long_data$acc <- as.numeric(long_data$acc)
long_plot <- gather(data=full_data, key="episem", value="acc", acc)
long_plot$acc <- as.numeric(long_plot$acc)

# Run anova
res.aov <- anova_test(data = long_data, dv = acc, wid = id, within = episem)
get_anova_table(res.aov)

# Pair-wise comparsions
pwc <- long_data %>%
  pairwise_t_test(
    acc ~ episem, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
pwc

# Visualize
long_data$episem <- as.factor(long_data$episem)
bxp <- ggplot(long_data, aes(x=episem, y=acc, color=episem)) + 
  geom_violin() + stat_summary(fun=median, geom="point", size=2, color="red")+scale_color_brewer(palette="Dark2")+
  theme(legend.position="none") + ylim(0, 1)
bxp

# open a file for ploting
figure_name=paste(out_dir, "postscan_pairing.png", sep="")
png(figure_name, width = 1000, height = 1000)

bxp +
   labs(y="Accuracy", x="memory condition") + 
  theme(plot.subtitle=element_text(size=25, face="italic", color="black"))+
  theme(axis.text = element_text(size=20)) +
  theme(axis.title = element_text(size=20))

dev.off() #close file


## Non parametric
kruskal.test(acc ~ Cycles, data = long_data)
pairwise.wilcox.test(long_data$acc, long_data$Cycles,
                     p.adjust.method = "bonf", exact=F)
