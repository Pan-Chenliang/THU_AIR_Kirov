clc;clear;close all;

disp('Kirov reporting!');

load_aerodynamic_data;
load_inertia_data;
generate_mavlink_buses;
load('data/prop_lookup_clean.mat')
load('data/battery_lookup_clean.mat')
slblocks;

% Battery model initial state: discharged capacity in mAh.
battery_initial_capacity_mAh = 0;

dt = 0.001;
