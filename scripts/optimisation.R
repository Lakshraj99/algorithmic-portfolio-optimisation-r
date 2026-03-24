library(tidyverse)
# Load returns data
returns <- read.csv("data/stock_returns.csv")
# Remove date column
returns_matrix <- as.matrix(returns[,-1])
# Number of assets
num_assets <- ncol(returns_matrix)
# Mean returns
mean_returns <- colMeans(returns_matrix)
# Covariance matrix
cov_matrix <- cov(returns_matrix)
portfolio_return <- function(weights, mean_returns) {
  sum(weights * mean_returns)
}
portfolio_risk <- function(weights, cov_matrix) {
  sqrt(t(weights) %*% cov_matrix %*% weights)
}
set.seed(42)
num_portfolios <- 5000
results <- matrix(nrow = 3, ncol = num_portfolios)
for (i in 1:num_portfolios) {
  # Generate random weights
  weights <- runif(num_assets)
  weights <- weights / sum(weights)
  # Calculate return & risk
  port_return <- portfolio_return(weights, mean_returns)
  port_risk <- portfolio_risk(weights, cov_matrix)
  # Store results
  results[1,i] <- port_return
  results[2,i] <- port_risk
  results[3,i] <- port_return / port_risk  # Sharpe (approx)
}

# Convert to dataframe
results_df <- data.frame(
  Return = results[1,],
  Risk = results[2,],
  Sharpe = results[3,]
)

# Max Sharpe Ratio
max_sharpe_idx <- which.max(results_df$Sharpe)

optimal_portfolio <- results_df[max_sharpe_idx,]

print("Optimal Portfolio (Max Sharpe):")
print(optimal_portfolio)
dir.create("visuals", showWarnings = FALSE)

p <- ggplot(results_df, aes(x = Risk, y = Return, color = Sharpe)) +
  geom_point(alpha = 0.6) +
  scale_color_gradient(low = "blue", high = "red") +
  geom_point(data = optimal_portfolio, aes(x = Risk, y = Return),
             color = "green", size = 4) +
  theme_minimal() +
  labs(title = "Efficient Frontier with Monte Carlo Simulation")
print(p)
ggsave("visuals/efficient_frontier.png", plot = p, width = 8, height = 6)
print("Portfolio Optimisation Completed!")