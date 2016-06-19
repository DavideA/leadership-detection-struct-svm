function [featureMap] = FeatureMap(G, labels)
%% FEATURE MAP function
% This is the FeatureMap implementation for out specific problem. Our 
% feature map function is row by column product between the evaluation 
% given by PageRank for each similarity metric adopted and a given order 
% for the group
% INPUT ARGS:
% G             ---> input feature vector (as a cell)
% labels        ---> input solution (as a cell)
% OUTPUT ARGS:
% featureMap    ---> evaluated map 

% pRanks=[];
% for i=1:length(G)
%     pRanks = [pRanks;  (pageRank2(G{1,i}, 0.85, 0.001))'];
% end

% in the i-est row of pRanks variable is set the pagerank evaluation for the
% i-est similarity metric.

pRanks=zeros(size(G,2),length(G{1})); % preallocated
for i=1:length(G)
    pRanks(i,:) = pageRank2(G{1,i}, 0.85, 0.001)';
end

% removing God from evaluation
pRanks=pRanks(:,2:end);

% row by column product
featureMap = pRanks * (length(labels)-labels+1)/length(labels);
% need to return a sparse column vector, needed by svm
featureMap=sparse(featureMap);

end