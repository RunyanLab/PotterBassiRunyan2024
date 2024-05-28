function plot_accuracy(output,bin,starts,param,shuffle_yn)

%% UNPACK VARIABLES

sp_accuracy=output.sp_accuracy;
spn_accuracy=output.spn_accuracy; 
sp_err=std(sp_accuracy)/sqrt(length(sp_accuracy)); 
spn_err=std(spn_accuracy)/sqrt(length(spn_accuracy)); 

pn_accuracy=output.pn_accuracy;
sn_accuracy=output.sn_accuracy;
sn_err=std(sn_accuracy)/sqrt(length(sn_accuracy)); 
pn_err=std(pn_accuracy)/sqrt(length(pn_accuracy)); 

%% PLOT 
if ~strcmp(shuffle_yn,'shuffle')
    figure(1)
    utils.set_figure(15) 
    hold on 
    frames=length(sp_err); 
    x = linspace(1,frames,frames)';
    
    y= mean(sp_accuracy,1)'; 
    dy=sp_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 1],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color',[1 0 1])
    
    y= mean(spn_accuracy,1)'; 
    dy=spn_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color','g')
    
    xlabel('Start of Time Bin Prior to Event Onset (Seconds)')
    ylabel('Classification Accuracy')
    
    title({'Classification Accuracy of SOM and PV Events at Different Time Points'})
    xticks(10:30:length(sp_accuracy))
    xticklabels(-3:1)
    legend({'SOM vs PV','SOM/PV vs Null'})
    xline(find(starts==0),'handleVisibility','off')
    
    yline(.5,'handleVisibility','off')
        
    %% COMPARE SOM AND PV TO NULL (Supplemental)

    figure(2)
    hold on 
    utils.set_figure(15)
    y= squeeze(mean(sn_accuracy,1))'; 
    dy=squeeze(sn_err);
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off'); 
    line(x,y,'Color','b')
    
    y= mean(pn_accuracy,1)'; 
    dy=pn_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off'); 
    line(x,y,'Color','r')

    xlabel('Start of Time Bin Prior to Event Onset (Seconds)')
    ylabel('Classification Accuracy')
    
    title({'Classification Accuracy of SOM and PV Events at Different Time Points'})
    xticks(10:30:length(sp_accuracy))
    xticklabels(-3:1)
    legend({'SOM vs PV','SOM/PV vs Null'})
    xline(find(starts==0),'handleVisibility','off')
    
    yline(.5,'handleVisibility','off')

%% if plotting shuffle
elseif strcmp(shuffle_yn,'shuffle')
    figure('Color','w')
    utils.set_figure(15)
    hold on 
    frames=length(sp_err); 
    x = linspace(1,frames,frames)';
    
    y= mean(sp_accuracy,1)'; 
    dy=sp_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 1],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color',[1 0 1])
    
    y= mean(spn_accuracy,1)'; 
    dy=spn_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 1 .8],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color','g')
    
    y= mean(sn_accuracy,1)'; 
    dy=sn_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 1],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color','b')
    
    y= mean(pn_accuracy,1)'; 
    dy=pn_err;
    fill([x;flipud(x)],[y-dy;flipud(y+dy)],[1 .8 .8],'linestyle','none','HandleVisibility','off'); 
    plot(x,y,'Color','r')

    xlabel('Start of Time Bin Prior to Event Onset (Seconds)')
    ylabel('Classification Accuracy')
    
    title({'Shuffled Classification Accuracy'})
    xticks(10:30:length(sp_accuracy))
    xticklabels(-3:1)
    legend({'SOM vs PV','SOM/PV vs Null','SOM vs Null','PV vs Null'})
    xline(find(starts==0),'handleVisibility','off')
    
    yline(.5,'handleVisibility','off')
    yticks([.4 .5 .6])

end







