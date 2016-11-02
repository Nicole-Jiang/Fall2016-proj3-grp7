# Project: Labradoodle or Fried Chicken? 
+ Team #7
+ Team members
	+ Jing Mu (jm4269)
	+ Wanyi Zhang(wz2323)
	+ Chencheng Jiang(cj2451)
	+ Jiayu Wang(jw3323)
	+ Skanda Vish(sv4281)
+ Project summary: In this project, we created a classification engine for images of poodles versus images of fried chickens. 

## 1. Baseline model

For every models, we used 5-folder cross validation and set the seed, to ensure the reprocudibility.

The baseline model is using gradient boosting machine (gbm) with decision stumps on 5000 SIFT features. We tuned the interaction.depth and n.trees. (n.tree= 250, interaction.depth =10).

The accuracy rate is 73.25%. 

![image](https://github.com/TZstatsADS/Fall2016-proj3-grp7/blob/master/figs/Pre%2001.png)


## 2. Introduce new features

![image](https://github.com/TZstatsADS/Fall2016-proj3-grp7/blob/master/figs/Pre%2002.png)

The new features are RGB features. 
The methods:
  + Import every image and extract the R,G,B colors of every image
  + Map every Red, Blue or Green color to the nearest color
  + Create a frequency map of every color combination of each pixel (In our case, we took 800 combinations)
  + Use the frequency for one combination as one feature. Hence, we have 800 features for a single image

Apply new features to the gbm model, we got the accuracy rate: 87.3% (The accuracy for the baseline model is 73.25%. Improved by 14.05%.)


### 3. Introduce new models
![image](https://github.com/TZstatsADS/Fall2016-proj3-grp7/blob/master/figs/Pre%2003.png)

### 3.1 Comparison of single models

Model | Adaboost  | Random forest | Knn | Xgboost |GBM
------|----------|--------------| -------------| -----------| ---
**Accuracy rate** | 92.75%  | 92.1% |  80.6% |  92.2% | 87.3% 

### 3.2 Ensemble methods
Use ensemble learning method to obtain better predictive performance than that from any of the single learning algorithm alone. 

+ Details
	+ Apply different models (Adaboost, Random forest, Knn, xgboost and GBM) and tune the parameters
	+ Use those models to predict the test results
	+ Take a simple majority vote of their predictions as the final prediction

+ Advantages:
  + Average out biases by combining the advantages of each model
  + Reduce the variance and become more stable when apply to the new test set
  + Avoid overfitting

The accuracy rate is: 91.25% (The accuracy for the gbm model is 87.3%. Improved by 3.95%.)

## 4. Business insights

We focused not only on the accuracy rate, but also on the reproducibility, stability and processing time. 

The feature extracting process takes about 30min, the ensemble model takes 10min and the test process takes about 10s. As we can see, if you want to only use RGB features and ensemble model, it takes you only 40min to train the model and 10s to use the model. 

Hence if we launch our model as a product, we could take update it on a daily basis which would take about 1 hour thus improving accuracy greatly. 

## 5. Future Improvements
Our model can be improved by doing the following:

1. Use established libraries like OpenCV and patented algorithms like SURF to improve the quality of features extratcted.

2. Improve the model itself by using sophisticated and modern algorithms like convolutional Neural Networks.

3. Reduce computation time by using distributed computing. 

