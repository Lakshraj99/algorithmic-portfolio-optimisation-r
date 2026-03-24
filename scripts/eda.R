library(tidyverse)
library(reshape2)
# Create visuals folder if not exists
dir.create("visuals", showWarnings = FALSE)
# Load dataset
returns <- read.csv("data/stock_returns.csv")
# Convert date column
returns$date <- as.Date(returns$date)
print(head(returns))
print(dim(returns))
# 1. Return Distribution
returns_long <- returns %>%
  pivot_longer(-date, names_to = "Stock", values_to = "Return")

p1 <- ggplot(returns_long, aes(x = Return, fill = Stock)) +
  geom_histogram(bins = 50, alpha = 0.6) +
  facet_wrap(~Stock, scales = "free") +
  theme_minimal() +
  labs(title = "Return Distribution of Stocks")

ggsave("visuals/return_distribution.png", plot = p1, width = 10, height = 6)
# 2. Volatility Comparison
volatility <- returns %>%
  select(-date) %>%
  summarise(across(everything(), sd)) %>%
  pivot_longer(everything(), names_to = "Stock", values_to = "Volatility")

p2 <- ggplot(volatility, aes(x = reorder(Stock, Volatility), y = Volatility)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Volatility of Stocks")


ggsave("visuals/volatility.png", plot = p2, width = 8, height = 5)
# 3. Correlation Heatmap
cor_matrix <- cor(returns[,-1])
cor_df <- melt(cor_matrix)

p3 <- ggplot(cor_df, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  labs(title = "Correlation Heatmap", x = "", y = "")

ggsave("visuals/correlation_heatmap.png", plot = p3, width = 8, height = 6)
# 4. Risk vs Return
mean_returns <- colMeans(returns[,-1])
risk <- apply(returns[,-1], 2, sd)
risk_return <- data.frame(
  Stock = names(mean_returns),
  Return = mean_returns,
  Risk = risk
)
p4 <- ggplot(risk_return, aes(x = Risk, y = Return, label = Stock)) +
  geom_point(color = "red", size = 3) +
  geom_text(vjust = -0.5) +
  theme_minimal() +
  labs(title = "Risk vs Return")

ggsave("visuals/risk_return.png", plot = p4, width = 8, height = 5)
# 5. Summary Statistics
summary_stats <- data.frame(
  Stock = colnames(returns)[-1],
  Mean_Return = mean_returns,
  Volatility = risk
)
print(summary_stats)
write.csv(summary_stats, "data/summary_statistics.csv", row.names = FALSE)
# Done
print("EDA Completed Successfully!")