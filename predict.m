function [ Y ] = predict( w , features_test )
%% PREDICT prediction function
%   prediction model based on the weigths evaluated by svm classifier.
%   INPUT ARGS:
%   w   ---> weights learned by svm classifier
%   test---> test features
%   OUTPUT ARGS:
%   Y   ---> predicted labels

for g=1:length(features_test)
    
    G=features_test(g);
    group_dim=length(G{1,1}{1,1})-1; %remove god    
    permutations=perms(1:group_dim);
    
    values=zeros(size(permutations,1),1);
    for i=1:size(permutations,1)
        values(i)=w'*FeatureMap(G{1},permutations(i,:)');
    end
   
    
    [~,I] = max(values);
    Y{g,1}=permutations(I,:)';
end


end

