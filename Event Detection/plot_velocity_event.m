function plot_velocity_event(velo,ds_events,t,save_yn)

frames=size(velo,3); 
num_ds=size(velo,1); 
med= median(1:frames);
scaled_start=med-60; 
scaled_end= med+120; 


%% PLOT VELOCITY DURING EVENTS

figure(99)
clf 
set(gcf,'color','w')

% SOM events --- 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(velo(:,1,:)));
dy = squeeze(nanstd(velo(:,1,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Blue')
hold on

% PV events ----
x = linspace(1,frames,frames)';
y = squeeze(nanmean(velo(:,2,:)));
dy = squeeze(nanstd(velo(:,2,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','Red')

% Mixed events--- 
x = linspace(1,frames,frames)';
y = squeeze(nanmean(velo(:,3,:)));
dy = squeeze(nanstd(velo(:,3,:)))./sqrt(num_ds);
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .6 1],'linestyle','none','HandleVisibility','off');
line(x,y,'Color','m')


% PLOT ----
legend({'SOM Events','PV Events','Mixed Events'},'location','northwest')
ylabel('Acceleration (cm/s^2)')
xlabel('Time from Event Onset (s)')
set(gca,'xtick',1:60:frames +1)
set(gca,'xticklabel',-4:2:4)
yl = ylim;
plot([120 120],yl,'--k','HandleVisibility','off')
axis square
set(gca,'fontsize',14)
title([t,' during Events'])


%% PLOT VELOCITY BY DATASET
figure(98)
hold on 
clf 
set(gcf,'color','w')

for d = 1:length(ds_events)
    subplot (4,3,d)
    hold on 
    yl = ylim;
    plot([120 120],yl,'--k','HandleVisibility','off')
   
    x = linspace(1,frames,frames)';
    ysom = squeeze(velo(d,1,:));
    ypv= squeeze(velo(d,2,:)); 
    ymixed=squeeze(velo(d,3,:)); 
    line(x,ysom,'color','b')
    line(x,ypv,'color','r')
    line(x,ymixed,'color','m')
    
%     if ismember(d,[1 2 7 8 9])
%         set(gca,'color',[1 .9 .9])
%         
%     else
%         set(gca,'color',[.9 1 .9])
%     end
    
    set(gca,'xtick',1:60:frames +1)
    set(gca,'xticklabel',-4:2:4)
    xline(120,'LineStyle','--')
    title(ds_events(d).tag)
end

sgtitle({[t,' During Events Across Datasets']})

% %% PLOT XCORR OF VELOCITY BY DATASET
% figure()
% hold on 
% clf 
% set(gcf,'color','w')
% 
% for d = 1:length(ds_events)
%     subplot (4,3,d)
%     hold on 
%     yl = ylim;
%     xline(201,'--k','HandleVisibility','off')
%    
%     x = linspace(1,401,401)';
%     ypyr = squeeze(ds_speed_xc(d,1,:));
%     ysom = squeeze(ds_speed_xc(d,2,:));
%     ypv = squeeze(ds_speed_xc(d,3,:));
%     
%     line(x,ysom,'color','b')
%     line(x,ypv,'color','r')
%     line(x,ypyr,'color','k')
%     xline(201,'--k')
% 
%     yline(0,'--k')
%     
%     if ismember(d,[1 2 7 8 9])
%         set(gca,'color',[1 .9 .9])
%     else
%         set(gca,'color',[.9 1 .9])
%     end
%     
%     set(gca,'xtick',[21:60:401])
%     set(gca,'xticklabel',[-6:2:6])
%    
%     title(ds_events(d).tag)
%     if ismember(d,[1])
%         legend({'SOM','PV','PYR'},'Location','southeast')
%     end
% end
% 
% sgtitle({['Cross-correlation Between Speed and Cell Types by Dataset'],'(green = trained)'})
%% SAVE


if strcmp(save_yn,'save')
    saveas(110,'Mean Velo During SOM and PV Events','pdf')
    saveas(110,'SOM PV Pyr Population Activity During SOM Events','fig')
  
end