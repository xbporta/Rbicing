### REQUIRED LIBRARIES  ###

library(jsonlite)
library(curl)
library(lubridate)

###  FUNCTIONS  ###

# Saves a csv file with bicing data
bicing.to.csv <- function(input.bicing, filetype = "bicing") {
  
  input.bicing <- as.data.frame(input.bicing)

  file.path <- paste0("output/",filetype,"_",strftime(unique(input.bicing$timestamp), format = "%Y%m%d_%H%M%S"),".csv")  
  write.csv2(input.bicing, file.path, row.names = F)
}



# Connects to server and get Bicing's Data
# Returns a list with the information saved on both files
get.bicing <- function(){
  
  url.bicing <- "http://wservice.viabicing.cat/v2/stations"
  json.bicing <- fromJSON(url.bicing)
  
  # Arranging the data to a data frame
  df.bicing <- as.data.frame(json.bicing$stations)
  
  # Creates a timestamp of the last data update
  df.bicing$timestamp <- as.POSIXlt(json.bicing$updateTime, origin="1970-01-01") 
  
  # Splitting the data frame into:
  #   @df.static  - Data frame with unvariable data of each station
  #   @df.var     - Data frame with data which may vary regularly
  
  df.static <- df.bicing[,c("id","type","latitude","longitude","streetName","streetNumber","altitude","nearbyStations","timestamp")]
  df.var <- df.bicing[,c("id","type","slots","bikes","status","timestamp")]
  
  # Return a list with both data frames
  return(list(static = df.static, var = df.var))
}



# Generates the first data frame
# Saves a .csv file with unvariable data of each station
# Saves a .csv file with variable data of each station
init.bicing <- function(){
  
  # Get initial data  
  df <- get.bicing()
  
  # Saves dataframes on csv files
  bicing.to.csv(df$static, filetype = "static")
  bicing.to.csv(df$var)
  
  # Returns a list with both data frames
  return(df)
}



# Updates data
update.bicing <- function(input.bicing.var){
  
  ts.input <- unique(input.bicing.var$timestamp)

  df <- get.bicing()
  df <- df$var
  
  ts.df <- unique(df$timestamp)
  
  if (ts.df > ts.input[length(ts.input)]){
    bicing.to.csv(df)
    input.bicing.var <- rbind(input.bicing.var,df)
  }
  
  return(input.bicing.var)
}
