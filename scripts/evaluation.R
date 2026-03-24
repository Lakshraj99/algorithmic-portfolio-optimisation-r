# Predictive Modelling (Regression)
library(tidyverse)

# Load summary data
data <- read.csv("data/summary_statistics.csv")

# Linear Regression Model

model <- lm(Mean_Return ~ Volatility, data = data)

summary(model)
# Predictions

data$Predicted_Return <- predict(model, data)

# Evaluation (RMSE)

rmse <- sqrt(mean((data$Mean_Return - data$Predicted_Return)^2))

print(paste("RMSE:", rmse))

# Plot
dir.create("visuals", showWarnings = FALSE)
p <- ggplot(data, aes(x = Volatility, y = Mean_Return)) +
  geom_point(color = "blue", size = 3) +
  geom_line(aes(y = Predicted_Return), color = "red") +
  theme_minimal() +
  labs(title = "Regression: Return vs Volatility")
ggsave("visuals/regression_plot.png", plot = p, width = 8, height = 5)
write.csv(data, "data/regression_results.csv", row.names = FALSE)

print("Regression model completed")