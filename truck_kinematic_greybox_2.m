function [dx, y] = truck_kinematic_greybox_2(t, x, u, Lr, steering_wheel_bias, yaw_rate_bias,varargin)

%theory behind function can be found at: http://borrelli.me.berkeley.edu/pdfpub/IV_KinematicMPC_jason.pdf

% === states and controls:
% x = [[x; y; car_angle]
% u = [steering_wheel_angle; speed]


%In this model we assume that the velocity data 'u(2)' is the velocity at
%the center of gravity of the truck

d = 5.02; % wheelbase
dt = 0.1;

%determine side slip angle (slip at center of gravity)  
B = atand((Lr/d)*tand(u(1)-steering_wheel_bias));

dx = zeros(3,1);

dx(1,1) = u(2)*cosd(B); %x-velocity component at center of gravity
dx(2,1) = u(2)*sind(B); %y-velocity component at center of gravity
dx(3,1) = (u(2)/Lr)*sind(B); %yaw change at center of gravity


y = (x(3)/dt*5.1) + yaw_rate_bias; 
end

