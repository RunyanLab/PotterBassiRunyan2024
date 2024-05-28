mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-05-10','2022-03-17','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};

for i = 1:12
    pooled_activity(i)=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\activity']);   
end

%%
depths=[]; 

for i = 1:12
    cur_depth=pooled_activity(i).combined_info.metaData.image_depth
    depths=[depths,max(cur_depth)];
end

depths(4)= 199; 

%%
for i = 1:12
    pooled_clustering(i)=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\clustering']);   
end

%%
distribution=cell(1,12); 

for i = 1:12
    temp=pooled_clustering(i).clustering_info.cellids; 
    temp(temp==0)=[];
    distribution{i}=temp; 
end

for i = 1:12
    cur_dist=distribution{i};  
    datapoints(1,i)=sum(cur_dist==1);
    datapoints(2,i)=sum(cur_dist==2); 
end

%%

figure
scatter (depths,datapoints(1,:)./datapoints(2,:),'k','filled')
xlabel('Cortical Depth')
ylabel('SOM:PV Ratio')
utils.set_figure(10)

%%

mdl= fitlm(depths,datapoints(1,:)./datapoints(2,:))


