######################################################
### Fit the classification model with testing data 
### Author: Jiayu Wang
######################################################

#data.test= data.all[-index,-801]
#train=result
test <- function(train, data.test){
  
  ### Fit the classfication model with testing data
  
  ### Input: 
  ###  - the fitted classification model using training data
  ###  -  processed features from testing images 
  ### Output: training model specification
  
  ### load libraries
  library(data.table)
  library(EBImage)
  library(dplyr)
  library(xgboost)
  library(MASS)
  library(ada)
  library(gbm)
  library(randomForest)
  library(tree)
  library(e1071)
  library(pROC)
  library(class)
  library(neuralnet)
  
  
  predict_results = vector()
  
  ##ada
  ada.predict <- predict(train$fit_ada,newdata=data.test[,1:800],type="vector")
  #predict_results[1]= mean(data.test$filelabel==ada.predict)
  
  ##randeom forest
  rf.predict <- predict(train$fit_rf, newdata=data.test[,1:800],n.trees= 600)
  #predict_results[2]= mean(data.test$filelabel==rf.predict)
  
  ##svm
  #svm.pred= predict(train$svm_fit,newdata = data.test)
  #predict_results[3]=mean(data.test$filelabel==svm.pred)
  
  ##knn
  knn.pred= knn(train$dat_train, data.test[,1:800], cl= train$label_train, k = train$k)
  #predict_results[4]=mean(data.test$filelabel==knn.pred)
  
  ##xgboost
  xg.pred <- predict(train$fit_xgboost, as.matrix(data.test[,1:800]))
  xg.pred <- as.numeric(xg.pred > mean(xg.pred))
  #predict_results[5] <- mean(data.test$filelabel == xg.pred)
  
  ##gbm
  gbm.pred <- predict(fit_gbm, data.test[,1:800])
  gbm.pred <- as.numeric(gbm.pred > mean(gbm.pred))
    
  ##majority vote
  results = data.frame(ada=as.numeric(ada.predict)-1, 
                       #gbm=gbm.predict,
                       rf= as.numeric(rf.predict)-1,
                       #svm=as.numeric(svm.pred)-1,
                       knn=as.numeric(knn.pred)-1,
                       xg=xg.pred,
                      gbm = gbm.pred)
  
  test= as.numeric(rowMeans(results)>0.5)
  return(test)
  
}

