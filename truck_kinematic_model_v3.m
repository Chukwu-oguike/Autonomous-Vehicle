%This script identifies a non-linear kinematic model for the truck. This
%model attempts to estimate the velocity of the front and rear tires by
%using estimates of the velocity components of the center of gravity of the
%truck. The lateral or y-component of teh velocity could not be determined
%because rate of change of linear velocity nearly matches the longitudinal
%acceleration of the truck. During cornering, these variables should be
%different because of the presence of centripital acceleration.
%Consequently the lateral velocity is zero. This may be the result of the
%possibility that the velocity readings are taking from the front tire.

%directly reading the velocity from the front and rear tires would
%eliminate this problem


load('truck_2018-07-15_data')

%zero timestamps
truck_speed(:,1) = truck_speed(:,1) - truck_speed(1,1);
accel(:,1) = accel(:,1) - accel(1,1);
gyro(:,1) = gyro(:,1) - gyro(1,1);
truck_steering_can(:,1) = truck_steering_can(:,1) - truck_steering_can(1,1);
truck_gps(:,1) = truck_gps(:,1) - truck_gps(1,1);
truck_dynamic_history(:,1) = truck_dynamic_history(:,1) - truck_dynamic_history(1,1);


%get the average sampling rates
speed_sample_fs = ceil(1/mean(diff(truck_speed(:,1)) ));
accel_sample_fs = ceil(1/mean(diff(accel(:,1)) ));
truck_gps_sample_fs = ceil(1/mean(diff(truck_gps(:,1)) ));

%set starting and ending indexes (I ensured that ending indexes were as
%temporally close to each other as possible)
truck_speed_temp = truck_speed(:,2);
truck_speed_span = truck_speed_temp(1:5995);

accelx_temp = accel(:,2);
accelx_span = accelx_temp(1:59944);

accely_temp = accel(:,3);
accely_span = accely_temp(1:59944);

truck_gpsy_temp = truck_gps(:,3);
truck_gpsy_span = truck_gpsy_temp(1:11989);

truck_gpsx_temp = truck_gps(:,2);
truck_gpsx_span = truck_gpsx_temp(1:11989);

gyro_temp = gyro(:,4);
gyro_span = gyro_temp(1:59944);

truck_steering_can_temp = truck_steering_can(:,2);
truck_steering_can_span = truck_steering_can_temp(1:62593);

%}

%filter gyro and accel data then compensate for filtering delay
%I chose FIR filters for linear delay response qualities
b1 = fir1(60,0.01,'low');
accely_span = filter(b1,1,accely_span);
delay2 = mean(grpdelay(b1));
accely_span(1:delay2) = [];%remove delayed section

b2 = fir1(60,0.01,'low');
accelx_span = filter(b2,1,accelx_span);
delay2 = mean(grpdelay(b2));
accelx_span(1:delay2) = [];%remove delayed section

b3 = fir1(50,0.01,'low');
gyro_span = filter(b3,1,gyro_span);
delay3 = mean(grpdelay(b3));
gyro_span(1:delay3) = [];%remove delayed section

%
%match up data points for torq, speed and gyro
truck_speed_size = size(truck_speed_span);
truck_speed_temp2 = interp1(1:truck_speed_size, truck_speed_span, linspace(1, 5995, 12001), 'pchip');

accelx_size = size(accelx_span);
accelx_temp2 = interp1(1:accelx_size, accelx_span, linspace(1, 59914, 12001), 'pchip');

accely_size = size(accely_span);
accely_temp2 = interp1(1:accely_size, accely_span, linspace(1, 59914, 12001), 'pchip');

gyro_size = size(gyro_span);
gyro_temp2 = interp1(1:gyro_size, gyro_span, linspace(1, 59919, 12001), 'pchip');

truck_gpsy_size = size(truck_gpsy_span);
truck_gpsy_temp2 = interp1(1:truck_gpsy_size, truck_gpsy_span, linspace(1, 11989, 12001), 'pchip');

truck_gpsx_size = size(truck_gpsx_span);
truck_gpsx_temp2 = interp1(1:truck_gpsx_size, truck_gpsx_span, linspace(1, 11989, 12001), 'pchip');

truck_steering_can_size = size(truck_steering_can_span);
truck_steering_can_temp2 = interp1(1:truck_steering_can_size, truck_steering_can_span, linspace(1, 62593, 12001), 'pchip');


final_accely = transpose(accely_temp2)*9.81;
final_accelx = transpose(accelx_temp2)*9.81;
final_gyro = transpose(gyro_temp2)*pi/180;
final_truck_gpsy = transpose(truck_gpsy_temp2);
final_truck_gpsx = transpose(truck_gpsx_temp2);
final_truck_speed = transpose(truck_speed_temp2);
final_truck_steering_can = transpose(truck_steering_can_temp2);

%convert gps to coordinates in reference systme
[X,Y] = ll2utm(final_truck_gpsy,final_truck_gpsx);

X(:,1) = X(:,1) - X(1,1);
Y(:,1) = Y(:,1) - Y(1,1);

Vdx = diff(final_truck_speed)/0.04995;
Vdxx = vertcat(Vdx,[0.0434027779999963]);
vy = zeros(12001,1);

for i = 1:12001
    
   if (-0.001 <= final_gyro(i)) && (final_gyro(i) <= 0.001)
       vy(i) = 0;
   else
       vy(i) = (Vdxx(i) - final_accelx(i))/final_gyro(i);
   end
end

final_vx = final_truck_speed;
final_vy = vy;

% % final_vx = cumtrapz(0.04995, final_accelx);
% % final_vy = cumtrapz(0.04995, final_accely);
% 
% %create input and output data sets
% y = final_gyro;
% u = horzcat(final_truck_steering_can, final_vx, final_vy, final_gyro);
% 
% %create iddata object
% truck_new_data_id = iddata(y, u, 0.04995,'Name', 'Truck Kinematics');
% truck_new_data_id.InputName = {'Steering Wheel Angle' 'Longitudinal Speed' 'Lateral Speed' 'yaw rate'};
% truck_new_data_id.InputUnit = {'rad' 'm/s' 'm/s' 'rad/s'};
% truck_new_data_id.OutputName = {'X gps'};
% truck_new_data_id.OutputUnit = {'m'};
% truck_new_data_id.Tstart = 0;
% truck_new_data_id.TimeUnit = 's';
% 
% %
% Lr = 3.5; %length between center of gravity and rear wheel axis (not accurate)
% 
% %arguments for the idnlgrey function
% Parameters = Lr;
% 
% InitialStates = [0; 0; 0];
% 
% Order = [1 4 3];
% 
% Ts = 0.04995;
% 
% %use truck_kinematic_grebox_3
% init_sys = idnlgrey('truck_kinematic_greybox_3',Order,Parameters, InitialStates, Ts); 
%                 
% compare(truck_new_data_id,init_sys)

%}

