%% GET PCA VARIANCE EXPLAINED FOR ALL ANIMALS

all_som_explained=cell(6,1); 
all_pv_explained=cell(6,1);
pyr_explained=cell(6,1); 
numsom=nan(6,1); 

for ds = 1:6
    curpv_ex=nan(6,1);
    curpyr_ex=nan(6,1);
    all_som_explained{ds}=all_pca(ds).som.explained(1:5);
    numsom(ds)=length(all_pca(ds).som.explained); 
    
    curpv_ex=nan(5,10);
    curpyr_ex=nan(5,10);
    for i =1:10 
        
        curpv_ex(:,i)=all_pca(ds).subpv(i).explained(1:5);
        curpyr_ex(:,i)=all_pca(ds).subpyr(i).explained(1:5);

    end
    
    all_pv_explained{ds}= mean(curpv_ex,2);
    all_pyr_explained{ds}=mean(curpyr_ex,2); 


end

%% TAKE MEAN ACROSS DATASETS
somex_matrix=nan(6,5); 
pvex_matrix=nan(6,5); 
pyrex_matrix=nan(6,5); 


for i = 1:6
    somex_matrix(i,:)=all_som_explained{i};
    pvex_matrix(i,:)=all_pv_explained{i};
    pyrex_matrix(i,:)=all_pyr_explained{i}; 
end

som_explained=mean(somex_matrix,1); 
pv_explained=mean(pvex_matrix,1); 
pyr_explained=mean(pyrex_matrix,1); 

som_std=std(somex_matrix,1); 
pv_std=std(pvex_matrix,1); 
pyr_std=std(pyrex_matrix,1); 

som_sem=som_std/sqrt(6);
pv_sem=pv_std/sqrt(6);
pyr_sem=pyr_std/sqrt(6);

%

ci95=tinv([.025 .975],5);
somci = bsxfun(@times,som_sem, ci95(:));
pvci = bsxfun(@times,pv_sem, ci95(:));
pyrci = bsxfun(@times,pyr_sem, ci95(:));




%%

figure('color','w')
hold on 
axis square

axis([0 6 0 40])
set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')

errorbar(.9:1:4.9,som_explained,somci(1,:),'o','Color','r','MarkerFaceColor','r')
errorbar(1.1:1:5.1,pv_explained,pvci(1,:),'o','Color','b','MarkerFaceColor','b')
errorbar(1:5,pyr_explained,pyrci(1,:),'o','Color','k','MarkerFaceColor','k')

plot(som_explained,'color','r','LineWidth',2,'LineStyle','--')
plot(pv_explained,'color','b','LineWidth',2,'LineStyle','--')
plot(pyr_explained,'color','k','LineWidth',2,'LineStyle','--')


%%plot(mean([som_explained;pv_explained;pyr_explained],1),'Color',[.5 0 .5],'LineWidth',1)

yticks([10 20 30])
yticklabels({'10%','20%','30%'})
xlabel('Principle Component','FontWeight','Bold')

legend({'SOM','PV','PYR'})

ylabel('Variance Explained','FontWeight','Bold')
xticks([1 2 3 4 5])
title('Dimensionality of Activity by Cell Type')


%% SAVE

saveas(1,'pc_var_explained','pdf')
saveas(1,'pc_var_explained','fig')

%% EXAMINE BOUTS ==============================================================
som_widths=[];
som_prom=[];
pv_widths=[];
pv_prom=[];
pyr_widths=[];
pyr_prom=[];
som_locs=[];
pv_locs=[];

for i = 1:6
    [~,cursom_locs,cursom_widths,cursom_prom] =get_pcbouts('SOM',all_pca(i).som,1,98,10,60);
    [~,curpv_locs,curpv_widths,curpv_prom] =get_pcbouts('PV',all_pca(i).pv,1,98,10,60);
    som_widths=[som_widths;cursom_widths];
    pv_widths=[pv_widths;curpv_widths];
    som_prom=[som_prom;cursom_prom];
    pv_prom=[pv_prom;curpv_prom];
    som_locs=[som_locs;cursom_locs];
    pv_locs=[pv_locs;curpv_locs];

end

%% DISTRIBUTIONS OF THRESHOLDS

figure('color','w')


histogram(pv_prom,'FaceColor','b')
hold on 
histogram(som_prom,'FaceColor','r')


title('Distribution of Peak Prominence for all SOM and PV Events')

set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')
axis square

axis ([0 15 0 1500])

xline(mean(pv_prom)+std(pv_prom)*2,'color','b','LineWidth',2)
xline(mean(som_prom)+std(som_prom)*2,'color','r','LineWidth',2)

legend({'PV Peak Prominences','SOM Peak Prominences','PV Threshold','SOM Threshold'})
yticks([0 1500])

xlabel('Peak Prominence')
ylabel('Frequency')
%%
saveas(1,'sompc_totalpeakproms','pdf')
saveas(1,'sompc_totalpeakproms','fig')

%% DISTRIBUTION OF DURATIONS
figure('color','w')
histogram(pv_widths,30,'FaceColor','b')
hold on 
histogram(som_widths,30,'FaceColor','r')

title('Distribution of Above Threshold Event Durations')

set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')
axis square
axis ([0 300 0 115])

xticks(0:60:300)
xticklabels(0:2:10)
    
xlabel('Seconds')
ylabel('Frequency')
yticks([0 40 80])

%%
saveas(1,'sompc_peakdurations','pdf')
saveas(1,'sompc_peakdurations','fig')

%% DISTRIBUTION INTER-EVENT-INTERVALS

figure('color','w')
diff_som=diff(som_locs);
diff_pv=diff(pv_locs); 

diff_som(diff_som<0)=[];
diff_pv(diff_pv<0)=[];

histogram(diff_som,30,'FaceColor','b')
hold on 
histogram(diff_pv,30,'FaceColor','r')

title('Distribution of Above Threshold Event Durations')

set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')
axis square
%axis ([0 300 0 115])

xticks(0:900:6000)
xticklabels(0:30:200)
    
xlabel('Seconds')
ylabel('Frequency')
yticks([0 20 40])

title('Distribution of Inter-Event-Intervals')

%%
saveas(1,'sompv_InterEventIntervals','pdf')
saveas(1,'sompv_InterEventIntervals','fig')