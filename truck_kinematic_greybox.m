function [dx, y] = truck_kinematic_greybox(...
    t, x, u, Kus, steering_wheel_bias, yaw_rate_bias,varargin)

%{
   
    This is the original kinematic model for the truck's planner.
    
    This model assumes that the velocity data represents the velocity of
    the truck's front  tires. Another assumption is that the front tire
    exactly follow the steering angle and the rear tires follow a straight
    path.
    
    Once the change in position of the front tire is determined, and the
    direction of the rear tires are known, the change in position of the
    rear tires and the total yaw can be calculated geometrically (i.e the
    rigid connection between front and rear tires adds geometric contrainst
    to the vehicle's motion)
    
    Note: the function also uses a theoretical model with a similar
    assumption(front tire exactly follow the steering angle and the rear 
    tires follow a straight path) to calculate the change in yaw. 
    
    geometric set up of this function can be seen in the
    "Truck_kinematic_greybox_diagram" file
    
    and thoery that uses Understeer Coefficient (Kus) can be seen in the 
    "Calculating_yaw_change.png" file
    
%}

% === states and controls:
% x = [x y t v]' = [x; y; car_angle]
% u = [sw v]'     = [steering_wheel_angle; speed]

% parameters
d = 5.02; % wheelbase
h = 0.04995; % time step
%yaw_rate_bias = 0.0;
% steering_wheel_k = 0.01;

% controls
w  = (u(1)-steering_wheel_bias); % w = front wheel angle
v  = u(2); % v = front wheel velocity
o  = x(3); % o = car angle
z  = [cosd(o); sind(o)]; % z = unit_vector(o)

front_wheel_rolling_dist  = h*v;

%change in rear tire position is calculated by assuming front tires follow
%steered angle and rear tire move parallel to thier initial direction
back_wheel_rolling_dist  = d + front_wheel_rolling_dist.*cosd(w) ...
       - sqrt(d^2 - (front_wheel_rolling_dist.*sind(w)).^2);


%theoretical model to calculate change in yaw as mentioned above
value = (w*pi/180) * front_wheel_rolling_dist / (d +  (Kus*v^2 / 9.8));%uses sine
%to convert to radians

delta_orientation = value*180/pi;

delta_x = [back_wheel_rolling_dist*z(1); ...
      back_wheel_rolling_dist*z(2); ...
      delta_orientation];  % change in state

dx = x + delta_x;

y = delta_orientation/h + yaw_rate_bias; % output (observable stuff for learning the model)
