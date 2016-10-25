features <- read.csv('c:/users/thinkpad/downloads/sift_features.csv')
#features <- read.csv('c:/users/jing Mu/onedrive/fall 2016/5243 applied data science/project3/sift_features.csv')
filename <- names(features)
filename <- unlist(strsplit(filename, '_'))
filename <- filename[seq(1,length(filename),2)]
filevalue <- filename
filevalue[filevalue == 'chicken'] <- 0
filevalue[filevalue == 'dog'] <- 1

features <- as.data.frame(t(features))
features <- cbind(features, filevalue)
colnames(features)[5001] <- 'y'
features$y <- as.factor(features$y)

k = 5
set.seed(40)
valid_index <- sample(1:2000, 2000/k)
valid <- features[valid_index,]
train <- features[-valid_index,]

######gbm about 16s
library(gbm)
gbm_ptm <- proc.time()
#fit_gbm <- gbm(y~., data = train, distribution = 'bernoulli', n.trees= 100, shrinkage = 1,
#               interaction.depth = 1)
fit_gbm <- gbm(y~., data = train, dist = 'adaboost', n.tree= 100, shrinkage = 1,
               interaction.depth = 1)
gbm_ptm <- gbm_ptm - proc.time()
gbm.perf(fit_gbm)
#best_iter <- gbm.perf(fit_gbm, method = 'OOB')
gbm_predict <- predict(fit_gbm, valid, n.trees = 1)
mean(valid$y==gbm_predict)

#####pca first
pc <- prcomp(t(train[,1:5000]), center = T)
summary(pc)[1]

###adaboost about 4 min
library(ada)
ada_ptm <- proc.time()
ada.fit= ada(y~.,data=train,iter=20,nu=1,type="discrete")
ada_ptm <- ada_ptm - proc.time()
ada.predict <- predict(ada.fit,newdata=valid,type="vector")
mean(valid$y==ada.predict)
