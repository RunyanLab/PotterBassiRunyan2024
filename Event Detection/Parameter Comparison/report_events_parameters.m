function []= report_events_parameters (ds_events,ds,nparams,specify)
%% UNPACK STRUCTURE
all_mchw=[]; 
all_mchws=[];
all_mchwe=[]; 
all_mchp=[];
all_mcho=[];

all_tdtw=[];
all_tdtws=[]; 
all_tdtwe=[];
all_tdtp=[];
all_tdto=[]; 

n_mch_events=[];
n_tdt_events=[];

%% MAKE TITLE STRINGS
params=ds_events.params; 
nparams=6; 
titles=cell(nparams,1); 

for i=1:length(titles)
    titles{i}= ['Min Height: ',num2str(params(i,1)),'| Min Dist: ',num2str(params(i,2)),'| Min Prom: ',num2str(params(i,3)),'| Max Width: ',num2str(params(i,4)),'| Min Width: ',num2str(params(i,5))];
end





%% PLOT ONSET TO WIDTH END 
figure('Color','w')

for onum =1:nparams
    subplot(2,3,onum)
    all_mchw=[]; 
    all_mchws=[];
    all_mchwe=[]; 
    all_mchp=[];
    all_mcho=[];
    
    all_tdtw=[];
    all_tdtws=[]; 
    all_tdtwe=[];
    all_tdtp=[];
    all_tdto=[]; 
    
    n_mch_events=[];
    n_tdt_events=[];
    
    for i = ds
        all_mchw=[all_mchw,ds_events(i).onsets(onum).mch_widths];
        all_mcho=[all_mcho,ds_events(i).onsets(onum).mch_onsets]; 
        all_mchws=[all_mchws,ds_events(i).onsets(onum).mch_events];
        all_mchwe=[all_mchwe,ds_events(i).onsets(onum).mch_ends];
        all_mchp=[all_mchp,ds_events(i).onsets(onum).mch_peaks];
        n_mch_events(i)=length(ds_events(i).onsets(onum).mch_peaks);
        
        all_tdtw=[all_tdtw,ds_events(i).onsets(onum).tdt_widths];
        all_tdto=[all_tdto,ds_events(i).onsets(onum).tdt_onsets]; 
        all_tdtws=[all_tdtws,ds_events(i).onsets(onum).tdt_events];
        all_tdtwe=[all_tdtwe,ds_events(i).onsets(onum).tdt_ends];
        all_tdtp=[all_tdtp,ds_events(i).onsets(onum).tdt_peaks];
        n_tdt_events(i)=length(ds_events(i).onsets(onum).tdt_peaks);
    end

    
    hold on 
    histogram(all_tdtwe-all_tdto,50,'FaceColor','r')
    histogram(all_mchwe-all_mcho,50,'FaceColor','b')
    xlabel('Frames')
    ylabel('Frequency')
    
    
    xline(120,'color','g','LineWidth',2)
    xline(mean(all_tdtwe-all_tdto),'color','r')
    xline(mean(all_mchwe-all_mcho),'color','b')
    text(.5,.4,['Length(PV Onsets -> Width Ends): ',num2str(mean(all_tdtwe-all_tdto))],'units','normalized')
    text(.5,.3,['Length(SOM Onsets -> Width Ends): ',num2str(mean(all_mchwe-all_mcho))],'units','normalized')
    
    legend({'PV','SOM','Current Analysis Point'})
    title(titles{onum})
    

end
sgtitle('Length of Onset-defined frames')

%% PLOT EVENT START TO WIDTH END 
figure('Color','w')
hold on 

for onum=1:nparams
    subplot(2,3,onum)
    all_mchw=[]; 
    all_mchws=[];
    all_mchwe=[]; 
    all_mchp=[];
    all_mcho=[];
    
    all_tdtw=[];
    all_tdtws=[]; 
    all_tdtwe=[];
    all_tdtp=[];
    all_tdto=[]; 
    
    n_mch_events=[];
    n_tdt_events=[];
    
    for i = ds
        all_mchw=[all_mchw,ds_events(i).onsets(onum).mch_widths];
        all_mcho=[all_mcho,ds_events(i).onsets(onum).mch_onsets]; 
        all_mchws=[all_mchws,ds_events(i).onsets(onum).mch_events];
        all_mchwe=[all_mchwe,ds_events(i).onsets(onum).mch_ends];
        all_mchp=[all_mchp,ds_events(i).onsets(onum).mch_peaks];
        n_mch_events(i)=length(ds_events(i).onsets(onum).mch_peaks);
    
        all_tdtw=[all_tdtw,ds_events(i).onsets(onum).tdt_widths];
        all_tdto=[all_tdto,ds_events(i).onsets(onum).tdt_onsets]; 
        all_tdtws=[all_tdtws,ds_events(i).onsets(onum).tdt_events];
        all_tdtwe=[all_tdtwe,ds_events(i).onsets(onum).tdt_ends];
        all_tdtp=[all_tdtp,ds_events(i).onsets(onum).tdt_peaks];
        n_tdt_events(i)=length(ds_events(i).onsets(onum).tdt_peaks);
    end

    hold on 
    histogram(all_tdtwe-all_tdtws,50,'FaceColor','r')
    histogram(all_mchwe-all_mchws,50,'FaceColor','b')
    xlabel('Frames')
    ylabel('Frequency')
    
    
    xline(120,'color','g','LineWidth',2)
    xline(mean(all_tdtwe-all_tdtws),'color','r')
    xline(mean(all_mchwe-all_mchws),'color','b')
    text(.5,.5,['Length(PV Onsets -> Width Ends): ',num2str(mean(all_tdtwe-all_tdto))],'units','normalized')
    text(.5,.4,['Length(SOM Onsets -> Width Ends): ',num2str(mean(all_mchwe-all_mcho))],'units','normalized')
    
    legend({'PV','SOM','Current Analysis Point'})
    title(titles{onum})
    

end
sgtitle('Event Width')

%% PLOT LENGTHS OF EVENTS BY DATASET
specify=3; 
onum=specify;
figure(1)
figure(2)

for i = ds
    all_mchw=[]; 
    all_mchws=[];
    all_mchwe=[]; 
    all_mchp=[];
    all_mcho=[];
    
    all_tdtw=[];
    all_tdtws=[]; 
    all_tdtwe=[];
    all_tdtp=[];
    all_tdto=[]; 
    
    n_mch_events=[];
    n_tdt_events=[];

    all_mchw=[all_mchw,ds_events(i).onsets(onum).mch_widths];
    all_mcho=[all_mcho,ds_events(i).onsets(onum).mch_onsets]; 
    all_mchws=[all_mchws,ds_events(i).onsets(onum).mch_events];
    all_mchwe=[all_mchwe,ds_events(i).onsets(onum).mch_ends];
    all_mchp=[all_mchp,ds_events(i).onsets(onum).mch_peaks];
    n_mch_events(i)=length(ds_events(i).onsets(onum).mch_peaks);

    all_tdtw=[all_tdtw,ds_events(i).onsets(onum).tdt_widths];
    all_tdto=[all_tdto,ds_events(i).onsets(onum).tdt_onsets]; 
    all_tdtws=[all_tdtws,ds_events(i).onsets(onum).tdt_events];
    all_tdtwe=[all_tdtwe,ds_events(i).onsets(onum).tdt_ends];
    all_tdtp=[all_tdtp,ds_events(i).onsets(onum).tdt_peaks];
    n_tdt_events(i)=length(ds_events(i).onsets(onum).tdt_peaks);
    
    figure(1)
    set(gcf,'Color','w')
    subplot(3,4,i)
    hold on 
    histogram(all_tdtwe-all_tdto,50,'FaceColor','r')
    histogram(all_mchwe-all_mcho,50,'FaceColor','b')
    xlabel('Frames')
    ylabel('Frequency')
    
    
    xline(120,'color','g','LineWidth',2)
    xline(mean(all_tdtwe-all_tdto),'color','r')
    xline(mean(all_mchwe-all_mcho),'color','b')
    text(.35,.6,['PV onsets: ',num2str(mean(all_tdtwe-all_tdto))],'units','normalized')
    text(.35,.5,['SOM onsets: ',num2str(mean(all_mchwe-all_mcho))],'units','normalized')
    
    legend({'PV','SOM','Current Analysis Point'})
    figure(2)
    set(gcf,'Color','w')
    subplot(3,4,i)
    b = bar([mean(all_mchwe-all_mcho),mean(all_tdtwe-all_tdto)]);
    b.FaceColor = 'flat';
    b.CData(1,:)=[1 0 0]
    b.CData(2,:) = [0 0 1];
    xticks([1,2])
    xticklabels({'PV','SOM'})
    if mod(i+3,4)==0
        ylabel('Mean Length of Event (s)')
    end

end
figure(1)
sgtitle({'Length of events across datasets',titles{onum}})
figure(2)
sgtitle({'Length of events across datasets',titles{onum}})

%% PLOT NUMBER OF EVENTS BY DATASET 

figure('Color','w')
hold on 


for onum=1:nparams
    subplot(2,3,onum)
    all_mchw=[]; 
    all_mchws=[];
    all_mchwe=[]; 
    all_mchp=[];
    all_mcho=[];
    
    all_tdtw=[];
    all_tdtws=[]; 
    all_tdtwe=[];
    all_tdtp=[];
    all_tdto=[]; 
    
    n_mch_events=[];
    n_tdt_events=[];
    
    for i = ds
    all_mchw=[all_mchw,ds_events(i).onsets(onum).mch_widths];
    all_mcho=[all_mcho,ds_events(i).onsets(onum).mch_onsets]; 
    all_mchws=[all_mchws,ds_events(i).onsets(onum).mch_events];
    all_mchwe=[all_mchwe,ds_events(i).onsets(onum).mch_ends];
    all_mchp=[all_mchp,ds_events(i).onsets(onum).mch_peaks];
    n_mch_events(i)=length(ds_events(i).onsets(onum).mch_peaks);

    all_tdtw=[all_tdtw,ds_events(i).onsets(onum).tdt_widths];
    all_tdto=[all_tdto,ds_events(i).onsets(onum).tdt_onsets]; 
    all_tdtws=[all_tdtws,ds_events(i).onsets(onum).tdt_events];
    all_tdtwe=[all_tdtwe,ds_events(i).onsets(onum).tdt_ends];
    all_tdtp=[all_tdtp,ds_events(i).onsets(onum).tdt_peaks];
    n_tdt_events(i)=length(ds_events(i).onsets(onum).tdt_peaks);
end

    bar([mean(n_mch_events) mean(n_tdt_events)],'grouped','k','FaceAlpha',.01)
    hold on 

    for i = ds
        plot ([1 2],[n_mch_events(i),n_tdt_events(i)],'LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
    
    end
    
    legend({'Average Number of Events'})
    xticks([1 2])
    xticklabels({'SOM','PV'})
    ylabel('Number')
    title(titles{onum})
    text(.7,.5,[num2str(mean(n_mch_events)),' SOM events'],'units','normalized')
    text(.7,.4,[num2str(mean(n_tdt_events)),' PV events'],'units','normalized')
end

sgtitle('Number of Events for Each Cell Type')

%% COMPARE EVENTS TO ONSETS


figure('color','w')
hold on 

for onum=1:nparams
    subplot(2,3,onum)
    all_mchw=[]; 
    all_mchws=[];
    all_mchwe=[]; 
    all_mchp=[];
    all_mcho=[];
    
    all_tdtw=[];
    all_tdtws=[]; 
    all_tdtwe=[];
    all_tdtp=[];
    all_tdto=[]; 
    
    n_mch_events=[];
    n_tdt_events=[];
    
    for i = ds
    all_mchw=[all_mchw,ds_events(i).onsets(onum).mch_widths];
    all_mcho=[all_mcho,ds_events(i).onsets(onum).mch_onsets]; 
    all_mchws=[all_mchws,ds_events(i).onsets(onum).mch_events];
    all_mchwe=[all_mchwe,ds_events(i).onsets(onum).mch_ends];
    all_mchp=[all_mchp,ds_events(i).onsets(onum).mch_peaks];
    n_mch_events(i)=length(ds_events(i).onsets(onum).mch_peaks);

    all_tdtw=[all_tdtw,ds_events(i).onsets(onum).tdt_widths];
    all_tdto=[all_tdto,ds_events(i).onsets(onum).tdt_onsets]; 
    all_tdtws=[all_tdtws,ds_events(i).onsets(onum).tdt_events];
    all_tdtwe=[all_tdtwe,ds_events(i).onsets(onum).tdt_ends];
    all_tdtp=[all_tdtp,ds_events(i).onsets(onum).tdt_peaks];
    n_tdt_events(i)=length(ds_events(i).onsets(onum).tdt_peaks);
end
 
    histogram([all_tdtwe-all_tdto,all_mchwe-all_mcho],'FaceColor','m')
    hold on 
    histogram([all_tdtw,all_mchw],'FaceColor','g')
    
   
  
    xlabel('Frames')
    ylabel('Frequency')
    legend({'Findpeaks width','Width defined by zscore onset'})
    
    text(.4,.5,[num2str(round(mean([all_tdtw,all_mchw])-mean([all_tdtwe-all_tdto,all_mchwe-all_mcho]))),' frames between onset and 1/2 prominence'],'units','normalized')
    title(titles{onum})

end

sgtitle('Frames between onset and 1/2 prominence for both SOM and PV')



