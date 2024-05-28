distribution=cell(1,12); 

for i = 1:12
    temp=pooled_clustering(i).clustering_info.cellids; 
    temp(temp==0)=[];
    distribution{i}=temp; 
end
%% LINE PLOT FOR EACH DATASET

figure('color','w')

hold on 
c=[0 .447 .741;.85 .325 .098; .929 .694 .125; .494 .184 .556; .466 .674 .188; .301 .745 .933]; 

total_SOM=0; 
total_PV=0; 
datapoints=nan(2,6);

for i = 1:12
    cur_dist=distribution{i}; 
    plot([0 .1], [sum(cur_dist==2) sum(cur_dist==1)],'Color','k','LineWidth',3,'MarkerSize',12)
    scatter([0 .1], [sum(cur_dist==2) sum(cur_dist==1)],270,'k','filled','Marker','square')
    total_SOM=total_SOM+sum(cur_dist==1); 
    total_PV=total_PV+sum(cur_dist==2); 
    datapoints(1,i)=sum(cur_dist==1);
    datapoints(2,i)=sum(cur_dist==2); 

end

xline(-.01)

xticks([ 0 .1]) 
xticklabels({'PV','SOM'})
yticks([10 30 50 70])
set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')
axis square 
%%
saveas(1,'SOMvPV_lineplot','pdf')
saveas(1,'SOMvPV_lineplot','fig')
%% PIE CHART FOR COMBINED DATASETS

figure('color','w')

mPV=round(mean(datapoints(2,:)),1); 
mSOM=round(mean(datapoints(1,:)),1); 
sdPV=round(std(datapoints(2,:)),1); 
sdSOM=round(std(datapoints(1,:)),1); 


PV_label=[num2str(mPV),' (S.D.:',num2str(sdPV),')']; 
SOM_label=[num2str(mSOM),' (S.D.: ',num2str(sdSOM),')'];
labels={PV_label,SOM_label};

colors={'r','b'};
pie([mPV mSOM],labels)

%save('/Users/christianpotter/Dropbox/Draft_Figures/Fig 2/SOMvPVdist.fig')
%%
saveas(1,'SOMvPV_dist','pdf')
saveas(1,'SOMvPV_dist','fig')

%% PLOT IMAGE DEPTH
depth=nan(1,12); 

for i = 1:12
    temp=pooled_combined(i).combined_info.metaData.image_depth; 
    depth(i)=max(temp); 
end

%%
select=[1 2 3 5 6]; 
figure
scatter (depth(select),datapoints(1,select))

xlabel('depth(nm)')
ylabel('n SOM neurons')
%%
reorder=[1 2 3 4 6 5];

pooled_clustering=pooled_clustering(reorder); 
