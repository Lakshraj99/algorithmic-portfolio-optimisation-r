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
library(fredr)

# Set your FRED API key
fredr_set_key("d730817f3fe07cca979811852a4c20b6")

# Fetch 3-Month Treasury Bill rate
risk_free_rate <- fredr(
  series_id = "DTB3",
  observation_start = as.Date("2019-01-01"),
  observation_end = Sys.Date()
)

# Preview data
head(risk_free_rate)

# Save dataset
write.csv(risk_free_rate, "data/risk_free_rate.csv", row.names = FALSE)