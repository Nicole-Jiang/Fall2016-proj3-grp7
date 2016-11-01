#######load in rgb feature
load('F:/onedrive/fall 2016/5243 applied data science/project3/rgb_feature_train.RData')
library(gbm)

#######gbm parameter tuning
gbmGrid <- expand.grid(interaction.depth = (1:5) * 2,n.trees = (1:10)*25,shrinkage = .1,
                       n.minobsinnode = 10) ##choice of parameters
control <- trainControl(method = 'cv', number = 5)  #use 5-fold cross validation

gbmfit <- train(data.all[,1:800], data.all[,801],
                method = "gbm", trControl = control, verbose = FALSE,
                bag.fraction = 0.5, tuneGrid = gbmGrid)

#######5-fold cross validation accuracy
data.all <- rgb_feature
set.seed(10)
index <- sample(rep(1:5,400))
predict_results1 <- vector()
for (i in 1:5){
  dat_train <- data.all[index !=i, -ncol(data.all)]
  label_train <- data.all[index !=i, ncol(data.all)]
  dat_test <- data.all[index == i, ]
  gbm_fit <- gbm.fit(dat_train, label_train, n.trees = gbmfit$bestTune$n.trees,
                     interaction.depth = gbmfit$bestTune$interaction.depth,
                     shrinkage = gbmfit$bestTune$shrinkage,
                     n.minobsinnode = gbmfit$bestTune$n.minobsinnode,
                     distribution = 'bernoulli')
  gbm_pred <- predict(gbm_fit, dat_test[,-ncol(data.all)], n.trees = 250)
  gbm_pred <- as.numeric(gbm_pred > mean(gbm_pred))
  predict_results1[i] <- mean(gbm_pred == dat_test[,ncol(data.all)])
}
mean(predict_results1)


