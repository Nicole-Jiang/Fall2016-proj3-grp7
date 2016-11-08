# Project: Predictive Analytics - Labradoodle or Fried Chicken? 
![image](https://s-media-cache-ak0.pinimg.com/236x/6b/01/3c/6b013cd759c69d17ffd1b67b3c1fbbbf.jpg)
### [Full Project Description](https://github.com/TZstatsADS/ADS_Teaching/blob/master/Fall2016_Projects/Project3_PoodleKFC/doc/project3_desc.md)

Term: Fall 2016

+ Team #7
+ Team members
	+ team member 1 Chencheng Jiang (cj2451)
	+ team member 2 Jing Mu (jm4269) 
	+ team member 3 Skanda Vish (sv4281)
	+ team member 4 Jiayu Wang (jw3323)
	+ team member 5 Wanyi Zhang (wz2323)
+ Project summary: In this project, we try to propose a feasible improvement on the currant classification engine to classify poodle dogs and fried chicken in terms of running cost (storage, memory and time) and prediction accuracy. The baseline model uses gradient boosting machine (gbm) with decision stumps on 5000 SIFT features. Our advanced model uses ensemble method (majority vote) of adaboost, random forest, knn, xgboost, and gbm on combination of 521 RGB features and original 5000 SIFT features, which enhances the accuracy rate by 21%.
	+ Image processing and features extraction
	+ Classification methods
	+ Model evaluation and comparison

	
**Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
|-- test/
└── output/

```

Please see each subfolder for a README file.
