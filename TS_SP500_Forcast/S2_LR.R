library('quantmod')
library('MTS')
library('DataCombine')
library('forecast')
library('TSPred')
library('TSA')
library('tsoutliers')


suppressWarnings(getSymbols("NWSA",from="2014-12-30",to="2020-2-1"))
suppressWarnings(getSymbols("DIS",from="2014-12-30",to="2020-2-1"))
suppressWarnings(getSymbols("NFLX",from="2014-12-30",to="2020-2-1"))
ATT = suppressWarnings(getSymbols("T",from="2014-12-30",to="2020-2-1", auto.assign = FALSE))
suppressWarnings(getSymbols("GOOGL",from="2014-12-30",to="2020-2-1"))

head(DIS)
tail(DIS)

head(GOOGL)
tail(GOOGL)

head(NFLX)
tail(NFLX)

head(NWSA)
tail(NWSA)

head(ATT)
tail(ATT)

###############################
## Data for lm
###############################

NFLX.shift = slide(as.data.frame(NFLX), Var = 'NFLX.Close', NewVar = 'NFLX.Close.shift')
DIS.shift = slide(as.data.frame(DIS), Var = 'DIS.Close', NewVar = 'DIS.Close.shift')
NWSA.shift = slide(as.data.frame(NWSA), Var = 'NWSA.Close', NewVar = 'NWSA.Close.shift')
ATT.shift = slide(as.data.frame(ATT), Var = 'T.Close', NewVar = 'T.Close.shift')
GOOGL.shift = slide(as.data.frame(GOOGL), Var = 'GOOGL.Close', NewVar = 'GOOGL.Close.shift')
GOOGL.shift = slide(as.data.frame(GOOGL.shift), Var = 'GOOGL.Volume', NewVar = 'GOOGL.Volume.shift')

GOOGL.shift$GOOGL.Range = log(GOOGL.shift$GOOGL.High/GOOGL.shift$GOOGL.Low)
GOOGL.shift = slide(as.data.frame(GOOGL.shift), Var = 'GOOGL.Range', NewVar = 'GOOGL.Range.shift')

yesterday.prices = cbind(DIS.shift$DIS.Close.shift, NFLX.shift$NFLX.Close.shift, NWSA.shift$NWSA.Close.shift, ATT.shift$T.Close.shift, GOOGL.shift$GOOGL.Close.shift)

colnames(yesterday.prices) = c('DIS.Close.Prev', 'NFLX.Close.Prev', 'NWSA.Close.Prev', 'T.Close.Prev', 'GOOGL.Close.Prev')
yesterday.return = diff(log(yesterday.prices))
colnames(yesterday.return) = c('DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')
prices = cbind(diff(log(GOOGL$GOOGL.Close)), GOOGL.shift$GOOGL.Range.shift)
prices = prices['2014-12-31/2020-02-01']
prices = cbind(prices, yesterday.return)
colnames(prices) = c('GOOGL.Close', 'GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')
prices.returns = prices['2015-01-01/2020-01-02']
n = length(prices.returns$GOOGL.Close)

head(prices.returns)

################################
## Data for VARMA
################################

prices.varma = cbind(diff(log(DIS$DIS.Close)), diff(log(NWSA$NWSA.Close)),diff(log(NFLX$NFLX.Close)), diff(log(ATT$T.Close)), diff(log(GOOGL$GOOGL.Close)))
train.varma = prices.varma['2015-01-01/2020-01-02']


googl.close.px = GOOGL['2015-01-01/2020-01-02']$GOOGL.Close

colnames(googl.close.px) = c('GOOGL.Close.px')
all.prices = cbind(prices, train.varma, googl.close.px)

all.prices = all.prices['2015-01-01/2020-01-02']

##################################
## VARMA - not that interesting
###################################

Eccm(as.matrix(train.varma))
mod1 = VARMA(as.matrix(train.varma))
mod2 = VARMA(as.matrix(train.varma), include.mean = F)

pred.varma.mod1 = VARMApred(mod1, h=20)
pred.varma.mod2 = VARMApred(mod2, h=20)

##################################
## Try linear models
###################################

lr.lm = lm(GOOGL.Close ~ ., data = prices.returns[2:n,])
summary(lr.lm)

lr.lm.arima = auto.arima(prices.returns[2:n,'GOOGL.Close'], xreg = prices.returns[2:n,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
summary(lr.lm.arima)

test = prices['2020-01-03/2020-02-01']

head(test)
tail(test)

pred.lm.arima = forecast(lr.lm.arima, xreg = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

pred.lm = predict(lr.lm, newdata = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

###############################
## Functions for testing
###############################

#convert a series of log returns to a series of prices given start price
convert.to.price = function(px.start, log.returns)
{
  out.price = numeric(length(log.returns))
  
  curr.px = px.start
  j=1
  
  for(i in log.returns){
    out.price[j] = curr.px*exp(i)
    curr.px = out.price[j]
    j = j+1
  }
  
  return(out.price)
}

# convert log return predictions into price given yesterday's prices
convert.to.price.single = function(prices, log.returns) {
  out.price = numeric(length(log.returns))
  
  j = 1
  
  for(i in log.returns){
    out.price[j] = prices[j]*exp(i)
    j = j+1
  }
  
  return(out.price)
}

#trade.model.1 = function()

#####################
## Check some predictions
####################

px.start = tail(GOOGL['2015-01-01/2020-01-02']$GOOGL.Close, 1)
px = GOOGL['2020-01-02/2020-02-01']$GOOGL.Close


pred.lm.prices = convert.to.price(px.start, pred.lm)
pred.lm.prices.single = convert.to.price.single(px, pred.lm)
smape.lm = sMAPE(px[2:21,], pred.lm.prices)
smape.lm.single = sMAPE(px[2:21,], pred.lm.prices.single)

plot.ts(px[2:21,], main = 'Basic Regression', xlab = 'date', ylab = 'GOOGL price')
points(as.data.frame(px[2:21,]), col='orange')
points(pred.lm.prices, col='blue')
legend('topleft', legend = c('Observed Price', 'Predicted Price'), col = c('orange', 'blue'), pch = 'o')
points(pred.lm.prices.single, col='red')


pred.lm.arima.prices = convert.to.price(px.start, pred.lm.arima$mean)
pred.lm.arima.prices.single = convert.to.price.single(px, pred.lm.arima$mean)
smape.lm.arima = sMAPE(px[2:21], pred.lm.arima.prices)
smape.lm.arima.single = sMAPE(px[2:21], pred.lm.arima.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.lm.arima.prices, col='blue')
points(pred.lm.arima.prices.single, col='red')


pred.varma.mod1.prices = convert.to.price(px.start, pred.varma.mod1$pred[,5])
pred.varma.mod1.prices.single = convert.to.price.single(px, pred.varma.mod1$pred[,5])
smape.varma.mean = sMAPE(px[2:21], pred.varma.mod1.prices)
smape.varma.mean.single = sMAPE(px[2:21], pred.varma.mod1.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.varma.mod1.prices, col='blue')
points(pred.varma.mod1.prices.single, col='red')


pred.varma.mod2.prices = convert.to.price(px.start, pred.varma.mod2$pred[,5])
pred.varma.mod2.prices.single = convert.to.price.single(px, pred.varma.mod2$pred[,5])
smape.varma.nomean = sMAPE(px[2:21], pred.varma.mod2.prices)
smape.varma.nomean.single = sMAPE(px[2:21], pred.varma.mod2.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.varma.mod2.prices, col='blue')
points(pred.varma.mod2.prices.single, col='red')

######################################
## Try ARIMA = a bunch of nearly identically performing models
######################################

lr.arima = auto.arima(prices.returns$GOOGL.Close) #, max.p = 10, max.q = 10, max.order = 30, max.P = 20, max.Q = 20, stepwise = F, trace = T)

summary(lr.arima)

lr.arima.big = auto.arima(prices.returns$GOOGL.Close, max.p = 10, max.q = 10, max.order = 20, stepwise = F, trace = TRUE)
summary(lr.arima.big)

pred.lr.arima = forecast(lr.arima, h=20)
pred.lr.arima.big = forecast(lr.arima.big, h=20)


pred.lr.arima.prices = convert.to.price(px.start, pred.lr.arima$mean)
pred.lr.arima.prices.single = convert.to.price.single(px, pred.lr.arima$mean)
smape.small.arima = sMAPE(px[2:21], pred.lr.arima.prices)
smape.small.arima.single = sMAPE(px[2:21], pred.lr.arima.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.lr.arima.prices, col='blue')
points(pred.lr.arima.prices.single, col='red')


pred.lr.arima.big.prices = convert.to.price(px.start, pred.lr.arima.big$mean)
pred.lr.arima.big.prices.single = convert.to.price.single(px, pred.lr.arima.big$mean)
smape.big.arima = sMAPE(px[2:21], pred.lr.arima.big.prices)
smape.big.arima.single = sMAPE(px[2:21], pred.lr.arima.big.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.lr.arima.big.prices, col='blue')
points(pred.lr.arima.big.prices.single, col='red')

########################
## NULL Model - price tomorrow is the same as price today
#######################

model.null.pred = slide(as.data.frame(px), Var = 'GOOGL.Close', NewVar = 'mean')

smape.null = sMAPE(px[2:21], model.null.pred$mean[2:21])

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(model.null.pred$mean[2:21], col='blue')

#########################
## Try some outlier cleaning
########################

detectAO(lr.arima)
detectIO(lr.arima)

detectAO(lr.arima.big)
detectIO(lr.arima.big)

ol = tsoutliers(prices.returns$GOOGL.Close)

# all return similar outliers lets take a look

for(i in ol$index){
  print(prices.returns[i,])
}

# Most of the dates look like they could be around quarterly earnings let's check

# relevent GOOGL announce dates: 
# 7-16-15, 10-22-15, 4-21-16, 2-1-18, 4-23-18, 10-25-18*, 4-29-19, 7-25-19

# 8-21-15 and 8-26-15 were during the August 2015 market melt down
# the feb 2018 outliers were during the levered short vix market crisis
# both dates in december 2018 were in the incredibly volatile month of dec and then the end of year rally

# This covers all the outlier dates except 6-3-2019, This was due to a never before seen Google Cloud outage the day before

#let's try again without these

prices.returns.no.out = prices.returns

j = 1

for(i in ol$index){
  prices.returns.no.out[i,]$GOOGL.Close = ol$replacements[j]
  j=j+1
}

arima.small = auto.arima(prices.returns.no.out$GOOGL.Close)
summary(arima.small)

arima.big = auto.arima(prices.returns.no.out$GOOGL.Close, max.p = 10, max.q = 10, max.order = 20, stepwise = F, trace = TRUE)
summary(arima.big)

pred.arima.small = forecast(arima.small, h=20)
pred.arima.big = forecast(arima.big, h=20)


pred.arima.small.prices = convert.to.price(px.start, pred.arima.small$mean)
pred.arima.small.prices.single = convert.to.price.single(px, pred.arima.small$mean)
smape.small.arima.no.out = sMAPE(px[2:21], pred.arima.small.prices)
smape.small.arima.no.out.single = sMAPE(px[2:21], pred.arima.small.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.arima.small.prices, col='blue')
points(pred.arima.small.prices.single, col='red')


pred.arima.big.prices = convert.to.price(px.start, pred.arima.big$mean)
pred.arima.big.prices.single = convert.to.price.single(px, pred.arima.big$mean)
smape.big.arima.no.out = sMAPE(px[2:21], pred.arima.big.prices)
smape.big.arima.no.out.single = sMAPE(px[2:21], pred.arima.big.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.arima.big.prices, col='blue')
points(pred.arima.big.prices.single, col='red')


#######################
## Can we retry our regressions without outliers?
########################
# if we want to retry our regression we have to do the outlier process for each column
head(prices.returns)

display.outliers = function(ol, ts, c)
{
  j = 1
  
  for(i in ol$index){
    print(ts[i, c])
    j=j+1
  }
}

replace.outliers = function(js, ol, ts, c)
{
  for(j in js){
    ts[ol$index[j], c] = ol$replacements[j]
  }
  
  return(ts)
}

dis.ol = tsoutliers(prices.returns.no.out$DIS.Return.Prev)

display.outliers(dis.ol, prices.returns.no.out, 'DIS.Return.Prev')
#earnings 2015-02-03, 2015-08-04
#2015-08-21 was the 2015 crash, 2018-12-27 was the 2018 christmas rally
dis.js = c(1, 2, 8, 9)
prices.returns.no.out = replace.outliers(dis.js, dis.ol, prices.returns.no.out, 'DIS.Return.Prev')

nwsa.ol = tsoutliers(prices.returns.no.out$NWSA.Return.Prev)
display.outliers(nwsa.ol, prices.returns.no.out, 'NWSA.Return.Prev') 
# earnings: 2015-05-15, 2015-08-14, 2015-02-08 (shift from friday to monday), 2017-02-13, 2018-05-14, 2018-08-13
# market crash 2018-08-25
nwsa.js = c(1,2,3,4,7,8,9)
prices.returns.no.out = replace.outliers(nwsa.js, nwsa.ol, prices.returns.no.out, 'NWSA.Return.Prev')


t.ol = tsoutliers(prices.returns.no.out$T.Return.Prev)
display.outliers(t.ol, prices.returns.no.out, 'T.Return.Prev') 
# earnings: 2017-07-27, 2018-02-02, 2018-04-27, 2018-07-26, 2019-01-31, 2019-04-25, 
# market crash 2018-10-25
t.js = c(1,3,4,6,7,8,9)
prices.returns.no.out = replace.outliers(t.js, t.ol, prices.returns.no.out, 'T.Return.Prev')


nflx.ol = tsoutliers(prices.returns.no.out$NFLX.Return.Prev)
display.outliers(nflx.ol, prices.returns.no.out, 'NFLX.Return.Prev') 
# earnings: 2015-01-22, 2015-04-17, 2015-07-17, 2016-01-14, 2016-04-20, 2016-07-20, 2016-10-19, 2017-07-19, 2018-01-24, 2019-07-19
nflx.js = c(1,2,3,4,5,6,7,8,9,12)
prices.returns.no.out = replace.outliers(nflx.js, nflx.ol, prices.returns.no.out, 'NFLX.Return.Prev')


#replace GOOGL returnprev as well
j = 1

for(i in ol$index){
  prices.returns.no.out[i+1,'GOOGL.Return.Prev'] = ol$replacements[j]
  j=j+1
}

# try out the lms
no.out.lm = lm(GOOGL.Close ~ ., data = prices.returns.no.out)
summary(no.out.lm)

no.out.lm.arima = auto.arima(prices.returns.no.out[,'GOOGL.Close'], xreg = prices.returns.no.out[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
summary(no.out.lm.arima)

pred.no.out.lm.arima = forecast(no.out.lm.arima, xreg = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

pred.no.out.lm = predict(no.out.lm, newdata = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])


pred.no.out.lm.prices = convert.to.price(px.start, pred.no.out.lm)
pred.no.out.lm.prices.single = convert.to.price.single(px, pred.no.out.lm)
smape.no.out.lm = sMAPE(px[2:21,], pred.no.out.lm.prices)
smape.no.out.lm.single = sMAPE(px[2:21,], pred.no.out.lm.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.no.out.lm.prices, col='blue')
points(pred.no.out.lm.prices.single, col='red')


pred.no.out.lm.arima.prices = convert.to.price(px.start, pred.no.out.lm.arima$mean)
pred.no.out.lm.arima.prices.single = convert.to.price.single(px, pred.no.out.lm.arima$mean)
smape.no.out.lm.arima = sMAPE(px[2:21], pred.no.out.lm.arima.prices)
smape.no.out.lm.arima.single = sMAPE(px[2:21], pred.no.out.lm.arima.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.no.out.lm.arima.prices, col='blue')
points(pred.no.out.lm.arima.prices.single, col='red')

head(prices.returns.no.out)
prices.returns.no.out.no.range = prices.returns.no.out[, c('GOOGL.Close', 'GOOGL.Range.Prev', 'GOOGL.Return.Prev')]

no.out.no.range.lm = lm(GOOGL.Close ~ . , data = prices.returns.no.out.no.range)
summary(no.out.no.range.lm)

no.out.lm.arima = auto.arima(prices.returns.no.out[,'GOOGL.Close'], xreg = prices.returns.no.out[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
summary(no.out.lm.arima)

pred.no.out.lm.arima = forecast(no.out.lm.arima, xreg = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

pred.no.out.no.range.lm = predict(no.out.no.range.lm, newdata = test[,c('GOOGL.Range.Prev', 'GOOGL.Return.Prev')])

pred.no.out.no.range.lm.prices = convert.to.price(px.start, pred.no.out.no.range.lm)
pred.no.out.no.range.lm.prices.single = convert.to.price.single(px, pred.no.out.no.range.lm)
smape.no.out.no.range.lm = sMAPE(px[2:21,], pred.no.out.no.range.lm.prices)
smape.no.out.no.range.lm.single = sMAPE(px[2:21,], pred.no.out.no.range.lm.prices.single)

plot.ts(px[2:21,], main = 'No Outlier Regression', xlab = 'date', ylab = 'GOOGL price')
points(as.data.frame(px[2:21,]), col='orange')
points(pred.no.out.no.range.lm.prices, col='blue')
legend('topright', legend = c('Observed Price', 'Predicted Price'), col = c('orange', 'blue'), pch = 'o')
points(pred.no.out.no.range.lm.prices.single, col='red')


#######################
## VARMA no outliers
######################

head(train.varma)

nflx.varma.ol = tsoutliers(train.varma$NFLX.Close)
train.varma.no.out = replace.outliers(nflx.js, nflx.varma.ol, train.varma, 'NFLX.Close')

dis.varma.ol = tsoutliers(train.varma.no.out$DIS.Close)
train.varma.no.out = replace.outliers(dis.js, dis.varma.ol, train.varma.no.out, 'DIS.Close')

nwsa.varma.ol = tsoutliers(train.varma.no.out$NWSA.Close)
train.varma.no.out = replace.outliers(nwsa.js, nwsa.ol, train.varma.no.out, 'NWSA.Close')

t.varma.ol = tsoutliers(train.varma.no.out$T.Close)
train.varma.no.out = replace.outliers(t.js, t.ol, train.varma.no.out, 'T.Close')

train.varma.no.out = replace.outliers(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14), ol, train.varma.no.out, 'GOOGL.Close')

mod1.no.out = VARMA(as.matrix(train.varma.no.out))
mod2.no.out = VARMA(as.matrix(train.varma.no.out), include.mean = F)

pred.varma.no.out.mod1 = VARMApred(mod1.no.out, h=20)
pred.varma.no.out.mod2 = VARMApred(mod2.no.out, h=20)

pred.varma.mod1.no.out.prices = convert.to.price(px.start, pred.varma.no.out.mod1$pred[,5])
pred.varma.mod1.no.out.prices.single = convert.to.price.single(px, pred.varma.no.out.mod1$pred[,5])
smape.varma.no.out.mean = sMAPE(px[2:21], pred.varma.mod1.no.out.prices)
smape.varma.mean.no.out.single = sMAPE(px[2:21], pred.varma.mod1.no.out.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.varma.mod1.no.out.prices, col='blue')
points(pred.varma.mod1.no.out.prices.single, col='red')


pred.varma.mod2.no.out.prices = convert.to.price(px.start, pred.varma.no.out.mod2$pred[,5])
pred.varma.mod2.no.out.prices.single = convert.to.price.single(px, pred.varma.no.out.mod2$pred[,5])
smape.varma.no.out.nomean = sMAPE(px[2:21], pred.varma.mod2.no.out.prices)
smape.varma.no.out.nomean.single = sMAPE(px[2:21], pred.varma.mod2.no.out.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.varma.mod2.no.out.prices, col='blue')
points(pred.varma.mod2.no.out.prices.single, col='red')


########################
## sMAPEs of all models
#######################

rbind(smape.null,
smape.lm,
smape.lm.arima,
smape.small.arima,
smape.big.arima,
smape.varma.mean,
smape.varma.nomean,
smape.small.arima.no.out,
smape.big.arima.no.out,
smape.no.out.lm,
smape.no.out.lm.arima,
smape.varma.no.out.mean,
smape.varma.no.out.nomean,
smape.no.out.no.range.lm)


rbind(smape.null,
smape.lm.single,
smape.lm.arima.single,
smape.small.arima.single,
smape.big.arima.single,
smape.varma.mean.single,
smape.varma.nomean.single,
smape.small.arima.no.out.single,
smape.big.arima.no.out.single,
smape.no.out.lm.single,
smape.no.out.lm.arima.single,
smape.varma.mean.no.out.single,
smape.varma.no.out.nomean.single)


sMAPE(GOOGL$GOOGL.Close[3:1259], GOOGL$GOOGL.Close[2:1258]*exp(no.out.lm$fitted.values[1:1257]))
sMAPE(GOOGL.shift$GOOGL.Close[3:1259], GOOGL.shift$GOOGL.Close.shift[3:1259])

########################
## Fit over fewer days
#######################

refit.evaluate.models = function(data.fit, data.test, tmp)
{
  arima.big = auto.arima(data.fit$GOOGL.Close, max.p = 8, max.q = 8, max.order = 8, stepwise = TRUE)
  #varma = VARMA(data.fit[, c('DIS.Close', 'NWSA.Close', 'NFLX.Close', 'T.Close', 'GOOGL.Close')])
  simple.lm = lm(GOOGL.Close~., data = data.fit[, c('GOOGL.Close', 'GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
  arima.lm = auto.arima(data.fit[,'GOOGL.Close'], xreg = data.fit[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
  
  h=length(data.test$GOOGL.Close)
  
  pred.arima = forecast(arima.big, h = h)
  pred.arima.lm = forecast(arima.lm, xreg = data.test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
  pred.simple.lm = predict(no.out.lm, newdata = data.test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
  #pred.varma = VARMApred(varma, h = h)
  
  start.px = tail(data.fit$GOOGL.Close.px, 1)
  
  pred.arima.price = convert.to.price(start.px, pred.arima$mean)
  pred.arima.lm.price = convert.to.price(start.px, pred.arima.lm$mean)
  pred.simple.lm.price =convert.to.price(start.px, pred.simple.lm)
  #pred.varma.price = convert.to.price(px.start, pred.varma$pred[,5])
  
  smape.arima = sMAPE(data.test$GOOGL.Close.px, pred.arima.price)
  smape.arima.lm = sMAPE(data.test$GOOGL.Close.px, pred.arima.lm.price)
  smape.simple.lm = sMAPE(data.test$GOOGL.Close.px, pred.simple.lm.price)
  #smape.varma = sMAPE(data.test$GOOGL.Close.px, pred.arima.price)
  
  tmp$arima = cbind(tmp$arima, smape.arima)
  tmp$arima.lm = cbind(tmp$arima, smape.arima.lm)
  tmp$simple.lm = cbind(tmp$arima, smape.simple.lm)
  #tmp$varma = cbind(tmp$arima, smape.varma)
  
  return(tmp)
}

data.length = length(all.prices$GOOGL.Close)
n.data.points = c(20,60,90,120)

smape.mean = matrix(nrow = 3, ncol = 4)
smape.sd = matrix(nrow = 3, ncol = 4)

j = 1
for(n in n.data.points){
  tmp = c()
  tmp$arima = c()
  tmp$arima.lm = c()
  tmp$simple.lm = c()
  #tmp$varma = c()
  
  curr.idx = 1
  while(curr.idx+n+22 < data.length) {
    data.fit = all.prices[curr.idx:(curr.idx+n),]
    data.test = all.prices[(curr.idx+n+1):(curr.idx+n+22),]
    tmp = refit.evaluate.models(data.fit, data.test, tmp)
    curr.idx = curr.idx+1
    
    if(curr.idx %% 100 == 0) {print(curr.idx)}
  }
  
  print(n)
  
  smape.mean[1,j] = mean(tmp$arima)
  smape.sd[1,j] = sd(tmp$arima)
  
  smape.mean[2,j] = mean(tmp$arima.lm)
  smape.sd[2,j] = sd(tmp$arima.lm)
  
  smape.mean[3,j] = mean(tmp$simple.lm)
  smape.sd[3,j] = sd(tmp$simple.lm)
  
  j=j+1
}

colnames(smape.mean) = n.data.points
colnames(smape.sd) = n.data.points

rownames(smape.mean) = c('arima', 'regression.arima', 'regression')
rownames(smape.sd) = c('arima', 'regression.arima', 'regression')

print(smape.mean[,1:6])
smape.sd[,1:6]

###################
## final models
##################
n = length(prices.returns.no.out$GOOGL.Close)
final.data = prices.returns.no.out[(n-60):n,]

head(final.data)
tail(final.data)

final.lm = lm(GOOGL.Close ~ ., data = final.data)
summary(final.lm)

length(final.data$GOOGL.Close)

final.lm.arima = auto.arima(final.data[,'GOOGL.Close'], xreg = final.data[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])
summary(final.lm.arima)

pred.final.lm.arima = forecast(final.lm.arima, xreg = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

pred.final.lm = predict(final.lm, newdata = test[,c('GOOGL.Range.Prev', 'DIS.Return.Prev', 'NFLX.Return.Prev', 'NWSA.Return.Prev', 'T.Return.Prev', 'GOOGL.Return.Prev')])

px.start = tail(GOOGL['2015-01-01/2020-01-02']$GOOGL.Close, 1)

pred.final.lm.prices = convert.to.price(px.start, pred.final.lm)
pred.final.lm.prices.single = convert.to.price.single(px, pred.final.lm)
smape.final.lm = sMAPE(px[2:21,], pred.final.lm.prices)
smape.final.lm.single = sMAPE(px[2:21,], pred.final.lm.prices.single)

plot.ts(px[2:21,])
points(as.data.frame(px[2:21,]), col='green')
points(pred.final.lm.prices, col='blue')
points(pred.final.lm.prices.single, col='red')


pred.final.lm.arima.prices = convert.to.price(px.start, pred.final.lm.arima$mean)
pred.final.lm.arima.prices.single = convert.to.price.single(px, pred.final.lm.arima$mean)
smape.final.lm.arima = sMAPE(px[2:21], pred.final.lm.arima.prices)
smape.final.lm.arima.single = sMAPE(px[2:21], pred.final.lm.arima.prices.single)

plot.ts(px[2:21,], main = 'Final Regression', xlab = 'date', ylab = 'GOOGL price')
points(as.data.frame(px[2:21,]), col='orange')
points(pred.final.lm.arima.prices, col='blue')
legend('topright', legend = c('Observed Price', 'Predicted Price'), col = c('orange', 'blue'), pch = 'o')
points(pred.final.lm.arima.prices.single, col='red')

smape.final.lm
smape.final.lm.arima


##################
## actual trades
##################

calc.trades = function(predictions) 
{
  l = length(predictions)
  trades = numeric(l)
  
  i = 2
  while(i < l){
    if((predictions[i-1] < predictions[i]) && (predictions[i+1] < predictions[i])){trades[i] = -100}
    else if((predictions[i-1] > predictions[i]) && (predictions[i+1] > predictions[i])){trades[i] = 100}
    i=i+1
  }
  trades[i] = -1*sum(trades)
  return(trades)
}

calc.pnl = function(trades, prices)
{
  pnl = 0
  for (i in seq(1:length(prices))){
    pnl = pnl + -1*trades[i]*prices[i]
  }
  return(pnl)
}

trades.lm.arima = calc.trades(pred.final.lm.arima.prices)
calc.pnl(trades.lm.arima, as.vector(px[2:21]$GOOGL.Close))

trades.lm = calc.trades(pred.final.lm.prices)
calc.pnl(trades.lm, as.vector(px[2:21]$GOOGL.Close))
trades.lm
trades.lm.arima


smape.mean
smape.sd
