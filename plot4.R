# read electric power consumption file
#       only need 2007-02-01 through 2007-02-02
#       missing data appears as ? (so na.string="?)
#       don't read strings as factors (Date and Time, we want characters to work wtih)
#
# create graph that will go to png (480 pixel by 480 pixel)
#       name plot as plotX.png where X is plot number (1-4)
#
library(dplyr)
#
#
startdt <- as.POSIXct("2007-02-01")
enddt <- as.POSIXct("2007-02-02 23:59:59")

#
# first read file in
# this is 2,075,259 records with 9 variables = 18,677,331 variables
# at about 8 bytes per that's 149,418,648 or roughly 149M, not a 
# problem on this machine with 8G of RAM.  8 bytes may be low, but
# error margin is wide.
#
filename <- "household_power_consumption.txt"
electric.in <- read.table(filename,header=T,sep=";",na.strings="?",stringsAsFactors=FALSE)
#
# now clean up the date and time variables
# and consolidate them into one date/time variable
electric.in$DateTime <- as.POSIXct(strptime(paste(electric.in$Date, electric.in$Time), "%d/%m/%Y %H:%M:%S"))
#
# let's get in dplyr form to make it easy to work with
#       free up memory by releasing unneeded objects
electric.tbl <- tbl_df(electric.in)
rm(electric.in)
#
# Only keep those within date range we want
electric.in.rng <- electric.tbl %>%
        select(-Date,-Time) %>%
        filter((DateTime >= startdt) & (DateTime < enddt))
#
# release objects we no longer need from memory
rm(electric.tbl)
#
# we now have a dplyr tbl_df class dataset named electric.in.rng with the
# following row names:
#  Global_active_power  : num  
#  Global_reactive_power: num  
#  Voltage              : num 
#  Global_intensity     : num  
#  Sub_metering_1       : num  
#  Sub_metering_2       : num  
#  Sub_metering_3       : num 
#  DateTime             : POSIXct
#
# plot using base
#       specify it going to PNG, plot with base package and flush plot buffer
#       configure common upper limit for y axis as max value needed
png(file="plot4.png")

par(mfrow=c(2,2))

# first plot (same as plot 2)
xl=""
yl="Global Active Power"
with(electric.in.rng,plot(Global_active_power ~ DateTime,type="l",xlab=xl,ylab=yl))

# second plot, new plot of Voltage over the time period
with(electric.in.rng,plot(Voltage ~ DateTime,type="l",xlab="datetime"))

# third plot (same as plot 3)
yl <- "Energy sub metering"
xl <- ""
ymax <- max(max(electric.in.rng$Sub_metering_1),max(electric.in.rng$Sub_metering_2),max(electric.in.rng$Sub_metering_3))
ylim <- c(0,ymax)
#
with(electric.in.rng,plot(Sub_metering_1 ~ DateTime,type="l",ylim=ylim,xlab="",ylab=""))
par(new=T)
with(electric.in.rng,plot(Sub_metering_2 ~ DateTime,type="l",col=2,ylim=ylim,xlab="",ylab=""))
par(new=T)
with(electric.in.rng,plot(Sub_metering_3 ~ DateTime,type="l",col="blue",ylim=ylim,xlab=xl,ylab=yl))
legend("topright",c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),lty=1,col=c("black",2,"blue"),bty="n")

# fourth plot, Global_reactive_power over the time period
with(electric.in.rng,plot(Global_reactive_power ~ DateTime,type="l",xlab="datetime"))

dev.off()