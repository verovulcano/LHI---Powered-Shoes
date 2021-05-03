clear all
close all
clc

%%
people_q = [1, 1, 0;
            2, 2, 0];

people_int = {{@(x) sin(x), @(x) sin(2*x), @(x) 2*sin(x)},{@(x) sin(3*x), @(x) sin(x/3), @(x) 3*sin(x)}};

recovered_v = 1;
sigma_theta = 0;
Kr = 1;
gamma = 2;

r = room(5, 5, people_q, people_int, recovered_v, sigma_theta, Kr, gamma);

