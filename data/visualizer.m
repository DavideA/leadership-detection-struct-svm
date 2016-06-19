function visualizer (dataDirectory,g_id,labels)
close all; clc;


% this function should show the simulation of the trajectories coloring
% clusters toghether. On the left subploy we'll be able to see che ground
% truth clustering while on the right one the predicted clustering!
% ALSO, it can provide a selective visualization based on g_id (group
% identifier), and a label representation for showing results (in this
% case, specify labels in increasing order of pedestrian id)

% setting default values
if isempty(g_id)
    g_id=0;
end

show_labels=false;

if labels~=0
    show_labels=true;
end

% load data
[myF, clusters, video_par] = loadData('load from file', dataDirectory);

% this variable add a subplot if we also have a video to display
n_subplots = 2 - (video_par.videoObj == 0);

% resize the figure based on the number of subplots
hFig = figure(1);
set(hFig, 'Position', [300, 300, 500 * n_subplots, 400]);

% note that some color may repeat even amongst clearly different clusters
% due to lackage of "simple" colors.
colors = 'rbgkmcy';

groups=[];
n_c=length(clusters);

j=1;
for i=1:n_c
    if(length(clusters{1,i}.members)>1)
        groups(j).members=clusters{1,i};
        j=j+1;
    end
end

groups=groups';
% select the working window
if g_id ~= 0
    
    tmp=[];
    for i=1:length(groups(g_id,1).members.members)
        tmp=[tmp;myF(myF(:,2)==(groups(g_id,1).members.members(i)),:)];
    end
    
    myF=tmp;
    
end
% path is my global variable which contains structured information about
% the trajectory of each pedestrian
path = struct;
path(1).mts = [];

% pre-read my video file if any, so to speed up the displaying of the
% results
if video_par.videoObj ~= 0
    %myVideo = read(video_par.videoObj, [1, myF(end, 1)]);
end

% extract the pedestrians which can be seen inside this window
members = unique(myF(:, 2));

% it is also very useful to verify that each pedestrians will remain in the
% scene for at least a minimum number of frames, let's say 4  - so that we
% will be able to actually work on some data. shorter sequences will thus
% be ignored!
for i = 1 : size(members)
    if sum(myF(:, 2) == members(i)) < 4
        % delete the trajectory of the user from this scene
        myF(myF(:, 2) == members(i), :) = [];
    end
end

% update members
members = unique(myF(:, 2));

[mycluster] = getClustersFromWindow(members, dataDirectory);

% pedestrians who won't be displayed during the plot!
donotdisplay = [];


% now i check my video/simulation frame by frame
for f = myF(1, 1) : video_par.downsampling : myF(end, 1)
    % since the number of rows in myF associated with each frame is not
    % fixed, we have to extract subwindows regarding the current frame
    frame_idxs = myF(:, 1) == f;
    
    % I just need the information about this particular frame
    pedestrians = myF(frame_idxs, 2);
    locations = myF(frame_idxs, [3 5]);
    
    if video_par.videoObj ~= 0
        subplot(1, n_subplots, n_subplots - 1);
        myVideo = read(video_par.videoObj, f - myF(1, 1) + 1);
        imshow(myVideo(:, :, :, 1));
    end
    
    % now, for each pedestrian, I can update its multivariate timeseries
    oneinscene = false;
    for i = 1 : size(pedestrians)
        
        if ismember(pedestrians(i), donotdisplay)
            continue;
        end
        oneinscene = true;
        
        % initialize the mts if this is the first frame which he appears in
        if (size(path, 2) < pedestrians(i))
            path(pedestrians(i)).mts = [];
        end
        
        % update path vector
        path(pedestrians(i)).mts = [path(pedestrians(i)).mts; f, locations(i, :)];
        
        % find it in the ground truth clusters and in the predicted
        % scenario
        for p = 1 : size(mycluster, 2)
            if ismember(pedestrians(i), mycluster{p})
                index_found_ground = p;
            end
        end
        
        
        subplot(1, n_subplots, n_subplots);
        plot(path(pedestrians(i)).mts(:, 3), path(pedestrians(i)).mts(:, 2), colors(mod(index_found_ground,7)+1));
        if show_labels
            h1 = text(path(pedestrians(i)).mts(:, 3), path(pedestrians(i)).mts(:, 2), num2str(labels(i)));
        else
            h1 = text(path(pedestrians(i)).mts(:, 3), path(pedestrians(i)).mts(:, 2), num2str(pedestrians(i)));
        end
        delete(h1(1:end-1));
        axis([video_par.xMin video_par.xMax video_par.yMin video_par.yMax]);
        title('Ground truth')
        hold all;
    end
    
    subplot(1, n_subplots, n_subplots);   hold off;
    
    if oneinscene
        pause(0.02);
        pause;
    else
    end
end