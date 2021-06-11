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
full_data <- read.csv2(paste(data_dir, "obj_pairing.csv", sep=""), sep=",", header=F,stringsAsFactors=FALSE)
data_sem <- data.frame(data.matrix(full_data))

# Re-code ID
colnames(full_data)[1] <- "id"
colnames(full_data)[2] <- "c1"
colnames(full_data)[3] <- "c2"
colnames(full_data)[4] <- "c3"
colnames(full_data)[5] <- "c4"
colnames(full_data)[6] <- "c5"
colnames(full_data)[7] <- "Final"

# Remove empty subjects
missing_subs <- full_data$Final==0
full_data <- full_data[!missing_subs,]

# Convert id and time into factor variables
full_data$id <- as.factor(full_data$id)

# Arrange columns into long format
learn <- full_data[,1:6]
long_data <- gather(data=learn, key="Cycles", value="acc", c1:c5)
long_data$acc <- as.numeric(long_data$acc)
long_plot <- gather(data=full_data, key="Cycles", value="acc", c1:Final)
long_plot$acc <- as.numeric(long_plot$acc)

# Run anova
res.aov <- anova_test(data = long_data, dv = acc, wid = id, within = Cycles)
get_anova_table(res.aov)

# Pair-wise comparsions
pwc <- long_data %>%
  pairwise_t_test(
    acc ~ Cycles, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
pwc

# Visualize
bxp <- ggplot(long_plot, aes(x=Cycles, y=acc, color=Cycles)) + 
  geom_violin() + stat_summary(fun=median, geom="point", size=2, color="red")+scale_color_brewer(palette="Dark2")+
  theme(legend.position="none") + geom_vline(xintercept = 5.5,linetype="dashed",size=2)
bxp

# open a file for ploting
figure_name=paste(out_dir, "obj_pairing.png", sep="")
png(figure_name, width = 1000, height = 1000)

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "Cycles")
bxp + 
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc),
    y="Accuracy"
  ) + theme(plot.subtitle=element_text(size=25, face="italic", color="black")) +
  theme(axis.text = element_text(size=20)) +
  theme(axis.title = element_text(size=20))
dev.off() #close file


## Non parametric
kruskal.test(acc ~ Cycles, data = long_data)
pairwise.wilcox.test(long_data$acc, long_data$Cycles,
                     p.adjust.method = "bonf", exact=F)
