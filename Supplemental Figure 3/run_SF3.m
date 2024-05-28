%SF3
load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat')

%% MAKE FIGURES B,C,D 
[rate_mch_events,rate_tdt_events,rate_ex_events,durations]= supplemental_report_events (ds_events,2,'ratio');
 
%% FREQUENCY STATS
%%-- Frequency stats
mt=signrank(rate_mch_events,rate_tdt_events);
me=signrank(rate_mch_events,rate_ex_events);
te=signrank(rate_tdt_events,rate_ex_events);

event_rate_stats.SOMvPV=mt;event_rate_stats.SOMvMix=me;event_rate_stats.PVvMix=te; 
%% DURATION STATS

sompv_t= ranksum(durations.somt,durations.pvt)
sommix_t= ranksum(durations.somt,durations.mixt)
pvmix_t= ranksum(durations.pvt,durations.mixt)


sompv_p= ranksum(durations.somp,durations.pvp)
sommix_p= ranksum(durations.somp,durations.mixp)
pvmix_p= ranksum(durations.pvp,durations.mixp)



%% 
utils.save_figures(3,'SF3','Num_events_celltype')
utils.save_figures(1,'SF3','total_event_length')
utils.save_figures(2,'SF3','peak_event_length')
utils.save_figures(4,'Figure 3','Event Rate')

%% LOOK AT DISTRIBUTION OF ACTIVITIES FROM OPPOSING CELL TYPE
som_pure=[]; 
pv_pure=[]; 
som_ratio=[];
pv_ratio=[];

som_counter=0;
som_ex_counter=0; 
pv_counter=0; 
pv_ex_counter=0; 

%PURE EXCLUSION COUNTER
% for i = 1:length(ds_events)
%     cur_onsets= ds_events(i).onsets; 
%    
%         for j = 1:length(cur_onsets)
%           
%             if strcmp(cur_onsets(j).condition,'SOM')
%                 som_pure=[som_pure,cur_onsets(j).pure]; 
%                 som_counter=som_counter+1; 
%                 if cur_onsets(j).pure >=2
%                     som_ex_counter=som_ex_counter+1;
%                 end
% 
%             elseif strcmp(cur_onsets(j).condition,'PV')
%                 pv_pure=[pv_pure,cur_onsets(j).pure]; 
%                 pv_counter=pv_counter+1; 
%                 if cur_onsets(j).pure >=2
%                     pv_ex_counter=pv_ex_counter+1;
%                 end
%             end
% 
%         end
% end
ex_thresh=2; 

for i = 1:length(ds_events)
    cur_onsets= ds_events(i).onsets; 
    mch_pop_signal=ds_events(i).mch_pop_signal;
    tdt_pop_signal=ds_events(i).tdt_pop_signal;
    
        for tr = 1:length(cur_onsets)
            [ratio]=utils.get_ratio(cur_onsets,tr,ds_events,i);
          
            if strcmp(cur_onsets(tr).condition,'SOM')
                som_counter=som_counter+1; 
                if ratio > ex_thresh 
                    som_pure=[som_pure,cur_onsets(tr).pure]; 
                    som_ratio=[som_ratio,ratio];
                    
                end
                if ratio < ex_thresh
                    som_ex_counter=som_ex_counter+1;
                end

            elseif strcmp(cur_onsets(tr).condition,'PV')
                pv_counter=pv_counter+1; 
                if ratio > ex_thresh
                    pv_pure=[pv_pure,cur_onsets(tr).pure]; 
                    pv_ratio=[pv_ratio,ratio];
                    
                end

                if ratio < ex_thresh
                    pv_ex_counter=pv_ex_counter+1;
                end
            end
            
        end
end

%%
utils.save_figures(15,'Figure 3','SOM_vs_PV_rel_activity')
%%
figure(4)
clf
hold on 
histogram(som_pure,'FaceColor','r','FaceAlpha',.65,'BinWidth',.2)
histogram(pv_pure,'FaceColor','b','FaceAlpha',.65,'BinWidth',.2)
%xline(2,'LineStyle','--')
xlabel('ZScored Activity of Opposite Cell Type During Event')
ylabel('Frequency')
legend({'PV activity during SOM events','SOM activity during PV events'})
utils.set_figure(10)
%%
utils.save_figures(4,'SF3','Other_cell_type_during_event')

%% HISTOGRAM OF SOM/ PV RATIO
figure
hold on 
histogram(som_ratio,'FaceColor','b','Binwidth',1)
histogram(pv_ratio,'FaceColor','r','BinWidth',1)
axis([0 25 0 150])

%% BAR GRAPH OF EXCLUDED EVENTS BY CELL TYPE
figure(6)
hold on 
utils.set_figure(10)
bar([1 2],[som_counter pv_counter],'FaceColor','w')
bar([1 2],[som_ex_counter pv_ex_counter],'FaceColor','k')

xticks([1 2])
xticklabels({'SOM','PV'})

ylabel('Number of Events')
title('Excluded Events by Cell Type')

legend({'Included Events','Excluded Events'})
%% save
utils.save_figures(6,'SF3','num_exlcuded_events_by_celltype')

%%









