## cross validation
data.all= as.data.frame(rgb_feature)
names(data.all)[801]= "filelabel"
data.all$filelabel = as.factor(data.all$filelabel)
#data.all$filelabel=factor(data.all$filelabel,labels = c("no", "yes"))
set.seed(10)
index= sample(rep(1:5,400))
predict_results= vector()
for( i in 1:5){
  dat_train= data.all[index != i,-801]
  label_train= data.all[index != i,801]
  data.test= data.all[index==i,]
  ada.fit= ada(label_train~.,data=dat_train,type="discrete")
  ada.predict = predict(ada.fit,newdata=data.test,type="vector")
  predict_results[i]= mean(data.test$filelabel==ada.predict)
}
####################### ransom forest
predict_results= vector()
for(i in 1:5){
  dat_train= data.all[index != i,-801]
  label_train= data.all[index != i,801]
  data.test= data.all[index==i,]
  bestmtry <- tuneRF(y=label_train, x=dat_train, stepFactor=1.5, improve=1e-5, ntree=600)
  best.mtry <- bestmtry[,1][which.min(bestmtry[,2])]
  rf.fit=randomForest(label_train~., dat_train, mtry=best.mtry, ntree=600, importance=T)
  out.rf <- predict(rf.fit, newdata=data.test,n.trees= 600)
  predict_results[i]= mean(data.test$filelabel==out.rf)
}

####################### knn
predict_results= vector()
for(ii in 1:5){
  dat_train= data.all[index != ii,-801]
  label_train= data.all[index != ii,801]
  dat_test= data.all[index==ii,]
  knn.Tuning<-data.frame(k=1:10,cvError=rep(NA,10))
  for(i in 1:nrow(knn.Tuning)){
    index= sample(rep(1:5,nrow(dat_train)/5))
    cvError.temp=0
    for(j in 1:5){
      data.train= dat_train[index != j,]
      data.test= dat_train[index==j,]
      knn.temp= knn(data.train, data.test, cl=label_train[index != j] , k = knn.Tuning$k[i])
      cvError.temp=cvError.temp+(1- mean(label_train[index == j]==knn.temp))/5
    }
    knn.Tuning$cvError[i]= cvError.temp
  }
  knn.Tuning<-knn.Tuning[order(knn.Tuning$cvError),]
  knn.pred= knn(dat_train[,-801], dat_test[,-801], cl= label_train, k = knn.Tuning$k[1])
  predict_results[ii]=mean(dat_test$filelabel==knn.pred)
}


####################### xgboost
predict_results= vector()
for( i in 1:5){
  dat_train= data.all[index != i,-801]
  label_train= data.all[index != i,801]
  data.test= data.all[index==i,]
  dtrain <- xgb.DMatrix(as.matrix(dat_train),label = as.numeric(label_train)-1)
  best_param = list()
  best_seednumber = 1234
  best_logloss = Inf
  best_logloss_index = 0
  
  for (iter in 1:40) {
    param <- list(objective = "binary:logistic",
                  max_depth = sample(6:10, 1),
                  eta = runif(1, .01, .3),
                  gamma = runif(1, 0.0, 0.2) 
    )
    cv.nround = 50
    cv.nfold = 5
    seed.number = sample.int(10000, 1)[[1]]
    set.seed(seed.number)
    mdcv <- xgb.cv(data=dtrain, params = param, nthread=6, 
                   nfold=cv.nfold, nrounds=cv.nround,
                   verbose = T, early.stop.round=8, maximize=FALSE)
    
    min_logloss = min(mdcv[, test.error.mean])
    min_logloss_index = which.min(mdcv[, test.error.mean])
    
    if (min_logloss < best_logloss) {
      best_logloss = min_logloss
      best_logloss_index = min_logloss_index
      best_seednumber = seed.number
      best_param = param
    }
  }
  nround = best_logloss_index
  set.seed(best_seednumber)
  xg.fit <- xgboost(data=dtrain, params=best_param, nrounds=nround, nthread=6)
  xg.pred <- predict(xg.fit, as.matrix(data.test[,1:800]))
  xg.pred <- as.numeric(xg.pred > mean(xg.pred))
}
