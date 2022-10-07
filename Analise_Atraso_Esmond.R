library(urca)
library(forecast)
library(e1071)
library(Metrics)
library(tseries)

dataset = read.csv(file.choose(), sep = ',', header = T)

myts_atraso = ts(dataset[,2], start = c(1, 1), frequency = 60)

plot(myts_atraso, main = "Atraso", ylab = "Atraso (ms)")
