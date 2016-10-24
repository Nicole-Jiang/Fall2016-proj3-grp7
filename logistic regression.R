setwd("~/Documents/Courses/ADS/Project 3")
library(data.table)
#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library(EBImage)
library(dplyr)
library(xgboost)
library(MASS)
library(gbm)
sift= fread("Project3_poodleKFC_train/sift_features.csv", header= F)
labels <- dir("Project3_poodleKFC_train/images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
labels= substr(labels,1,nchar(labels)-4)
labels.df = data.frame(filename= labels, filelabel= filelabel)

sift.df= as.data.frame(t(sift))
colnames(sift.df)[1] <- "filename"

data.all= merge(sift.df,labels.df, by= names(sift.df)[1])[,-1]
data.all = as.data.frame(apply(data.all,2, as.numeric))
data.all$filelabel = as.factor(data.all$filelabel)
#############################################################
###  logistic regression  ###
sample= sample(nrow(data.all),0.8*nrow(data.all))
data.train= data.all[sample,]
data.test= data.all[-sample,]
glm.log = glm(filelabel ~ ., family=binomial("logit"), data=data.train)
#############################################################
###  logistic regression  ###
sample= sample(nrow(data.all),0.8*nrow(data.all))
sample.col= sample(5000,200)
data.train= data.all[sample,c(sample.col,5001)]
data.test=data.all[-sample,c(sample.col,5001)]
glm.log = glm(filelabel ~ .,family="binomial", data=data.train)
glm.log.pred= predict(glm.log,newdata = data.test,type = "response")
glm.log.pred= as.numeric(glm.log.pred > 0.5)
mean(data.test$filelabel==glm.log.pred)
##############################################################
##  boost adaboost stump
library(ada)
ada.fit= ada(filelabel~.,data=data.train,iter=20,nu=1,type="discrete")
ada.predict <- predict(ada.fit,newdata=data.test,type="vector")
mean(data.test$filelabel==ada.predict)  # 0.595





