For my data mining class, we were given the freedom to select a topic for our final project that allowed us to demonstrate a variety of the skills and techniques we used throughout the semester.
Given the increase in both the duration and frequency of wildfires and because I grew up and have spent most of my life in California, I decided to make classifying the size and cause of California wildfires the primary topic of my final project.
The Jupyter Notebook, Classifying_CA_Wildfires.ipynb, contains 5 sections:
  1. Extracting and Formatting the Data: Contains the code for querying the SQLite database and initial preprocessing such as removing  NA's and formatting a few of the features for later use.
  2. Exploratory Analysis: Visualizations of the distribution of the data.
  3. Feature Engineering: The creation of various new features to be used in the models
  4. Labeling the Fire Size Class: Testing of various models to see which features are the most predictive and which models have the highest AUC for classifying fire size.
  5. Classifying the Cause of Fires: Testing of various models to see which features are the most predictive and which models have the highest AUC for classifying the cause of fires.
