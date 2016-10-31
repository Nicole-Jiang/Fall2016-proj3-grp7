######################################################
### Fit the classification model with testing data ###
######################################################


test <- function(fit_train, data.test){
  
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
  
  
  predict_results = vector()
  
  ##ada
  ada.predict <- predict(train$fit.ada,newdata=data.test,type="vector")
  predict_results[1]= mean(data.test$filelabel==ada.predict)
  
  ##randeom forest
  out.rf <- predict(gbm.fit, newdata=data.test,n.trees= train$ntrees)
  rf.predict=as.numeric(out.rf > mean(out.rf)) 
  predict_results[2]= mean(data.test$filelabel==rf.predict)
  
  ##svm
  svm.pred= predict(svm.fit,newdata = data.test)
  predict_results[3]=mean(data.test$filelabel==svm.pred)
  
  ##knn
  knn.pred= knn(data.train[,-801], data.test[,-801], cl= data.train$filelabel, k = train$k)
  predict_results[4]=mean(data.test$filelabel==knn.pred)
  
  ##xgboost
  xg.pred <- predict(xg.fit, as.matrix(data.test[,1:800]))
  xg.pred <- as.numeric(xg.pred > mean(xg.pred))
  predict_results[5] <- mean(data.test$filelabel == xg.pred)
  
  ##majority vote
  results = data.frame(ada=as.numeric(ada.predict)-1, 
                       gbm=gbm.predict,rf= rf.predict,
                       svm=as.numeric(svm.pred)-1,
                       knn=as.numeric(knn.pred)-1)
  
  test= as.numeric(rowMeans(results)>0.5)
  mean(data.test$filelabel==test)
  return(as.numeric(pred> 0.5))
  
}

