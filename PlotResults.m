[myF, clusters, video_par]=loadData('load from file',strcat(pwd,'/data'));

% note that some color may repeat even amongst clearly different clusters
% due to lackage of "simple" colors.
colors = 'rbgkmcyw';

leaders=zeros(length(Y),1);
for i=1:length(leaders)
    leaders(i)=groups(i).members.members(Y{i,1}==1);
end


listing=dir('data/frames');
listing=listing(3:end);

x_max=max(myF(:,3));
y_max=max(myF(:,5));

curr_frame=1;
h=figure();

% Set up the movie object.
outputVideo = VideoWriter(fullfile(pwd,'output.avi'));
outputVideo.FrameRate = 6;
open(outputVideo)

% for each frame we draw a convex hull around the group members and a big
% dot on the leader
for i=1:length(listing)
    % we extract the current frame data
    on_scene=myF(myF(:,1)==curr_frame,:);
    
    clf
    img = imread(strcat('data/frames/',listing(i).name));
    axis([video_par.yMin video_par.yMax video_par.xMin video_par.xMax ]);
    
    % we show the current frame
    imagesc(img);
    hold on;
    
    for g=1:length(groups)
        % cgmos = current group member on scene
        cgmos=ismember(groups(g,1).members.members,on_scene(:,2));
        if sum(cgmos)~=0 %% i have at least one person of group g on scene
            cgmos_ids=groups(g,1).members.members(cgmos);
            cluster_points=[];
            r=20;
            steps=10;
            for p=1:length(cgmos_ids)
                % for each group member we draw a circle around him and
                % then we use the points to create a convex hull.
                c=on_scene(on_scene(:,2)==cgmos_ids(p),[3,5]);
                % scaling
                c(1)=video_par.m2pixel(2, 1)*c(1)+video_par.m2pixel(2, 2);
                c(2)=video_par.m2pixel(1, 1)*c(2)+video_par.m2pixel(1, 2);

                [x,y]=MyCircle(c(2),c(1),r,steps);
                
                cluster_points = [cluster_points; [x', y']];
                if ismember(cgmos_ids(p),leaders)~=0
                   plot(c(2),c(1),'o','linewidth',4,'color', colors(mod(g, length(colors)) + 1));
                   set(gca,'position',[0 0 1 1],'units','normalized'); % esoteric solution to remove white border around plot
                end
                
            end
            if size(cluster_points, 1) > 0
                % we draw the convex hull
                k = convhull(cluster_points(:, 1), cluster_points(:, 2));
                h = fill(cluster_points(k, 1), cluster_points(k, 2), colors(mod(g, length(colors)) + 1));
                set(h,'EdgeColor',colors(mod(g, length(colors)) + 1));
                alpha(h, 0.1)
            end
        end
        
        %if mod(i,4)==0, % Uncomment to take 1 out of every 4 frames.
%             frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
%             writeVideo(writerObj, frame);
        %end
       
    end
    
    f = getframe;              %Capture screen shot
    writeVideo(outputVideo,frame2im(f));
    
    hold off;
    pause(0.1);
    
    % saving frames to an output folder (if necessary)
%     fname = strcat('out-frames-kinder/frame',int2str(i),'.jpg');
%     saveas(h, fname, 'jpg');
    
    curr_frame=curr_frame+6;
end

% Saves the movie.
close(outputVideo);
