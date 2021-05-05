classdef person_with_shoes < handle
    %PERSON_WITH_SHOES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
        theta
        vx_int
        vy_int
        w_int
        recovered_v
        sigma_theta
        Kr
        gamma
    end
    
    methods
        function obj = person_with_shoes(q, int_vel, recovered_v, sigma_theta, Kr, gamma)
            
            %PERSON_WITH_SHOES Construct an instance of this class
            %   Detailed explanation goes here

            obj.x = q(1);
            obj.y = q(2);
            obj.theta = q(3);
            obj.vx_int = int_vel(1);
            obj.vy_int = int_vel(2);
            obj.w_int = int_vel(3);
            obj.recovered_v = recovered_v;
            obj.sigma_theta = sigma_theta;
            obj.Kr = Kr;
            obj.gamma = gamma;
        end
        
        function applyInput(obj, v, t, dT)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            angle_noise=normrnd(0, obj.sigma_theta);
            x_k1 = obj.x + (obj.vx_int{1}(t) - v*cos(obj.theta+angle_noise) )*dT;
            y_k1 = obj.y + (obj.vy_int{1}(t) - v*sin(obj.theta+angle_noise) )*dT;
            theta_k1 = obj.theta + (obj.w_int{1}(t))*dT;
                        
            obj.x = x_k1;
            obj.y = y_k1;
            obj.theta = theta_k1;
        end
        
        function output = getPosition(obj)
           output = [obj.x; obj.y];
        end
        
        function V = getIntentional(obj, t)
            V = [obj.vx_int{1}(t); obj.vy_int{1}(t); obj.w_int{1}(t)];
        end
        
        function u_tot = computeU(obj, obs)
            
            u_tot = 0;
            G_pinv = [-cos(obj.theta) -sin(obj.theta) 0];
            for i=1:size(obs, 1)
                ob = obs(i, :);
                
                n = norm([obj.x obj.y] - ob);
                Dn = [ (obj.x - ob(1))/((obj.x - ob(1))^2 + (obj.y - ob(2))^2)^(1/2);
                        (obj.y - ob(2))/((obj.x - ob(1))^2 + (obj.y - ob(2))^2)^(1/2);
                        0];
                f = (obj.Kr/n^2)*( (1/n)^(obj.gamma-1) ) * Dn;
                
                u = G_pinv*f;
                u_tot = u_tot+u;
            end
        end
    end
end

