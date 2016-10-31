library(caret)
data.all= as.data.frame(rgb_feature)
names(data.all)[801]= "filelabel"
data.all$filelabel = as.factor(data.all$filelabel)
predict_results =matrix(nrow=5, ncol= 5)
index= sample(rep(1:5,400))
cor_pred= list()
final_results= vector()
for(i in 1:5){
  data.train= data.all[index != i,]
  data.test= data.all[index==i,]
  data.train= data.train[sample(1600,1600),]
  data.test=data.test[sample(400,400),]
  ##########################################
  # ADA boost
  #########################################
  ada.fit= ada(filelabel~.,data=data.train,iter=20,nu=0.05,type="discrete")
  ada.predict = predict(ada.fit,newdata=data.test,type="vector")
  #mean(data.test$filelabel==ada.predict)  # nu=1: 0.61; mu=0.1: 0.68；mu=0.01: 0.6875
  predict_results[i,1]= mean(data.test$filelabel==ada.predict)
  ##########################################
  # GBM
  #########################################
  library(gbm) 
  gbm.fit <- gbm(filelabel~., data = data.train, distribution = "gaussian", n.tree= 1000, 
                 shrinkage = 0.001)
  gbm.predict <- predict(gbm.fit, newdata=data.test, n.trees= 100)
  gbm.predict=as.numeric(gbm.predict > mean(gbm.predict)) 
  predict_results[i,2]= mean(data.test$filelabel==gbm.predict)
  ##########################################
  # Random Forest
  #########################################
  library(randomForest)
  tree.rf.fit <- randomForest(filelabel~., data = data.train)
  out.rf <- predict(gbm.fit, newdata=data.test,n.trees= 500)
  rf.predict=as.numeric(out.rf > mean(out.rf)) 
  predict_results[i,3]= mean(data.test$filelabel==rf.predict)
  ##########################################
  # svm
  ##########################################
  #library(e1071)
  #svm.fit=svm(filelabel~., data = data.train,kernel="radial",scale = T)
  #svm.pred= predict(svm.fit,newdata = data.test)
  #predict_results[1,4]=mean(data.test$filelabel==svm.pred)
  ##########################################
  # Knn
  ##########################################
  library(class)
  knn.pred= knn(data.train[,-801], data.test[,-801], cl= data.train$filelabel, k = 7, l = 1)
  predict_results[i,4]=mean(data.test$filelabel==knn.pred)
  ##########################################
  # logistic
  ##########################################
  #glm.log = glm(filelabel ~ .,family="binomial", data=data.train)
  #glm.log.pred= predict(glm.log,newdata = data.test,type = "response")
  #glm.log.pred= as.numeric(glm.log.pred > mean(glm.log.pred))
  #mean(data.test$filelabel==glm.log.pred)
  #######
  library(xgboost)
  xg.fit <- xgboost(data = as.matrix(data.train[,1:800]), label = as.numeric(data.train$filelabel)-1, max.depth=10,
                eta = 0.3, nround = 10, objective = 'binary:logistic')
  xg.pred <- predict(xg.fit, as.matrix(data.test[,1:800]))
  xg.pred <- as.numeric(xg.pred > mean(xg.pred))
  predict_results[i,5] <- mean(data.test$filelabel == xg.pred)
  ########

  results = data.frame(ada=as.numeric(ada.predict)-1, gbm=gbm.predict,rf= rf.predict
                       ,knn=as.numeric(knn.pred)-1,xg=xg.pred)
  cor_pred[[i]]= cor(results)
  test= as.numeric(rowMeans(results)>0.5)
  final_results[i]= mean(data.test$filelabel==test)
  
}
