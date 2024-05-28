% FIGURE 1
%% LOAD DATA
if ismac
    load('/Users/christianpotter/Desktop/Analysis/pop_analysis_potter2023/fixed_outcomes.mat')
else 
    load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\fixed_outcomes.mat')
end

%% GET INFO ABOUT WAVELENGTHS
iters=length(fixed_outcomes);

dataset_idx=1:iters/6:iters; 
all_combos_info=cell(iters/6,1); 

for i = 1:iters/6
    cur_correct=nan(6,1);
    for j =1:6
        current=fixed_outcomes((i-1)+dataset_idx(j)).identoutcome==1; 
        cur_correct(j)=sum(current==1)/length(current);    
    end
    all_combos_corr(i)=sum(cur_correct)/6; 
    all_combos_info{i}=fixed_outcomes((i-1)+dataset_idx(j)).index;
end


%% RANK OVERALL
overall=nan(iters,1);  
ds_iters=iters/6; 
count=0;

for i = 1:iters
    overall(i)=fixed_outcomes(i).overall; 
end
for ds = 1:6
    for i = 1 : ds_iters
        count = count+1; 
        overall_matrix(ds,i)=overall(count);     
    end
end

ds_overall=mean(overall_matrix,1); 

[cluster_rank,ds_idx]=sort(ds_overall,'descend'); 
[ranked_overall,ranked_idx]=sort(ds_overall,'descend');
ranked_info=all_combos_info(ds_idx);
ranked_correct=all_combos_corr(ds_idx); 

%% MAKE IMAGE DEPICTING BEST COMBINATIONS
best_combos= zeros(25,17); 
count=0;
 

for i = 1:100
    cur_combo=ranked_info{i};
    if ranked_correct(i)==1
        count=count+1;
        temp_list= 1:17; 
        temp_list([13 15])=[]; 
        for j = temp_list
            if ismember(j,cur_combo)                 
                best_combos(count,j) = 1; 
            end
        end
    end

end

xline([.5:17.5],'Color',[.5 .5 .5])
yline([.5:25.5],'Color',[.5 .5 .5])
axis([.5 17.5 .5 25.5])
xticks([1:17])
xticklabels(ans)
map=[0 0 0; 1 1 1]
figure(1)
hold on
imagesc(best_combos(1:25,:))
colormap(map)
utils.set_figure(10)
%%
utils.save_figures(1,'Figure 1','Best Combinations(white)')

%% BAR GRAPH DEPICTING WAVELENGTH MEMBERSHIP 

best_combos=zeros(17,1)
ranked_info_correct=ranked_info(ranked_correct==1);
for i = 1:50
    cur_combo=ranked_info_correct{i};
    count=count+1;
    temp_list= 1:17; 
    temp_list([13 15])=[]; 
    for j = temp_list
        if ismember(j,cur_combo)                 
            best_combos(j) = best_combos(j)+1; 
        end
    end
end

%%
figure(6)
bar(best_combos,'FaceColor','k')
utils.set_figure(15)
axis([0 17.5 .5 45])
xticks([2:2:17])
%xticklabels(fixed_outcomes(length(fixed_outcomes)/6).info(2:2:15)); 
xticklabels([800 840 880 920 960 1000 1040 1080]); 
xlabel('Wavelengths')
ylabel('Frequency')


%%
utils.save_figures(6,'Figure 1','Best Combinations Bar Graph')

%% POOL CLUSTERING
for d = 1:12
    temp= load(['Z:\Potter et al datasets\' ds_events(d).tag 'clustering.mat'])
    pooled_clustering(d)= temp; 
end

%% PLOT NORMALIZED INTENSITY 
%load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\MATLAB_data\Figure 1\exp_emision_spectra_ws.mat')
mci=[]; 
tdi=[]; 
for i = 1: 6
    cur_mci = normr(mcherry_intensities{i}); 
    cur_tdi = normr(tdtom_intensities{i}); 
    mci=[mci;cur_mci];
    tdi=[tdi;cur_tdi]; 
end

list=1:17; list([13 15])=[]; 
figure(5)
errorbar(list,mean(mci,1),std(mci,[],1),'Color','b','LineWidth',1.5)
hold on 
errorbar(list,mean(tdi,1),std(tdi,[],1),'Color','r','LineWidth',1.5)

xticks([2:2:17])
xticklabels([800 840 880 920 960 1000 1040 1080]); 
utils.set_figure(15)

%%
utils.save_figures(5,'Figure 1','Error Bar Plot')


  


