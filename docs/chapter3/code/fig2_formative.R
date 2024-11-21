#Code for the article Kazlou T., Cherp A., Jewell J.
#Feasible deployment of carbon capture and storage and the requirements of climate targets

#Producing a feasibility space for CCS deployment in the formative phase (replication of Figure 2)
#Working directory should be set to the directory containing input files
#Necessary packages (should be installed)

library(tidyverse)
library(deSolve)
library(readxl)
library(ggrepel)
library(patchwork)
`%nin%` = Negate(`%in%`)

####Panel A####
#Preparing a "project pipeline" dataframe containing operational and planned projects for every year - from projects database 
data <- read.csv("CCS_Projects_database.csv") #set the path to the source file "CCS_Projects_database.csv"
ipcc <- read.csv("CCS_data.csv") #set the path to "CCS_data.csv"

# Function to filter project data by year and status to create a 'pipeline of projects' in each year
pipeline_by_year <- function(data, year) {
  filtered_data <- data %>% 
    filter((Status %in% c("Completed","Not finished","Active") & FacilityStart <= year & (FacilityEnd >= year | is.na(FacilityEnd))) |
             (Status %in% c("Not started","Completed","Not finished", "Active") & ProjectStart <= year & ActualProjectEnd >= year) |
             (Status == "Future" & ProjectStart <= year))
  filtered_data$actyear <- year
  return(filtered_data)
}
# Loop through years and filter project data
years_all <- data.frame(matrix(ncol = 26, nrow = 0))  # Initialize empty dataframe
colnames(years_all) <- colnames(data)

for (year in 2002:2022) {
  year_data <- pipeline_by_year(data, year)
  years_all <- rbind(years_all, year_data)
}

# Now we add a new column to represent the status of the project in a given year
years_all <- years_all %>% 
  mutate(status_year = 
           ifelse(Status %in% c("Completed", "Not finished", "Active") & FacilityStart <= actyear & (FacilityEnd >= actyear | is.na(FacilityEnd)), "Operational", "In Development")) %>% 

# Now we need to establish proposed and actual capture rates during announcement and operation
# and put them in the same column so we can visualize it later on
# We create a column that, in a year when project is in "in development" stage, shows the proposed
# capture, and once it starts operating - shows the actual capture (in Mt/yr)
  
  mutate(mtpa = ifelse(status_year == "Operational", ActualCapacity, AnnouncedCapacity))

#final dataset
h2 <- years_all %>%  subset(., !is.na(Sector) & !is.na(mtpa)) %>%
  group_by(Sector, status_year, actyear) %>% summarise(mtpa=sum(mtpa)) %>% mutate(mtpa = mtpa*365/1000000000)

#Plotting
panelA <- ggplot(h2, aes(actyear,  mtpa, fill = Sector))+ 
  geom_bar(data = subset(h2, status_year != "Operational"), aes(x = actyear+0.35+0.01, y =  mtpa, 
              fill = factor(Sector, levels=c("NGP","Industry: Process",  "Fossil Industry", "Fossil Electricity", "BECCS Electricity", "BECCS Industry",  "DACCS"))),  
           stat = "identity",  inherit.aes = FALSE, width = 0.35, alpha =.7)+
  geom_bar(data = subset(h2, status_year == "Operational"), aes(x = actyear, y =  mtpa, 
              fill = factor(Sector, levels=c("NGP","Industry: Process",  "Fossil Industry", "Fossil Electricity", "BECCS Electricity", "BECCS Industry",  "DACCS"))), 
           stat = "identity",  inherit.aes = FALSE, width = 0.35, color = "black", size =0.2)+
  scale_fill_brewer(palette = "Set2")+
  labs(title = "", x = "", y = "Operational capacity and planned additions, Gt/yr", alpha = "")+
  xlim(2001.8,2022.6)+
  theme_bw(base_size = 7)+
  theme(panel.grid.minor.x = element_blank(), legend.title = element_blank(), legend.position = "bottom", legend.text=element_text(size=7), panel.grid.major.y = element_blank())+
  scale_y_continuous(limits = c(0,0.3), breaks = seq(0.1,0.2,0.1), expand = c(0,0))
####Panel B####
#Checking the IQR range of CCS capacity in 2030 in the IPCC AR6 scenario ensemble
iqr_ipcc <- ipcc %>% 
  filter(temp %in% c("1.5°C", "2.0°C") & Year == 2030) %>% 
  group_by(model_scenario, Year, temp) %>% summarise(Value = sum(Value)) %>% group_by(temp, Year) %>% 
  summarise(m = median(Value)/1000, q1 = quantile(Value/1000, probs = 0.25), q3 = quantile(Value/1000, probs = 0.75))

projection <- data.frame(label = c("operational (2022)", "current plans", "current plans", "45% failure (nuclear)", "45% failure (nuclear)", "76% failure (subsector-adjusted)", 
                                   "76% failure (subsector-adjusted)", "88% failure (historical)", "88% failure (historical)", "1.5°C pathways", "2.0°C pathways"),
                         group = c("current", "planned", "current", "planned", "current", "planned", "current", "planned", "current", "scenario", "scenario"),
                         y = c(0.035, 0.3, 0.035, 0.165, 0.035, 0.072, 0.035, 0.036, 0.035, 0.85, 0.26),
                         rate = c(1, 0.15, 1, 0.25,1, 0.45,1, 0.75,1, 1, 1)) %>% 
  mutate(iqr_q1 = ifelse(label == "1.5°C pathways", 0.38, ifelse(label == "2.0°C pathways", 0.04, NA)), 
         iqr_q3 =ifelse(label == "1.5°C pathways", 1.534, ifelse(label == "2.0°C pathways", 0.623, NA)))
references <- c("operational (2022)", "current plans", "88% failure (historical)", "76% failure (subsector-adjusted)", "45% failure (nuclear)", "2.0°C pathways", "1.5°C pathways") 

panelB <- ggplot(projection)+ 
  geom_bar(aes(x=label, y = y, alpha = rate, fill = factor(group, levels = c("planned", "current"))), width = 0.35,  stat = "identity")+
  geom_bar(data=subset(projection, group == "scenario"), aes(x=label, y = y, color = label), stat = "identity",  width = 0.35, fill = "white", size = 0.3)+
  geom_errorbar(data=subset(projection, group == "scenario"), aes(x=label, ymin=iqr_q1, ymax=iqr_q3, color = label), width = 0.15, size = 0.3)+
  scale_fill_manual(values = c("planned" = "darkgrey", "current" = "black"))+
  scale_colour_manual("Operational capacity in 2030", values = c("1.5°C pathways" = "#a6cee3", "2.0°C pathways" = "#7fc97f"))+
  guides(color = "none", alpha = "none", fill = "none")+
  labs(x = "", y = "Operational capacity by 2030, Gt/yr", alpha = "")+
  scale_x_discrete(limits = references, expand = c(0.3,0))+
  theme_bw(base_size = 7)+
  theme(panel.grid.minor.x = element_blank(), legend.position = "bottom", legend.text=element_text(size=7),
        axis.title.y = element_blank(), panel.grid.major.y = element_blank())+
  scale_y_continuous(limits = c(0,1.75), breaks = seq(0.25,1.5,0.25), expand = c(0,0))
####Panel C####
#isolines for scenario medians
x <- seq(0,2000, by = 1)
y0 <- 0
f_median15 <- function(x,y,params) list((x*(1-y)-850+35))
d_median15 <- as.data.frame(ode(y0,x,f_median15,parms=NULL)) %>% rename(x = time, y = "1") %>% 
  mutate(y = y*100, x=x/1000) %>% mutate(isoline = "IPCC 1.5°C")
f_median20 <- function(x,y,params) list((x*(1-y)-260+35))
d_median20 <- as.data.frame(ode(y0,x,f_median20,parms=NULL)) %>% rename(x = time, y = "1") %>% 
  mutate(y = y*100, x=x/1000) %>% mutate(isoline = "IPCC 2.0°C")
f_median_iea <- function(x,y,params) list((x*(1-y)-1665+35))
d_median_iea <- as.data.frame(ode(y0,x,f_median_iea,parms=NULL)) %>% rename(x = time, y = "1") %>% 
  mutate(y = y*100, x=x/1000) %>% mutate(isoline = "IEA NZE 2021")
f_median_iea2 <- function(x,y,params) list((x*(1-y)-1024+35))
d_median_iea2 <- as.data.frame(ode(y0,x,f_median_iea2,parms=NULL)) %>% rename(x = time, y = "1") %>% 
  mutate(y = y*100, x=x/1000) %>% mutate(isoline = "IEA NZE 2023")

points <- data.frame(x = c(0.6, 0.6, 0.6, 0.3, 0.3, 0.3), y = c(88, 76, 45, 88, 76, 45))

panelC <- ggplot()+
  geom_point(data = points, aes(x = x, y = y), shape = 4, color = "black", size = 1)+
  geom_line(data = d_median15, aes(x =x, y=y, group = isoline), color = "#a6cee3", linewidth = 0.3)+
  geom_line(data = d_median20, aes(x =x, y=y, group = isoline), color = "#7fc97f", linewidth = 0.3)+
  geom_line(data = d_median_iea, aes(x =x, y=y, group = isoline), color = "coral", linewidth = 0.3)+
  geom_line(data = d_median_iea2, aes(x =x, y=y, group = isoline), color = "coral3", linewidth = 0.3)+
  geom_label_repel(data=subset(d_median15, x == 1.75), aes(x=x, y=y, label=isoline),
                   color="white", fill = "#a6cee3", size = 3, min.segment.length = 0, max.time = 1, max.iter = 1e5, box.padding = 0, segment.color = 'transparent')+
  geom_label_repel(data=subset(d_median20, x == 1.75), aes(x=x, y=y, label=isoline),
                   color="white", fill = "#7fc97f", size = 3, min.segment.length = 0, max.time = 1, max.iter = 1e5, box.padding = 0, segment.color = 'transparent')+
  geom_label_repel(data=subset(d_median_iea, x == 1.75), aes(x=x, y=y, label=isoline),
                   color="white", fill = "coral", size = 3, min.segment.length = 0, max.time = 1, max.iter = 1e5, box.padding = 0, segment.color = 'transparent')+
  geom_label_repel(data=subset(d_median_iea2, x == 1.75), aes(x=x, y=y-3, label=isoline),
                   color="white", fill = "coral3", size = 3, min.segment.length = 0, max.time = 1, max.iter = 1e5, box.padding = 0, segment.color = 'transparent')+
  scale_x_continuous("Planned capacity by 2025, Gt/yr", limits = c(0.25,1.75), breaks = seq(0.25,1.5,0.25), expand = c(0,0)) +
  scale_y_reverse("Failure rate of planned projects, %", breaks = seq(90,10,-10), expand = c(0,0)) +
  coord_flip(ylim = c(100,0))+
  labs(title = "Feasibility space of operational CCS capacity in 2030")+
  theme_bw(base_size = 7)+
  theme(panel.grid = element_blank())
####Figure 2 - compiling the panels####
design <-
  "
AB
CC
"

figure2 <- (panelA & theme_bw(base_size = 7) & theme(plot.title =element_blank(), axis.title.x = element_blank(), axis.ticks.y=element_blank(), panel.grid.minor.y = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank(),
                                                   legend.direction = "horizontal", legend.box = "vertical", legend.position = "bottom", legend.title = element_blank(), legend.key.size = unit(0.3, "cm"))) + 
  (panelB & theme_bw(base_size = 7) & theme(plot.title=element_blank(),axis.ticks.x=element_blank(), panel.grid.minor.y = element_blank(), axis.text.x=element_text(angle = -51, hjust = 0, size = 5),
                                            axis.ticks.y=element_blank(), axis.title.x = element_blank(), panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank()))+
  (panelC & theme_bw(base_size = 7) & theme(plot.title=element_blank(),axis.ticks.x=element_blank(),  axis.ticks.y=element_blank(), panel.grid = element_blank()))+
  plot_annotation(tag_levels = 'A') +
  plot_layout(design = design, widths=c(4.8,2.2), heights=c(5,7)) 

ggsave("figure2.png", path = "./", dpi = 500, width = 130, height = 204, units = "mm")

#saves a PNG file of Figure 2 in the working directory (geom_line warning messages are to be expected)


