function [loss] = LossFunction(y_i, y_lab)
%% LOSS function
% Evaluates the loss value between two vectors, specific for our ranking
% problem
% INPUT ARGS:
% y_i       ---> first sorting
% y_lab     ---> second sorting
% OUTPUT ARGS:
% loss      ---> loss value

loss = 0;
norm_factor = 0;
group_dim = length(y_i);

for i = 1:group_dim
    loss = loss + (y_i(i) - y_lab(i))^2;
    norm_factor = norm_factor + (i-(group_dim -i +1))^2;  
end

loss = loss/norm_factor;
end

