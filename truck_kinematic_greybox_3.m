function [dx, y] = truck_kinematic_greybox_3(t, x, u, Lr,varargin)

% === states and controls:
% x = [[x; y; car_angle]
% u = [steering_wheel_angle; longitudinal velocity; lateral velocity; yaw rate]
%u(2) and u(3) are longitudinal and lateral speeds respectively


%we make the assumption that u(2) is velocity at the center of gravity of
%the car (not true)

%the 


d = 5.02; % wheelbase for truck
dt = 0.04995; %sample time interval for training data set

%calculate slip angles for rear and front tire

%convert yaw rates and steering angles to radians respectively
yw = u(4)*pi/180; %yaw rate
st = u(1)*pi/180; %steering angle

% calculate slip for front and rear tires respectively
alpha_f =  atan((u(3) + (1-Lr)*yw)/u(2)) - (st);
alpha_r = atan((u(3) - Lr*yw)/u(2));

%velocities for front and rear tires respectively
V_f = sqrt((u(3) + (1-Lr)*yw)^2 + u(2)^2);%we should try v as an input to for this value
V_r = sqrt((u(3) - Lr*yw)^2 + u(2)^2);

%distance cover by front and rear tires in dt secs respectively 
front_d = V_f*dt;
rear_d =  V_r*dt;

%geometric formulation of trucks change in orientation in dt sec
%theory: if we know the change in coordinates of the front and rear tires,
%we can calculate the change in the vehicle's orientation.
%a picture in the folder explains this reasoning
p = d + front_d*cos(alpha_f) - rear_d*cos(alpha_r);

theta = asin(p/d);

%calculate the change x and y coordinates of the center of mass
delta_y = Lr*sin(theta) + rear_d*cos(alpha_r) - Lr;
delta_x = Lr*cos(theta) - rear_d*sin(alpha_r);

%calculate the change in yaw with respect to the longitudinal axis of truck
delta_yw = 90 - theta;

%output of grey-box function
dx = [delta_x; delta_y; delta_yw];

y = delta_x;
end

