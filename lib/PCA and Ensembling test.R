###PCA
setwd("~/Sem 2/Applied Data Science/Project 3")
library(data.table)
library(caretEnsemble)
library(caret)
library(rpart)
library(pROC)
sift= fread("sift_features.csv", header= F)
labels <- dir("images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
labels= substr(labels,1,nchar(labels)-4)
labels.df = data.frame(filename= labels, filelabel= filelabel)

Data.pca=as.data.frame(t(fread("sift_features.csv")))
#test= Data.pca[1:50,1:1000]
feature_pca= prcomp(Data.pca)
scores= as.data.frame(cbind(feature_pca$x,filelabel))
names(scores)[2001]= "filelabel"
dim(feature_pca$x)


scores$filelabel = factor(scores$filelabel, labels = c("no", "yes"))
sample= sample(nrow(scores),0.8*nrow(scores))
#data.train= data.all[sample,]
#data.test= data.all[-sample,]
#sample.col= sample(5000,1000)
data.train= scores[sample,c(1:1000,2001)]
data.test=scores[-sample,c(1:1000,2001)]
control <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions="final", classProbs=TRUE)
algorithmList <- c('rpart', 'knn')  #deleted 'glm'
models <- caretList(filelabel~., data=data.train, trControl=control, methodList=algorithmList) # model_list
xyplot(resamples(models))
results <- resamples(models)
summary(results)
dotplot(results)
modelCor(results)
splom(results)
##################
#stackControl <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions=TRUE, classProbs=TRUE)
#set.seed(100)
#stack.glm <- caretStack(models, method="glm", metric="ROC", trControl=stackControl)
#print(stack.glm)
##############################################

#greedy_ensemble <- caretEnsemble(models, metric="ROC",trControl=stackControl)
greedy_ensemble <- caretEnsemble( models,  metric="ROC", 
                                  trControl=trainControl(number=2,summaryFunction=twoClassSummary,
                                                         classProbs=TRUE
                                  ))
summary(greedy_ensemble)
##############
### test set
#library("caTools")
#model_preds <- lapply(models, predict, newdata=testing, type="prob")
#model_preds <- lapply(models, function(x) x[,"M"])
#model_preds <- data.frame(model_preds)
ens_preds <- predict(greedy_ensemble, newdata=data.test)
#bb= as.factor(ens_preds>0.5)
#cc= factor(bb, labels= c("no","yes"))
#model_preds$ensemble <- ens_preds
#caTools::colAUC(ens_preds, data.test$filelabel)
mean(ens_preds== data.test$filelabel) # 40.25 Do not use it!!!
