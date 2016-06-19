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


% Evaluate feature vectors for all groups...
% features = cell(length(groups),1);
% parfor i=1:length(groups)
%     features(i)=FeaturesExtraction(pedestrians,groups,i,'dea',9,0);
% end

% save ('features_dea_noker.mat','features');

%Or load them, if previously saved

load features_dea_noker.mat


% Inf and NaN check
[mask bad_idx] = FeatureReport(features);

for i=1:length(bad_idx)
    features=[features(1:bad_idx(i)-1);features(bad_idx(i)+1:end)];
    labels=[labels(1:bad_idx(i)-1);labels(bad_idx(i)+1:end)];
    bad_idx=bad_idx-1;
end

results=zeros(5,4);
for n_examples=10:50
    lossacc=zeros(1,5);
    leadacc=zeros(1,5);
    for b=1:5
        %% EXTRACT SETS RANDOMLY
        [features_train,idx_train]=datasample(features,n_examples,'Replace',false);
        labels_train=labels(idx_train);
        sample_weigths=ones(1,length(features));
        sample_weigths(idx_train)=0;
        [features_test,idx_test]=datasample(features,50,'Replace',false,'Weights',sample_weigths);
        labels_test=labels(idx_test);
        %% NORMALIZE FEATURES
        [features_train features_extr] = FeaturesGlobalNorm(features_train);
        
        % testing set features normalization
        for i = 1:length(features{1})
            for j = 1:length(features_test) % iterate over each group to normalize the current feature
                features_test{j}(i) = {( cell2mat(features_test{j}(i)) - features_extr{i}(1) ) * (1/features_extr{i}(2))};
            end
        end
        
        %% TRAIN CLASSIFIER
        % Train structural svm classifier with n_examples training examples and the
        % relatives groundtruth labels
        % [model] = svm_struct_train(features_train,labels_train);
        % w = model.w;
        [model] = trainFW(features_train,labels_train);
        w = model.w;
        %% TEST LEARNED MODEL
        
        Y=predict(w,features_test);
        
        % Evaluate accuracy
        lossacc(b)=LossAccuracy(Y,labels_test);
        leadacc(b)=LeadAccuracy(Y,labels_test);
    end
    %     results(n_examples/10, 1)=mean(lossacc);
    %     results(n_examples/10, 3)=mean(leadacc);
    %     results(n_examples/10, 2)=var(lossacc);
    %     results(n_examples/10, 4)=var(leadacc);
    results(n_examples-9, 1)=mean(lossacc);
    results(n_examples-9, 3)=mean(leadacc);
    results(n_examples-9, 2)=var(lossacc);
    results(n_examples-9, 4)=var(leadacc);
end

plot(1:1:41,results(:,1),'b');
hold;
plot(1:1:41,results(:,3),'r'); 

% save results_dea results
% save weigths_dea w
% PlotResults