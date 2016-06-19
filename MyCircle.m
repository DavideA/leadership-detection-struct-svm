function [ xunit,yunit ] = MyCircle( xc,yc,radius,steps)
%CIRCLE Summary of this function goes here
%   Detailed explanation goes here

th = 0:2*pi/steps:2*pi;
xunit = radius * cos(th) + xc;
yunit = radius * sin(th) + yc;

end

