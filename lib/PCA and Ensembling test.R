###PCA
library(data.table)
library(caretEnsemble)
library(caret)
library(rpart)
library(pROC)
library(class)
labels <- dir("images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
Data.pca=as.data.frame(t(fread("sift_features.csv")))
#test= Data.pca[1:50,1:1000]
feature_pca= prcomp(Data.pca)
scores= as.data.frame(cbind(feature_pca$x, filelabel))
scores$filelabel= as.factor(filelabel)
#scores$filelabel = factor(scores$filelabel, labels = c("no", "yes"))
sample= sample(nrow(scores),0.8*nrow(scores))
#data.train= data.all[sample,]
#data.test= data.all[-sample,]
#sample.col= sample(5000,1000)
data.train= scores[sample,c(1:1000,2001)]
data.test=scores[-sample,c(1:1000,2001)]
##############################################
## ensemple stack
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
ens_preds <- predict(greedy_ensemble, newdata=data.test)
#bb= as.factor(ens_preds>0.5)
#cc= factor(bb, labels= c("no","yes"))
#model_preds$ensemble <- ens_preds
#caTools::colAUC(ens_preds, data.test$filelabel)
mean(ens_preds== data.test$filelabel) # 40.25 Do not use it!!!
##########################################
# ADA boost
#########################################
ada.fit= ada(filelabel~.,data=data.train,iter=20,nu=0.05,type="discrete")
ada.predict <- predict(ada.fit,newdata=data.test,type="vector")
mean(data.test$filelabel==ada.predict)  # nu=1: 0.61; mu=0.1: 0.68；mu=0.01: 0.6875
predict_results = vector()
predict_results[1]= mean(data.test$filelabel==ada.predict)
##########################################
# GBM
#########################################
library(gbm) 
gbm.fit <- gbm(filelabel~., data = data.train, distribution = "gaussian", n.tree= 1000, 
               shrinkage = 0.001)
gbm.predict <- predict(gbm.fit, newdata=data.test, n.trees= 100)
gbm.predict=as.numeric(gbm.predict > mean(gbm.predict)) 
predict_results[2]= mean(data.test$filelabel==gbm.predict)
##########################################
# Random Forest
#########################################
library(randomForest)
tree.rf.fit <- randomForest(filelabel~., data = data.train)
out.rf <- predict(gbm.fit, newdata=data.test,n.trees= 500)
rf.predict=as.numeric(out.rf > mean(out.rf)) 
predict_results[3]= mean(data.test$filelabel==rf.predict)
##########################################
# svm
##########################################
svm.fit=svm(filelabel~., data = data.train,kernel="radial")
svm.pred= predict(svm.fit,newdata = data.test)
predict_results[4]=mean(data.test$filelabel==svm.pred)
##########################################
# Knn
##########################################
knn.pred= knn(data.train[,-1001], data.test[,-1001], cl= data.train$filelabel, k = 7, l = 1)
predict_results[5]=mean(data.test$filelabel==knn.pred)


results = data.frame(ada=as.numeric(ada.predict)-1, gbm=gbm.predict,rf= rf.predict,
                     svm=as.numeric(svm.pred)-1,knn=as.numeric(knn.pred)-1)
cor(results)
test= as.numeric(rowMeans(results)>0.5)
mean(data.test$filelabel==test)
