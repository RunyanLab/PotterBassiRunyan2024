mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};

dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-05-10','2022-03-17','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};
%%
%load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\mice.mat')
%load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\dates.mat')

for i = 1:12
    pooled_clustering(i)=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\clustering']);
end


%% Index into structure, get choosen combination, get length of excluded vect, add to distribution of silhouette scores
silhouettes=[];
excluded=[]; 

for i = 1:12 
    cur_silhouettes=pooled_clustering(i).clustering_info.used_silhouettes'; 
    silhouettes= [silhouettes,cur_silhouettes]; 

    temp_excluded=zeros(length(cur_silhouettes),1); 
    temp_excluded(pooled_clustering(i).clustering_info.excluded')=1; 
    excluded=[excluded,temp_excluded'];

end

%%

included_ss=silhouettes(silhouettes>=.7); 
excluded_ss=silhouettes(silhouettes<.7); 


figure('color','w')
hi=histogram(included_ss,'FaceColor','w'); 
hold on 
he=histogram(excluded_ss,'FaceColor','k','BinWidth',hi.BinWidth); 

xline(.7,'color','r')
%%

figure
histogram(silhouettes)


%%

figure('color','w')
slices=[length(included_ss) length(excluded_ss)];
pie_labels={'Included','Excluded'}; 

p=pie(slices,'%.1f%%');

legend(pie_labels)