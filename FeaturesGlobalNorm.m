function [features features_extr] = FeaturesGlobalNorm( features )
%% FEATUREGLOBALNORM function 
% This function's purpose is to globally normalize the features previously
% extracted
% INPUT ARGS:
% features      ---> feature vector for every group, unnormalized

% OUTPUT ARGS:
% features      ---> feature vector for every group, normalized
% features_extr	---> max and min for each feature, needed during the
%                    prediction phase

for i = 1:length(features{1}) % iterate over each feature
    tot_min = Inf;
    tot_max = -Inf;
    for j = 1:length(features) % iterate over each group to find min and max
        curr_min = min(min(cell2mat(features{j}(i))));
        curr_max = max(max(cell2mat(features{j}(i))));
        if curr_min < tot_min
            tot_min = curr_min;
        end
        if curr_max > tot_max
            tot_max = curr_max;
        end
    end
    
    features_extr{i} = [tot_min tot_max-tot_min]; % save min and max for later use
    
    for j = 1:length(features) % iterate over each group to normalize the current feature
        features{j}(i) = {( cell2mat(features{j}(i)) - features_extr{i}(1) ) / features_extr{i}(2)};
    end
end

end

