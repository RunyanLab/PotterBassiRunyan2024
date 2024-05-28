function []= report_events (ds_events,ex_thresh)
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


% for i = ds
%    
%     all_mchw=[all_mchw,ds_events(i).onsets.mch_widths];
%     cur_mchws=ds_events(i).onsets.mch_peaks-floor(ds_events(i).onsets.mch_widths/2); 
%     cur_mchwe=ds_events(i).onsets.mch_peaks+floor(ds_events(i).onsets.mch_widths/2); 
%     all_mchws=[all_mchws,cur_mchws];
%     all_mchwe=[all_mchwe,cur_mchwe];
%     all_mchp=[all_mchp,ds_events(i).onsets.mch_peaks]; 
%     all_mcho=[all_mcho,ds_events(i).onsets.mch_onsets'];
%     n_mch_events(i)=length(cur_mchwe);  
% 
%     all_tdtw=[all_tdtw,ds_events(i).onsets.tdt_widths];
%     cur_tdtws=ds_events(i).onsets.tdt_peaks-floor(ds_events(i).onsets.tdt_widths/2); 
%     cur_tdtwe=ds_events(i).onsets.tdt_peaks+floor(ds_events(i).onsets.tdt_widths/2); 
%     all_tdtws=[all_tdtws,cur_tdtws];
%     all_tdtwe=[all_tdtwe,cur_tdtwe];
%     all_tdtp=[all_tdtp,ds_events(i).onsets.tdt_peaks]; 
%     all_tdto=[all_tdto,ds_events(i).onsets.tdt_onsets'];
%     n_tdt_events(i)=length(cur_tdtwe); 
% 
% end

% for i = ds
%     all_mchw=[all_mchw,ds_events(i).onsets.mch_widths];
%     all_mcho=[all_mcho,ds_events(i).onsets.mch_onsets]; 
%     all_mchws=[all_mchws,ds_events(i).onsets.mch_events];
%     all_mchwe=[all_mchwe,ds_events(i).onsets.mch_ends];
%     all_mchp=[all_mchp,ds_events(i).onsets.mch_peaks];
%     n_mch_events(i)=length(ds_events(i).onsets.mch_peaks);
% 
%     all_tdtw=[all_tdtw,ds_events(i).onsets.tdt_widths];
%     all_tdto=[all_tdto,ds_events(i).onsets.tdt_onsets]; 
%     all_tdtws=[all_tdtws,ds_events(i).onsets.tdt_events];
%     all_tdtwe=[all_tdtwe,ds_events(i).onsets.tdt_ends];
%     all_tdtp=[all_tdtp,ds_events(i).onsets.tdt_peaks];
%     n_tdt_events(i)=length(ds_events(i).onsets.tdt_peaks);
% end

for i = 1:length(ds_events)

    cur_onsets= ds_events(i).onsets; 
    
    mch_counter=0; 
    tdt_counter=0; 
    
    for tr = 1:length(cur_onsets)
        if cur_onsets(tr).pure<ex_thresh
            onset=cur_onsets(tr).onset; 
            event=cur_onsets(tr).event;
            peak=cur_onsets(tr).peak; 
            width=cur_onsets(tr).width; 

            if strcmp(cur_onsets(tr).condition,'SOM')
                all_mchw=[all_mchw,width];
                all_mcho=[all_mcho,onset];
                all_mchws=[all_mchws,event];
                all_mchwe=[all_mchwe,event+width]; 
                all_mchp=[all_mchp,peak];
                mch_counter=mch_counter+1; 
            else
                all_tdtw=[all_tdtw,width];
                all_tdto=[all_tdto,onset];
                all_tdtws=[all_tdtws,event];
                all_tdtwe=[all_tdtwe,event+width]; 
                all_tdtp=[all_tdtp,peak];
                tdt_counter=tdt_counter+1; 
            end
        end
    end
    
    n_mch_events(i)=mch_counter;
    n_tdt_events(i)=tdt_counter; 

end

%% PLOT ONSET TO WIDTH END 
figure('Color','w')
hold on 
histogram(all_tdtwe-all_tdto,50,'FaceColor','r')
histogram(all_mchwe-all_mcho,50,'FaceColor','b')
xlabel('Frames')
ylabel('Frequency')


xline(120,'color','g','LineWidth',2)
xline(mean(all_tdtwe-all_tdto),'color','r')
xline(mean(all_mchwe-all_mcho),'color','b')
text(.5,.7,['Length of PV Onsets -> Width Ends: ',num2str(mean(all_tdtwe-all_tdto))],'units','normalized')
text(.5,.6,['Mean Length of SOM Onsets -> Width Ends: ',num2str(mean(all_mchwe-all_mcho))],'units','normalized')

legend({'PV','SOM','Current Analysis Point'})
title('Length of Onset-defined frames')

%% PLOT EVENT START TO WIDTH END 
figure('Color','w')
hold on 
histogram(all_tdtwe-all_tdto,50,'FaceColor','r')
histogram(all_mchwe-all_mcho,50,'FaceColor','b')
xlabel('Frames')
ylabel('Frequency')


xline(120,'color','g','LineWidth',2)
xline(mean(all_tdtwe-all_tdtws),'color','r')
xline(mean(all_mchwe-all_mchws),'color','b')
text(.5,.7,['mean width of PV events: ',num2str(mean(all_tdtwe-all_tdto))],'units','normalized')
text(.5,.6,['mean width of SOM events: ',num2str(mean(all_mchwe-all_mcho))],'units','normalized')

legend({'PV','SOM','Current Analysis Point'})
title('Length of 1/2 prominence-defined frames')

%% PLOT NUMBER OF EVENTS BY DATASET 

figure('Color','w')
hold on 

bar([mean(n_mch_events) mean(n_tdt_events)],'grouped','k','FaceAlpha',.01)

for i = 1:length(ds_events)
    plot ([1 2],[n_mch_events(i),n_tdt_events(i)],'LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')

end

legend({'Average Number of Events'})
xticks([1 2])
xticklabels({'SOM','PV'})
ylabel('Number')
title('Number of Events for Each Cell Type')

%% COMPARE EVENTS TO ONSETS

% 
% figure('color','w')
% % title([mouse,' ',date,': comparison of SOM and PV events'])
% 
% histogram([all_tdtw,all_mchw],'FaceColor','g')
% hold on 
% histogram([all_tdtwe-all_tdto,all_mchwe-all_mcho],'FaceColor','m')
% title('Frames between onset and 1/2 prominence for SOM and PV combined')
% xlabel('Frames')
% ylabel('Frequency')
% legend({'Findpeaks width','Width defined by zscore onset'})
% 
% text(200,140,[num2str(round(mean([all_tdtw,all_mchw])-mean([all_tdtwe-all_tdto,all_mchwe-all_mcho]))),' frames between onset and 1/2 prominence'])

%%
figure('color','w')
% title([mouse,' ',date,': comparison of SOM and PV events'])




widths=[all_tdtw,all_mchw];
onsets=[all_tdtwe-all_tdto,all_mchwe-all_mcho];
histogram(onsets-widths)

title('Frames between onset and 1/2 prominence for SOM and PV combined')
xlabel('Frames')
ylabel('Frequency')
legend({'Findpeaks width','Width defined by zscore onset'})

text(200,140,num2str(mean(onsets-widths)),' frames between onset and 1/2 prominence')

