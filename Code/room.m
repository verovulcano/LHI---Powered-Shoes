classdef room < handle
    %ROOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Edge_x
        Edge_y
        n_people
        people
        v_previous
        observers
    end
    
    methods
        function obj = room(edgex, edgey, people_q, people_int, recovered_v, sigma_theta, Kr, gamma, noise_xy, noise_theta)
            %ROOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.Edge_x = edgex;
            obj.Edge_y = edgey;
            obj.n_people = size(people_q, 1);
            obj.people = cell(obj.n_people, 1);
            for i=1:obj.n_people
                obj.people{i} = person_with_shoes(people_q(i, :), people_int{i}, recovered_v, sigma_theta, Kr, gamma, noise_xy, noise_theta);
                obj.observers{i} = observer(1, obj.people{i}.x, obj.people{i}.y);
            end
            obj.v_previous=zeros(obj.n_people,1);
        end
        
        function applyNoise(obj)
           for i=1:obj.n_people
               obj.people{i}.applyNoise();
           end
        end
        
        function U = getAllU(obj)
            U = zeros(obj.n_people, 1);
            all_pos = zeros(obj.n_people, 2);
            all_walls = cell(obj.n_people, 1);
            
            for i=1:obj.n_people
                all_pos(i, :) = [obj.people{i}.x_noise; obj.people{i}.y_noise];
            end
            for i=1:obj.n_people
                all_walls{i} = zeros(4, 2);
                all_walls{i} = [obj.people{i}.x_noise 0;
                                obj.people{i}.x_noise obj.Edge_y;
                                0 obj.people{i}.y_noise;
                                obj.Edge_x obj.people{i}.y_noise];
            end
            for i=1:obj.n_people
                all_pos_i = all_pos;
                all_pos_i(i, :) = [];
                wall_i = all_walls{i};

                obs_i = [all_pos_i; wall_i];
                
                u_i = obj.people{i}.computeU(obs_i);
                U(i) = u_i;
            end
            
        end
        
        function [V_tot,V_est] = computeV(obj, t, dT)
            U = obj.getAllU();
            
            for i=1:obj.n_people
                G_pinv = [-cos(obj.people{i}.theta_noise) -sin(obj.people{i}.theta_noise) 0];
                 R = [cos(obj.people{i}.theta_noise) -sin(obj.people{i}.theta_noise);
                sin(obj.people{i}.theta_noise) cos(obj.people{i}.theta_noise);];
                
                v_est = obj.observers{i}.update(obj.people{i}.x_noise,obj.people{i}.y_noise,obj.people{i}.theta_noise,obj.v_previous(i), dT);

                %v_int = double(obj.people{i}.getIntentional(t));
                %v_intxy = R*(v_int(1:2));
                v_ff(i) = -G_pinv * [v_est;0];
                V_est(i,:) = v_est';
            end
            
            V_tot = U + obj.people{i}.recovered_v*v_ff';
            
            limit=0.8;
            for i=1:obj.n_people
                                
                if V_tot(i)>1
                    V_tot(i)=1;
                elseif V_tot(i)<-1
                    V_tot(i)=-1;
                end

                if V_tot(i)-obj.v_previous(i)>limit
                    V_tot(i)=limit+obj.v_previous(i);
                elseif V_tot(i)-obj.v_previous(i)<-limit
                    V_tot(i)=-limit+obj.v_previous(i);
                end
                                            
                if V_tot(i)>1
                    V_tot(i)=1;
                elseif V_tot(i)<-1
                    V_tot(i)=-1;
                end

            end
            
            obj.v_previous=V_tot;
     
        end
        
        function [V_tot, v_applied, V_int, all_pos, V_est] = applyAllInput(obj, t, dT)
            
            [V_tot,V_est] = obj.computeV(t,dT);
            
            for i=1:obj.n_people
                all_pos(i, 1:2) = obj.people{i}.getPosition();
                all_pos(i, 3) = obj.people{i}.theta;
                R = [cos(obj.people{i}.theta) -sin(obj.people{i}.theta);
                    sin(obj.people{i}.theta) cos(obj.people{i}.theta);];
                v_int = double(obj.people{i}.getIntentional(t));
                v_intxy = R*(v_int(1:2));
                v_app = [- V_tot(i)*cos(obj.people{i}.theta); - V_tot(i)*sin(obj.people{i}.theta)];
                if dot(v_intxy,v_app) > 0
                   V_tot(i) = 0;
                end
            end
 
            for i=1:obj.n_people
                v_applied(i, :) = obj.people{i}.applyInput(V_tot(i), t, dT);
            end
            
            for i=1:obj.n_people
                all_pos(i, 1:2) = obj.people{i}.getPosition();
                all_pos(i, 3) = obj.people{i}.theta;
                V_int(i, :) = double(obj.people{i}.getIntentional(t));
            end
            
        end
        
    end
end

