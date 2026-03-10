options(timeout = 120)

# Load required libraries
library(quantmod)
library(tidyverse)
library(lubridate)
library(fredr)
library(dotenv)

load_dot_env()

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

  tryCatch({

    data <- getSymbols(
      ticker,
      src = "yahoo",
      from = start_date,
      to = end_date,
      auto.assign = FALSE
    )

    stock_data_list[[ticker]] <- data
    print(paste("Downloaded", ticker))

  }, error = function(e) {

    print(paste("Failed:", ticker))

  })

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
    df

  })
)

# Preview dataset
head(stock_prices)

# Save dataset locally
write.csv(stock_prices, "data/stock_prices.csv", row.names = FALSE)

# Set FRED API key
fredr_set_key(Sys.getenv("FRED_API_KEY"))

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