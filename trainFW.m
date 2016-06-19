function [model, w_final] = trainFW(X, Y)

model = [];
w_final = [];

% check for training
if size(X, 1) == 0, return; end

parameters.C = 10000;
parameters.maxIter = 300;

callbacks.lossFn = @LossFunction;
callbacks.constraintFn = @OracleCall;
callbacks.featureFn = @FeatureMap;

n = size(X, 1);
n_it = parameters.maxIter;

% initialize variables
w = zeros(length(X{1}), 1);
w_i = zeros(length(X{1}), n);
l = 0;
l_i = zeros(1, n);

lambda = 1 / parameters.C;

w_final = zeros(length(X{1}), n_it);

for k = 1 : n_it
    % pick a block at random
    i = ceil(rand*n);
    
    % solve the oracle
    model.w = w;
    y_star = callbacks.constraintFn(X{i}, Y{i}, model.w);
    
    % find the new best value of the variable
    w_s = 1/lambda/n*(callbacks.featureFn(X{i}, Y{i}) - callbacks.featureFn(X{i}, y_star))';
    
    % also compute the loss at the new point
    l_s = 1/n*callbacks.lossFn(Y{i}, y_star);
    
    % compute the step size
    step_size = min(max((lambda*(w_i(:, i)-w_s')'*w - l_i(i) + l_s) / lambda / ...
        ((w_i(:, i)-w_s')'*(w_i(:, i)-w_s')), 0), 1);
    
    % evaluate w_i and l_i
    w_i_new = (1 - step_size) * w_i(:, i) + step_size * w_s';
    l_i_new = (1 - step_size) * l_i(i) + step_size * l_s;
    
    % update w and l
    w = w + w_i_new - w_i(:, i);
    l = l + l_i_new - l_i(i);
    
    % update w_i and l_i
    w_i(:, i) = w_i_new;
    l_i(i) = l_i_new;
    
    % slowing update should lead to faster convergence
    % w = k/(k+2) * model.w + 2/(k+2) * w;
    
%     fprintf('%d: %s\n', k, mat2str(w));
    
    w_final(:, k) = w;
%     figure(2);
%     clf;
%     plot(w_final');
%     title(['Convergence at ' num2str(k) '-th iteration']);
end
fprintf('\n');

model.w = w;

end
