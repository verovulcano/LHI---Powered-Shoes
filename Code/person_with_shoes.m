classdef person_with_shoes < handle
    %PERSON_WITH_SHOES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
        theta
        x_noise
        y_noise
        theta_noise
        vx_int
        vy_int
        w_int
        recovered_v
        sigma_theta
        Kr
        gamma
        noise_xy
        noise_theta
    end
    
    methods
        function obj = person_with_shoes(q, int_vel, recovered_v, sigma_theta, Kr, gamma, noise_xy, noise_theta)
            
            %PERSON_WITH_SHOES Construct an instance of this class
            %   Detailed explanation goes here

            obj.x = q(1);
            obj.y = q(2);
            obj.theta = q(3);
            obj.x_noise = q(1);
            obj.y_noise = q(2);
            obj.theta_noise = q(3);
            
            obj.noise_xy = noise_xy;
            obj.noise_theta = noise_theta;
            
            obj.vx_int = int_vel(1);
            obj.vy_int = int_vel(2);
            obj.w_int = int_vel(3);
            obj.recovered_v = recovered_v;
            obj.sigma_theta = sigma_theta;
            obj.Kr = Kr;
            obj.gamma = gamma;
        end
        
        function applyNoise(obj)
            obj.x_noise = obj.x + normrnd(0, obj.noise_xy);
            obj.y_noise = obj.y + normrnd(0, obj.noise_xy);
            obj.theta_noise = obj.theta + normrnd(0, obj.noise_theta);
        end
        
        function v_applied = applyInput(obj, v, t, dT)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            angle_noise=normrnd(0, obj.sigma_theta);
            R = [cos(obj.theta) -sin(obj.theta);
            sin(obj.theta) cos(obj.theta);];
            
            v_int = double([obj.vx_int{1}(t);obj.vy_int{1}(t)]);
            v_intxy = R*v_int;
            
            x_k1 = obj.x + (v_intxy(1) - v*cos(obj.theta+angle_noise) )*dT;
            y_k1 = obj.y + (v_intxy(2) - v*sin(obj.theta+angle_noise) )*dT;
            theta_k1 = obj.theta + (double(obj.w_int{1}(t)))*dT;
                        
            obj.x = x_k1;
            obj.y = y_k1;
            obj.theta = theta_k1;
            v_applied = [- v*cos(obj.theta+angle_noise); - v*sin(obj.theta+angle_noise)];
        end
        
        function output = getPosition(obj)
           output = [obj.x; obj.y];
        end
        
        function V = getIntentional(obj, t)
            V = double([obj.vx_int{1}(t); obj.vy_int{1}(t); obj.w_int{1}(t)]);
        end
        
        function [u_tot, min_n] = computeU(obj, obs)
            
            u_tot = 0;
            G_pinv = [-cos(obj.theta_noise) -sin(obj.theta_noise) 0];
            min_n = 10e15;
            
            for i=1:size(obs, 1)
                ob = obs(i, :);
                
                n = norm([obj.x_noise obj.y_noise] - ob);
                Dn = [ (obj.x_noise - ob(1))/((obj.x_noise - ob(1))^2 + (obj.y_noise - ob(2))^2)^(1/2);
                        (obj.y_noise - ob(2))/((obj.x_noise - ob(1))^2 + (obj.y_noise - ob(2))^2)^(1/2);
                        0];
                f = (obj.Kr/n^2)*( (1/n)^(obj.gamma-1) ) * Dn;
                
                u = G_pinv*f;
                u_tot = u_tot+u;
                if n < min_n
                    min_n = n;
                end
            end
        end
    end
end

