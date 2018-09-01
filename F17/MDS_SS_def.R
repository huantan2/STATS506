## MDS Comparing MLB Shortstop Defense in 2016
## 
## The data used here was taken from: 
##   www.fangraphs.com 
##   using the 2016 advanced fielding leaderboard
##
## Author: James Henderson (jbhender@umich.edu)
## Date: October 10, 2017

# load libraries
library(dplyr); library(tidyr)
library(gplots); library(ggplot2); library(plotly)

# read in data 
df <- read.csv('./SS_Def_2016.csv',stringsAsFactors = FALSE)

# save composite variables #
def_main <- df[,c('Inn','DRS','UZR','Def')]

# remove unwanted variables #
df[,c('Team','Pos','Inn','rSB','rARM','BIZ',
      'Plays','FSR','UZR.150','OOZ','RZR','playerid',
      'CPP','RPP','TZL','ARM')] <- NULL

# create a data frame without composites
df_single <- df
df_single[,c('DRS','UZR','Def')] <- NULL

# convert to a matrix #
defenseMat <- as.matrix(df[,-1])
rownames(defenseMat) <- df$Name

# metrics have different units, so convert to z-scores #
zScore <- function(x) {x-mean(x)}/sd(x)
defenseZ <- apply(defenseMat, 2, zScore)

# heatmap
cols <- colorRampPalette(c('blue','white','red'))(999)
heatmap.2(defenseZ, col=cols, trace='none', lwid=c(1,3))

# compute pairwise distances
defenseDist <- as.matrix(dist(defenseZ, diag=T, upper=T))

# compute MDS results
# scale by -1 for more natural order
defMDS2 <- -1*cmdscale(defenseDist,2)
#defMDS3 <- -1*cmdscale(defenseDist,3)

## convert coordinates to data frame
dfMDS2 <- cbind(
  data.frame(Player=df$Name, Coord1=defMDS2[,1], Coord2=defMDS2[,2]),
  df)
#dfMDS3 <- cbind(data.frame(Player=df$Name,Coord1=defMDS3[,1],Coord2=defMDS3[,2]),Coord3=defMDS3[,3],df)

# Correlation of Coord1 with original variables #
cor_1 <- data.frame(cor(dfMDS2$Coord1, defenseZ)) %>%
  gather(Metric,Correlation,rGDP:Def)

# Plot correlations
cor_1 %>% 
  arrange(desc(Correlation)) %>%
  mutate(Metric=factor(Metric,Metric)) %>%
  ggplot(aes(x=Metric, y=Correlation)) +
  geom_col() +
  ggtitle('Correlation of 1st MDS coordinate with defensive metrics.')

# Plot Embedding
p1 <- dfMDS2 %>%
  mutate(Coordinate_1=round(Coord1,1), Coordinate_2=round(Coord2, 2)) %>%
  ggplot(aes(x=Coordinate_1, y=Coordinate_2, Name=Player)) +
  geom_point(aes(col=Def))
ggplotly(p1)

# Correlation of Coord2 with orginal variables #
cor_2 <- data.frame(cor(dfMDS2$Coord2,defenseZ)) %>%
  gather(Metric,Correlation,rGDP:Def)

p2 <- dfMDS2 %>%
  mutate(Coordinate_1=round(Coord1,1), Coordinate_2=round(Coord2, 2)) %>%
  ggplot(aes(x=Coordinate_1, y=Coordinate_2, Name=Player)) +
  geom_point(aes(col=DPR, alpha=Def))
ggplotly(p2)

# Bar plot showing correlation with coordinate 2
r2 <- cor(dfMDS2$Coord2,defenseZ)
o <- order(r2)
r2ord <- r2[o]; names(r2ord) <- colnames(r2)[o]
barplot(r2ord, las=1, ylab='Correlation',main='Coordinate 2')

p3 <- dfMDS2 %>% 
  ggplot(aes(x=Coord1,y=Coord2,Name=Player)) + 
  geom_point(aes(col=DPR,size=Def)) + 
  xlab('Overall Defense / Range') + 
  ylab('Double Play Value') + 
  ggtitle('MLB Shortstops, 2016.')
ggplotly(p3)

## 3D plotting ##
#with(dfMDS3,cor(Coord3,defenseZ))
#plot_ly(dfMDS3,x=~Coord1,y=~Coord2,z=~Coord3,color=~DPR,size=~Def) %>% add_markers()

