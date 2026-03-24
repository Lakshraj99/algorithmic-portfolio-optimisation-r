library(tidyverse)
# Create visuals folder
dir.create("visuals", showWarnings = FALSE)
# Load Returns Data
returns <- read.csv("data/stock_returns.csv")
returns_matrix <- as.matrix(returns[,-1])
num_assets <- ncol(returns_matrix)
# Load Risk-Free Rate (FRED)
rf_data <- read.csv("data/risk_free_rate.csv")
rf_data$date <- as.Date(rf_data$date)
rf_data <- rf_data %>%
  select(date, value)
# Convert % → decimal
rf_data$value <- rf_data$value / 100
# Average risk-free rate
risk_free_rate <- mean(rf_data$value, na.rm = TRUE)

print(paste("Average Risk-Free Rate:", round(risk_free_rate, 4)))
# Calculate Metrics
mean_returns <- colMeans(returns_matrix)
cov_matrix <- cov(returns_matrix)
# Portfolio Functions
portfolio_return <- function(weights, mean_returns) {
  sum(weights * mean_returns)
}

portfolio_risk <- function(weights, cov_matrix) {
  sqrt(t(weights) %*% cov_matrix %*% weights)
}

# Monte Carlo Simulation
set.seed(42)
num_portfolios <- 5000
results <- matrix(nrow = 3, ncol = num_portfolios)
weights_list <- list()
for (i in 1:num_portfolios) {

  # Random weights
  weights <- runif(num_assets)
  weights <- weights / sum(weights)

  weights_list[[i]] <- weights

  # Portfolio metrics
  port_return <- portfolio_return(weights, mean_returns)
  port_risk <- portfolio_risk(weights, cov_matrix)

  # Sharpe ratio (REAL)
  sharpe <- (port_return - risk_free_rate) / port_risk

  results[1,i] <- port_return
  results[2,i] <- port_risk
  results[3,i] <- sharpe
}

# Convert to dataframe
results_df <- data.frame(
  Return = results[1,],
  Risk = results[2,],
  Sharpe = results[3,]
)

# Optimal Portfolio
max_sharpe_idx <- which.max(results_df$Sharpe)

optimal_portfolio <- results_df[max_sharpe_idx,]
optimal_weights <- weights_list[[max_sharpe_idx]]

print("Optimal Portfolio (Max Sharpe):")
print(optimal_portfolio)

# Display weights
weights_df <- data.frame(
  Stock = colnames(returns_matrix),
  Weight = optimal_weights
)

print("Optimal Weights:")
print(weights_df)

# Save weights
write.csv(weights_df, "data/optimal_weights.csv", row.names = FALSE)
# Efficient Frontier Plot
p <- ggplot(results_df, aes(x = Risk, y = Return, color = Sharpe)) +
  geom_point(alpha = 0.6) +
  scale_color_gradient(low = "blue", high = "red") +
  geom_point(data = optimal_portfolio, aes(x = Risk, y = Return),
             color = "green", size = 4) +
  theme_minimal() +
  labs(title = "Efficient Frontier with Monte Carlo Simulation")

ggsave("visuals/efficient_frontier.png", plot = p, width = 8, height = 6)
print("Portfolio Optimisation Completed Successfully!")