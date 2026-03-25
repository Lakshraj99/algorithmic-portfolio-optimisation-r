library(tidyverse)
library(lubridate)

# Load stock prices dataset
stock_prices <- read.csv("data/stock_prices.csv")

# Convert date column
stock_prices$date <- as.Date(stock_prices$date)

# Preview dataset
head(stock_prices)

# Calculate daily returns
stock_returns <- stock_prices %>%
  arrange(date) %>%
  mutate(across(-date, ~ (. - lag(.)) / lag(.)))

# Remove NA values
stock_returns <- stock_returns %>%
  drop_na()

# Save processed dataset
write.csv(stock_returns, "data/stock_returns.csv", row.names = FALSE)

# Check dataset
print(dim(stock_returns))
head(stock_returns)