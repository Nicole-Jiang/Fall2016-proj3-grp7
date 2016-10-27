setwd("~/Desktop/ADS/Proj3-grp7")
library(data.table)

#source("http://bioconductor.org/biocLite.R")
#biocLite("EBImage")
library(EBImage)
library(dplyr)
library(xgboost)
library(MASS)
library(gbm)
library(e1071)
library(tree)
sift= fread("sift_features.csv", header= F)
labels <- dir("images")
filelabel= as.numeric(substr(labels, 1,1) == "c")
labels= substr(labels,1,nchar(labels)-4)
labels.df = data.frame(filename= labels, filelabel= filelabel)

sift.df= as.data.frame(t(sift))
colnames(sift.df)[1] <- "filename"

data.all= merge(sift.df,labels.df, by= names(sift.df)[1])[,-1]
data.all = as.data.frame(apply(data.all,2, as.numeric))
data.all$filelabel = as.factor(data.all$filelabel)
#############################################################

# Split data into testing and training using 
set.seed(2)
train=sample(1:nrow(data.all),nrow(data.all)*0.8)
test=-train
train_data=data.all[train,]
test_data=data.all[test,]
test_label=filelabel[test]

# fit the tree model using training data
tree_model=tree(filelabel~.,data=train_data)
plot(tree_model)
text(tree_model,pretty=0)

# check how the model is doin using the test data
tree_pred=predict(tree_model,test_data,type="class")
mean(tree_pred==test_label) #0.6075

### Prune the tree
## cross validation to check where to step pruning
set.seed(3)
cv_tree=cv.tree(tree_model,FUN=prune.misclass)
names(cv_tree)
plot(cv_tree$size,
     cv_tree$dev,
     type="b")
### prune the tree
pruned_model=prune.misclass(tree_model,best=2)
plot(pruned_model)
text(pruned_model,pretty=0)

### check how it is doing
tree_pred_pruned=predict(pruned_model,test_data,type="class")
mean(tree_pred_pruned==test_label) #0.605
