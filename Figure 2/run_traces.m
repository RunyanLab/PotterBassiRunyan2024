%% LOAD DATA
mouse='FU1-00';
date='2022-03-17';

load(['/Volumes/Runyan2/Christian/Processed Data/functional-dual_red/FU1-00_2022-03-17_activity.mat'])
load(['/Volumes/Runyan2/Christian/Processed Data/functional-dual_red/FU1-00_2022-03-17_clustering.mat'])
load('/Volumes/Runyan2/Christian/Processed Data/functional-dual_red/PCA/FU1-00/2022-03-17/PCA30.mat')

%% GET DECONV/ DFF
deconv=combined_info.deconv; 
dff= combined_info.dff; 
velocity= combined_info.velocity;   

cell_types=clustering_info.cellids; 
%% FIND BEST CANDIDATE CELLS
stat=clustering_info.Fall.stat; 
skew=nan(1,length(stat)); 

for i = 1:length(stat)
    skew(i)=stat{i}.skew; 
end

skew(clustering_info.iscell==0)=[]; 

%% GET SORTED PV/SOM/PYR
ntype=[sum(cell_types==0) sum(cell_types==1) sum(cell_types==2)];

[sorted_ctype,idx]=sort(cell_types); 
sorted_deconv=deconv(idx,:); 
sorted_dff=dff(idx,:); 
sorted_skew=skew(idx); 

pyr_skew=sorted_skew(cell_types==0); 
som_skew=sorted_skew(cell_types==1); 
pv_skew=sorted_skew(cell_types==2); 
%% SORT BY SKEWNESS
% select_SOM=find(sorted_ctype==1,5,'last');
% select_PV=find(sorted_ctype==2,5,'last'); 
% select_PYR=find(sorted_ctype==0,5,'last'); 

[~,pyr_order]=sort(pyr_skew,'descend'); 
[~,som_order]=sort(som_skew,'descend'); 
[~,pv_order]=sort(pv_skew,'descend'); 


pyr_locs=pyr_order; 
som_locs=som_order+ntype(1); 
pv_locs=pv_order+ntype(1)+ntype(2); 

rsom=[1 5 9];
rpv= [1 5 8];
rpyr=[3 9 10];
rsom=[1 3 5 9];
rpv= [1 2 5 8];
rpyr=[3 4 9 10];

n=10; 
selectvector=[pyr_locs(rpyr),som_locs(rsom),pv_locs(rpv)];
t=[mouse,' ',date,': ','Sorted by Skewness'];
%% SORT BY WEIGHT ONTO PC 1
pyr_w=pca30.pyr.coeff(:,1); 
som_w=pca30.som.coeff(:,1); 
pv_w=pca30.pv.coeff(:,1); 



[~,pyr_order]=sort(pyr_w,'descend'); 
[~,som_order]=sort(som_w,'descend'); 
[~,pv_order]=sort(pv_w,'descend'); 


pyr_locs=pyr_order; 
som_locs=som_order+ntype(1); 
pv_locs=pv_order+ntype(1)+ntype(2); 


rsom=[2 4 5 10];
rpv= [4 5 10 13];
rpyr=[1 3 9 10];
selectvector=[pyr_locs(rpyr),som_locs(rsom),pv_locs(rpv)];
%selectvector=[pyr_locs(1:n),som_locs(1:n),pv_locs(1:n)];

t=[mouse,' ',date,': ','Sorted by PC 1 weight'];
%% PLOT ACTIVITY TRACES

reduced_deconv=sorted_deconv(selectvector,:); 
reduced_dff=sorted_dff(selectvector,:); 
reduced_ctype=sorted_ctype(selectvector); 

window=13901:25498;
%window=0;  
[traces_figure,smoothed_dff]=plot_traces(reduced_dff,reduced_deconv,reduced_ctype,velocity,window,t);

%%

saveas(1,'dff-deconv traces','pdf')
saveas(1,'dff-deconv traces','fig')
%% PLOT VELOCITY
figure
speed=sqrt(velocity(1,:).^2+velocity(2,:).^2); 

%speed=normr(speed);
speed=movmean(speed,30); 


plot(speed(window),'color','k')





ylabel('Velocity (cm/s)');
xlabel('Time (30s)');
set(gca,'FontName','Arial');
set(gca,'FontSize',10);
set(gcf, 'DefaultFigureRenderer', 'painters');

set(gca,'xtick',1:30*30:length(window)) %30s interval
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])

set(gcf,'Units','inches');
screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],...
    'PaperSize',[screenposition(3:4)]);
print -dpdf -painters velocity


