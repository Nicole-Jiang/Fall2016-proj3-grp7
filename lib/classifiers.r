###########Data processing
library(data.table)

setwd('C:/users/jing mu/onedrive/fall 2016/5243 Applied Data Science/Project3')
sift_features <- fread('sift_features.csv')
image_name <- names(sift_features)
image_name <- unlist(strsplit(image_name, '_'))
image_name <- image_name[seq(1,length(image_name),2)]
image_label <- image_name
image_label[image_label == 'chicken'] <- 'c'
image_label[image_label == 'dog'] <- 'd'

features <- as.data.frame(t(sift_features))
features <- cbind(features, image_label)

###########set up training and validation sets
k = 5
set.seed(40)
valid_index <- sample(1:2000, 2000/k)
valid <- features[valid_index,]
train <- features[-valid_index,]

##########logistic regression 51%?
glm_log <- glm(image_label~., family = 'binomial', data = train)
glm_log_pred= predict(glm_log, newdata = valid[,1:5000],type = "response")
glm_log_pred= as.numeric(glm_log_pred > 0.5)
mean(as.numeric(valid$image_label)-1==glm_log_pred)

##########adaboost about 4mins 64.5%
library(ada)
ada_runtime <- proc.time()
ada_fit <- ada(image_label~.,data=train,iter=20,nu=1,type="discrete")
ada_runtime <- proc.time() - ada_runtime
ada_runtime
ada_predict <- predict(ada_fit,newdata=valid[,1:5000],type="vector")
ada_accu <- mean(valid$image_label == ada_predict)
#possibly change the parameter in adaboost

############gbm about 1.5min 64%
library(gbm)
gbm_train <- train
gbm_train$image_label <- as.numeric(gbm_train$image_label) - 1

gbm_runtime <- proc.time()
gbm_fit <- gbm(image_label~., data = train, distribution = "gaussian", n.tree= 1000, 
                          shrinkage = 0.001)
gbm_runtime <- proc.time() - gbm_runtime
gbm_runtime
gbm_predict <- predict(gbm_fit, newdata=valid[,1:5000], n.trees= 100)
gbm_predict <- as.numeric(gbm_predict > mean(gbm_predict)) 
gbm_accu <- mean(as.numeric(valid$image_label)-1 == gbm_predict)

##########xgboost about 5s very fast 72.25%
library(xgboost)
xg_runtime <- proc.time()
xg <- xgboost(data = as.matrix(train[,1:5000]), label = as.numeric(train$image_label)-1, max.depth=10,
              eta = 0.3, nround = 100, objective = 'binary:logistic')
xg_runtime <- proc.time() - xg_runtime
pred <- predict(xg, as.matrix(valid[,1:5000]))
pred <- as.numeric(pred > mean(pred))
xg_accu <- mean(as.numeric(valid$image_label)-1 == pred)

##########knn about 40s 58.25%
library(class)
knn_runtime <- proc.time()
knn_pred <- knn(train = train[,1:5000], test = valid[,1:5000], cl = train$image_label, k = 3)
#k = 3 gives best prediction correctness for k = 1:10
knn_runtime <- proc.time() - knn_runtime
knn_accu <- mean(valid$image_label == knn_pred)

# pred_accuracy <- vector()
# for (i in 1:10){
#     knn_pred <- knn(train = train[,1:5000], test = valid[,1:5000], cl = train$image_label, k = i)
#     pred_accuracy[i] <- mean(valid$image_label == knn_pred)
#     print(paste(as.character(i),'done'))
# }
# plot(1:10, pred_accuracy)
# lines(1:10, pred_accuracy)

##########pca best can get 73%
train_center <- apply(train[,1:5000],2, mean)
train_center_matrix <- matrix(rep(train_center, each = nrow(train)), nrow = nrow(train))
train_pc  <- as.matrix(train[,1:5000]) - train_center_matrix
pc <- prcomp(train_pc)
train_new <- t(pc$rotation[,1:1600] %*% (t(pc$rotation[,1:1600]) %*% t(train_pc))) + train_center_matrix
xg_pc <- xgboost(data = as.matrix(train_new), label = as.numeric(train$image_label)-1,
                 max.depth=10, eta = 0.95, nround = 50, objective = 'binary:logistic')
xg_pc_pred <- predict(xg_pc, as.matrix(valid[,1:5000]))
xg_pc_pred <- as.numeric(xg_pc_pred > mean(xg_pc_pred))
xg_accu <- mean(as.numeric(valid$image_label)-1 == xg_pc_pred)
