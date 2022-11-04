library(urca)
library(forecast)
library(e1071)
library(Metrics)
library(tseries)

dataset = read.csv(file.choose(), sep = ',', header = T)

TScubic = ts(dataset[,2], start = c(1, 1), frequency = 6)

plot(TScubic, main = "Vazão", ylab = "Vazão (bits/s)", xlab = "Tempo (hr)")

for(i in dataset){
  print(dataset[i])
}
