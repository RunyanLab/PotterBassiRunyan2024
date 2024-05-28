%FIGURE3
%% LOAD DATA
base = 'Z:\Potter et al datasets\';
event_frame = 120;
%load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat')
base= '/Volumes/Runyan/Potter et al datasets/'
%% GET MEAN ACTIVITY
[pyr_mean_activity,som_mean_activity,pv_mean_activity,velo,acc] = get_mean_activity(base,ds_events,event_frame,2); 

%% PLOT EXAMPLE TRACES 
ds=3; %dataset 
som_peaks=[];
pv_peaks=[]; 
onsets= ds_events(ds).onsets; 

for i = 1: length(onsets)
    if strcmp(onsets(i).condition,'SOM')
        som_peaks=[som_peaks,onsets(i).peak];
    else
        pv_peaks=[pv_peaks,onsets(i).peak];
    end
end

timepoints=11000:20365; 
timepoints=timepoints(5600:6800);
som_peak_idxs=find(som_peaks>timepoints(1)&som_peaks<timepoints(end));
pv_peak_idxs=find(pv_peaks>timepoints(1)&pv_peaks<timepoints(end))


figure(5)
hold on
set(gcf,'Color','w')
plot(ds_events(ds).mch_pop_signal(timepoints),'Color','b')
plot(ds_events(ds).tdt_pop_signal(timepoints),'Color','r')
scatter(som_peaks(som_peak_idxs)-timepoints(1),ds_events(ds).mch_pop_signal(som_peaks(som_peak_idxs)),'MarkerEdgeColor','b')
scatter(pv_peaks(pv_peak_idxs)-timepoints(1),ds_events(ds).tdt_pop_signal(pv_peaks(pv_peak_idxs)),'MarkerEdgeColor','r')
xticks([0:300:1200])
xticklabels([0:10:40])
yticks([-2:1:2])
xlabel('Time (seconds)')
ylabel('Z-Scored Activity')

%% PLOT UNITY COMPARISON 
som_other=[];pv_other=[];  
som_own=[];pv_own=[];  

som_ex_other=[];pv_ex_other=[];
som_ex_own=[];pv_ex_own=[];

for i = 1:length(ds_events)
    cur_onsets= ds_events(i).onsets; 
    cur_meansom=ds_events(i).mch_pop_signal;
    cur_meanpv=ds_events(i).tdt_pop_signal;
    
        for j = 1:length(cur_onsets)
            ratio = utils.get_ratio(cur_onsets,j,ds_events,i);   
            if strcmp(cur_onsets(j).condition,'SOM')
                
                if abs(ratio) > 2
                    som_other=[som_other,cur_onsets(j).pure];
                    som_own=[som_own,cur_meansom(cur_onsets(j).peak)];
                    som_counter=som_counter+1; 
                else
                    som_ex_other=[som_ex_other,cur_onsets(j).pure];
                    som_ex_own=[som_ex_own,cur_meansom(cur_onsets(j).peak)];
                end

            elseif strcmp(cur_onsets(j).condition,'PV')
                 if abs(ratio) > 2
                    pv_other=[pv_other,cur_onsets(j).pure]; 
                    pv_own=[pv_own,cur_meanpv(cur_onsets(j).peak)]; 
                    pv_counter=pv_counter+1;

                 else
                    pv_ex_other=[pv_ex_other,cur_onsets(j).pure];
                    pv_ex_own=[pv_ex_own,cur_meanpv(cur_onsets(j).peak)];
                
                end
            end
        end
end

%% PLOT 
figure(14)
hold on 
utils.set_figure(10)

scatter(som_own,som_other,'b','filled','MarkerFaceAlpha',.3)
scatter(pv_other,pv_own,'r','filled','MarkerFaceAlpha',.3)
scatter(pv_ex_other,pv_ex_own,[], [.5 .5 .5],'filled','MarkerFaceAlpha',.3)
scatter(som_ex_own,som_ex_other,[], [.5 .5 .5],'filled','MarkerFaceAlpha',.3)


%axis([0 12 0 12])
xline(0)
yline(0)

%plot([0 12], [0 12],'LineStyle','--','Color','k')
plot([0 6], [0 12],'LineStyle','--','Color','k')
plot([0 12], [0 6],'LineStyle','--','Color','k')
plot([0 1],[0 0])
plot([0 0],[1 0])
%fill([0 1 1 0],[0 0 1 1],'k')
xlabel ('SOM Population Activity')
ylabel ('PV Population Activity')
xticks([1:2:10])
yticks([1:2:10])

%% save 
utils.save_figures(14,'Figure 3','Exclusion Criteria')
%% PLOT MEAN ACTIVITY 
[SOMe,PVe,MIXe]=plot_allct_event(pyr_mean_activity,som_mean_activity,pv_mean_activity,'nosave')

all(1,:,:,:)=SOMe; all(2,:,:,:)=PVe; all(3,:,:,:)=MIXe; 

%% SCALED STATS
lags = nan(3,12); 
for ct = 1:3
    sompeak=[];
    pvpeak=[]; 
    for d = 1:12
        [~,sompeak(d)]=max(all(ct,1,d,:)) 
        [~,pvpeak(d)]=max(all(ct,2,d,:)) 
    end
    lag=sompeak-pvpeak; 
    lags(ct,:)=lag; 
end 


mean_somelags=mean(lags(1,:))
mean_pvelags=mean(lags(2,:)) 
mean_mixelags=mean(lags(3,:))

std_somelags=std(lags(1,:))
std_pvelags=std(lags(2,:)) 
std_mixelags=std(lags(3,:)) 

%%
p= signrank(lags(1,:))
p = signrank(lags(2,:))
p = signrank(lags(3,:))


%% save
utils.save_figures(103,'Figure 3','PV_event_activity')
utils.save_figures(102,'Figure 3','SOM_event_activity')
utils.save_figures(105,'Figure 3','PV_event_activity(Scaled)')
utils.save_figures(104,'Figure 3','SOM_event_activity(Scaled)')
utils.save_figures(106,'Figure 3','Mixed_event_activity(Scaled)')
utils.save_figures(55,'Figure 3','Mixed_event_activity')
%% PLOT ACCELERATION DURING EVENTS
plot_velocity_event(acc,ds_events,' Acceleration','nosave')

%% save
utils.save_figures(99,'Figure 3','Acc_during_events')
%%
utils.save_figures(98,'SF3a','Acceleration by Dataset')



