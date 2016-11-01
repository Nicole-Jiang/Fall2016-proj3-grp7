data.all= as.data.frame(rgb_feature)
names(data.all)[801]= "filelabel"
data.all$filelabel = as.factor(data.all$filelabel)
#data.all$filelabel=factor(data.all$filelabel,labels = c("no", "yes"))
index= sample(2000,1600)
dat_train= data.all[index,-801]
label_train= data.all[index,801]
data.test= data.all[-index,]

train <- function(dat_train, label_train, par=NULL){
  
  ### Train a Gradient Boosting Model (GBM) using processed features from training images
  
  ### Input: 
  ###  -  processed features from images 
  ###  -  class labels for training images
  ### Output: training model specification
  
  ### load libraries
  library(ada)
  library(gbm)
  library(randomForest)
  library(class)
  library(xgboost)
  ###########################   Ada boost model
  ada.fit= ada(label_train~.,data=dat_train,type="discrete")
  
  ########################## Tune random forest model
  # Tune parameter 'mtry'
  set.seed(1234)
  bestmtry <- tuneRF(y=label_train, x=dat_train, stepFactor=1.5, improve=1e-5, ntree=600)
  best.mtry <- bestmtry[,1][which.min(bestmtry[,2])]
  
  ########################### Get random forest model
  rf.fit=randomForest(label_train~., dat_train, mtry=best.mtry, ntree=600, importance=T)
  ###########################  Tune svm 
  #cross validation for kernels
  index= sample(rep(1:5,nrow(dat_train)/5))
  error.radial=vector()
  error.linear=vector()
  error.poly=vector()
  
  for(i in 1:5){
    #trainingset=data.train[index != i,]
    #testset=data.train[index==i,]
    #names(trainingset)[ncol(data.train)]="label_train"
    #names(testset)[ncol(data.train)]= "label_train"
    trainingset=dat_train[index != i,]
    testset=dat_train[index==i,]
    trainingset$label_train= label_train[index != i]
    testset$label_train= label_train[index==i]
    
    trainingset$label_train= factor(as.numeric(trainingset$label_train)-1)
    testset$label_train=factor(as.numeric(trainingset$label_train)-1)
    
    
    svm.fit.radial=svm(label_train~.,data=trainingset,kernel="radial")
    svm.fit.linear=svm(label_train~.,data=trainingset,kernel="linear")
    svm.fit.poly=svm(label_train~.,data=trainingset,kernel="polynomial")
    
    svm.pred.radial=predict(svm.fit.radial,newdata=testset)
    svm.pred.linear=predict(svm.fit.linear,newdata=testset)
    svm.pred.poly=predict(svm.fit.poly,newdata=testset)
    
    err.radial=mean(svm.pred.radial!=testset$label_train)
    err.linear=mean(svm.pred.linear!=testset$label_train)
    err.poly=mean(svm.pred.poly!=testset$label_train)
    
    error.radial=c(error.radial,err.radial)
    error.linear=c(error.linear,err.linear)
    error.poly=c(error.poly,err.poly)
  }
  
  result.matrix=matrix(nrow=3,ncol=1,c(mean(error.radial),mean(error.linear),mean(error.poly)))
  rownames(result.matrix)=c("radial","linear","polynomial")
  index=which.min(result.matrix)
  kernel= names(result.matrix[index,])
  
  
  ###########################   Tune Knn model
  tree.Tuning<-data.frame(k=1:10,cvError=rep(NA,10))
  for(i in 1:nrow(tree.Tuning)){
    index= sample(rep(1:5,nrow(dat_train)/5))
    cvError.temp=0
    for(j in 1:5){
      data.train= dat_train[index != j,]
      data.test= dat_train[index==j,]
      knn.temp= knn(data.train, data.test, cl=label_train[index != j] , k = tree.Tuning$k[i])
      cvError.temp=cvError.temp+(1- mean(label_train[index == j]==knn.temp))/5
    }
    tree.Tuning$cvError[i]= cvError.temp
  }
  ###########################   Get k for Knn model
  tree.Tuning<-tree.Tuning[order(tree.Tuning$cvError),]
  ###########################   Tune XG boost
  dtrain <- xgb.DMatrix(as.matrix(dat_train),label = as.numeric(label_train)-1)
  best_param = list()
  best_seednumber = 1234
  best_logloss = Inf
  best_logloss_index = 0
  
  for (iter in 1:30) {
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
  ###########################   get XG boost model
  nround = best_logloss_index
  set.seed(best_seednumber)
  xg.fit <- xgboost(data=dtrain, params=best_param, nrounds=nround, nthread=6)
  #######################
  
  
  return(list(fit_ada=ada.fit,fit_rf=rf.fit, #fit_svm= svm.fit, kernel= kernel,
              dat_train= dat_train, label_train= label_train, k=tree.Tuning$k[1], fit_xgboost=xg.fit))
}
