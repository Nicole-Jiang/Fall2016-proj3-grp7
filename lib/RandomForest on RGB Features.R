######### Random Forest Using RGB Features ##########

library(randomForest)

# Split data into testing and training using 
data.all=as.data.frame(rgb_feature)
data.all[,801]<-as.factor(data.all[,801])
set.seed(999)
train=sample(1:nrow(data.all),nrow(data.all)*0.5)
test=-train
train_data=data.all[train,]
test_data=data.all[-train,]

### Make formula
varNames <- colnames(train_data)
# Exclude ID or Response variable
varNames <- varNames[!varNames %in% c("label")]
# add + sign between exploratory variables
varNames1 <- paste(varNames, collapse = "+")
# Add response variable and convert to a formula object
rf.form <- as.formula(paste("label", varNames1, sep = " ~ "))

# Tune parameter 'mtry'
set.seed(421)
bestmtry <- tuneRF(y=train_data[,801], x=train_data[,-801], stepFactor=1.5, improve=1e-5, ntree=600)
print(bestmtry)
best.mtry <- bestmtry[,1][which.min(bestmtry[,2])]

# Run random forest
rf=randomForest(rf.form, train_data, mtry=best.mtry, ntree=600, importance=T)
plot(rf)

# Predicting response variable
train_data$predicted.response <- predict(rf ,train_data)

# Load Library or packages
library(e1071)
library(caret)
# Create Confusion Matrix
confusionMatrix(data=train_data$predicted.response,reference=train_data$label,positive='1')

# Predicting response variable
test_data$predicted.response <- predict(rf,test_data)

# Create Confusion Matrix
confusionMatrix(data=test_data$predicted.response,
                reference=test_data$label,
                positive='1') # prediction accuracy rate is 92.5%
