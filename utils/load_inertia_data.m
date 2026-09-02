% Frame: FRD rel to wing front;
%% Mass property in kg, inertia property in kg*m^2 rel to part cog
M_body = 8;
CoG_body = [-0.327741; 0.0; -0.019404];
Inertia_body = [ ...
     7.510203,  1.100000, -0.541003;
     1.100000, 15.451138,  0.000000;
    -0.541003,  0.000000, 20.915935]; % rel to part cog

M_load = 15;
CoG_load = [-0.025000; 0.0; 0.0];
Inertia_load = [ ...
     1.105000,  0.000000,  0.000000;
     0.000000, 12.883000,  0.000000;
     0.000000,  0.000000, 12.883000]; % rel to part cog

M_aile = 0.15;
M_elev = 0.15;
M_rudd = 0.2;
M_flap = 0.4;
M_spoiler = 0.2;
M_main_gear = 0.3;
M_front_gear = 0.3;
M_prop = 0.1;

total_mass = M_body+M_load+2*M_aile+M_elev+M_rudd+2*M_flap+2*M_spoiler+2*M_main_gear+M_front_gear+2*M_prop; % kg
disp('Total mass = '+string(total_mass)+'kg');