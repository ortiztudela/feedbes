# Repeated measures ANOVA
library(tidyverse)
library(ggpubr)
library(rstatix)
library(lme4)
# Where is the data and where do you want to generate the output?
main_dir <- "/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES"
data_dir <- paste(main_dir, "/outputs/group_level/RSA/", sep="")
out_dir <- data_dir

# Read in data in short format
data <- read.csv2(paste(data_dir, "obj_specific_episodic.csv", sep=""), sep=",", header=TRUE,stringsAsFactors=FALSE)
data <- data.frame(data.matrix(data))
data_sem <- read.csv2(paste(data_dir, "obj_specific_semantic.csv", sep=""), sep=",", header=TRUE,stringsAsFactors=FALSE)
data <- data.frame(data.matrix(data))

data <- rbind(data, data_sem)
data$episem <- c(rep(1,29), rep(2,29))

# Re-code id and convert into factor variables
colnames(data)[1] <- "id"
data$id <- as.factor(data$id)

# Arrange columns into long format
long_data <- gather(data=data, key="ROI", value="values", c(v1_periph:v2_fov, LOC_neurosynth))
long_data$values <- as.numeric(long_data$values)
# Summary 
long_data %>%
group_by(ROI) %>%
  get_summary_stats(values, type = "mean_sd")

# Visualize
bxp <- ggboxplot(long_data, x = "ROI", y = "values", add = "point", 
                 fill = "ROI", palette = c("#FC4E0750", "#00AFBB50","#FC4E0750","#00AFBB50","#FC4E0750", "#00AFBB50","#FC4E0750","#00AFBB50"),
                 facet.by = "episem")
bxp

# Outliers
long_data %>%
  group_by(id) %>%
  identify_outliers(values)
# Normality
long_data %>%
  group_by(ROI) %>%
  shapiro_test(values)
ggqqplot(long_data, "values", facet.by = "ROI")

# Run anova
t <- subset(long_data, select = c("id", "values", "episem", "ROI"))
res.aov <- anova_test(data = t, dv = values, wid = id, within = c(episem, ROI))
get_anova_table(res.aov)

# Run pair-wise comparisons 
my_comparisons <- list( c("v1_periph", "v1_fov"), c("v2_periph", "v2_fov"))
compare_means(values ~ ROI, long_data, group.by = "episem", paired=T, p.adjust.method = "bonferroni", method="wilcox.test")
# The next bit is to get the Z score out of the wilcoxon test
a <- wilcox.test(long_data$values[long_data$episem==1 & long_data$ROI=="v1_periph"],long_data$values[long_data$episem==1 & long_data$ROI=="v1_fov"], paired=T)
qnorm(a$p.value/2)
a <- wilcox.test(long_data$values[long_data$episem==1 & long_data$ROI=="v2_periph"],long_data$values[long_data$episem==1 & long_data$ROI=="v2_fov"], paired=T)
qnorm(a$p.value/2)
a <- wilcox.test(long_data$values[long_data$episem==2 & long_data$ROI=="v1_periph"],long_data$values[long_data$episem==2 & long_data$ROI=="v1_fov"], paired=T)
qnorm(a$p.value/2)
a <- wilcox.test(long_data$values[long_data$episem==2 & long_data$ROI=="v2_periph"],long_data$values[long_data$episem==2 & long_data$ROI=="v2_fov"], paired=T)
qnorm(a$p.value/2)

# And this is to update the plot
my_comparisons <- list( c("v1_periph", "v1_fov"), c("v2_periph", "v2_fov"), c("LOC_neurosynth", "v1_fov"), c("LOC_neurosynth", "v2_fov"))
bxp + stat_compare_means(method="wilcox", paired=T, ref.group = "v1_periph", hide.ns = T, label = "p.signif", comparisons = my_comparisons)

# Pair-wise comparsions
pwc <- long_data %>%
  pairwise_t_test(
    values ~ ROI, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
pwc

# Visualization: box plots with p-values
pwc <- pwc %>% add_xy_position(x = "ROI")
bxp + 
  stat_pvalue_manual(pwc,hide.ns = TRUE) +
  labs(
    subtitle = get_test_label(res.aov, detailed = TRUE),
    caption = get_pwc_label(pwc)
  )

## Non parametric
#kruskal.test(values ~ ROI, data = long_data)
#pairwise.wilcox.test(long_data$values, long_data$ROI,
#                     p.adjust.method = "bonf", exact=F)
