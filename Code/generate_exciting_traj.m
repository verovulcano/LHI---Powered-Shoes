function [pos] = generate_exciting_traj(min_q, max_q)
    %GENERATE_EXCITING_TRAJ Summary of this function goes here
    %   Detailed explanation goes here
    
    found = 0;
    limit = max_q-min_q;
    a = rand(5,1) -0.5;
    b = rand(5,1) -0.5;
    q0 = rand(1,1) - 0.5;
    w = 0.15*pi;

    syms pos(t);

    pos = @(t) q0(1) + (a(1)/w)*sin(w*t) - (b(1)/w)*cos(w*t) ...
             + (a(2)/(2*w))*sin(2*w*t) - (b(2)/(2*w))*cos(2*w*t) ...
             + (a(3)/(3*w))*sin(3*w*t) - (b(3)/(3*w))*cos(3*w*t) ...
             + (a(4)/(4*w))*sin(4*w*t) - (b(4)/(4*w))*cos(4*w*t) ...
             + (a(5)/(5*w))*sin(5*w*t) - (b(5)/(5*w))*cos(5*w*t);

    g = diff(pos, t);
    i=1;
    sol = [];
    for n = 1:80
        S = vpasolve(g==0,t,[-1 2*pi/w],'Random',true);
        sol(i)=S;
        i = i+1;
    end
    extrema = vpa(sol);
    maximum = max(pos(extrema));
    minimum = min(pos(extrema));
    pos = @(t) pos(t)*(limit*0.8)/(maximum-minimum);

    maximum = max(pos(extrema));
    pos = @(t) pos(t) - (maximum-max_q);
    pos = @(t) pos(t) - pos(0);

end