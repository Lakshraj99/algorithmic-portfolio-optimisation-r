# Load required libraries
library(quantmod)
library(tidyverse)
library(lubridate)

# Define stock tickers
tickers <- c(
  "AAPL",
  "MSFT",
  "AMZN",
  "GOOGL",
  "TSLA",
  "NVDA",
  "JPM",
  "KO",
  "WMT",
  "META"
)

# Define time range
start_date <- as.Date("2019-01-01")
end_date <- Sys.Date()

# Create list to store stock data
stock_data_list <- list()

# Download data from Yahoo Finance
for (ticker in tickers) {
  data <- getSymbols(
    ticker,
    src = "yahoo",
    from = start_date,
    to = end_date,
    auto.assign = FALSE
  )
  stock_data_list[[ticker]] <- data
}

# Convert to dataframe
stock_prices <- bind_rows(
  lapply(names(stock_data_list), function(ticker) {
    data <- stock_data_list[[ticker]]
    df <- data.frame(
      date = index(data),
      coredata(data)
    )
    df$ticker <- ticker
    return(df)
  })
)

# Preview dataset
head(stock_prices)

# Save dataset locally
write.csv(stock_prices, "data/stock_prices.csv", row.names = FALSE)