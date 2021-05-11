classdef room < handle
    %ROOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Edge_x
        Edge_y
        n_people
        people
        v_previous
    end
    
    methods
        function obj = room(edgex, edgey, people_q, people_int, recovered_v, sigma_theta, Kr, gamma)
            %ROOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.Edge_x = edgex;
            obj.Edge_y = edgey;
            obj.n_people = size(people_q, 1);
            obj.people = cell(obj.n_people, 1);
            for i=1:obj.n_people
                obj.people{i} = person_with_shoes(people_q(i, :), people_int{i}, recovered_v, sigma_theta, Kr, gamma);
            end
            obj.v_previous=zeros(obj.n_people,1);
        end
        
        function U = getAllU(obj)
            U = zeros(obj.n_people, 1);
            all_pos = zeros(obj.n_people, 2);
            all_walls = cell(obj.n_people, 1);
            
            for i=1:obj.n_people
                all_pos(i, :) = obj.people{i}.getPosition();
            end
            for i=1:obj.n_people
                all_walls{i} = zeros(4, 2);
                all_walls{i} = [obj.people{i}.x 0;
                                obj.people{i}.x obj.Edge_y;
                                0 obj.people{i}.y;
                                obj.Edge_x obj.people{i}.y];
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
        
        function V_tot = computeV(obj, t)
            U = obj.getAllU();
            
            for i=1:obj.n_people
                G_pinv = [-cos(obj.people{i}.theta) -sin(obj.people{i}.theta) 0];
                 R = [cos(obj.people{i}.theta) -sin(obj.people{i}.theta);
                sin(obj.people{i}.theta) cos(obj.people{i}.theta);];

                v_int = double(obj.people{i}.getIntentional(t));
                v_intxy = R*(v_int(1:2));
                v_ff(i) = -G_pinv * [v_intxy;0];
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
        
        function [V_tot, v_applied, V_int, all_pos] = applyAllInput(obj, t, dT)
            
            V_tot = obj.computeV(t);
            
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

