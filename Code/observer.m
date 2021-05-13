classdef observer < handle
    %OBSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xi_x
        xi_y
        k_wx
        k_wy
    end
    
    methods
        function obj = observer(k_w,x,y)
            %OBSERVER Construct an instance of this class
            %   Detailed explanation goes here
            obj.k_wx = k_w;
            obj.k_wy = k_w;
            obj.xi_x = x;
            obj.xi_y = y;
        end
        
        function V = update(obj,x,y,theta,v,dT)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            xi_x_k1 = obj.xi_x + (obj.k_wx*(x-obj.xi_x) - v*cos(theta))*dT;
            xi_y_k1 = obj.xi_y + (obj.k_wy*(y-obj.xi_y) - v*sin(theta))*dT;
            
            V_x = obj.k_wx*(x-obj.xi_x);
            V_y = obj.k_wy*(y-obj.xi_y);
            
            V = [V_x;V_y];
            
            obj.xi_x = xi_x_k1;
            obj.xi_y = xi_y_k1;
        end
    end
end

