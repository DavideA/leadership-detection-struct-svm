function [ mask bad_idx ] = FeatureReport( features )
%% FEATURE REPORT function
% Function that looks for invalid values in the feature vectors, due to 
% evaluation errors.
% INPUT ARGS:
% features      ---> feature vectors of the complete dataset
% OUTPUT ARGS:
% mask          ---> mask that indicates invalid groups
% bad_idx       ---> indexes of invalid groups

err_n = 1;
mask = zeros(1, length(features));
bad_idx = [];

for i=1:length(features)
    for k=1:length(features{i,1})
        if any(isnan(features{i,1}{1,k}(:)))
            disp(['Err. n° ' num2str(err_n) ' - c''è un valore NaN nel gruppo ' num2str(i) ' nella feature ' num2str(k)]);
            err_n = err_n +1;
            mask(1, i) = 1;
            bad_idx = [bad_idx i];
        end
        if any(isinf(features{i,1}{1,k}(:)))
            disp(['Err. n° ' num2str(err_n) ' - c''è un valore Inf nel gruppo ' num2str(i) ' nella feature ' num2str(k)]);
            err_n = err_n +1;
            mask(1, i) = 1;
            bad_idx = [bad_idx i];
        end
    end
end

bad_idx = unique(bad_idx);
mask=1-mask;
end

