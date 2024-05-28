function[]=plot_mssVScorrect(cluster_outcome,nbins,tickspacing)
% Plots relationship between the mean silhouette score and the percent correct of a cluster combination

overall=nan(1,length(cluster_outcome));
pcorr=nan(1,length(cluster_outcome)); 

for i = 1:length(cluster_outcome)
    overall(i)=cluster_outcome(i).overall; 
    pcorr(i)=sum(cluster_outcome(i).identoutcome)/length(cluster_outcome(i).identoutcome);
end


%% BIN COMBINATIONS
 
binned_overall = nan(1,nbins); 
binned_pcorr = nan(1,nbins);
%binned_sem= nan(1,nbins); 
binned_iqr=nan(2,nbins); 
bin_centers= nan(1,nbins); 

ssrange = .3; %range(overall); 
binsize= ssrange/nbins; 
ssmin= .7; %min(overall); 

for i = 1:nbins
    greater = overall > ssmin + (i-1) * binsize; 
    lesser = overall < ssmin + i * binsize;
    bin_centers(i)= round(mean([ssmin + (i-1) * binsize,ssmin + i * binsize]),3); 
    
    bin_positions= greater==lesser; 
    cur_overall = overall(bin_positions);
    cur_pcorr = pcorr(bin_positions); 

    binned_overall(i)=mean(cur_overall);
    binned_pcorr(i)=mean(cur_pcorr);
    %binned_sem(i)= std(cur_pcorr);%/ sqrt(length(pcorr)); 
    binned_iqr(1,i)= prctile(cur_pcorr,75)-mean(cur_pcorr); 
    binned_iqr(2,i)=mean(cur_pcorr)-prctile(cur_pcorr,25); 
    
    
   
end


%% MAKE FIGURE 
figure(2)
errorbar(binned_overall,binned_pcorr,binned_iqr(2,:),binned_iqr(1,:),'k','LineWidth',1,'Marker','o','MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',3)

hold on 

xlabel('Mean SS of Combination')
ylabel('Percent Correctly Classified')
title({'Relationship Between Mean SS and Classification Performance',[num2str(nbins),' Bins of Combinations']})
xticks(bin_centers(1:tickspacing:end))
reduced_bins= bin_centers(1:tickspacing:end);
bin_labels=cell(1,length(reduced_bins)); 

for i = 1 : length(reduced_bins)
    bin_labels{i}=num2str(round(reduced_bins(i),2)); 
end

xticklabels(bin_labels); 

utils.set_figure(8); 







    