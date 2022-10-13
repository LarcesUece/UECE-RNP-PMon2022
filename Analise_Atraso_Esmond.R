library(urca)
library(forecast)
library(e1071)
library(Metrics)
library(tseries)

dataset = read.csv(file.choose(), sep = ',', header = T)

TSatraso = ts(dataset[,2], start = c(1, 1), frequency = 60)
# uma observação por minuto, num total de 60 observações por hora.
# O dataset tem 4499 observações, o que da aproximadamente 74 por hora (4499/60).

TSatraso_clean = tsclean(TSatraso)

plot(TSatraso, main = "Atraso", ylab = "Atraso (ms)", xlab = "Tempo (hr)")

# Decomposições multiplicativas e aditivas da série original e depois do clean.
tsadditive_clean = decompose(TSatraso_clean, type = "additive")
tsmult_clean = decompose(TSatraso_clean, type = "multiplicative")
tsadditive = decompose(TSatraso, type = "additive")
tsmult = decompose(TSatraso, type = "multiplicative")

# Vizualização das componentes das séries
plot(tsadditive_clean)
plot(tsmult_clean)
plot(tsadditive)
plot(tsmult)

# Destaque da variável aleatória para análise
random_ad_c = tsadditive_clean$random
random_ad = tsadditive$random
random_mt_c = tsmult_clean$random
random_mt = tsmult$random

# Exclusão de valores nulos
random_ad = na.omit(random_ad)
random_mt = na.omit(random_mt)
random_ad_c = na.omit(random_ad_c)
random_mt_c = na.omit(random_mt_c)

# Testes estácionários como critério de escolha de um tipo de decomposição
kpss_add = ur.kpss(random_ad)
kpss_mul = ur.kpss(random_mt)

kpss_addc = ur.kpss(random_ad_c)
kpss_mulc = ur.kpss(random_mt_c)

adf_add = ur.df(random_ad)
adf_mul = ur.df(random_mt)

adf_addc = ur.df(random_ad_c)
adf_mulc = ur.df(random_mt_c)

# 
testes = data.frame("KPSS-ADD"=kpss_add@teststat,
              "KPSS-MUL"=kpss_mul@teststat,
              "KPSS-ADD-Clean"=kpss_addc@teststat,
              "KPSS-MUL-Clean"=kpss_mulc@teststat,
              "ADF-ADD"=adf_add@teststat,
              "ADF-MUL"=adf_mul@teststat,
              "ADF-ADD-Clean"=adf_addc@teststat,
              "ADF-MUL-Clean"=adf_mulc@teststat
)
print(testes)
# Atraves dos testes, escolhemos decomposição aditiva

# Separação dos conjuntos - 3 pra 1
conjunto_treino = c("mytsTrain3", 
                    "mytsTrain6",
                    "mytsTrain9", 
                    "mytsTrain12",
                    "mytsTrain15",
                    "mytsTrain18",
                    "mytsTrain21",
                    "mytsTrain24",
                    "mytsTrain27",
                    "mytsTrain30",
                    "mytsTrain33",
                    "mytsTrain36",
                    "mytsTrain39",
                    "mytsTrain42",
                    "mytsTrain45",
                    "mytsTrain48",
                    "mytsTrain51",
                    "mytsTrain54",
                    "mytsTrain57",
                    "mytsTrain60",
                    "mytsTrain63",
                    "mytsTrain66",
                    "mytsTrain69",
                    "mytsTrain72")

mytsTrain3 = window(random_ad, start = c(1,1), end = c(3,60))
mytsTrain6 = window(random_ad, start = c(1,1), end = c(6,60))
mytsTrain9 = window(random_ad, start = c(1,1), end = c(9,60))
mytsTrain12 = window(random_ad, start = c(1,1), end = c(12,60))
mytsTrain15 = window(random_ad, start = c(1,1), end = c(15,60))
mytsTrain18 = window(random_ad, start = c(1,1), end = c(18,60))
mytsTrain21 = window(random_ad, start = c(1,1), end = c(21,60))
mytsTrain24 = window(random_ad, start = c(1,1), end = c(24,60))
mytsTrain27 = window(random_ad, start = c(1,1), end = c(27,60))
mytsTrain30 = window(random_ad, start = c(1,1), end = c(30,60))
mytsTrain33 = window(random_ad, start = c(1,1), end = c(33,60))
mytsTrain36 = window(random_ad, start = c(1,1), end = c(36,60))
mytsTrain39 = window(random_ad, start = c(1,1), end = c(39,60))
mytsTrain42 = window(random_ad, start = c(1,1), end = c(42,60))
mytsTrain45 = window(random_ad, start = c(1,1), end = c(45,60))
mytsTrain48 = window(random_ad, start = c(1,1), end = c(48,60))
mytsTrain51 = window(random_ad, start = c(1,1), end = c(51,60))
mytsTrain54 = window(random_ad, start = c(1,1), end = c(54,60))
mytsTrain57 = window(random_ad, start = c(1,1), end = c(57,60))
mytsTrain60 = window(random_ad, start = c(1,1), end = c(60,60))
mytsTrain63 = window(random_ad, start = c(1,1), end = c(63,60))
mytsTrain66 = window(random_ad, start = c(1,1), end = c(66,60))
mytsTrain69 = window(random_ad, start = c(1,1), end = c(69,60))
mytsTrain72 = window(random_ad, start = c(1,1), end = c(72,60))

# Testes
mytsTest1 = window(random_ad, start = c(4,1), end = c(5,60))
mytsTest2 = window(random_ad, start = c(7,1), end = c(7,60)) 
mytsTest3 = window(random_ad, start = c(10,1), end = c(10,60)) 
mytsTest4 = window(random_ad, start = c(13,1), end = c(13,60)) 
mytsTest5 = window(random_ad, start = c(16,1), end = c(16,60)) 
mytsTest6 = window(random_ad, start = c(19,1), end = c(19,60)) 
mytsTest7 = window(random_ad, start = c(22,1), end = c(22,60)) 
mytsTest8 = window(random_ad, start = c(25,1), end = c(25,60))
mytsTest9 = window(random_ad, start = c(28,1), end = c(28,60)) 
mytsTest10 = window(random_ad, start = c(31,1), end = c(31,60)) 
mytsTest11 = window(random_ad, start = c(34,1), end = c(34,60)) 
mytsTest12 = window(random_ad, start = c(37,1), end = c(37,60))
mytsTest13 = window(random_ad, start = c(40,1), end = c(40,60)) 
mytsTest14 = window(random_ad, start = c(43,1), end = c(43,60)) 
mytsTest15 = window(random_ad, start = c(46,1), end = c(46,60)) 
mytsTest16 = window(random_ad, start = c(49,1), end = c(49,60))
mytsTest17 = window(random_ad, start = c(52,1), end = c(52,60)) 
mytsTest18 = window(random_ad, start = c(55,1), end = c(55,60)) 
mytsTest19 = window(random_ad, start = c(58,1), end = c(58,60)) 
mytsTest20 = window(random_ad, start = c(61,1), end = c(61,60))
mytsTest21 = window(random_ad, start = c(64,1), end = c(64,60))
mytsTest22 = window(random_ad, start = c(67,1), end = c(67,60))
mytsTest23 = window(random_ad, start = c(70,1), end = c(70,60))
mytsTest24 = window(random_ad, start = c(73,1), end = c(73,60))

# Testes de Estacionariedade 
adf_test = c(
  adf.test(mytsTrain3)$statistic,
  adf.test(mytsTrain6)$statistic,
  adf.test(mytsTrain9)$statistic,
  adf.test(mytsTrain12)$statistic,
  adf.test(mytsTrain15)$statistic,
  adf.test(mytsTrain18)$statistic,
  adf.test(mytsTrain21)$statistic,
  adf.test(mytsTrain24)$statistic,
  adf.test(mytsTrain27)$statistic,
  adf.test(mytsTrain30)$statistic,
  adf.test(mytsTrain33)$statistic,
  adf.test(mytsTrain36)$statistic,
  adf.test(mytsTrain39)$statistic,
  adf.test(mytsTrain42)$statistic,
  adf.test(mytsTrain45)$statistic,
  adf.test(mytsTrain48)$statistic,
  adf.test(mytsTrain51)$statistic,
  adf.test(mytsTrain54)$statistic,
  adf.test(mytsTrain57)$statistic,
  adf.test(mytsTrain60)$statistic,
  adf.test(mytsTrain63)$statistic,
  adf.test(mytsTrain66)$statistic,
  adf.test(mytsTrain69)$statistic,
  adf.test(mytsTrain72)$statistic
)

kpss_test = c(
  kpss.test(mytsTrain3)$statistic,
  kpss.test(mytsTrain6)$statistic,
  kpss.test(mytsTrain9)$statistic,
  kpss.test(mytsTrain12)$statistic,
  kpss.test(mytsTrain15)$statistic,
  kpss.test(mytsTrain18)$statistic,
  kpss.test(mytsTrain21)$statistic,
  kpss.test(mytsTrain24)$statistic,
  kpss.test(mytsTrain27)$statistic,
  kpss.test(mytsTrain30)$statistic,
  kpss.test(mytsTrain33)$statistic,
  kpss.test(mytsTrain36)$statistic,
  kpss.test(mytsTrain39)$statistic,
  kpss.test(mytsTrain42)$statistic,
  kpss.test(mytsTrain45)$statistic,
  kpss.test(mytsTrain48)$statistic,
  kpss.test(mytsTrain51)$statistic,
  kpss.test(mytsTrain54)$statistic,
  kpss.test(mytsTrain57)$statistic,
  kpss.test(mytsTrain60)$statistic,
  kpss.test(mytsTrain63)$statistic,
  kpss.test(mytsTrain66)$statistic,
  kpss.test(mytsTrain69)$statistic,
  kpss.test(mytsTrain72)$statistic
)

testes_estac = data.frame(conjuntos_de_treino=conjunto_treino, 
                          ADF_Test=adf_test, KPSS_Test=kpss_test)

plot(mytsTrain27)

# Treinamento ARIMA

mytsArima3 = auto.arima(mytsTrain3)
mytsArima6 = auto.arima(mytsTrain6)
mytsArima9 = auto.arima(mytsTrain9)
mytsArima12 = auto.arima(mytsTrain12)
mytsArima15 = auto.arima(mytsTrain15)
mytsArima18 = auto.arima(mytsTrain18)
mytsArima21 = auto.arima(mytsTrain21)
mytsArima24 = auto.arima(mytsTrain24)
mytsArima27 = auto.arima(mytsTrain27)
mytsArima30 = auto.arima(mytsTrain30)
mytsArima33 = auto.arima(mytsTrain33)
mytsArima36 = auto.arima(mytsTrain36)
mytsArima39 = auto.arima(mytsTrain39)
mytsArima42 = auto.arima(mytsTrain42)
mytsArima45 = auto.arima(mytsTrain45)
mytsArima48 = auto.arima(mytsTrain48)
mytsArima51 = auto.arima(mytsTrain51)
mytsArima54 = auto.arima(mytsTrain54)
mytsArima57 = auto.arima(mytsTrain57)
mytsArima60 = auto.arima(mytsTrain60)
mytsArima63 = auto.arima(mytsTrain63)
mytsArima66 = auto.arima(mytsTrain66)
mytsArima69 = auto.arima(mytsTrain69)
mytsArima72 = auto.arima(mytsTrain72)
