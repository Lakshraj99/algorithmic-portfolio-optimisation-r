options(timeout = 120)

library(quantmod)
library(tidyverse)
library(lubridate)
library(fredr)
library(dotenv)

load_dot_env()

tickers <- c(
  "AAPL","MSFT","AMZN","GOOGL","TSLA",
  "NVDA","JPM","KO","WMT","META"
)

start_date <- as.Date("2019-01-01")
end_date <- Sys.Date()

price_list <- list()

for (ticker in tickers) {

  tryCatch({

    data <- getSymbols(
      ticker,
      src = "yahoo",
      from = start_date,
      to = end_date,
      auto.assign = FALSE
    )

    price_list[[ticker]] <- Ad(data)
    print(paste("Downloaded", ticker))

  }, error = function(e) {

    print(paste("Failed:", ticker))

  })

}

# Merge all successful downloads
prices <- do.call(merge, price_list)

# Rename columns
colnames(prices) <- names(price_list)

# Convert to dataframe
stock_prices <- data.frame(
  date = index(prices),
  coredata(prices)
)

# Save dataset
write.csv(stock_prices, "data/stock_prices.csv", row.names = FALSE)

# Fetch risk free rate
fredr_set_key(Sys.getenv("FRED_API_KEY"))

risk_free_rate <- fredr(
  series_id = "DTB3",
  observation_start = start_date,
  observation_end = end_date
)

write.csv(risk_free_rate, "data/risk_free_rate.csv", row.names = FALSE)