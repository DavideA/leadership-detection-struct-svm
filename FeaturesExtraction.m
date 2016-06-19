function [G] = FeaturesExtraction(p,g,g_id,metric,lags, ker)
%% FEATURES EXTRACTION function
% Build the weighted normalized graphs of a group based on the specified
% similarity metrics.
% INPUT ARGS:
% p         ---> pedestrians' information
% g         ---> groups' information
% g_id      ---> group we want to build the graph for
% metric 	---> string that specifies wanted similarity metrics. Contains:
%                   'd' ---> DTW
%                   'e' ---> Euclidean Distance
%                   'a' ---> Angle
%                despite the metrics we choose, we always evaluates them in
%                a timelag way, as described in [1].Note that, the order is
%                chosen to specify metrics is irrelevant. Graphs will
%                always be returned in the order specified above (i.e. 'ed'
%                and 'de' will both return DTW graph and Euclidian
%                Distance graph, in this order).
% lags      ---> number of time lags
% ker       ---> use non linear kernel

% Extract group members from group struct
my_members=g(g_id).members.members;
% Extract trajectories from group members
my_trajectories=p(my_members);

%% This section is supposed to select the frames in which each pedestrian of the group
% is in the scene. We only consider frames where every member is present.

min_frames=zeros(1,length(my_members));
max_frames=zeros(1,length(my_members));

for i = 1:length(my_members)
    % this loop finds the first and the last frames in which a group
    % member appears
    nz_x = find(my_trajectories(i).traj(1,:));
    min_frames(i) = min(nz_x);
    max_frames(i) = max(nz_x);
end

abs_min = max(min_frames);
abs_max = min(max_frames);

for i = 1:length(my_members)
    my_trajectories(i).traj =  my_trajectories(i).traj(:, abs_min:abs_max);
end
%% Now we evaluate graphs for every similarity metric specified

g_count=0; %number of graphs, increases at every features evaluation

if ~isempty(strfind(metric, 'd'))
    %% DTW+TimeLag implementation
    disp(['calculating DTW+TimeLag for group' num2str(g_id)]);
    graph = zeros(length(my_members)); % initializing graph
    for i=1:length(graph)
        for j=1:length(graph) % This loop evaluates the time lag features for each
            % couple of members using dtw.
            % 'lags' is the number of time lags used.
            graph(i,j) = TimeLagFeatures(my_trajectories(i), my_trajectories(j), lags,'dtw');
        end
    end
    
    % Adding God to our model
    god_power=(1/(length(graph)+1))/100;
    graph=[ones(1,length(graph)+1)*god_power; zeros(length(graph),1) graph];
    
    g_count=g_count+1;
    G_arr{1,g_count} = graph;
end

if ~isempty(strfind(metric, 'e'))
    %% Euclidean Distance implementation
    disp(['calculating euclidean distance for group' num2str(g_id)]);
    graph = zeros(length(my_members)); % initializing graph
    for i=1:length(graph)
        for j=1:length(graph)
            % here is evaluated for every couple of pedestrians the
            % aritmetic mean between euclidian distance for each frame (!)
            graph(i,j)=TimeLagFeatures(my_trajectories(i), my_trajectories(j), lags,'ed');
        end
    end
    
    % Adding God to our model
    god_power=(1/(length(graph)+1))/100;
    graph=[ones(1,length(graph)+1)*god_power; zeros(length(graph),1) graph];
    
    g_count=g_count+1;
    G_arr{1,g_count} = graph;
end

if ~isempty(strfind(metric, 'a'))
    %% Angle variation detection implementation
    disp(['calculating angle stuff for group' num2str(g_id)]);
    graph = zeros(length(my_members)); % initializing graph
    for i=1:length(graph)
        for j=1:length(graph)
            % the angle+timelag is evaluated for each couple of pedesetrian
            % in the current group.
            graph(i,j)=TimeLagFeatures(my_trajectories(i), my_trajectories(j), lags,'angle');
        end
    end
    
    % Adding God to our model
    god_power=(1/(length(graph)+1))/100;
    graph=[ones(1,length(graph)+1)*god_power; zeros(length(graph),1) graph];
    
    g_count=g_count+1;
    G_arr{1,g_count} = graph;
end

if ker
    for i=1:g_count-1
        for j=i+1:g_count
            G_arr{end+1}=G_arr{i}.*G_arr{j}*10;
        end
    end
    
    tempG = ones(size(G_arr{1}));
    for j=1:g_count
        tempG = tempG.*G_arr{j}*10;
    end
    G_arr{end+1} = tempG/10;
end

%% Building the cell containing the graph array
G={G_arr};
end