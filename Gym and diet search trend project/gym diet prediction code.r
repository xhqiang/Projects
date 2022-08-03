install.packages("astsa")
install.packages("devtools")
devtools::install_github("nickpoison/astsa")
library(astsa)
library(devtools)

data<-read.csv(file.choose())
colnames(data)<-c("Month","Diet", "Gym")

sarima(data$diet, 0,1,1, 0,1,1, 12)
sarima(log(data$gym), 0,1,1, 0,1,1, 12)

m1<-arima(data$diet,order=c(0,1,1),seasonal=list(order=c(0,1,1),period=12))
shapiro.test(m1$residuals)

m2<-arima(log(data$gym),order=c(0,1,1),seasonal=list(order=c(0,1,1),period=12))
shapiro.test(m2$residuals)

sarima.for(data$diet, 12, 0,1,1, 0,1,1,12)
sarima.for(log(data$gym), 12, 0,1,1, 0,1,1,12)
