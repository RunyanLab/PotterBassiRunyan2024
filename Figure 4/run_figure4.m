%% LOAD
[ds_events]= utils.load_ds_events('standard');
%load('id_list.mat')

%% CLASSIFICATION 
type='onsets';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;

starts=-99:1:50; 
bin=10; 
[output_sp]= event_classifier(starts,bin,param(1),ds_events,'SVM','noshuffle','nodecay'); 

[output_spm]= event_classifier(starts,bin,param(1),ds_events,'1v1','noshuffle','nodecay'); 

%% PLOT CLASSIFICATION 

plot_accuracy(outputs,bin,starts,param(1),'shuffle');
%% save
print(2,'/Users/christianpotter/Dropbox/Dual Labeling Paper/V2/Figure 4/classifcation-painters.pdf','-dpdf','-painters','-bestfit')
utils.save_figures(1,'Figure 4','SOMvPV_SOMPVvNull')
utils.save_figures(2,'SF4','SOMvNull_PVvNull')
utils.save_figures(3,'SF4','Shuffled_classification')

%% RUN PAIRWISE CORRELATIONS
[corrs] = get_ms_partial_correlations(ds_events,5,'Peaks',2)
%try with dff
%% Plot binned corrs
load('id_list.mat')
load('ds_partialcorrsn.mat')
[ds_ct_corr,all_ct_corr,ds_ct_matrix] = organize_corrs (ds_partialcorrs,id_list);
[all_ref,all_som,all_pv]=plot_binned_correlations(corrs,ds_ct_matrix);
%%
load('Y:\Christian\Processed Data\correlations\ms_correlation.mat')
mean_corr=nan(3,length(ds_events)); 

for i = 1:length(ds_events)
    cur_pvcorrs= corrs{2,i};
    cur_somcorrs=corrs{1,i};
    cur_excorrs=corrs{3,i};

    mean_corr(1,i)=mean(cur_somcorrs(:),'omitnan'); 
    mean_corr(2,i)=mean(cur_pvcorrs(:),'omitnan'); 
    mean_corr(3,i)=mean(cur_excorrs(:),'omitnan'); 
end

%% plot pairwise correlaions (Within events)
figure(1)
utils.set_figure(15)
hold on 
b= bar([mean(mean_corr(1,:)), mean(mean_corr(3,:)),mean(mean_corr(2,:))],'FaceColor','w'); 
%b.CData([1 2 3],:)=[1 .5 .5;.5 .5 1]; 
plot([1 2 3],[mean_corr(1,:);mean_corr(3,:);mean_corr(2,:)],'Color','k','Marker','o','MarkerFaceColor','w')

xl=xlim;
yl=ylim; 
%text(xl(1)/4,yl(2)/2,['significance: ',num2str(round(pvalue,4))])
xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})
xlabel('Event Type')
ylabel("Mean Pairwise Correlation")
title({'Correlations of Deconvolved Data'})

%% PAIRWISE CORRELATION STATS
pc_stats(1).label='SOMvsPV'
[pc_stats(1).p, pc_stats(1).h, pc_stats(1).stats]= signrank(mean_corr(1,:),mean_corr(2,:)); 
pc_stats(2).label='SOMvsMixed'
[pc_stats(2).p, pc_stats(2).h, pc_stats(2).stats]= signrank(mean_corr(1,:),mean_corr(3,:)); 
pc_stats(3).label='PVvsMixed'
[pc_stats(3).p, pc_stats(3).h, pc_stats(3).stats]= signrank(mean_corr(2,:),mean_corr(3,:)); 

corrected_p=bonf_holm([pc_stats(1).p,pc_stats(2).p,pc_stats(3).p],.05);
pc_stats(1).p=corrected_p(1); pc_stats(2).p=corrected_p(2);pc_stats(3).p=corrected_p(3)
%% save 
utils.save_figures(1,'Figure 4','Pairwise Correlations')

%% GET POP SPARSENESS
[outcomes] = get_pop_sparseness(ds_events,2); 

%% UNITY VECT (4A)
som_means=[];
pv_means=[];
for d = 1:12
    %som_means=[som_means,outcomes(d).mean_som_vect']; 
    %pv_means=[pv_means,outcomes(d).mean_pv_vect'];
    for n= 1:size(outcomes(d).pv_binned_vect,1)
        zs=zscore([outcomes(d).pv_binned_vect(n,:),outcomes(d).som_binned_vect(n,:)]); 
        som_means=[som_means,mean(zs(size(outcomes(d).pv_binned_vect,2)+1:size(outcomes(d).som_binned_vect,2)))];
        pv_means=[pv_means,mean(zs(1:size(outcomes(d).pv_binned_vect,2)))];
    end

end
figure(6)
hold on
scatter(som_means,pv_means,40,'k','filled','MarkerFaceAlpha',.8)
xlabel('Mean Activity During SOM Event') 
ylabel('Mean Activity During PV Event')
title('Mean Activity During SOM and PV Events')
utils.set_figure(15)
axis([-1.5 1.5 -1.5 1.5])
xline(0)
yline(0)
%axis manual
plot([-4 4], [-4 4],'Color','r','LineStyle','--')


%% save
utils.save_figures(6,'Figure 4','Mean SOM vs PV activity')
%% PIE CHART
figure
utils.set_figure(15)
pie([sum(som_means>pv_means)/length(som_means),sum(pv_means>som_means)/length(som_means)])
legend({'SOM Preferring','PV Preferring'})
%% save
utils.save_figures(5,'Figure 4','Pie Chart')

%% PLOT FACTOR ANALYSIS
%load('Y:\Christian\Processed Data\fa_final.mat')
Np=3; 
figure(55)
utils.set_figure(15)
colorAU= [0    0    1;1    0    0;1 0 1];
hold on
i=1;
 for pid=1:Np
        errorbar(1:M, mean(Lambda(:,:,pid,i),2),std(Lambda(:,:,pid,i),[],2)/sqrt(size(Lambda,2)/5),'-','color',colorAU(pid,:),'LineWidth',2)
 end
legend({'SOM Events', 'PV Events'},'location','northeast')
xticks([1:5])
xlabel('Factor')
ylabel('Eigenvalue')
axis([.5 5.5 0 .03])

%% FACTOR ANALYSIS STATS

for f= 1:5
    cur_somL=Lambda(f,:,1,1);
    cur_pvL=Lambda(f,:,2,1); 
    cur_mixedL=Lambda(f,:,3,1); 
    
    lambda_stats(1).label='SOMvsPV'
    [lambda_stats(1).p, lambda_stats(1).h, lambda_stats(1).stats]= ranksum(cur_somL(:),cur_pvL(:)); 
    lambda_stats(2).label='SOMvsMixed'
    [lambda_stats(2).p, lambda_stats(2).h, lambda_stats(2).stats]= ranksum(cur_somL(:),cur_mixedL(:)); 
    lambda_stats(3).label='PVvsMixed'
    [lambda_stats(3).p, lambda_stats(3).h, lambda_stats(3).stats]= ranksum(cur_pvL(:),cur_mixedL(:)); 
    
    corrected_p=bonf_holm([lambda_stats(1).p,lambda_stats(2).p,lambda_stats(3).p],.05);
    lambda_stats(1).p=corrected_p(1); lambda_stats(2).p=corrected_p(2);lambda_stats(3).p=corrected_p(3); 
    
    fa_stats(f).mode_number=f;
    fa_stats(f).mode_stats=lambda_stats; 
    
end


%% save
utils.save_figures(55,'Figure 4','Factor Analysis2')

%%
[outcomes] = get_pop_sparseness(ds_events,2,30); 
[ds_unit_angles,ds_within_angles] = get_vector_angles(outcomes,ds_events)

%% COSINE SIMILARITY TO UNIT VECTOR
%--
figure(91)
utils.set_figure(20)
hold on 

bar([1,2,3],[mean(ds_unit_angles(1,:),'omitnan'),mean(ds_unit_angles(3,:),'omitnan'),mean(ds_unit_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
for i = 1:length(ds_events)
    plot ([1 2 3],[ds_unit_angles(1,i),ds_unit_angles(3,i),ds_unit_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
end

xticks([1 2 3])
xticklabels({'SOM Events','Mixed Events','PV Events'})
title({' Similarity of Mean Vector from one Event to Unit Vector'})
ylabel('Cosine Similarity')
axis([0 4 .615 .625])

yline(.2)
%% UNITY VECT CORRELATION STATS
uv_stats(1).label='SOMvsPV'
[uv_stats(1).p, uv_stats(1).h, uv_stats(1).stats]= signrank(ds_unit_angles(1,:),ds_unit_angles(2,:)); 
uv_stats(2).label='SOMvsMixed'
[uv_stats(2).p, uv_stats(2).h, uv_stats(2).stats]= signrank(ds_unit_angles(1,:),ds_unit_angles(3,:)); 
uv_stats(3).label='PVvsMixed'
[uv_stats(3).p, uv_stats(3).h, uv_stats(3).stats]= signrank(ds_unit_angles(2,:),ds_unit_angles(3,:)); 

corrected_p=bonf_holm([uv_stats(1).p,uv_stats(2).p,uv_stats(3).p],.05);
uv_stats(1).p=corrected_p(1); uv_stats(2).p=corrected_p(2); uv_stats(3).p=corrected_p(3);
%% save unit vector
utils.save_figures(90,'SF4','Unit Vector Similarity')

%% WITHIN VECTOR SIMILARITY 
figure(181)
utils.set_figure(20)
hold on
bar([1,2,3],[mean(ds_within_angles(1,:),'omitnan'),mean(ds_within_angles(3,:),'omitnan'),mean(ds_within_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
for i = 1:length(ds_events)
    plot ([1 2 3],[ds_within_angles(1,i),ds_within_angles(3,i),ds_within_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
end

xticks([1 2 3])
xticklabels({'SOM Events','Mixed Events','PV Events'})
title('Pairwise Similarity of Event Vectors Within Events')

ylabel('Cosine Similarity')

%% UNITY VECT CORRELATION STATS
wv_stats(1).label='SOMvsPV'
[wv_stats(1).p, wv_stats(1).h, wv_stats(1).stats]= signrank(ds_within_angles(1,:),ds_within_angles(2,:)); 
wv_stats(2).label='SOMvsMixed'
[wv_stats(2).p, wv_stats(2).h, wv_stats(2).stats]= signrank(ds_within_angles(1,:),ds_within_angles(3,:)); 
wv_stats(3).label='PVvsMixed'
[wv_stats(3).p, wv_stats(3).h, wv_stats(3).stats]= signrank(ds_within_angles(2,:),ds_within_angles(3,:)); 

corrected_p=bonf_holm([wv_stats(1).p,wv_stats(2).p,wv_stats(3).p],.05);
wv_stats(1).p=corrected_p(1); wv_stats(2).p=corrected_p(2); wv_stats(3).p=corrected_p(3);

%% save
utils.save_figures(180,'Figure 4','Pairwise Similarity')


%%
pwithin_angles(isnan(pwithin_angles))=[];

swithin_angles(isnan(swithin_angles))=[];

figure
hold on
histogram(pwithin_angles,'FaceColor','r')
histogram(swithin_angles,'FaceColor','b')



%% 



