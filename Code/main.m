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

% people_int = {{@(t) 1, @(t) 0, @(t) sin(t/3) }, {@(t) 1, @(t) 0, @(t) sin(t/3)},...
%               {@(t) 1, @(t) 0, @(t) sin(2*t/3)}, {@(t) 1, @(t) 0, @(t) sin(-t/3) }};
%           
disp("starting simulation");
recovered_v = 0.9;
sigma_theta = 5*pi/180;
Kr = 1;
gamma = 2;

edge_x = 5;
edge_y = 5;

noise_xy = 0.01;
noise_theta = 5*pi/180;

r = room(edge_x, edge_y, people_q, people_int, recovered_v, sigma_theta, Kr, gamma, noise_xy, noise_theta);

dT = 0.1;
T_tot = 30;
i = 1;
V_tot = [];
V_int = [];
f = waitbar(0, 'Simulation...');
for t=0:dT:T_tot
    
    r.applyNoise();
    [V_tot1, V_app, V_int1, pos_xytheta{i}, V_est1] = r.applyAllInput(t, dT);
    
    p1History(i,:) =  pos_xytheta{i}(1,:);
    p2History(i,:) =  pos_xytheta{i}(2,:);
    p3History(i,:) =  pos_xytheta{i}(3,:);
    p4History(i,:) =  pos_xytheta{i}(4,:);
    
    v1_int_History(i,:) =  V_int1(1, :);
    v2_int_History(i,:) =  V_int1(2, :);
    v3_int_History(i,:) =  V_int1(3, :);
    v4_int_History(i,:) =  V_int1(4, :);
    
    v1_est_History(i,:) =  V_est1(1, :);
    v2_est_History(i,:) =  V_est1(2, :);
    v3_est_History(i,:) =  V_est1(3, :);
    v4_est_History(i,:) =  V_est1(4, :);
    
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

pHistory = [p1History,p2History, p3History, p4History];
v_int_History = [v1_int_History,v2_int_History,v3_int_History,v4_int_History];
v_appl_History = [v1_appl_History,v2_appl_History,v3_appl_History,v4_appl_History];

v_est_History = [v1_est_History,v2_est_History,v3_est_History,v4_est_History];
v_int1_History = [v1_int_History(:,1:2),v2_int_History(:,1:2),v3_int_History(:,1:2),v4_int_History(:,1:2)];

addpath('results')
formatOut = 'yyyy.mm.dd-HH.MM.SS';
name = datestr(datetime('now'),formatOut);
mkdir('results',name)

utils.displayVideo(pHistory, V_tot, v_appl_History, v_int_History, edge_x, edge_y, strcat('results/',name), 1/dT, false)

utils.plotState(time, p1History, 1)
saveas(gcf,strcat('results/',name,'/state_p1'),'epsc')
saveas(gcf,strcat('results/',name,'/state_p1.png'))
utils.plotState(time, p2History, 2)
saveas(gcf,strcat('results/',name,'/state_p2'),'epsc')
saveas(gcf,strcat('results/',name,'/state_p2.png'))
utils.plotState(time, p3History, 3)
saveas(gcf,strcat('results/',name,'/state_p3'),'epsc')
saveas(gcf,strcat('results/',name,'/state_p3.png'))
utils.plotState(time, p4History, 4)
saveas(gcf,strcat('results/',name,'/state_p4'),'epsc')
saveas(gcf,strcat('results/',name,'/state_p4.png'))

utils.plotV(time, V_tot(:,1), 1)
saveas(gcf,strcat('results/',name,'/command_p1'),'epsc')
saveas(gcf,strcat('results/',name,'/command_p1.png'))
utils.plotV(time, V_tot(:,2), 2)
saveas(gcf,strcat('results/',name,'/command_p2'),'epsc')
saveas(gcf,strcat('results/',name,'/command_p2.png'))
utils.plotV(time, V_tot(:,3), 3)
saveas(gcf,strcat('results/',name,'/command_p3'),'epsc')
saveas(gcf,strcat('results/',name,'/command_p3.png'))
utils.plotV(time, V_tot(:,4), 4)
saveas(gcf,strcat('results/',name,'/command_p4'),'epsc')
saveas(gcf,strcat('results/',name,'/command_p4.png'))


utils.plotIntentional(time, v_int1_History, v_est_History, pHistory, strcat('results/',name))