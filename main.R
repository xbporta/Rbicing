source("functions.bicing.R", encoding = "UTF-8")

###  Initialize the data frame  ###
df <- init.bicing()
df.static <- df$static
df.var <- df$var

# We will get data during a whole day. 24 hours * 60 minutes * 2 times every minute
# The following loop will connect to the Bicing server every 30 seconds to ensure we don't loose data.
# Official data refreshes every minute.
i <- 24*60*2

while (i > 0){
  
  df.var <- update.bicing(df.var)
  i <- i - 1
  
  # System stops during 30 seconds
  Sys.sleep(time = 30)
}