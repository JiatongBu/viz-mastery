# 必要包
library(tidyverse)

# 读取数据
data <- read.csv("C:/Users/c3388/Downloads/CCS_article-main/CCS_Projects_database.csv") # 替换为正确路径

# 定义函数：根据年份和状态过滤项目数据
pipeline_by_year <- function(data, year) {
  filtered_data <- data %>% 
    filter((Status %in% c("Completed", "Not finished", "Active") & FacilityStart <= year & 
              (FacilityEnd >= year | is.na(FacilityEnd))) |
             (Status %in% c("Not started", "Completed", "Not finished", "Active") & ProjectStart <= year & 
                ActualProjectEnd >= year) |
             (Status == "Future" & ProjectStart <= year))
  filtered_data$actyear <- year
  return(filtered_data)
}

# 循环处理：2002-2022年
years_all <- data.frame(matrix(ncol = 26, nrow = 0))  # 初始化空数据框
colnames(years_all) <- colnames(data)

for (year in 2002:2022) {
  year_data <- pipeline_by_year(data, year)
  years_all <- rbind(years_all, year_data)
}

# 增加状态列和碳捕获量列
years_all <- years_all %>% 
  mutate(status_year = 
           ifelse(Status %in% c("Completed", "Not finished", "Active") & FacilityStart <= actyear & 
                    (FacilityEnd >= actyear | is.na(FacilityEnd)), "Operational", "In Development")) %>%
  mutate(mtpa = ifelse(status_year == "Operational", ActualCapacity, AnnouncedCapacity))

# 聚合数据
h2 <- years_all %>% 
  subset(!is.na(Sector) & !is.na(mtpa)) %>%
  group_by(Sector, status_year, actyear) %>% 
  summarise(mtpa = sum(mtpa)) %>% 
  mutate(mtpa = mtpa * 365 / 1000000000)

# 绘制 Panel A
panelA <- ggplot(h2, aes(actyear, mtpa, fill = Sector)) + 
  geom_bar(data = subset(h2, status_year != "Operational"), aes(x = actyear + 0.35, y = mtpa, 
                                                                fill = factor(Sector, levels = c("NGP", "Industry: Process", "Fossil Industry", 
                                                                                                 "Fossil Electricity", "BECCS Electricity", "BECCS Industry", "DACCS"))),  
           stat = "identity", inherit.aes = FALSE, width = 0.35, alpha = .7) +
  geom_bar(data = subset(h2, status_year == "Operational"), aes(x = actyear, y = mtpa, 
                                                                fill = factor(Sector, levels = c("NGP", "Industry: Process", "Fossil Industry", 
                                                                                                 "Fossil Electricity", "BECCS Electricity", "BECCS Industry", "DACCS"))), 
           stat = "identity", inherit.aes = FALSE, width = 0.35, color = "black", size = 0.2) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "", x = "Year", y = "Operational capacity and planned additions, Gt/yr") +
  xlim(2001.8, 2022.6) +
  theme_bw(base_size = 7) +
  theme(panel.grid.minor.x = element_blank(), legend.title = element_blank(), legend.position = "bottom", 
        legend.text = element_text(size = 7), panel.grid.major.y = element_blank()) +
  scale_y_continuous(limits = c(0, 0.3), breaks = seq(0.1, 0.2, 0.1), expand = c(0, 0))

print(panelA)
# 保存图表
ggsave("PanelA.png", plot = panelA, path = "./", dpi = 300, width = 130, height = 80, units = "mm")
