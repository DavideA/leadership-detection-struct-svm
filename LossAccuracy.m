function [ acc ] = LossAccuracy(Y, labels_test)
%% ACCURACY function
% this script evaluates the accuracy of predicted labels vector 
% using the same loss function used by the struct svm
% INPUT ARGS:
% Y             ---> predicted labels
% labels_test   ---> groundtruth labels
% OUTPUT ARGS:
% acc           ---> accuracy of prediction

a=zeros(1,size(labels_test,1)); %accuracy vector for each group, preallocated
% accuracy evaluation
for i=1:length(labels_test)
    a(i)=LossFunction(Y{i,1},labels_test{i,1})/length(labels_test{i,1});
end

acc=1-sum(a)/length(a);