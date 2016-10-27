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
sample.col= sample(5000,1000)
data.train= data.all[sample,c(sample.col,5001)]
data.test=data.all[-sample,c(sample.col,5001)]
glm.log = glm(filelabel ~ .,family="binomial", data=data.train)
glm.log.pred= predict(glm.log,newdata = data.test,type = "response")
glm.log.pred= as.numeric(glm.log.pred > 0.5)
mean(data.test$filelabel==glm.log.pred)
##############################################################
##  boost adaboost stump ##
library(ada)
ada.fit= ada(filelabel~.,data=data.train,iter=20,nu=1,type="discrete")
ada.predict <- predict(ada.fit,newdata=data.test,type="vector")
mean(data.test$filelabel==ada.predict)  # 0.65

##############################################################
library(gbm) 
#n.tree= 1000: 0.63; ntree=100:0.52; n.tree= 2000:0.61

gbm.fit <- gbm(filelabel~., data = data.train, distribution = "gaussian", n.tree= 1000, 
               shrinkage = 0.001)
gbm.predict <- predict(gbm.fit, newdata=data.test, n.trees= 100)
#gbm.predict = (gbm.predict-min(gbm.predict))/(max(gbm.predict)-min(gbm.predict))
gbm.predict=as.numeric(gbm.predict > mean(gbm.predict)) 
mean(data.test$filelabel==gbm.predict) 

##############################################################
library(xgboost)
xg.fit= xgboost(data= as.matrix(data.train[,-1001]),label= data.train$filelabel, nrounds=2)
xg.predict <- predict(xg.fit,as.matrix(data.test[,-1001]))
xg.predict=as.numeric(xg.predict > mean(xg.predict)) 
mean(data.test$filelabel==xg.predict) 


write.csv(data.all, file= "data.csv")



