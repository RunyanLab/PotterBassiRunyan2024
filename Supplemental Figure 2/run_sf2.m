% SUPPLEMENTAL FIGURE 2 
%% LOAD FIXED OUTCOMES
if ismac
    load('/Users/christianpotter/Desktop/Analysis/pop_analysis_potter2023/fixed_outcomes.mat')
else 
    load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\fixed_outcomes.mat')
end

%% PLOT INFO ABOUT COMBINATION CORRECTNESS (S2A)
%-- Make variables abotu combinations % correct and info about wavelengths 
iters=length(fixed_outcomes);
all_combos_corr=nan(iters/6,1); 
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

%-- Plot figure 
figure('Color','w')

histogram(all_combos_corr,'faceColor','k'); 
utils.set_figure(10)
xlabel('Percent Correct Across Combinations')
ylabel('Frequency')
title('Distribution of Mean Percent Correct across all Combinations')

%% UNPACK OUTCOMES 
iters=length(fixed_outcomes);
overall=nan(iters,1); 
n_mis=nan(iters,1);
p_mis=nan(iters,1);
overall_std=nan(iters,1); 


for i = 1:iters
    overall(i)=fixed_outcomes(i).overall; 
    n_mis(i)=sum(fixed_outcomes(i).identoutcome==0); 
    p_mis(i)=sum(fixed_outcomes(i).identoutcome==0)/length(fixed_outcomes(i).identoutcome);
    overall_std(i)=std(fixed_outcomes(i).scores); 

end

[sorted_overall,sorted_idx]=sort(overall);
sorted_overall_std=overall_std(sorted_idx); 
%ranked_outcomes=fixed_outcomes(sorted_idx); 
ranked_pmis=p_mis(sorted_idx);

%% RANK COMBINATIONS 
ds_iters=iters/6;
overall_matrix= nan(6,ds_iters);
pmis_matrix= nan(6,ds_iters); 
count=0; 

for ds = 1:6
    for i = 1 : ds_iters
        count = count+1; 
        overall_matrix(ds,i)=overall(count); 
        pmis_matrix(ds,i)=p_mis(count); 
        std_matrix(ds,i)=overall_std(count); 
    end
end

ds_overall=mean(overall_matrix,1); 

[cluster_rank,ds_idx]=sort(ds_overall); 
%% PLOT INCORRECT PERCENTAGE BY RANK (FIGURE S2C LEFT)
nbins=100; 

bin_centers = nan(1,nbins+1); 
binned_pmis= nan(1,nbins+1);
binsize=floor(ds_iters/nbins); 

ds_pmis= mean(pmis_matrix,1); 
ds_pmis= sort(ds_pmis);

for i = 1:nbins
    cur_bin = 1+(i-1)*binsize : i*binsize; 
    binned_pmis(i) = mean(ds_pmis(cur_bin)); 
    bin_centers(i) = median(cur_bin); 
end

binned_pmis(end)=mean(ds_pmis(end-mod(ds_iters,nbins):end));
bin_centers(end)= median(ds_iters-(ds_iters-binsize*nbins));

%-- PLOT FIGURE
figure('color','w')
hold on 

fbc=flip(bin_centers);

combinedx= [fbc(91),fbc(91:-1:1),fbc(91)];
combinedy=[0,binned_pmis(91:-1:1),0];
fill(combinedx,combinedy,'r')

plot (flip(bin_centers),binned_pmis,'k','LineWidth',2)
tickspacing=15 ; 
reduced_bins= bin_centers(1:tickspacing:end-1);
bin_labels=cell(1,length(reduced_bins)); 

for i = 1 : length(reduced_bins)
    bin_labels{i}=num2str(round(reduced_bins(i),-2)); 
end

xline(ds_iters/10,'LineStyle','--')
xticks(5000:5000:30000)
xticklabels(30000:-5000:5000)
ylabel('% Incorrectly Classified')
xlabel('Combination Rank')
title('100 Bins')
utils.set_figure(8)
%% save
saveas(2,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_incorrect','pdf')
saveas(2,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_incorrect','fig')

%% PLOT DISTRIBUTION OF SILHOUETTE SCORES
figure('Color','w')
histogram(overall,'FaceColor','k')
xlabel('Silhouette Score')
ylabel('Frequency')
title('Distribution of Silhouette Scores')
axis([.6 1 0 5000])
utils.set_figure(10)
%%
saveas(3,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/SS_dist','pdf')
saveas(3,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/SS_dist','fig')

%% PLOT FIGURE S2C (RIGHT)
[unsuccessful,incorrect_scores,correct_scores]=find_misclassified(fixed_outcomes,[1 5],'yes');

%% PLOT RELATIONSHIP BETWEEN SS AND PERCENT CORRECT 

plot_mssVScorrect(fixed_outcomes,50,5);
%% save
saveas(1,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/mSS_vs_pcorr','pdf')
saveas(1,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/mSS_vs_pcorr','fig')

%% PLOT STD BY RANK OF COMBINATION  
mean_stds= mean(std_matrix,1); 
mean_stds=mean_stds(ds_idx);

std_stds=std(std_matrix,1); 
std_stds=std_stds(ds_idx);

nbins=100; 

bin_centers = nan(1,nbins+1); 
binned_mstds= nan(1,nbins+1);
binned_mstds_sem=nan(1,nbins+1); 

binned_sstds= nan(1,nbins+1);
binned_sstds=nan(1,nbins+1); 
binned_sstds_sem=nan(1,nbins+1);

binsize=floor(ds_iters/nbins); 

for i = 1:nbins
    cur_bin = 1+(i-1)*binsize : i*binsize; 
    binned_mstds(i) = mean(mean_stds(cur_bin));
    binned_mstds_sem(i)= std(mean_stds(cur_bin));%/ length(cur_bin);

    binned_sstds(i) = mean(std_stds(cur_bin));
    binned_sstds_sem(i)= std(std_stds(cur_bin));%/ length(cur_bin);
    bin_centers(i) = median(cur_bin); 
end

binned_mstds(end)=mean(mean_stds(end-mod(ds_iters,nbins):end));
binned_mstds_sem(end)=std(mean_stds(end-mod(ds_iters,nbins):end));%/length(mean_stds(end-mod(ds_iters,nbins):end));

binned_sstds(end)=mean(std_stds(end-mod(ds_iters,nbins):end));
binned_mstds_sem(end)=std(std_stds(end-mod(ds_iters,nbins):end));%/length(std_stds(end-mod(ds_iters,nbins):end));
bin_centers(end)= median(ds_iters-(ds_iters-binsize*nbins));


%%
figure(5)
errorbar(bin_centers,flip(binned_mstds),flip(binned_mstds_sem),'k','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3)
utils.set_figure(6); 

xticks(10000:10000:30000)
reduced_bins= bin_centers(1:tickspacing:end);
bin_labels=cell(1,length(reduced_bins)); 

count=0;
for i = 10000:10000:30000
    count=count+1;
    bin_labels{count}=num2str(round(i,-2)); 
end

xticklabels(bin_labels); 
yticks([.02:.04:.22])

xlabel('Combination Rank')
ylabel('Std of SS scores')
title('Combination Rank Versus Outlier Classification')
%% 
saveas(5,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_outlier','pdf')
saveas(5,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_outlier','fig')

%%
figure(6)
errorbar(bin_centers,flip(binned_sstds),flip(binned_sstds_sem),'k','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3)
utils.set_figure(10); 
%xticks(bin_centers(1:tickspacing:end))
xticks(5000:5000:30000)
reduced_bins= bin_centers(1:tickspacing:end);
bin_labels=cell(1,length(reduced_bins)); 

count=0;
for i = 5000:5000:30000
    count=count+1;
    bin_labels{count}=num2str(round(i,-2)); 
end

xticklabels(bin_labels); 
yticks([.02:.04:.22])

xlabel('Combination Rank')
ylabel('Std of SS Across Datasets')
title('Combination Rank Versus Stability Across Datasets')

%%

saveas(6,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_outlier','pdf')
saveas(6,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/rank_vs_outlier','fig')

%% COMPARE SIMULATED AND ACTUAL DISTRIBUTIONS
mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-05-10','2022-03-17','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};

silhouettes=[];
for i = 1:12
    if ispc
        pooled_clustering(i)=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\clustering']);
    else
        pooled_clustering(i)=load(['/Volumes/runyan/Potter et al datasets/',mice{i},'/',dates{i},'/clustering']);
    end

    cur_silhouettes=pooled_clustering(i).clustering_info.used_silhouettes'; 
    silhouettes= [silhouettes,cur_silhouettes]; 
end
%%
combined_actual=[];
for d = 1:12
    cc= pooled_clustering(d).clustering_info.all_silhouettes{14};    
    curAll= pooled_clustering(d).clustering_info.all_silhouettes{14}; 
    combined_actual=[combined_actual;curAll]; 

end


%-- from control data
[unsuccessful,incorrect_scores,correct_scores]=find_misclassified(fixed_outcomes,[1 5],'no')
combined_cntrl=[incorrect_scores',correct_scores']; 

[~,p,ks2stat]=kstest2(combined_cntrl,combined_actual); 

%%

figure(10)
utils.set_figure(10); 
hold on 

subsample = length(combined_actual);
ssample_vect=randperm(length(combined_cntrl),subsample); 

histogram(combined_actual,'FaceColor','m','BinWidth',.03)
histogram(combined_cntrl(ssample_vect),'FaceColor','c','BinWidth',.03,'FaceAlpha',.4)
legend({'Experimental SS Distribution','Simulated SS Distribution'})
xline(mean(combined_cntrl),'Color','c','LineStyle','--','HandleVisibility','off')
xline(mean(combined_actual),'Color','m','LineStyle','--','HandleVisibility','off')
xlabel('Silhouette Score')
ylabel('Frequency')

%%
if ismac
    saveas(10,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/actual_vs_exp_ssDist','pdf')
    saveas(10,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Supplemental/SF2/actual_vs_exp_ssDist','fig')
else
    saveas(10,'C:\Users\Runyan1\Dropbox\Dual Labeling Paper\V2\Supplemental\SF2\actual_vs_exp_ssDist','pdf')
    saveas(10,'C:\Users\Runyan1\Dropbox\Dual Labeling Paper\V2\Supplemental\SF2\actual_vs_exp_ssDist','fig')
end



