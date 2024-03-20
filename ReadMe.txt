kinematic_model_id.m: This script trains and validates the intial kinematic model for and autonomous vehicle. 
It utilizes the function "truck_kinematic_greybox"

kinematic_model_id_v2.m: This script trains and non-linear grey-box kinematic model for the 
truck that utilizes equations developed with a no slip assumption. It utilizes the function "truck_kinematic_greybox_2"

kinematic_model_v3.m: This script identifies a non-linear kinematic model for an autonomous vehicle. This
model attempts to estimate the velocity of the front and rear tires by using estimates of the velocity 
components of the center of gravity of the autonomous vehicle. It utilizes the function "truck_kinematic_greybox_3"

truck_kinematic_greybox: This is a kinematic model for an autonomous vehicle's planner.    
This model assumes that the velocity data represents the velocity of the vehicle's front  
tires. Another assumption is that the front tire exactly follow the steering angle and 
the rear tires follow a straight path

truck_kinematic_greybox_2: This function uses a system of equations developed with a no-slip assumption to calculate
the location of the center of gravity of the vehicle. It assumes that the velocity data is the velocity vector at the center 
of gravity of the vehicle

truck_kinematic_greybox_3.m: This function attempts to theoretically calculate the lateral velocity components at the center
of gravity of the vehicle by assuming that using the velocity data to calculate the rate of change in the magnitude of the longitudinal  
velocity component. With the velocity components known, the the slip angles and velocities at each tire is then estimated and to determine the change in
the vehicle's orientation and coordinates 