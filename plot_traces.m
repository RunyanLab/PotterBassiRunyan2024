function[traces_figure,smoothed_dff]=plot_traces(dff,deconv,ctype,velocity,select_time,t)
%%
%DFF/DECONV/CTYPE MUST BE SORTED BY CELLTYPE 

dff=normr(dff);
deconv= normr(deconv)./5; 

numframes=size(dff,2);

smoothed_dff=movmean(dff,10,2); 

velocity=normr(velocity)*15;
velocity=movmean(velocity,30); 
%% SELECTED TIME

if length(select_time)==1
    select_time=1:numframes;
end

%% MAKE FIGURE
traces_figure=figure('Color','w');
hold on 
gc='g';%[.4 .4 .4]; 
lw=2; 
for i = 1: size(smoothed_dff,1)
    if ctype(i)==0
        plot(1:length(select_time),deconv(i,select_time)+i*.02,'Color',gc)
        %plot(1:length(select_time),smoothed_dff(i,select_time)+i*.02,'Color','k','LineWidth',lw)
        bar(1:length(select_time),deconv(i,select_time)+i)
        
    elseif ctype(i)==1
        plot(1:length(select_time),deconv(i,select_time)+i*.02,'Color',gc)
        plot(1:length(select_time),smoothed_dff(i,select_time)+i*.02,'Color','b','LineWidth',lw)
        

    elseif ctype(i)==2
        plot(1:length(select_time),deconv(i,select_time)+i*.02,'Color',gc)
        plot(1:length(select_time),smoothed_dff(i,select_time)+i*.02,'Color','r','LineWidth',lw)
        
    end
end

%% FIGURE PARAMETERS

frames=1:size(dff,2);
%seconds=frames/30; 


ylabel('Normalized Fluorescence (dF/F)');
xlabel('Time (30s)');
set(gca,'FontName','Arial');
set(gca,'FontSize',10);
set(gca, 'DefaultFigureRenderer', 'painters');

set(gca,'xtick',1:30*30:length(select_time)) %30s interval
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
title(t); 
axis square

%% PDF ISSUE
set(gcf,'Units','inches');
screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize',[screenposition(3:4)]);
%print -dpdf -painters  traces

%% MAKE VELOCITY FIGURE

%plot(1:length(select_time),velocity(select_time)+(i+3)*.02,"Color",'m','LineWidth',1.2)


%% OLD HEATMAP CODE  
% 
% 
% figure
% heatmap(smoothed_activity(:,36100:36300),'Colormap',summer,'GridVisible','off') 
% 
% 
% set(gcf,'xtick',[])

end
