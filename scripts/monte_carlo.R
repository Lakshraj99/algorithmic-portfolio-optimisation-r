# Load libraries
library(tidyverse)

# Load returns dataset
returns <- read.csv("data/stock_returns.csv")

# Remove date column
returns_matrix <- returns %>% select(-date)

# Convert to matrix
returns_matrix <- as.matrix(returns_matrix)

# Number of assets
num_assets <- ncol(returns_matrix)

# Number of simulations
num_portfolios <- 5000

# Initialize results
results <- data.frame(
  Return = numeric(num_portfolios),
  Risk = numeric(num_portfolios),
  Sharpe = numeric(num_portfolios)
)

# Store weights
weights_list <- matrix(NA, nrow = num_portfolios, ncol = num_assets)

# Mean returns & covariance
mean_returns <- colMeans(returns_matrix)
cov_matrix <- cov(returns_matrix)

# Risk-free rate (daily approx)
risk_free_rate <- 0.02 / 252

# Monte Carlo Simulation
for (i in 1:num_portfolios) {
  
  # Generate random weights
  weights <- runif(num_assets)
  weights <- weights / sum(weights)
  
  weights_list[i, ] <- weights
  
  # Portfolio return
  portfolio_return <- sum(weights * mean_returns)
  
  # Portfolio risk
  portfolio_risk <- sqrt(t(weights) %*% cov_matrix %*% weights)
  
  # Sharpe ratio
  sharpe <- (portfolio_return - risk_free_rate) / portfolio_risk
  
  # Store results
  results$Return[i] <- portfolio_return
  results$Risk[i] <- portfolio_risk
  results$Sharpe[i] <- sharpe
}

# Combine results
portfolio_results <- cbind(results, weights_list)

# Find best portfolio (max Sharpe)
best_portfolio <- portfolio_results[which.max(portfolio_results$Sharpe), ]

print("Best Portfolio (Monte Carlo):")
print(best_portfolio)

# Save results
write.csv(portfolio_results, "data/monte_carlo_results.csv", row.names = FALSE)
write.csv(best_portfolio, "data/monte_carlo_best.csv", row.names = FALSE)

# Plot Efficient Frontier
png("visuals/monte_carlo_frontier.png", width = 800, height = 600)

plot(
  portfolio_results$Risk,
  portfolio_results$Return,
  col = "blue",
  pch = 16,
  xlab = "Risk (Volatility)",
  ylab = "Return",
  main = "Monte Carlo Efficient Frontier"
)

# Highlight best portfolio
points(
  best_portfolio$Risk,
  best_portfolio$Return,
  col = "red",
  pch = 19,
  cex = 2
)

dev.off()

print("Monte Carlo Simulation Completed!")