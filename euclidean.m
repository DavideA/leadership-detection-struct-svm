function [ distance ] = euclidean(p1,p2)
%% EUCLIDEAN function
% Computes the euclidean distance between two points
% INPUT ARGS:
% p1        ---> first point
% p2        ---> second point
% OUTPUT ARGS:
% distance  ---> evaluated euclidean distance

distance=0;
for i=1:length(p1) %%for every dimension, we accumulate square dist
    distance=distance+(p1(i)-p2(i))^2;
end

distance=sqrt(distance);

end

