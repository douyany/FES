# in addition to counting the number of forms each month,
# this graph also displays the forms where the minimum standard dataset 
# is not available 

# read in the data
mdata <- read.table("h://mbg_db_reporting//reports//20150409_philly_fes_counts.csv",
  header=TRUE, sep=",")

# remove obs from year past 2015
mdata <-mdata[mdata$SubYear<=2015,]   

library(psych)
describe(mdata$SubYear)
## finding max value within a county for how many forms
## within the time window



# trying to get the graph using reshape . melt
## max of rows will be same within a county 
## should not add any rows to the table
library(reshape2)
mydata<- melt(mdata, id=c("COUNTY_ID", "SubYear", "SubMonth"))
head(mydata)
tail(mydata)


# load lattice library 
library(lattice)

  
#use zoo package to convert year and month into a date 
#load(zoo)
library(zoo)
mydata$yrmo <- as.yearmon(paste(mydata$SubYear, mydata$SubMonth, sep="-")) 


# add factors for county names
mydata$COUNTY_ID<-factor(mydata$COUNTY_ID,
 levels = c(02, 20, 22, 35, 51, 61),
 labels = c("Allegheny","Crawford","Dauphin","Lackawanna","Philadelphia","Venango"))

# create labels for what type of number depicted
mydata$fancyname[mydata$variable=="NumComplete"]<-1
mydata$fancyname[mydata$variable=="NumFFS"]<-2
mydata$fancyname[mydata$variable=="TotSurveys"]<-3

# add factors for what type of number depicted
mydata$fancyname<-factor(mydata$fancyname,
 levels = c(1, 2, 3),
 labels = c("Number of Complete Packets",
		"Number of Meetings",
		"Total Number of Surveys"))

 
# create a date that is in word rather than in decimal format
mydata$timelabels<-as.Date(mydata$yrmo)
mydata$timelabels
#describe(mydata$timelabels)

#ylabel_vector--where to put values
mydata$put_vector <- mydata$value+3

### add info for footnote
library(grid)
 add.footnote <- function(string="Note: Graph excludes meetings \nlater than 2015", col="grey",
lineheight=0.7, cex=0.7){
       grid.text(string,
      x=unit(1, "npc") - unit(1, "mm"),
      y=unit(1, "mm"), just=c("right", "bottom"),
      gp=gpar(col=col,lineheight=lineheight, cex=cex))
      }

# setup for no margins on the legend
# bottom margin is the first number in the sequence
# top margin is the third number in the sequence
par(mar=c(5.1, 0, 4.1, 0))

 
####
####
####Various iterations of the graph
#### towards the final version of the graph
####
####

 ##saves file as pdf
pdf(file="h://mbg_db_reporting//reports//20150409_Philly_FES_summary.pdf", paper="letter", height = 10) 
# with the x-axis now uniform across the counties			
# removed the symbols for each point
# do not draw y-axis ticks


xyplot(mydata$value ~ mydata$timelabels |factor(mydata$fancyname),
page=function(n){ add.footnote()},
	groups=factor(mydata$variable), 
   prepanel = function(x, y, subscripts) { 
         list(ylim=extendrange(mydata$put_vector[subscripts], f=.25)) 
       }, 
	   		 labels=mydata$value,
scales=list(
            y=list(relation="free", draw=FALSE )), 
 type="l",  layout = c(1,3), xlab="Month", 
	ylab="Number Occurring That Month",
 pch=NA_integer_,
 lty=c(1, 1, 1), 
 main="Number of Family Engagement Meetings \nby Month",
 sub="Data pulled on 2015/04/09",
 index.cond=list(c(3, 2, 1)),
 panel= panel.superpose,
  panel.groups=function(x, y, ..., subscripts) {
               panel.xyplot(x, y, ..., subscripts=subscripts );
               panel.text(mydata$timelabels[subscripts], mydata$put_vector[subscripts], labels=mydata$value[subscripts], offset=1)
            }
  )

dev.off()
			


 			
			
# trying to draw using plot			
plot(mydata$value , mydata$yrmo 			, type="l")

plot( mydata$yrmo, mydata$value 			, type="l")

