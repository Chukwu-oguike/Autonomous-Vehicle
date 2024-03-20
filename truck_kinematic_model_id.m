%--------------Prepare data---------------------
% NOTE: In early April 2018, truck steering wheel is re-installed, 
% and previous bias is removed (mostly). Therefore, DO NOT USE MARCH 
% AND APRIL DATASETS TOGETHER WITHOUT CALIBRATING THIS BIAS!!!! 

%
folder_path_1 = './data/truck/cali5mph_2018-03-11-15-47-32';
folder_path_2 = './data/truck/cali10mph_2018-03-11-15-52-13';
folder_path_3 = './data/truck/cali_hispd_2018-03-11-15-55-42';
folder_path_4 = './data/truck/truck_2018-03-11-13-35-10';
folder_path_5 = './truck_2018-04-15';
folder_path_6 = './truck_2018-04-15_highway';
folder_path_7 = './truck_2018-04-15_local';
folder_path_new_1 = './truck_2018-07-08/1';
folder_path_new_2 = './truck_2018-07-08/2';

yaw_rate_latency = 0.3;

% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_1, yaw_rate_latency, false);
% 
% experiment_data_1 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_1.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_1.OutputName = {'yaw rate'};

% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_2, yaw_rate_latency, false);
% 
% experiment_data_2 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_2.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_2.OutputName = {'yaw rate'};
% 
% 
% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_3, yaw_rate_latency, false);
% 
% experiment_data_3 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_3.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_3.OutputName = {'yaw rate'};
% 
% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_4, yaw_rate_latency);
% 
% experiment_data_4 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_4.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_4.OutputName = {'yaw rate'};

% 
% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_5, yaw_rate_latency, true);
% 
% experiment_data_5 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_5.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_5.OutputName = {'yaw rate'};
% 
% [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_6, yaw_rate_latency, true);
% 
% experiment_data_6 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_6.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_6.OutputName = {'yaw rate'};
% 
%  [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
%      steering_can_sampled, x_sampled, y_sampled] = ...
%      load_truck_data(folder_path_7, yaw_rate_latency, true);
% 
% experiment_data_7 = iddata([yaw_rate_sampled], ...
%                       [steering_can_sampled, speed_sampled], 0.1);
% experiment_data_7.InputName  = {'steering_wheel_angle', 'speed'};
% experiment_data_7.OutputName = {'yaw rate'};

[speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
     steering_can_sampled, x_sampled, y_sampled] = ...
     load_truck_data(folder_path_new_1, yaw_rate_latency, true);

experiment_data_new_1 = iddata([yaw_rate_sampled], ...
                      [steering_can_sampled, speed_sampled], 0.1);
experiment_data_new_1.InputName  = {'steering_wheel_angle', 'speed'};
experiment_data_new_1.OutputName = {'yaw rate'};
% 
% 
[speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
     steering_can_sampled, x_sampled, y_sampled] = ...
     load_truck_data(folder_path_new_2, yaw_rate_latency, true);

experiment_data_new_2 = iddata([yaw_rate_sampled], ...
                      [steering_can_sampled, speed_sampled], 0.1);
experiment_data_new_2.InputName  = {'steering_wheel_angle', 'speed'};
experiment_data_new_2.OutputName = {'yaw rate'};

%-------------Training of grey box--------------
delta_x_sampled = bsxfun(@minus, x_sampled(2:end), x_sampled(1:end-1));
delta_y_sampled = bsxfun(@minus, y_sampled(2:end), y_sampled(1:end-1));

% experiment_data = iddata([delta_x_sampled, delta_y_sampled], ...
%                       [steering_can_sampled(1:end-1), speed_sampled(1:end-1)], 0.1);

%%
grey_sys_training_datasets = merge(experiment_data_new_1, experiment_data_new_2);%, experiment_data_7);
% grey_sys_training_datasets = merge(data_set{1},data_set{6},data_set{7});
%grey_sys_training_datasets = merge(experiment_data_new_1, ...
    %experiment_data_new_2);

steering_wheel_bias = 0; %steering wheel bias

yaw_rate_bias = 0; %gyro bias

Kus = 0.1; %length between center of gravity and rear wheel axis
    
Parameters = [Kus; steering_wheel_bias; yaw_rate_bias];

InitialStates = [0; 0; 0];

Order = [1 2 3];

Ts = 0.1;

%use truck_kinematic_grebox_5
init_sys = idnlgrey('truck_kinematic_greybox',Order,Parameters, InitialStates, Ts); 
                
                
%compare(experiment_data_new_2, init_sys)

%
% for i = 1:3
%     
%     init_sys.Parameters(i).Minimum = 0;
%     
% end
 
init_sys.Parameters(2).Fixed = true;
init_sys.Parameters(3).Fixed = true;

init_sys.InitialStates(3).Fixed = 0;
grey_opt = nlgreyestOptions('Display', 'on','SearchMethod','auto');
grey_opt.SearchOption.MaxIter = 50;
%grey_opt.GradientOptions.GradientType = 'Refined';
%grey_opt.SearchOption.Advanced.TolX = 1e-10;
grey_sys = nlgreyest(grey_sys_training_datasets, init_sys, grey_opt);
%results = [results; grey_sys.Report.Fit.FitPercent];
grey_sys.Report.Fit.FitPercent

sys = nlgreyest(experiment_data_new_2,init_sys);

compare(experiment_data_new_2, sys)
%end

%}                    
                    
%{
%--------------- Verification on training sets---------------
figure(4)
subplot(2,1,1)
plot(grey_sys_training_datasets)
subplot(2,1,2)
compare(grey_sys_training_datasets,grey_sys)

%%
%--------------- Validation on training sets---------------
figure(5)
subplot(2,1,1)
plot(experiment_data_new_1)
subplot(2,1,2)
compare(experiment_data_new_1,grey_sys)


%%
%--------------- Other stuff ----------------------

% reload first dataset
[speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
     steering_can_sampled, x_sampled, y_sampled] = ...
     load_truck_data(folder_path_new_1, yaw_rate_latency, true);

% Forward simulation
N = size(steering_can_sampled,1)-10;
init_orientation = atan2(y_sampled(10), x_sampled(10));
x_state = [0, 0, init_orientation]';
x_simulated = zeros(N, 3);
y_simulated = zeros(N, 1);
% d = 1.5; % wheelbase
% steering_wheel_k = -0.000232;
% steering_wheel_bias = -41;
% kus = 0.2;

% d = grey_sys.Parameters(1).Value; % wheelbase
% d = k;
steering_wheel_k = grey_sys.Parameters(1).Value;
steering_wheel_bias = grey_sys.Parameters(2).Value;
kus = grey_sys.Parameters(3).Value;

for t = 1:N
    [x_state, y] = truck_kinematic_greybox(0, x_state, ...
                  [steering_can_sampled(t), speed_sampled(t)], ...
                  steering_wheel_k, steering_wheel_bias, kus, {k});
    x_simulated(t, :) = x_state;
    y_simulated(t, :) = y;
end

figure(2)
hold off
plot(x_sampled, y_sampled)
hold on
plot(x_simulated(:,1), x_simulated(:,2), 'r.')
%%
figure(3)
plot(yaw_rate_sampled)
hold on
plot(y_simulated)
legend('gt yaw rate', 'simulated yaw rate')

%}
function [speed_sampled, yaw_rate_sampled, lateral_acc_sampled, ...
          steering_can_sampled, x_sampled, y_sampled] = ...
          load_truck_data(folder_path, yaw_rate_delay, ...
          use_gyro_for_yaw_rate)
    % [timestamp, speed(m/s)]
    speed = load([folder_path, '/truck_speed.txt']);
    % [timestamp, yaw_rate, lat_acc, lon_acc]
    dynamic_hist = load([folder_path, '/truck_dynamic_history.txt']);
    % [timestamp, steering_wheel_angle]
    steering_can = load([folder_path, '/truck_steering_can.txt']);
    % [timestamp, lon, lat, heading_vehicle, heading_motion]
    % heading_vehicle and heading_motion seems unreliable
    gps_hist = load([folder_path, '/truck_gps.txt']);
    if use_gyro_for_yaw_rate
        % [timestamp, gyro?]
        gyro = load([folder_path, '/gyro.txt']);
    end

    start_time = min(gps_hist(:,1))+7.0;
    end_time = gps_hist(end,1)-start_time-5;

    % Shift the start time
    speed(:,1) = speed(:,1)-start_time;
    dynamic_hist(:,1) = dynamic_hist(:,1)-start_time-yaw_rate_delay;
    steering_can(:,1) = steering_can(:,1)-start_time;
    gps_hist(:,1) = gps_hist(:,1)-start_time;
    if use_gyro_for_yaw_rate
        gyro(:,1) = gyro(:,1)-start_time;
    end

    % Trim data to start time = 0
    first_ind = find(gps_hist(:,1) >= 0);
    gps_hist = gps_hist(first_ind:end, :);
    gps_hist(1,1) = 0.0;
    first_ind = find(dynamic_hist(:,1) >= 0);
    dynamic_hist = dynamic_hist(first_ind:end, :);
    dynamic_hist(1,1) = 0.0;
    first_ind = find(steering_can(:,1) >= 0);
    steering_can = steering_can(first_ind:end, :);
    steering_can(1,1) = 0.0;
    first_ind = find(speed(:,1) >= 0);
    speed = speed(first_ind:end, :);
    speed(1,1) = 0.0;
    if use_gyro_for_yaw_rate
        first_ind = find(gyro(:,1) >= 0);
        gyro = gyro(first_ind:end, :);
        gyro(1,1) = 0.0;
    end

%     % Plot raw data
%     figure(1)
%     subplot(2,1,1)
%     plot(speed(:,1), speed(:,2), '-')
%     subplot(2,1,2)
%     plot(steering_can(:,1), steering_can(:,2), 'b')
%     hold on;
%     plot(dynamic_hist(:,1), dynamic_hist(:,2), 'g')
%     plot(dynamic_hist(:,1), dynamic_hist(:,3), 'r')
%     if use_gyro_for_yaw_rate
%         plot(gyro(:,1), gyro(:,4), 'c')
%     end
%     legend('Steering can', 'Yaw rate (CAN)', 'Lateral acc', 'Yaw rate (IMU)')

    % Pre-processing
    resample_hz = 10;
    [speed_sampled, t_speed_sampled] = ...
        resample(speed(:,2), speed(:,1), resample_hz);
    if use_gyro_for_yaw_rate
        [yaw_rate_sampled, t_yaw_rate_sampled] = ...
        resample(gyro(:,4), gyro(:,1), resample_hz);
    else
        [yaw_rate_sampled, t_yaw_rate_sampled] = ...
            resample(dynamic_hist(:,2), dynamic_hist(:,1), resample_hz);
    end
    [lateral_acc_sampled, t_lateral_acc_sampled] = ...
        resample(dynamic_hist(:,3), dynamic_hist(:,1), resample_hz);
    [steering_can_sampled, t_steering_can_sampled] = ...
        resample(steering_can(:,2), steering_can(:,1), resample_hz);

    % GPS info pre-processing
    lat_sampled = interp1(gps_hist(:,1), gps_hist(:,3), [0:0.1:end_time], 'linear');
    lon_sampled = interp1(gps_hist(:,1), gps_hist(:,2), [0:0.1:end_time], 'linear');
    x_sampled = zeros(size(lat_sampled,2),1);
    y_sampled = zeros(size(lat_sampled,2),1);
    for i = 1:size(lat_sampled,2)
        [x_sampled(i), y_sampled(i)] = ll2utm(lat_sampled(i), lon_sampled(i), 'nad83');
    end
    x_sampled = x_sampled - x_sampled(1);
    y_sampled = y_sampled - y_sampled(1);
    
%     figure(2)
%     plot(gps_hist(:,2), gps_hist(:,3))
%     hold on
%     plot(lat_sampled, lon_sampled)

    N = size(lat_sampled,2);
    speed_estimated = speed_sampled;
    for i = 1:N-1
        speed_estimated(i) = sqrt((y_sampled(i+1)-y_sampled(i))^2 + ...
                                 (x_sampled(i+1)-x_sampled(i))^2) / 0.1;
    end

%     figure(6)
%     plot(speed_sampled, '.');
%     hold on
%     plot(speed_estimated, '.');
%     legend('speed can', 'speed gps');

    speed_sampled = speed_sampled(1:N);
    yaw_rate_sampled = yaw_rate_sampled(1:N);
    lateral_acc_sampled = lateral_acc_sampled(1:N);
    steering_can_sampled = steering_can_sampled(1:N);
end
%}

