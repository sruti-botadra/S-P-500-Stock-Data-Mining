library("quantmod")
library(ggplot2)
library(fpp)
library(fpp2)

AAPL = getSymbols("AAPL",src="yahoo", from="2009-01-01", auto.assign = FALSE)

# Plotting data
ggplot(AAPL, aes(x = index(AAPL), y = AAPL[,6])) + geom_line(color = "darkblue") + 
  ggtitle("AAPL Stock Price") + xlab("Date") + ylab("Price") + 
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_x_date(date_labels = "%b %y", date_breaks = "6 months")

# Forecasting using mean, naive and drift methods. 
AAPL_Adjusted = ts(AAPL[,6])
AAPL_Adjusted_Test <- window(AAPL_Adjusted,start=1,end=2100)
AAPLMeanFit <- meanf(AAPL_Adjusted_Test,h=641)
AAPLNaiveFit <- rwf(AAPL_Adjusted_Test,h=641)
AAPLSnaiveFit <- snaive(AAPL_Adjusted_Test,h=641)
AAPLDriftFit <- rwf(AAPL_Adjusted_Test,drift=TRUE,h=641)
autoplot(AAPL_Adjusted_Test) +
  autolayer(AAPLMeanFit, series="Mean", PI=FALSE) +
  autolayer(AAPLNaiveFit, series="NaÃ¯ve", PI=FALSE) +
  autolayer(AAPLSnaiveFit, series="Seasonal naÃ¯ve", PI=FALSE) +
  autolayer(AAPLDriftFit, series="Drift", PI=FALSE) +
  xlab("Day") + ylab("Price") +
  ggtitle("Apple Share Price Forecast") +
  guides(colour=guide_legend(title="Forecast"))

# Forecasting using Arima method.
arima <- auto.arima(AAPL_Adjusted_Test,seasonal = FALSE)
arimafit = forecast(arima, h = 641)
plot(arimafit, main = "PREDICTION USING AUTO ARIMA")

# Measuring Accuracy
AAPL_Adjusted_Train <- window(AAPL_Adjusted, start=2101)
accuracy(AAPLMeanFit, AAPL_Adjusted_Train)
accuracy(AAPLNaiveFit, AAPL_Adjusted_Train)
accuracy(AAPLSnaiveFit, AAPL_Adjusted_Train)
accuracy(AAPLDriftFit, AAPL_Adjusted_Train)
accuracy(arimafit, AAPL_Adjusted_Train)
# Drift method provides best results as MAE and RMSE are least.

#Plotting next 180 days using Drift method - 
AAPLDriftFit <- rwf(AAPL_Adjusted,h=180, drift = TRUE)
autoplot(AAPL_Adjusted) +
  autolayer(AAPLDriftFit, series="Drift", PI=FALSE) +
  xlab("Day") + ylab("Price") +
  ggtitle("Apple Share Price Forecast") +
  guides(colour=guide_legend(title="Forecast"))

# uppper and lower values
View(AAPLDriftFit[["lower"]])
View(AAPLDriftFit[["upper"]])
# We see prices going upto 328.7401 in next 6 months 
# or it can go down to 230.7376 at 95% CI.

# ACF - 
gglagplot(AAPL_Adjusted) # Lag plots suggest data is highly correlated.
ggAcf(AAPL_Adjusted)
# ACF shows significant correlation and upward trend pattern in data 
# as all lags cross CI are decreasing constantly.

# Residuals - 
res<-residuals(rwf(AAPL_Adjusted, drift = TRUE))
plot(res, main="Residual of Apple stock price", xlab="Day", ylab="Price")
Acf(res, main="ACF of residuals")
# Above correlogram plot shows that autocorrelation does not 
# significantly exists in residuals. Hence residuals are not statistically 
# significant and our forecasting method is good.

