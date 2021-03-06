## Classifying Loan Default

#### The Project
This was the final project for my machine learning course. As part of this course, we built our own machine learning libraries for each homework assignment. All coding was done in Ruby. This may seem strange but this was our professor's way of ensuring that we did not just copy other implementations of machine learning libraries, as very few people use Ruby for machine learning.

For the final project, we were tasked with predicting if an individual will default on a loan with insufficient or non-existent credit histories. This was a Kaggle competition that was carried out the previous year. More details on the specifics of the competition and the data can be found here: https://www.kaggle.com/c/home-credit-default-risk

#### Challenges
This project was challenging for several reasons. First, we could only use models that we had personally implemented as part of the class. This meant dealing with bugs that may have slipped by during the initial implementation for homework. Second, feature engineering had to be done entirely through SQL queries. This was necessary because the dataset was too large to load into memory without overwhelming the server that hosted all of our projects. There were several different tables, all with a many-to-one relationship with the train dataset. This meant that feature engineering primarily involved left joins and aggregations from other tables. Finally, Ruby is not an ideal language to use for working with large datasets. Something simple that could have been done with one command in python had to be critically thought about and methodically implemented with Ruby.

#### Results
In the end, my logistic regression model performed the best for me so I chose it for my final submission. After tweaking the parameters and spending a significant amount of time engineering my featureset, my final model scored an AUC of 0.7354, which was the highest in the class by over 0.015. A condensed version of my final project only containing the code relevant to my final model can be found in Classifying_Loan_Default.ipynb.
