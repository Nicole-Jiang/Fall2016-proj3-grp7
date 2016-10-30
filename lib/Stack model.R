library(caretEnsemble)
library(caret)
library(rpart)
library(pROC)
library(kernlab)
# create submodels
data.all$filelabel = factor(data.all$filelabel, labels = c("no", "yes"))
sample= sample(nrow(data.all),0.8*nrow(data.all))
data.train= data.all[sample,c(1:200,5001)]
data.test= data.all[-sample,c(1:200,5001)]
#sample.col= sample(5000,1000)
#data.train= data.all[sample,c(sample.col,5001)]
#data.test=data.all[-sample,c(sample.col,5001)]
control <- trainControl(method="repeatedcv", number=5, repeats=2, savePredictions="final", classProbs=TRUE)
algorithmList <- c('rpart', 'knn','svmRadial','rf','lda')
set.seed(111)
models <- caretList(filelabel~., data=data.train, trControl=control, methodList=algorithmList) # model_list
x1yplot(resamples(models))
results <- resamples(models)
summary(results)
dotplot(results)
modelCor(results)
splom(results)
##################
#stackControl <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions=TRUE, classProbs=TRUE)
#set.seed(100)
#stack.glm <- caretStack(models, method="glm", metric="ROC", trControl=stackControl)
#print(stack.glm)
##############################################

#greedy_ensemble <- caretEnsemble(models, metric="ROC",trControl=stackControl)
greedy_ensemble <- caretEnsemble( models,  metric="ROC", 
                                  trControl=trainControl(number=2,summaryFunction=twoClassSummary,
                                                         classProbs=TRUE
                                                         ))
summary(greedy_ensemble)
##############
### test set
#library("caTools")
#model_preds <- lapply(models, predict, newdata=testing, type="prob")
#model_preds <- lapply(models, function(x) x[,"M"])
#model_preds <- data.frame(model_preds)
ens_preds <- predict(greedy_ensemble, newdata=data.test)
#bb= as.factor(ens_preds>0.5)
#cc= factor(bb, labels= c("no","yes"))
#model_preds$ensemble <- ens_preds
#caTools::colAUC(ens_preds, data.test$filelabel)
mean(ens_preds== data.test$filelabel)


CV= vector()
CV[2]= mean(ens_preds== data.test$filelabel)

