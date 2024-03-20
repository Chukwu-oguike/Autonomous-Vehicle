%This script identifies a model that utilizes equations developed with a no
%slip assumption. It was interesting to discover that this model yielded
%the same results as the original model although the original model uses
%different theoretical approaches. One similarity between this model and
%the original was the no-slip assumption at the front and rear tires 
%(it only assumes side slip at the center of gravity). Hence if one can uses the
%velocities of the individual tires, calculate the front and rear slip, a
%more accurate model may result


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


final_accely = transpose(accely_temp2);
final_accelx = transpose(accelx_temp2);
final_gyro = transpose(gyro_temp2);
final_truck_gpsy = transpose(truck_gpsy_temp2);
final_truck_gpsx = transpose(truck_gpsx_temp2);
final_truck_speed = transpose(truck_speed_temp2);
final_truck_steering_can = transpose(truck_steering_can_temp2);

% final_vx = cumtrapz(accelx,0.04995);
% final_vy = cumtrapz(accely,0.04995);

%create input and output data sets
y = final_gyro;
u = horzcat(final_truck_steering_can, final_truck_speed);

%create iddata object
truck_new_data_id = iddata(y, u, 0.04995,'Name', 'Truck Kinematics');
truck_new_data_id.InputName = {'Steering Wheel Angle' 'Speed'};
truck_new_data_id.InputUnit = {'rad' 'm/s'};
truck_new_data_id.OutputName = {'Yaw Rate'};
truck_new_data_id.OutputUnit = {'rad/s'};
truck_new_data_id.Tstart = 0;
truck_new_data_id.TimeUnit = 's';


steering_wheel_bias = 0; %steering wheel bias
yaw_rate_bias = 0; %gyro bias
Lr = 4.5; %length between center of gravity and rear wheel axis
lw = 1.295;

%arguments for the idnlgrey function
Parameters = [Lr; lw; steering_wheel_bias; yaw_rate_bias];

InitialStates = [0; 0; 0];

Order = [1 2 3];

Ts = 0.04995;

%use truck_kinematic_grebox_2
init_sys = idnlgrey('truck_kinematic_greybox_2',Order,Parameters, InitialStates, Ts); 
                
compare(truck_new_data_id,init_sys)

%}