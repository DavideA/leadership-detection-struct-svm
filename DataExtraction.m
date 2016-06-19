function [pedestrians groups] = DataExtraction()
%% DATA EXTRACTION function
% this function loads data and puts it in a convenient format for features
% extraction.

% Load data using Malvezzi's loadData function.
[myF, clusters, ~]=loadData('load from file',strcat(pwd,'/data'));

n_p=length(unique(myF(:,2))); % number of pedestrians
n_f=length(unique(myF(:,1))); % number of frames
n_c=length(clusters);         % number of clusters

% Builds pedestrians trajectories vector.
for i=1:n_p
    pos = zeros(2,n_f);
    
    tmp = myF( (myF(:,2)==i)  ,:);
    
    for j=1:size(tmp,1)
        pos(1,floor(tmp(j,1)/6)+1) = tmp(j,3);
        pos(2,floor(tmp(j,1)/6)+1) = tmp(j,5);
    end
    pedestrians(i).traj=pos;
end

pedestrians=pedestrians';

% Cycle that keeps only groups with more than one person. Very c-like.
groups=[];

j=1;
for i=1:n_c
    if(length(clusters{1,i}.members)>1)
        groups(j).members=clusters{1,i};
        j=j+1;
    end
end
groups=groups';

end

