function [ acc ] = LeadAccuracy(Y, labels_test)
%% ACCURACY function
% this script evaluates the accuracy of predicted labels vector 
% only on the leader prediction
% INPUT ARGS:
% Y             ---> predicted labels
% labels_test   ---> groundtruth labels
% OUTPUT ARGS:
% acc           ---> accuracy of prediction

a=zeros(1,size(labels_test,1)); %accuracy vector for each group, preallocated
% accuracy evaluation
for i=1:length(labels_test)
    a(i)=isequal((labels_test{i}==1),(Y{i}==1));
end

acc=sum(a)/length(a);

