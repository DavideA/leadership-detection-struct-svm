function [ yhat ] = OracleCall( G , y , w )
%% ORACLECALL function
% Evaluates the most violated constraint solution. This oracle is a
% specific model for this type of problem. 
% Returns argmax_Y(-2*loss+w'phi(X,Y))
% INPUT ARGS:
% G         ---> feature vector (as a cell)
% y         ---> input labels
% w         ---> weight vector
% OUTPUT ARGS:
% yhat      ---> most violated constraint solution

group_dim = length(y); % number of members

norm_factor = 0;
for i = 1:group_dim
    norm_factor = norm_factor + (i-(group_dim -i +1))^2;
end

% in each row of pRanks variable we put the pagerank evaluation for the
% i-est similarity metric.

pRanks=zeros(size(G,2),length(G{1})); % preallocated
for i=1:length(G)
    pRanks(i,:) = pageRank2(G{1,i}, 0.85, 0.001)';
end

% removing God from evaluation
pRanks=pRanks(:,2:end);

% maximizing the objective function in Y
to_max = zeros(1,group_dim);
for m = 1: group_dim
    to_max(m) =(((-2*y(m))/norm_factor) + w'*pRanks(:,m));
end

permutations=perms(1:group_dim);
values=zeros(1,size(permutations,1));
for i=1:size(permutations,1)
   values(i)=to_max*permutations(i,:)'; 
end

[~,I] = max(values);
yhat=permutations(I,:)';
end

