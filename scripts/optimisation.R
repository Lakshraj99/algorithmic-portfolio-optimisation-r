library(tidyverse)

# Create visuals folder
dir.create("visuals", showWarnings = FALSE)

# Load Returns Data

returns <- read.csv("data/stock_returns.csv")
returns_matrix <- as.matrix(returns[,-1])

num_assets <- ncol(returns_matrix)

# Load Risk-Free Rate

rf_data <- read.csv("data/risk_free_rate.csv")

rf_data$date <- as.Date(rf_data$date)

rf_data <- rf_data %>%
  select(date, value)

# Convert % → decimal
rf_data$value <- rf_data$value / 100

risk_free_rate <- mean(rf_data$value, na.rm = TRUE)

print(paste("Average Risk-Free Rate:", round(risk_free_rate, 4)))

# Metrics

mean_returns <- colMeans(returns_matrix)
cov_matrix <- cov(returns_matrix)
# Functions
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

  weights <- runif(num_assets)
  weights <- weights / sum(weights)

  weights_list[[i]] <- weights
  port_return <- portfolio_return(weights, mean_returns)
  port_risk <- portfolio_risk(weights, cov_matrix)

  sharpe <- (port_return - risk_free_rate) / port_risk

  results[1,i] <- port_return
  results[2,i] <- port_risk
  results[3,i] <- sharpe
}

# Results
results_df <- data.frame(
  Return = results[1,],
  Risk = results[2,],
  Sharpe = results[3,]
)
# Optimal Portfolio

max_sharpe_idx <- which.max(results_df$Sharpe)

optimal_portfolio <- results_df[max_sharpe_idx,]
optimal_weights <- weights_list[[max_sharpe_idx]]

print("Optimal Portfolio:")
print(optimal_portfolio)

weights_df <- data.frame(
  Stock = colnames(returns_matrix),
  Weight = optimal_weights
)

print("Optimal Weights:")
print(weights_df)

write.csv(weights_df, "data/optimal_weights.csv", row.names = FALSE)
# Portfolio Comparison
equal_weights <- rep(1/num_assets, num_assets)

equal_return <- portfolio_return(equal_weights, mean_returns)
equal_risk <- portfolio_risk(equal_weights, cov_matrix)
equal_sharpe <- (equal_return - risk_free_rate) / equal_risk

comparison <- data.frame(
  Portfolio = c("Equal Weight", "Optimal"),
  Return = c(equal_return, optimal_portfolio$Return),
  Risk = c(equal_risk, optimal_portfolio$Risk),
  Sharpe = c(equal_sharpe, optimal_portfolio$Sharpe)
)

print("Portfolio Comparison:")
print(comparison)

write.csv(comparison, "data/portfolio_comparison.csv", row.names = FALSE)
# Plot Efficient Frontier
p <- ggplot(results_df, aes(x = Risk, y = Return, color = Sharpe)) +
  geom_point(alpha = 0.6) +
  scale_color_gradient(low = "blue", high = "red") +
  geom_point(data = optimal_portfolio,
             aes(x = Risk, y = Return),
             color = "green", size = 4) +
  theme_minimal() +
  labs(title = "Efficient Frontier with Monte Carlo Simulation")

ggsave("visuals/efficient_frontier.png", plot = p, width = 8, height = 6)
print("Portfolio Optimisation Completed Successfully!")