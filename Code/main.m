clear all
close all
clc

%% Simulation

people_q = [2, 2, pi/3;
            3, 2, pi/4;
            3, 3, 0;
            2, 3, pi/2];

people_int = {{generate_exciting_traj(0, 1), @(t) 0, generate_exciting_traj(-1.5, 1.5) },...
              {generate_exciting_traj(0, 1), @(t) 0, generate_exciting_traj(-1.5, 1.5)},...
              {generate_exciting_traj(0, 1), @(t) 0, generate_exciting_traj(-1.5, 1.5)},...
              {generate_exciting_traj(0, 1), @(t) 0, generate_exciting_traj(-1.5, 1.5)}};
              
disp("starting simulation");
recovered_v = 0.9;
sigma_theta = 5*pi/180;
Kr = 1;
gamma = 2;

edge_x = 5;
edge_y = 5;

r = room(edge_x, edge_y, people_q, people_int, recovered_v, sigma_theta, Kr, gamma);

dT = 0.1;
T_tot = 30;
i = 1;
V_tot = [];
V_int = [];
f = waitbar(0, 'Simulation...');
for t=0:dT:T_tot
    
    [V_tot1, V_app, V_int1, pos_xytheta{i}] = r.applyAllInput(t, dT);
    
    p1History(i,:) =  pos_xytheta{i}(1,:);
    p2History(i,:) =  pos_xytheta{i}(2,:);
    p3History(i,:) =  pos_xytheta{i}(3,:);
    p4History(i,:) =  pos_xytheta{i}(4,:);
    
    v1_int_History(i,:) =  V_int1(1, :);
    v2_int_History(i,:) =  V_int1(2, :);
    v3_int_History(i,:) =  V_int1(3, :);
    v4_int_History(i,:) =  V_int1(4, :);
    
    v1_appl_History(i,:) =  V_app(1, :);
    v2_appl_History(i,:) =  V_app(2, :);
    v3_appl_History(i,:) =  V_app(3, :);
    v4_appl_History(i,:) =  V_app(4, :);
    
    V_tot = [V_tot, V_tot1];
    V_int = [V_int, V_int1];
    i = i + 1;
    waitbar(t/T_tot, f, 'Simulation...');
end
close(f);

V_tot = V_tot';
V_int = V_int';

time = [0:dT:T_tot]';

%% Plot the results

utils.plotState(time, p1History, 1)
utils.plotState(time, p2History, 2)
utils.plotState(time, p3History, 3)
utils.plotState(time, p4History, 4)

utils.plotV(time, V_tot(:,1), 1)
utils.plotV(time, V_tot(:,2), 2)
utils.plotV(time, V_tot(:,3), 3)
utils.plotV(time, V_tot(:,4), 4)

pHistory = [p1History,p2History, p3History, p4History];
v_int_History = [v1_int_History,v2_int_History,v3_int_History,v4_int_History];
v_appl_History = [v1_appl_History,v2_appl_History,v3_appl_History,v4_appl_History];

addpath('results')
formatOut = 'yyyy.mm.dd-HH.MM.SS';
name = datestr(datetime('now'),formatOut);
mkdir('results',name)

close all
utils.displayVideo(pHistory, V_tot, v_appl_History, v_int_History, edge_x, edge_y, strcat('results/',name), 1/dT, false)