setwd("~/Desktop/ADS/Proj3-grp7")
library(data.table)

#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library(EBImage)
library(dplyr)
library(xgboost)
library(MASS)
library(gbm)
library(e1071)
sift= fread("sift_features.csv", header= F)
labels <- dir("images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
labels= substr(labels,1,nchar(labels)-4)
labels.df = data.frame(filename= labels, filelabel= filelabel)

sift.df= as.data.frame(t(sift))
colnames(sift.df)[1] <- "filename"

data.all= merge(sift.df,labels.df, by= names(sift.df)[1])[,-1]
data.all = as.data.frame(apply(data.all,2, as.numeric))
data.all$filelabel = as.factor(data.all$filelabel)
#############################################################
###  support vector machine  ###
sample= sample(nrow(data.all),0.8*nrow(data.all))
dat_train= data.all[sample]
dat_test= data.all[-sample]
lab_train=data.all[sample,5001]
lab_test=data.all[-sample,5001]

svm_fit=svm(x=dat_train,y=lab_train,kernel="linear",scale = F)
#############################################################
###  support vector machine ###
svm.pred= predict(base.svm,newdata = dat_test)
mean(lab_test==svm.pred)
