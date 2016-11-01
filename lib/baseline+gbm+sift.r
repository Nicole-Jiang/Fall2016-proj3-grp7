#####read in SIFT feature and labels
features <- read.csv('F:/onedrive/fall 2016/5243 applied data science/project3/sift_features.csv')
filename <- names(features)
filename <- unlist(strsplit(filename, '_'))
filename <- filename[seq(1,length(filename),2)]
filevalue <- filename
filevalue[filevalue == 'chicken'] <- 1
filevalue[filevalue == 'dog'] <- 0

features <- as.data.frame(t(features))
features <- cbind(features, filevalue)
colnames(features)[5001] <- 'y'
###########

#########gbm parameter tuning
library(gbm)

gbmGrid <- expand.grid(interaction.depth = (1:5) * 2,n.trees = (1:10)*25,shrinkage = .1,
                       n.minobsinnode = 10) ##choice of parameters
control <- trainControl(method = 'cv', number = 5)  #use 5-fold cross validation

sift <- features

gbmfit_sift <- train(as.data.frame(sift), data.all[,801],
                     method = "gbm", trControl = control, verbose = FALSE,
                     bag.fraction = 0.5, tuneGrid = gbmGrid) #parameter tuning

######5-fold cross validation accuracy
data.all <- sift
set.seed(10)
index <- sample(rep(1:5,400))
predict_results1 <- vector()
for (i in 1:5){
  dat_train <- data.all[index !=i, -ncol(data.all)]
  label_train <- data.all[index !=i, ncol(data.all)]
  dat_test <- data.all[index == i, ]
  gbm_fit <- gbm.fit(dat_train, label_train, n.trees = gbmfit_sift$bestTune$n.trees,
                     interaction.depth = gbmfit_sift$bestTune$interaction.depth,
                     shrinkage = gbmfit_sift$bestTune$shrinkage,
                     n.minobsinnode = gbmfit_sift$bestTune$n.minobsinnode,
                     distribution = 'bernoulli')
  gbm_pred <- predict(gbm_fit, dat_test[,-ncol(data.all)], n.trees = 250)
  gbm_pred <- as.numeric(gbm_pred > mean(gbm_pred))
  predict_results1[i] <- mean(gbm_pred == dat_test[,ncol(data.all)])
}
mean(predict_results1)
