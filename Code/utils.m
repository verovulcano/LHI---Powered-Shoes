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
        
        function plotMap(pHistory, edge_x, edge_y)
            
            n_people = size(pHistory,2)/3;
            
            figure();
            im = imshow('Images/parquet.jpg','XData',[0,edge_x],'YData',[0,edge_y]);
            set(gca,'Ydir','normal')
            h = gca;
            h.Visible = 'On';
            hold on
            rectangle('Position',[0 0 edge_x edge_y],'EdgeColor',[0.7,0.3,0.1],'LineWidth',5)
            axis([-1 edge_x+1 -1 edge_y+1])
            hold on
            
            for i=1:n_people
                plot(pHistory(1+(i-1)*3),pHistory(2+(i-1)*3),'bo','MarkerSize',20, 'LineWidth',1.5)
            end
            hold off
        end
        
        function displayVideo(pHistory, edge_x, edge_y)
            
            for i=1:size(pHistory,1)
                utils.plotMap(pHistory(i,:), edge_x, edge_y)
            end
            
        end
        
    end
end

