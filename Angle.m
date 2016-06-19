function [ alpha ] = Angle( a , b )
%% ANGLE function
% evaluates angle between the vector v1 through points a and b, and
% the horizontal vector hor.

vec=[b(1)-a(1) b(2)-a(2)];
hor=[1 0];

alpha=acos((vec(1)*hor(1)+vec(2)*hor(2))/norm(vec)*norm(hor));

alpha=alpha/(pi);

end