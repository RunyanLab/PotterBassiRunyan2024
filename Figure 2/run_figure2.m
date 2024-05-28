%% LOAD/ POOL CLUSTERING INFO/ activity 
mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-03-17','2022-05-10','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};
%load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\mice.mat')
%load('C:\Users\Runyan1\Desktop\Desktop Code\dimred_event_analysis\pop_analysis_potter2023\Figure 1\dates.mat') 
% for i = 1:12
%     pooled_clustering(i)=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\clustering']);   
% end

for i = 1:12
    pooled_clustering(i)=load(['/Volumes/Runyan/Potter et al datasets/',mice{i},'/',dates{i},'/clustering']);   
end

%% HISTOGRAM OF EXCLUDED CELLS IN OVERLAPPING DATA 
all_ss=[];

for i = 1:12
    all_ss=[all_ss,pooled_clustering(i).clustering_info.all_silhouettes{14}']; 
end

figure(1)
hold on 
histogram(all_ss(all_ss>.7),'faceColor','w','binWidth',.03)
histogram(all_ss(all_ss<.7),'faceColor','k','binWidth',.03)
xline(.7,'r','LineStyle','--','HandleVisibility','off')
legend({'Included ROIs','Excluded ROIs'})
xlabel('Silhouette Score')
ylabel('Frequency')
utils.set_figure(10)
axis([0 1 0 350])
%% save
utils.save_figures(1,'Figure 2','silhouette_histogram')

%% PIE CHART OF INCLUDED VS EXCLUDED
figure(2)
included_label=num2str(round(sum(all_ss>.7)/length(all_ss)*100,1));
excluded_label=num2str(round(sum(all_ss<.7)/length(all_ss)*100,1));
labels={included_label,excluded_label};

colors={'r','b'};
pie([sum(all_ss(all_ss>.7)) sum(all_ss(all_ss<.7))],labels)
%% save
utils.save_figures(2,'Figure 2','included_excluded_piechart')

%% LINE PLOT FOR EACH DATASET
distribution=cell(1,12); 

for i = 1:12
    temp=pooled_clustering(i).clustering_info.cellids; 
    temp(temp==0)=[];
    distribution{i}=temp; 
end

%-- PLOT
figure(5)
hold on 
c=[0 .447 .741;.85 .325 .098; .929 .694 .125; .494 .184 .556; .466 .674 .188; .301 .745 .933]; 

total_SOM=0; 
total_PV=0; 
datapoints=nan(2,12);

for i = 1:12
    cur_dist=distribution{i}; 
    plot([0 .1], [sum(cur_dist==2) sum(cur_dist==1)],'Color','k','LineWidth',3,'MarkerSize',12)
    scatter([0 .1], [sum(cur_dist==2) sum(cur_dist==1)],270,'k','filled','Marker','square')
    total_SOM=total_SOM+sum(cur_dist==1); 
    total_PV=total_PV+sum(cur_dist==2); 
    datapoints(1,i)=sum(cur_dist==1);
    datapoints(2,i)=sum(cur_dist==2); 
end


xticks([ 0 .1]) 
xticklabels({'PV','SOM'})
yticks([10 30 50 70])
utils.set_figure(10); 
axis([-.025 .125 0 70])
utils.set_figure(10)
%% save 
utils.save_figures(5,'Figure 2','PV_SOM_dist_lineplot')

%% MAKE PIE CHART FOR DISTRIBUTION OF CELLS
figure(4)

mPV=round(mean(datapoints(2,:)),1); 
mSOM=round(mean(datapoints(1,:)),1); 
sdPV=round(std(datapoints(2,:)),1); 
sdSOM=round(std(datapoints(1,:)),1); 

PV_label=[num2str(mPV),' (S.D.:',num2str(sdPV),')']; 
SOM_label=[num2str(mSOM),' (S.D.: ',num2str(sdSOM),')'];
labels={PV_label,SOM_label};

colors={'r','b'};
pie([mPV mSOM],labels)

utils.set_figure(10)

%% save 
utils.save_figures(4,'Figure 2','PV_vs_SOM_piechart')

%% CALCULATE CORRELATIONS
mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-03-17','2022-05-10','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};

for i = 1:12
    activity=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\activity']);   
    ds_partialcorrs(i)=get_partialcorr(activity.combined_info); 

end
%%
%load('id_list.mat')
ds_partialcorrs([5 6])=ds_partialcorrs([6 5]);
[ds_ct_corr,all_corrs]=organize_corrs(ds_partialcorrs,id_list); 

%% PLOT CORRELATIONS CDF
figure(12)
clf
hold on 
colors={'k','b','r'}
for i = 1:3
    [f,x]=ecdf((all_corrs{i,i})); 
    plot(x,f,'Color',colors{i},'LineWidth',2)
end

[f,x]=ecdf(([all_corrs{3,2},all_corrs{2,3}])); 
plot(x,f,'Color',[1 0 1],'LineWidth',2)

axis([-.3 .6 0 1])
xline(0,'LineStyle','--')
utils.set_figure(10)
yticks([0 .5 1])
xticks([-.5:.25:1])
xlabel('Partial Correlation')
ylabel('Cumulative Probability')
legend({'PYR-PYR','SOM-SOM','PV-PV','SOM-PV'})
%%
utils.save_figures(12,'Figure 2','corr_cdf')

%% PLOT CORRELATIONS BY DATASET
pyr_pyr=[];
som_som=[];
pv_pv=[];
som_pv=[]; 
load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat')

for i = 1:12 
    labels{i}=ds_events(i).tag; 
    pyr_pyr(i)= mean(ds_ct_corr{i,1,1});
    som_som(i)=mean(ds_ct_corr{i,2,2});
    pv_pv(i)=mean(ds_ct_corr{i,3,3});
    pv_som(i)=mean(mean([ds_ct_corr{i,2,3},ds_ct_corr{i,2,3}]));
end
%%
figure
hold on 
utils.set_figure(10)
plot(pyr_pyr,'Color','k','LineWidth',2)
plot(som_som,'Color','b','LineWidth',2)
plot(pv_pv,'Color','r','LineWidth',2)
plot(pv_som,'Color',[1 0 1],'LineWidth',2)
xticks([1:12])
xticklabels(labels)
ylabel('Correlation Magnitude')
xlabel('Dataset')



%% 
mean_corr_matrix=nan(3,3); 
for i = 1:3
    for j =1:3
        cur_corrs1=all_corrs{i,j};
        cur_corrs2=all_corrs{j,i};
        mean_corr_matrix(i,j)=mean(cur_corrs1); 

    end
end

%%
figure(15)
clf
hold on 
utils.set_figure(10)

mcm=flip(mean_corr_matrix,2);

imagesc(mcm)
colorbar
xticks([1 2 3])
xticklabels({'PV','SOM','Pyr'})
yticklabels({'Pyr','SOM','PV'})
yticks([1 2 3])

for i = 1:3
    for j=1:3
        if i==j
            text(i,j,num2str(round(mcm(j,i),3)))
        else
            %curmean=mean([mcm(4-i,j),mcm(j,4-i)]);
            text(i,j,num2str(round(mcm(j,i),3)))
            %text(i,j,num2str(round(curmean,3)));
       
        end

    end
end

%%
utils.save_figures(15,'Figure 2','corr_conf_matrix')





















