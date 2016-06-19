# Structural SVM leadership detection

This work is part of my machine learning assignment in my master's. The aim of the project was to understand the concept of structured learning, and to apply it to learn how to recognize leaders in social groups moving in a crowd of people.

In particular, my group and I developed this Matlab software that takes advantage of time-lag features, Pagerank graph analysis and Structural Support Vector Machines. 

A detailed description of the algorithm can be found in this [draft paper](http://www.davideabati.com/resources/leaders.pdf).

A [demonstration video](https://youtu.be/XRNe_qRAifk) is available on YouTube.

### How to run?
Just checkout the repository and run the main script, which will load data from the provided sample dataset, perform time lag feature extraction, training and testing on new data. Please note that, despite the frames depicting crowd movements are given, this is not a computer vision project and such images are used just for debugging purposes. In fact, training data is stored in two files:
* data/trajectories.txt: stores the trajectories described by people in the following format:

 | frame_number | pedestrian_id | x_coord | 0 | y_coord | 0 | 0 | 0 |
 |--------------|---------------|---------|---|---------|---|---|---|

* data/clusters.txt: stores social group information in each line, as a list of pedestrians ids.
