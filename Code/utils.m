classdef utils
    %UTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % null
    end
    
    methods (Static)

        function plotState(time, pHistory, n)
            
            name_figure = strcat('State of person',{' '},string(n));
            
            figure('Name', name_figure);
            
            subplot(3,1,1);
            p1 = plot(time,pHistory(:,1));
            p1.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$x$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            grid on
            
            subplot(3,1,2);
            p2 = plot(time,pHistory(:,2));
            p2.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$y$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            grid on
            
            subplot(3,1,3);
            p3 = plot(time,pHistory(:,3));
            p3.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$\theta$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            grid on
        end
        
        function plotV(time, V, n)
            
            name_figure = strcat('Control input of person',{' '},string(n));
            
            figure('Name', name_figure);
            
            p1 = plot(time,V);
            p1.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$u$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            grid on
            
        end
        
        function plotN(time, V, n)
            
            name_figure = strcat('Clearance of person',{' '},string(n));
            
            figure('Name', name_figure);
            
            p1 = plot(time,V);
            p1.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$\eta$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            grid on
            
        end
        
        function plotIntentional(time,V_int,V_est,pHistory,path)
            
            n_people = size(pHistory,2)/3;
            
            for n = 1:n_people
                for i=1:size(pHistory,1)
                    
                    R = [cos(pHistory(i,3+(n-1)*3)) -sin(pHistory(i,3+(n-1)*3));
                         sin(pHistory(i,3+(n-1)*3)) cos(pHistory(i,3+(n-1)*3))];
                    
                    V_int1 = V_int(i,(1+(n-1)*2):(1+(n-1)*2)+1)';
                    V_int1 = R*V_int1;
                    V_int(i,(1+(n-1)*2):(1+(n-1)*2)+1) = V_int1';
                end
            end
            
            for n = 1:n_people
                utils.plotVperson(time,V_int(:,(1+(n-1)*2):(1+(n-1)*2)+1),V_est(:,(1+(n-1)*2):(1+(n-1)*2)+1),n)
                saveas(gcf,strcat(path,'/intentional_p',string(n)),'epsc')
                saveas(gcf,strcat(path,'/intentional_p',string(n),'.png'))
            end
            
        end
        
        function plotVperson(time,v_int,v_est,n)
            
            name_figure = strcat('Intentional velocity of person',{' '},string(n));
            
            figure('Name', name_figure);
            
            subplot(2,1,1);
            p1 = plot(time,v_int(:,1));
            p1.LineWidth = 1.5;
            grid on
            hold on
            p2 = plot(time,v_est(:,1));
            p2.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$V_x$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            legend({'$V_x$','$\tilde{V_x}$'},'Interpreter','latex','FontSize',15.0)
            
            subplot(2,1,2);
            p3 = plot(time,v_int(:,2));
            p3.LineWidth = 1.5;
            grid on
            hold on
            p4 = plot(time,v_est(:,2));
            p4.LineWidth = 1.5;
            xlabel('Time (s)','FontSize',15.0)
            ylabel('$V_y$','Interpreter','latex','FontSize',20.0,'FontWeight','Bold')
            legend({'$V_y$','$\tilde{V_y}$'},'Interpreter','latex','FontSize',15.0)
            
        end
        
        function plotMap(pHistory, v, v_app, v_int, edge_x, edge_y, debug)
            
            n_people = size(pHistory,2)/3;
            
            figure('visible','off');
            set(gcf, 'Position',  [0, 0, 800, 800])
            axis equal
            %figure
            if ~debug
                im = imshow('Images/parquet.jpg','XData',[0,edge_x],'YData',[0,edge_y]);
                axis square
            end
            set(gca,'Ydir','normal')
            h = gca;
            h.Visible = 'On';
            hold on
            rectangle('Position',[0 0 edge_x edge_y],'EdgeColor',[0.7,0.3,0.1],'LineWidth',5)
            axis([-1 edge_x+1 -1 edge_y+1])
            hold on
            
            shirt_colors = ['r', 'b', 'g', 'm'];
            hair_colors = [0.8 0.5 0.2;
                           0.5 0.3 0.1;
                           0.7 0.7 0.7;
                           0.9, 0.8, 0.5];
            for i=1:n_people
                utils.drawRectangleonImageAtAngle([pHistory(1+(i-1)*3); pHistory(2+(i-1)*3)], 0.2, 0.5, pHistory(3+(i-1)*3), shirt_colors(i));
                p = nsidedpoly(1000, 'Center', [pHistory(1+(i-1)*3),pHistory(2+(i-1)*3)], 'Radius', 0.125);
                plot(p,'FaceColor', hair_colors(i,:), 'FaceAlpha', 1)
                r = 0.125;
                semicrc = r.*[cos(pHistory(3+(i-1)*3)-80/180*pi:0.1:pHistory(3+(i-1)*3)+80/180*pi); 
                                sin(pHistory(3+(i-1)*3)-80/180*pi:0.1:pHistory(3+(i-1)*3)+80/180*pi)];
                semicrc = semicrc + [pHistory(1+(i-1)*3); pHistory(2+(i-1)*3)];
                patch(semicrc(1,:), semicrc(2,:), [1 0.7529 0.7960], 'FaceAlpha', 1)
                %axis equal

                %plot(pHistory(1+(i-1)*3)+0.1*cos(pHistory(3+(i-1)*3)),pHistory(2+(i-1)*3)+0.1*sin(pHistory(3+(i-1)*3)),'ko','MarkerSize',5, 'LineWidth',0.5)
                
                
                p1 = [pHistory(1+(i-1)*3),pHistory(2+(i-1)*3)];
                dp = [v_app(1+(i-1)*2) v_app(2+(i-1)*2)];
                quiver(p1(1),p1(2),dp(1),dp(2),0, 'LineWidth', 2, 'Color', 'g')
                
                 R = [cos(pHistory(3+(i-1)*3)) -sin(pHistory(3+(i-1)*3));
                sin(pHistory(3+(i-1)*3)) cos(pHistory(3+(i-1)*3));];

                v_int_i = [v_int(1+(i-1)*3); v_int(2+(i-1)*3)];
                v_intxy = R*v_int_i;
                dp = [v_intxy(1) v_intxy(2)];
                quiver(p1(1),p1(2),dp(1),dp(2),0, 'LineWidth', 2, 'Color', 'b')
            end
            hold off
        end
        
        function displayVideo(pHistory, V_tot, V_app, V_int, edge_x, edge_y, path, fr, debug)
            video_name = strcat(path,'/myVideo');
            if ismac
                % Code to run on Mac platform
                v = VideoWriter(video_name,'MPEG-4');
            elseif isunix
                % Code to run on Linux platform
                v = VideoWriter(video_name);
            elseif ispc
                % Code to run on Windows platform
                v = VideoWriter(video_name,'MPEG-4');
            else
                disp('Platform not supported')
                v = VideoWriter(video_name);
            end
            v.FrameRate = fr;
            open(v)
            f = waitbar(0, 'Please wait...');
            shape = [800, 800];
            for i=1:size(pHistory,1)
                utils.plotMap(pHistory(i,:), V_tot(i, :), V_app(i, :), V_int(i, :), edge_x, edge_y, debug)
                frame = getframe(gcf);
                if debug
                    if size(frame.cdata, 1)~=shape(1) || size(frame.cdata, 2)~=shape(2)
                        %new_frame = uint8(ones(shape(1), shape(2), 3)*255);
                        %new_frame(1:size(frame.cdata, 1), 1:size(frame.cdata, 2), :) = frame.cdata;
                        new_frame = imresize(frame.cdata,[shape(1) shape(2)]);
                        frame.cdata = new_frame;
                    end
                end
                writeVideo(v,frame)
                waitbar(i/size(pHistory,1), f, 'Please wait...');
            end
            close(f)
            close(v)
            if ismac
                % Code to run on Mac platform
            elseif isunix
                % Code to run on Linux platform
                % If Linux, convert AVI to MP4 using ffmpeg
                command = strcat('ffmpeg -i',{' '},video_name,'.avi',{' '},video_name,'.mp4');
                command = command{1};
                system(command);
            end
        end
        
        function drawRectangleonImageAtAngle(center,width, height,angle, color)
            hold on;
            theta = -angle;
            coords = [center(1)-(width/2) center(1)-(width/2) center(1)+(width/2)  center(1)+(width/2);...
                      center(2)-(height/2) center(2)+(height/2) center(2)+(height/2)  center(2)-(height/2)];
            R = [cos(theta) sin(theta);...
                -sin(theta) cos(theta)];

            rot_coords = R*(coords-repmat(center,[1 4]))+repmat(center,[1 4]);
            rot_coords(:,5)=rot_coords(:,1);
            
            line(rot_coords(1,:),rot_coords(2,:), 'color', color );
            patch(rot_coords(1,:),rot_coords(2,:), color)

        end
    end
end

