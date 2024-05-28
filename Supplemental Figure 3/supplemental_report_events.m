function [rate_mch_events,rate_tdt_events,rate_ex_events,durations]= supplemental_report_events (ds_events,ex_thresh,ex_type)

%% UNPACK STRUCTURE
mchw=[]; 
mchws=[];
mchwe=[]; 
mchp=[];
mcho=[];

tdtw=[];
tdtws=[]; 
tdtwe=[];
tdtp=[];
tdto=[];

exw=[];
exws=[]; 
exwe=[];
exp=[];
exo=[]; 

n_mch_events=[];
n_tdt_events=[];

%%
for i = 1:length(ds_events)
    cur_onsets= ds_events(i).onsets; 
    mch_counter=0; 
    tdt_counter=0; 
    ex_counter=0; 
    mch_pop_signal=ds_events(i).mch_pop_signal;
    tdt_pop_signal=ds_events(i).tdt_pop_signal; 

    for tr = 1:length(cur_onsets)      
       [ratio]=utils.get_ratio(cur_onsets,tr,ds_events,i);
       onset=cur_onsets(tr).onset; 
       event=cur_onsets(tr).event;
       peak=cur_onsets(tr).peak; 
       width=cur_onsets(tr).width; 

        if ratio>ex_thresh
            if strcmp(cur_onsets(tr).condition,'SOM')
                mchw=[mchw,width];
                mcho=[mcho,onset];
                mchws=[mchws,event];
                mchwe=[mchwe,event+width]; 
                mchp=[mchp,peak];
                mch_counter=mch_counter+1; 
            else
                tdtw=[tdtw,width];
                tdto=[tdto,onset];
                tdtws=[tdtws,event];
                tdtwe=[tdtwe,event+width]; 
                tdtp=[tdtp,peak];
                tdt_counter=tdt_counter+1; 
            end
        else
            exw=[exw,width];
            exo=[exo,onset];
            exws=[exws,event];
            exwe=[exwe,event+width];
            exp=[exp,peak];
            ex_counter=ex_counter+1; 

        end 
    end

    n_mch_events(i)=mch_counter;
    n_tdt_events(i)=tdt_counter;
    n_ex_events(i)=ex_counter; 
    rate_mch_events(i)=mch_counter/ (length(mch_pop_signal)/1800);
    rate_tdt_events(i)=tdt_counter/ (length(mch_pop_signal)/1800); 
    rate_ex_events(i)=ex_counter/ (length(mch_pop_signal)/1800); 
end
%% PLOTING PARAMS
nbins=15; 


%% FIGURE 1: PLOT ONSET TO WIDTH END (TOTAL LENGTH)
figure(1)
hold on 
[f,x]=ecdf(tdtwe-tdto)
plot(x,f,'Color','r')

[f,x]=ecdf(mchwe-mcho)
plot(x,f,'Color','b')

[f,x]=ecdf(exwe-exo)
plot(x,f,'color','m')

xlabel('Seconds')
ylabel('Frequency')

xticks([30 60 90 120 150 180 210 240 270 300 330])
xticklabels({'1','2','3','4','5','6','7','8','9','10','11'})

xline(mean(tdtwe-tdto),'color','r')
xline(mean(mchwe-mcho),'color','b')
xline(mean(exwe-exo),'color','m')
text(.5,.7,['Mean Length of PV Events:',num2str(mean(tdtwe-tdto)/30)],'units','normalized')
text(.5,.6,['Mean Length of SOM Events: ',num2str(mean(mchwe-mcho)/30)],'units','normalized')
text(.5,.5,['Mean Length of Excluded Events: ',num2str(mean(exwe-exo)/30)],'units','normalized')

axis([0 8*30 0 1])
durations.somt=mchwe-mcho; 
durations.pvt=tdtwe-tdto; 
durations.mixt=exwe-exo; 

legend({'PV','SOM'})
title('Length of Total Event')
utils.set_figure(10); 
%% FIGURE 2: PLOT PEAK TO WIDTH END (PERIOD OF ANALYSIS)
figure(2)
hold on 
[f,x]=ecdf(tdtwe-tdtp)
plot(x,f,'Color','r')

[f,x]=ecdf(exwe-exp)
plot(x,f,'color','m')

[f,x]=ecdf(mchwe-mchp)
plot(x,f,'Color','b')


xlabel('Seconds')
ylabel('Frequency')
xticks([30 60 90 120 150 180 210 240 270 300 330])
xticklabels({'1','2','3','4','5','6','7','8','9','10','11'})
xline(mean(tdtwe-tdtp),'color','r')
xline(mean(mchwe-mchp),'color','b')
xline(mean(exwe-exp),'color','m')

text(.5,.7,['Mean Length of PV events: ',num2str(mean(tdtwe-tdtp)/30)],'units','normalized')
text(.5,.6,['Mean Length of SOM events: ',num2str(mean(mchwe-mchp)/30)],'units','normalized')
text(.5,.5,['Mean Length of Excluded events: ',num2str(mean(exwe-exp)/30)],'units','normalized')
axis([0 7*30 0 1])

durations.somp=mchwe-mchp; 
durations.pvp=tdtwe-tdtp; 
durations.mixp=exwe-exp; 

legend({'PV','Mixed','SOM'})
title('Length of Peak to Width End')
utils.set_figure(10); 

%% FIGURE 3: PLOT NUMBER OF EVENTS BY DATASET 
figure(3)
hold on 

bar([mean(n_mch_events) mean(n_ex_events) mean(n_tdt_events) ],'grouped','k','FaceAlpha',.01)

for i = 1:length(ds_events)
    plot ([1 2 3],[n_mch_events(i),n_ex_events(i),n_tdt_events(i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')

end

legend({'Average Number of Events'})
xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})
ylabel('Number')
title('Number of Events for Each Cell Type')
utils.set_figure(10); 

%% PLOT RATE OF EVENTS
figure(4)
hold on 

bar([mean(rate_mch_events) mean(rate_ex_events) mean(rate_tdt_events) ],'grouped','k','FaceAlpha',.01)
for i = 1:length(ds_events)
    plot ([1 2 3],[rate_mch_events(i),rate_ex_events(i),rate_tdt_events(i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
end

legend({'Average Number of Events'})
xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})
ylabel('Events Per Minute')
title('Rate of Events per Minute for Each Cell Type')
utils.set_figure(10); 


