# in addition to counting the number of forms each month,
# this graph also displays the forms where the minimum standard dataset 
# is not available 

# read in the data
mdata <- read.table("h://mbg_db_reporting//reports//20150401_fes_counts_by_mtg_month_csv.csv",
  header=TRUE, sep=",")

# remove obs from year past 2015
mdata <-mdata[mdata$SubYear<=2015,]   

library(psych)
describe(mdata$SubYear)
## finding max value within a county for how many forms
## within the time window

### find the result using tapply
maxofrowsCompl<-tapply(mdata$NumComplete, mdata$COUNTY_ID, max)
maxofrowsInc<-tapply(mdata$NumIncomplete, mdata$COUNTY_ID, max)

### put result into data frame
### with first column as county id
maxofrows2<-data.frame("COUNTY_ID"=names(maxofrowsCompl), maxofrowsCompl)
maxofrows3<-data.frame("COUNTY_ID"=names(maxofrowsInc), maxofrowsInc)


describe(maxofrows2)
describe(maxofrows3)




# create a vector for the values of the labels
# will omit the value, if the value is zero
# will omit the value, if the value is the same as the value in 
mdata$SurvIncomplete[mdata$SurvIncomplete==0] <-NA
mdata$FLIncomplete[mdata$FLIncomplete==0] <-NA
mdata$BLIncomplete[mdata$BLIncomplete==0] <-NA
mdata$FFSIncomplete[mdata$FFSIncomplete==0] <-NA
head(mdata)

### merge info about max per county 
### back with the rest of the dataset
mdata2<-merge(mdata, maxofrows2, by="COUNTY_ID")
mdata3<-merge(mdata2, maxofrows3, by="COUNTY_ID")

## look over some rows
head(mdata3)

# if value is the same between the number of non-nine-digit MCI
# and the number of non-min-standard-dataset forms
# it doesn't need to be printed twice
mdata3$sameMCInonstd <- (mdata3$FFSIncomplete==mdata3$BLIncomplete & 
	mdata3$BLIncomplete==mdata3$FLIncomplete &
	mdata3$FLIncomplete==mdata3$SurvIncomplete)
## don't seem to have any values where the values are the same 
## across the four different counts of forms
describe(mdata3$sameMCInonstd)
head(mdata3$sameMCInonstd)
tail(mdata3$sameMCInonstd)

### closeness of obs from Complete and Incomplete
### create a new column for where the numbers are too close columns will go
mdata3$numstooclose<-NA
mdata3$diffbetComplandInc<-abs(mdata3$NumComplete-mdata3$NumIncomplete)

### generate percentage of how much the difference between the values is 
### relative to the range of the graph
index<- (!is.na(mdata3$diffbetComplandInc) & !is.na(mdata3$maxofrowsCompl))
mdata3$pctdiffbetComplandInc[index]<-(mdata3$diffbetComplandInc[index]/mdata3$maxofrowsCompl[index])
index<-NULL

index <- mdata3$pctdiffbetComplandInc<.50
mdata3$numstooclose[index]<-mdata3$NumComplete[index]
index<-NULL

# describe the dataset
library(psych)
describe(mdata3)
# all vars are being stored as numbers

# trying to get the graph using reshape . melt
## max of rows will be same within a county 
## should not add any rows to the table
library(reshape2)
mydata<- melt(mdata3, id=c("COUNTY_ID", "SubYear", "SubMonth", 
	"maxofrowsCompl", "maxofrowsInc", "sameMCInonstd",
	"diffbetComplandInc", "pctdiffbetComplandInc"))
head(mydata)
tail(mydata)


# load lattice library 
library(lattice)

  
#use zoo package to convert year and month into a date 
#load(zoo)
library(zoo)
mydata$yrmo <- as.yearmon(paste(mydata$SubYear, mydata$SubMonth, sep="-")) 

### county name for Allegheny is 02 in FES dataset
### will not be able to use factor to add county name 
mydata$fancyname[mydata$COUNTY_ID=="02"]<- "Allegheny"
mydata$fancyname[mydata$COUNTY_ID==20]<- "Crawford"
mydata$fancyname[mydata$COUNTY_ID==22]<- "Dauphin"
mydata$fancyname[mydata$COUNTY_ID==35]<- "Lackawanna"
mydata$fancyname[mydata$COUNTY_ID==51]<- "Philadelphia"
mydata$fancyname[mydata$COUNTY_ID==61]<- "Venango"

# add factors for county names
#mydata$COUNTY_ID<-factor(mydata$COUNTY_ID,
# levels = c(02, 20, 22, 35, 51, 61),
# labels = c("Allegheny","Crawford","Dauphin","Lackawanna","Philadelphia","Venango"))


# create a date that is in word rather than in decimal format
mydata$timelabels<-as.Date(mydata$yrmo)
mydata$timelabels
describe(mydata$timelabels)

# have labels for Number of Forms be above the point
# have labels for Number of Problematic Forms be below the point
# create a vector 
mydata$pos_vector <- NA
##mydata$pos_vector <- rep(NA, length(mydata$yearmon))
mydata$pos_vector[mydata$variable=="NumComplete"] <- 3
mydata$pos_vector[mydata$variable=="numstooclose"] <- 3
mydata$pos_vector[mydata$variable=="NumIncomplete"] <- 1

# change value to "below point" for problematic forms
mydata$pos_vector[mydata$variable %in% c("FFSIncomplete", "BLIncomplete", 
	"FLIncomplete", "SurvIncomplete", "diffbetComplandInc", "pctdiffbetComplandInc" )] <- 1
## FFSIncomplete,BLIncomplete,FLIncomplete,SurvIncomplete

mydata$pos_vector
#### if there are values for the num of records that are non-min-std,
#### put the y-value of those records' label at -(max)
#### helps stretch out the range of the data,
#### so that the lines will not overlap each other





# create a vector for the values of the labels
# will put the value at -.5(max) on the y-axis, if the value is for non-nine digit MCI 
# will put the value at -(max) on the y-axis,  for non-min std dataset values
# will omit the value, if the value is the same as the value in 

# will use the ASQ (rather than SE) value as the multiplier,
# as ASQ values are usually of higher magnitude
mydata$ylabel_vector <- mydata$value

index<- mydata$variable=="FFSIncomplete"
mydata$ylabel_vector[index] <- (-.5)*mydata$maxofrowsCompl[index]
index<-NULL

index<- mydata$variable=="BLIncomplete"
mydata$ylabel_vector[index]<- (-1)*mydata$maxofrowsCompl[index]
index<-NULL

index<- mydata$variable=="FLIncomplete"
mydata$ylabel_vector[index] <- (-1.5)*mydata$maxofrowsCompl[index]
index<-NULL

index<- mydata$variable=="SurvIncomplete"
mydata$ylabel_vector[index] <- (-2)*mydata$maxofrowsCompl[index]
index<-NULL

### for the points along the top for the max
### for when values are too close
index<- mydata$variable=="numstooclose"
mydata$ylabel_vector[index] <- (1)*mydata$maxofrowsCompl[index]
index<-NULL


# version of command
# if value for number of records of that type is NA
# will also set location to NA
mydata <-within(mydata, 
	ylabel_vector <-ifelse(is.na(mydata$value), NA, ylabel_vector)
		)

## if scale is going to be drawn at the max amount,
## want to remove the label at the line 
mydata$value[mydata$pctdiffbetComplandInc<.50 & mydata$variable =="NumComplete"]<-""

## if the value for the Num Incomplete is zero,
## the number doesn't need to be in the graph
mydata$value[mydata$value=0 & mydata$variable =="NumIncomplete"]<-""
		
## make y-position farther away from zero for the ASQ values
## trying to make graph more readable
## in the baseline version, did a multiply by 2
## in the second version, added twenty and then multiplied by 2
#mydata$ylabel_vector[mydata$variable=="NumFormsASQ"] <- (mydata$value+20)*2
## want this command to come before the command adding the equals sign

## change value to "=" if nonMCI is same as nonminstd
mydata$value[mydata$sameMCInonstd & mydata$variable =="FFSIncomplete"]<-"="
mydata$value[mydata$sameMCInonstd & mydata$variable =="BLIncomplete"]<-"="
mydata$value[mydata$sameMCInonstd & mydata$variable =="FLIncomplete"]<-"="
mydata$value[mydata$sameMCInonstd & mydata$variable =="SurvIncomplete"]<-"="


describe(mydata$ylabel_vector)
head(mydata$ylabel_vector)
tail(mydata$ylabel_vector, n=20)


# set colors for points
## have the number of forms written out in different colors
mydata$pointcolor <- NA
mydata$pointcolor[mydata$variable=="NumComplete"] <-"black"
mydata$pointcolor[mydata$variable =="numstooclose"] <-"black"
mydata$pointcolor[mydata$variable=="NumIncomplete"] <-"burlywood4"
mydata$pointcolor[mydata$variable=="FFSIncomplete"] <-"red"
mydata$pointcolor[mydata$variable=="BLIncomplete"] <-"darkorchid1"
mydata$pointcolor[mydata$variable=="FLIncomplete"] <-"coral"
mydata$pointcolor[mydata$variable=="SurvIncomplete"] <-"chartreuse4"
head(mydata$pointcolor)
tail(mydata$pointcolor)
####c("black", "burlywood4", "red", purple, orange-red, green)


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
# with all the counties on same graph
xyplot(mydata$value ~ mydata$yrmo)
# each county on own graph
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID) )

# allow each county to have own scale 
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),scales=list(relation="free"))

# connect the points of each line 
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),scales=list(relation="free"), 
 type="b")

# in a column of six graphs
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),scales=list(relation="free"), 
 type="b",  layout = c(1,6))
 
# label x-axis and y-axis
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),scales=list(relation="free"), 
 type="b",  layout = c(1,6), xlab="Month", ylab="Num. of Forms")
 
# label x-axis and y-axis, with order of counties in alphabetical order
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),scales=list(relation="free"), 
 type="b",  layout = c(1,6), xlab="Month", ylab="Num. of Forms", index.cond=list(c(6, 5, 4, 3, 2, 1)))

 # break data into groups within the panels 
 # the new part #
xyplot(mydata$value ~ mydata$yrmo |factor(mydata$COUNTY_ID),
	groups=factor(mydata$variable), 
	scales=list(relation="free"), 
 type="l",   xlab="Month", ylab="Num. of Forms")


 ##saves file as pdf
pdf(file="h://mbg_db_reporting//reports//20150413_FESbymo_with_issue_records.pdf", paper="letter", height = 10) 
# with the x-axis now uniform across the counties			
# removed the symbols for each point
# do not draw y-axis ticks



xyplot(mydata$ylabel_vector ~ mydata$timelabels |factor(mydata$fancyname),
page=function(n){ add.footnote()},
	groups=factor(mydata$variable), 
   prepanel = function(x, y, subscripts) { 
         list(ylim=extendrange(mydata$ylabel_vector[subscripts], f=.25)) 

       }, 
	   
	   		 labels=mydata$value,
			 key=list( title="Number of", x = .7, y =1, corner = c(0, 0),
			 				text=list(labels=c("Complete Packets", "Incomplete Packets", "FFS Unmatched", "BL Unmatched", "Follow-Up Unmatched", "Surveys Unmatched")),
			lines=list(col=c("black", "burlywood4", "red", "darkorchid1", "coral", "chartreuse4"),
				type=c("p", "p", "p", "p", "p", "p")
				),
			border=TRUE,
			 cex=0.5
			 ),
scales=list(
            y=list(relation="free", draw=FALSE )), 
 type="l",  layout = c(1,6), xlab="Month", 
	ylab="Number of Meetings or Case Closures Occurring That Month",
 pch=NA_integer_,
 lty=c(1, 1, 0, 0, 0, 0, 0), 
 main="Number of Fam. Eng. Meetings \nby County and Month",
 sub="Data pulled on 2015/04/01",
 index.cond=list(c(6, 5, 4, 3, 2, 1)),
 panel= panel.superpose,
  panel.groups=function(x, y, ..., subscripts) {
               panel.xyplot(x, y, ..., subscripts=subscripts );
               panel.text(mydata$timelabels[subscripts], mydata$ylabel_vector[subscripts], labels=mydata$value[subscripts],  cex=0.8, 
			   offset=1, 
			   	col=mydata$pointcolor[subscripts],
			   position=mydata$pos_vector[subscripts])

			    panel.axis("left", ticks=FALSE, labels=FALSE)
				
            })
## mtext(date(), side=3, line=4, adj=0) 
## y-value for problematic forms is not getting extended far enough
## for the latter counties


dev.off()
			


 			
			
# trying to draw using plot			
plot(mydata$value , mydata$yrmo 			, type="l")

plot( mydata$yrmo, mydata$value 			, type="l")

# trying to draw using ggplot
library(ggplot2)
p=ggplot( mydata, aes(x=yrmo, y=value)) + geom_line() +
    ggtitle("Growth curve for individual chicks")

	

library(xts) # Will also load zoo
mydata$datxts <- xts(mydata[-1], 
               order.by = as.yearmon(paste(mydata$SubYear, mydata$SubMonth, sep="-")) 
			   

			   
			   
			   
