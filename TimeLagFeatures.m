function [i_est] = TimeLagFeatures(a,b,L,metric)
%% TIME-LAG FEATURES function
% Evaluates the specified feature using a time-lag approach, much more
% specific for following pattern detection in pedestrians trajectories.
% INPUT ARGS:
% a             ---> first trajectory
% b             ---> second trajectory
% L             ---> number of lags
% metric        ---> specified metric. Values:
%                   >> 'dtw'    Dynamic Time Warping
%                   >> 'ed'     Euclidean Distance
%                   >> 'angle'  Angle
% OUTPUT ARGS: 
% i_est         ---> time-lag distance


cen_fr=floor(length(a.traj)/2);
min_frame=cen_fr-(floor(length(a.traj)*0.7/2))+1;
max_frame=cen_fr+(floor(length(a.traj)*0.7/2))-1; % orribile

lag_window=min(min_frame-1,length(a.traj)-max_frame+1);

lag_w_dimension=0;
while lag_w_dimension==0 && L~=1 ;
    lag_w_dimension=floor(lag_window/((L-1)/2));
    if(lag_w_dimension==0)
        L=L-2;
    end
end

Vab=zeros(1,L);
sh_val=(-(L-1)/2:1:(L-1)/2);

a_cut.traj=zeros(2,max_frame-min_frame);
a_cut.traj=a.traj(:,min_frame:max_frame);

for i=1:L
    
    b_cut.traj=zeros(2,max_frame-min_frame);
    b_cut.traj=b.traj(:,min_frame+sh_val(i)*lag_w_dimension:max_frame+sh_val(i)*lag_w_dimension);
    switch metric
        case 'dtw'
            [Dist,~,k,~]=dtw(a_cut.traj,b_cut.traj);
            Vab(i)=Dist/k;
        case 'ed'
            for k=1:size(a_cut.traj,2)
                Vab(i) = Vab(i)+euclidean(a_cut.traj(:,k),b_cut.traj(:,k));
            end
            Vab(i) = Vab(i)/length(a_cut.traj);
        case 'angle'
            mv_thresh = 0.01; % soglia 'tirata a cazzo' 
            if size(a_cut.traj,2)>1
                my_angles=zeros(2,size(a_cut.traj,2)-1);
                for k=1:size(my_angles,2)
                    % calculate the angle for the first member 'a'
                    if euclidean(a_cut.traj(:,k),a_cut.traj(:,k+1)) < mv_thresh
                        if k == 1
                            my_angles(1,k) = 0;
                        else
                            my_angles(1,k) = my_angles(1,k-1);
                        end
                    else
                        my_angles(1,k)=Angle(a_cut.traj(:,k),a_cut.traj(:,k+1));
                    end
                    % calculate the angle for the first member 'b'
                    if euclidean(b_cut.traj(:,k),b_cut.traj(:,k+1)) < mv_thresh
                        if k == 1
                            my_angles(2,k) = 0;
                        else
                            my_angles(2,k) = my_angles(1,k-1);
                        end
                    else
                        my_angles(2,k)=Angle(b_cut.traj(:,k),b_cut.traj(:,k+1));
                    end
                    
                end
                [Dist,~,k,~]=dtw(my_angles(1,:),my_angles(2,:));
                Vab(i)=Dist/k;
            else
                Vab(i)=0;
            end
    end
end

i_est = 0;
s=0;
for i=1:L
    if Vab(i)~=0
        s = s + 1/Vab(i);
        i_est = i_est + (1/Vab(i))*sh_val(i);
    end
end

i_est = i_est/s;
end