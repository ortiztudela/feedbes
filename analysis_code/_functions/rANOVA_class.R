# Repeated measures ANOVA
library(tidyverse)
library(ggpubr)
library(rstatix)

# Where is the data and where do you want to generate the output?
main_dir <- "/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES"
data_dir <- paste(main_dir, "/outputs/group_level/decoding/eye/", sep="")
out_dir <- data_dir


# Read in data in short format
#data <- read.csv2(paste(data_dir, "objects sem_results.csv", sep=""), sep=",", header=TRUE,stringsAsFactors=FALSE)
#data <- data.frame(data.matrix(data))
data_sem <- read.csv2(paste(data_dir, "diff scn-same obj sem_results.csv", sep=""), sep=",", header=TRUE,stringsAsFactors=FALSE)
data_sem <- data.frame(data.matrix(data_sem))

# Merge with semantic
#data <- rbind(data,data_sem)
#data$episem <- c(rep(1,29), rep(2,29))

# Re-code ID
colnames(data)[1] <- "id"

# Arrange columns into long format
# Convert id and time into factor variables
data$id <- as.factor(data$id)
ROI_labels=colnames(data)
ROI_labels <- ROI_labels[2:12]
long_data <- gather(data=data, key="ROI", value="acc", v1_fov:v2_periph)
#long_data <- unite(long_data, ROI, c(episem, ROI))
#head(data, 3)
#long_data$score <- as.numeric(long_data$score)
# Summary 
long_data %>%
group_by(ROI) %>%
  get_summary_stats(acc, type = "mean_sd")

# Recode brain ROI by VF ROI
long_data$brain_ROI[long_data$ROI=="v1_fov"] <- "v1"
long_data$VF_ROI[long_data$ROI=="v1_fov"] <- "fov"
long_data$brain_ROI[long_data$ROI=="v2_fov"] <- "v2"
long_data$VF_ROI[long_data$ROI=="v2_fov"] <- "fov"
long_data$brain_ROI[long_data$ROI=="v1_periph"] <- "v1"
long_data$VF_ROI[long_data$ROI=="v1_periph"] <- "periph"
long_data$brain_ROI[long_data$ROI=="v2_periph"] <- "v2"
long_data$VF_ROI[long_data$ROI=="v2_periph"] <- "periph"

# Visualize
bxp <- ggboxplot(long_data, x = "VF_ROI", y = "acc", add = "point", color = "brain_ROI",
                 fill = "brain_ROI", palette = c("#FC4E0750", "#00AFBB50"))
bxp

# Outliers
long_data %>%
  group_by(id) %>%
  identify_outliers(acc)
# Normality
long_data %>%
  group_by(ROI) %>%
  shapiro_test(acc)
ggqqplot(long_data, "acc", facet.by = "ROI")

# Run anova
t <- subset(long_data, select = c("id", "acc", "VF_ROI", "brain_ROI"))
res.aov <- anova_test(data = t, dv = acc, wid = id, within = c(VF_ROI,brain_ROI))
get_anova_table(res.aov)

selfesteem2 %>%
  pairwise_t_test(
    score ~ treatment, paired = TRUE, 
    p.adjust.method = "bonferroni"
  )

# Pair-wise comparsions
pwc <- long_data %>%
  pairwise_t_test(
    acc ~ VF_ROI, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
pwc

pwc <- long_data %>%
  pairwise_t_test(
    acc ~ brain_ROI, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
pwc

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "VF_ROI")
bxp + 
  stat_pvalue_manual(pwc,hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )
pwc <- pwc %>% add_xy_position(x = "VF_ROI")
bxp + 
  stat_pvalue_manual(pwc, tip.length = 0, hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )


## Non parametric
kruskal.test(acc ~ ROI, data = long_data)
pairwise.wilcox.test(long_data$acc, long_data$ROI,
                     p.adjust.method = "bonf", exact=F)

# Against chance
res <- wilcox.test(data$v2_fov, y=.5,alternative = "greater", exact=T)
res
