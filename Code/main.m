clear all
close all
clc

%% Simulation

people_q = [1, 1, 0;
            4, 4, 0];

people_int = {{@(x) sin(x), @(x) sin(2*x), @(x) 2*sin(x)},{@(x) sin(3*x), @(x) sin(x/3), @(x) 3*sin(x)}};

recovered_v = 1;
sigma_theta = 0;
Kr = 1;
gamma = 2;

edge_x = 5;
edge_y = 5;

r = room(edge_x, edge_y, people_q, people_int, recovered_v, sigma_theta, Kr, gamma);

dT = 0.01;
T_tot = 5;
i = 1;
V_tot = [];

for t=0:dT:T_tot
    
    [V_tot1, pos_xytheta{i}] = r.applyAllInput(t, dT);
    
    p1History(i,:) =  pos_xytheta{i}(1,:);
    p2History(i,:) =  pos_xytheta{i}(2,:);
    
    V_tot = [V_tot, V_tot1];
    
    i = i + 1;
    
end

V_tot = V_tot';

time = [0:dT:T_tot]';

%% Plot the results

utils.plotState(time, p1History, 1)
utils.plotState(time, p2History, 2)

utils.plotV(time, V_tot(:,1), 1)
utils.plotV(time, V_tot(:,2), 2)

pHistory = [p1History,p2History];

utils.displayVideo(pHistory, edge_x, edge_y)