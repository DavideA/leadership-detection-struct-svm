%% This is a main script, supposed to try to:
% 1 - Extract information about pedestrian trajectories and groups using
%     DataExtraction method
% 2 - Load groundtruth labels from file
% 3 - Evaluate feature vectors for all groups. A feature vector is a graph
%     vector where each graph is weighted with different time-lag similarity metrics
%     (i.e. dtw, euclidean distance,...)
% 4 - Train structural svm classifier with n_examples training examples and the
%     relatives groundtruth labels
% 5 - Test learned model on the remaining patterns
%% GENERATE DATA
clear; close all; clc;

% Extract information about pedestrian trajectories and groups using
% DataExtraction method
[pedestrians groups]=DataExtraction;

% Load groundtruth labels from file
load labels.mat

n_examples=50;

% Evaluate feature vectors for all groups...
features = cell(length(groups),1);
parfor i=1:length(groups)
    features(i)=FeaturesExtraction(pedestrians,groups,i,'dea',9,0);
end

save ('features_dea_noker.mat','features');

%Or load them, if previously saved
% load features_dea_noker.mat

% Inf and NaN check
[mask bad_idx] = FeatureReport(features);

for i=1:length(bad_idx)
    features=[features(1:bad_idx(i)-1);features(bad_idx(i)+1:end)];
    labels=[labels(1:bad_idx(i)-1);labels(bad_idx(i)+1:end)];
    bad_idx=bad_idx-1;
end


features_train=features(1:n_examples);
features_test=features(n_examples+1:end);

labels_train=labels(1:n_examples);
labels_test=labels(n_examples+1:end);

%% NORMALIZE FEATURES
[features_train features_extr] = FeaturesGlobalNorm(features_train);

%% TRAIN CLASSIFIER
% Train structural svm classifier with n_examples training examples and the
% relatives groundtruth labels
[model] = trainFW(features_train,labels_train);
w = model.w;

%% TEST LEARNED MODEL

% testing set features normalization
for i = 1:length(features{1})
    for j = 1:length(features_test) % iterate over each group to normalize the current feature
        features_test{j}(i) = {( cell2mat(features_test{j}(i)) - features_extr{i}(1) ) * (1/features_extr{i}(2))};
    end
end

features_test=[features_train; features_test];
labels_test=[labels_train; labels_test];

Y=predict(w,features_test);

% Evaluate accuracy
loss=LossAccuracy(Y,labels_test)

lead=LeadAccuracy(Y,labels_test)

PlotResults