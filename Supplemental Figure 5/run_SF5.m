%% GET PREFERNCE
[outcomes] = get_pop_sparseness(ds_events,2,60)
[pref]= get_event_preference(outcomes,ds_events,1000); 
%% COUNT PREFERENCE
somcount=0; 
pvcount=0; 
nullcount=0; 

for d = 1:12
    for n=1:length(pref(d).sompv_sig)

        if pref(d).sompv_sig(1,n)==1
            if pref(d).sompv_sig(2,n)>0
                somcount=somcount+1;
            elseif pref(d).sompv_sig(2,n)<0
                pvcount=pvcount+1; 
            end
        else
            nullcount=nullcount+1; 
        end
    
    end
end
%% PIE CHART 
figure(10);
utils.set_figure(15)
pie([somcount,pvcount,nullcount])
legend({'SOM Preferring','PV Preferring','No Preference'})

%% save
utils.save_figures(10,'SF5','preference_piechart')


%% DATA FOR CDF 

load('id_list.mat')
%load('ds_partialcorrsn.mat')
result=cell(3,12); 

for d = 1:12 
    corr_matrix= decon_matrices{d}(:,:,4); 
    ids=id_list{d}; 
    pyr_ids=find(ids==0); 
    dspref= pref(d).sompv_sig; 
    mean_corrs=nan(3,length(pyr_ids)); 
    k_corrs=nan(3,length(pyr_ids)); 
    std_corrs=nan(3,length(pyr_ids)); 

    for p = 1:size(dspref,2)
        cur_id= pyr_ids(p);
        corrs1=corr_matrix(cur_id,:);
        corrs2=corr_matrix(:,cur_id); 
        
        if dspref(1,p)==1
            if dspref(2,p)>0
                mean_corrs(1,p)=mean([corrs1,corrs2'],'omitnan');
                k_corrs(1,p)=kurtosis([corrs1,corrs2']);
                std_corrs(1,p)=std([corrs1,corrs2'],'omitnan');
            elseif dspref(2,p)<0
                mean_corrs(2,p)=mean([corrs1,corrs2'],'omitnan');
                k_corrs(2,p)=kurtosis([corrs1,corrs2']);
                std_corrs(2,p)=std([corrs1,corrs2'],'omitnan');
            end
        else
             mean_corrs(3,p)=mean([corrs1,corrs2'],'omitnan');
             k_corrs(3,p)=kurtosis([corrs1,corrs2']);
             std_corrs(3,p)=std([corrs1,corrs2'],'omitnan');

        end


    end
    result{1,d}=mean_corrs; 
    result{2,d}=k_corrs;
    result{3,d}=std_corrs; 
end
%%
spref_means=[];
ppref_means=[]; 
npref_means=[];

for d = 1:12
    cur_smeans=result{1,d}(1,:);
    cur_pmeans=result{1,d}(2,:); 
    cur_nmeans=result{1,d}(3,:); 
    cur_smeans(isnan(cur_smeans))=[];
    cur_pmeans(isnan(cur_pmeans))=[];
    cur_nmeans(isnan(cur_nmeans))=[];
    spref_means= [spref_means,cur_smeans];
    ppref_means= [ppref_means,cur_pmeans];
    npref_means=[npref_means,cur_nmeans];

end
%% PLOT
figure(3)
hold on 
[f,x]=ecdf(spref_means); 
plot(x,f,'Color','b','LineWidth',2)
[f,x]=ecdf(ppref_means); 
plot(x,f,'Color','r','LineWidth',2)
[f,x]=ecdf(npref_means);
plot(x,f,'Color','k','LineWidth',2)
utils.set_figure(15)
axis([-.02 .08, 0 1])

xline(0)
xlabel({'Mean of Pairwise Correlation',' with All Other Pyramidal Neurons'})
ylabel('Cumulative Frequency')
legend({'SOM Preferring','PV Preferring','No Preference'},'Location','northwest')
%% STATS
cdfstat(1).label='SOMvPV_pref';cdfstat(2).label='SOMvNo_pref';cdfstat(3).label='PVvNo_pref';
[cdfstat(1).p,cdfstat(1).h,cdfstat(1).stats]=ranksum(spref_means,ppref_means);
[cdfstat(2).p,cdfstat(2).h,cdfstat(2).stats]=ranksum(spref_means,npref_means);
[cdfstat(3).p,cdfstat(3).h,cdfstat(3).stats]=ranksum(ppref_means,npref_means);

corrected_p=bonf_holm([cdfstat(1).p,cdfstat(2).p,cdfstat(3).p],.05);

cdf_stat(1).p=corrected_p(1); cdf_stat(2).p=corrected_p(2); cdf_stat(3).p=corrected_p(3); 

%% save
utils.save_figures(3,'SF5','prefcorr_cdf')
%% WITHIN/ BETWEEN PREFERENCE CALCULATION
for d = 1:12
    cell_ids=id_list{d}; 
    cmatrix=decon_matrices{d}(:,:,4); 
    pyr_cmatrix=cmatrix(cell_ids==0,cell_ids==0); 
    sig_vect=pref(d).sompv_sig(1,:);
    within_sompref=[];
    within_pvpref=[];
    between_sompv=[];
    pvpref_ids=[];
    sompref_ids=[];
    
    for i =1:length(sig_vect)
        if sig_vect(i)==1
            if pref(d).sompv_sig(2,i)<0
                pvpref_ids=[pvpref_ids,i];
            else
                sompref_ids=[sompref_ids,i];
            end
        end
    end

    spref_corrs=pyr_cmatrix(sompref_ids,sompref_ids); 
    ppref_corrs=pyr_cmatrix(pvpref_ids,pvpref_ids); 
    anti_corrs=pyr_cmatrix(sompref_ids,pvpref_ids);

    sompref_mean(d)=mean(spref_corrs(:),'omitnan');
    pvpref_mean(d)=mean(ppref_corrs(:),'omitnan');
    anti_mean(d)=mean(anti_corrs(:),'omitnan'); 
end


%% PLOT
figure(2)
utils.set_figure(20)
hold on

bar([1 2 3],[mean(sompref_mean),mean(anti_mean),mean(pvpref_mean)],'FaceColor','w','EdgeColor','k');%,mean(all_mean)])

for d = 1:12
    plot([1 2 3],[sompref_mean(d),anti_mean(d),pvpref_mean(d)],'Marker','o','Color','k','MarkerFaceColor','w');%,all_mean(d)])
end

xlabel('Pairwise Interaction')
ylabel('Mean Pairwise Correlation')
xticks([1 2 3])
xticklabels({'SOM-SOM Preferring','PV-SOM Preferring','PV-PV Preferring'})

%% STATS

stat(1).label='SOMvPVpref';stat(2).label='SOMvAntipref';stat(3).label='PVvAntiPref';
[stat(1).p,stat(1).h,stat(1).stats]=signrank(sompref_mean,pvpref_mean);
[stat(2).p,stat(2).h,stat(2).stats]=signrank(sompref_mean,anti_mean);
[stat(3).p,stat(3).h,stat(3).stats]=signrank(pvpref_mean,anti_mean);

%% save
utils.save_figures(2,'SF5','within-between_preference')

%% CALCULATE ACROSS TIME PAIRWISE CORRELLATIONS

for d = 1:12
    ref_matrix=decon_matrices{d}(:,:,4);
    som_matrix=decon_matrices{d}(:,:,1); 
    pv_matrix=decon_matrices{d}(:,:,2); 
    mixed_matrix=decon_matrices{d}(:,:,3);

    
    meanm(1,d)=mean(som_matrix(:),'omitnan');
    meanm(2,d)=mean(pv_matrix(:),'omitnan');
    meanm(3,d)=mean(mixed_matrix(:),'omitnan');
end

%% PLOT ACROSS TIME CORRELATIONS
figure (1)
hold on
bar([mean(meanm(1,:)), mean(meanm(3,:)),mean(meanm(2,:))],'FaceColor','w')

plot([1 2 3],[meanm(1,:);meanm(3,:);meanm(2,:)],'Color','k','Marker','o')

ylabel('Pairwise Correlation Across All Events')
xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})
title('Pairwise Correlations of All Neurons Across Events')
utils.set_figure(15)

%% STATS
apc_stats(1).label='SOMvsPV'
[apc_stats(1).p, apc_stats(1).h, apc_stats(1).stats]= signrank(meanm(1,:),meanm(2,:)); 
apc_stats(2).label='SOMvsMixed'
[apc_stats(2).p, apc_stats(2).h, apc_stats(2).stats]= signrank(meanm(1,:),meanm(3,:)); 
apc_stats(3).label='PVvsMixed'
[apc_stats(3).p, apc_stats(3).h, apc_stats(3).stats]= signrank(meanm(2,:),meanm(3,:)); 

corrected_p=bonf_holm([apc_stats(1).p,apc_stats(2).p,apc_stats(3).p],.05);
apc_stats(1).p=corrected_p(1); apc_stats(2).p=corrected_p(2); apc_stats(3).p=corrected_p(3); 
%% 

utils.save_figures(1,'SF5','pc_across_time')

%% BETA WEIGHT ORTHOGONALITY 
[outcomes] = get_pop_sparseness(ds_events,2)
%%
starts=-99:1:100; 
bin=30; 
ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];
t=100; 
type='peak';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;
beta_similarity=[];
mean_vect=[]; 
angle=[]; 
for d = 1:12 
    [X,Y] = get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d); 
    som=find(Y==1); pv=find(Y==2); mixed=find(Y==4);
    
    trials= X([som,pv],:);
    response=Y([som,pv]);
   
    models(d).svm=fitcsvm(trials,response,'KernelFunction','linear'); 
    [bs(d),angle(d),~]= get_beta_similarity('mean',models(d).svm,trials,response,som,pv);
   
    labels{d}=ds_events(d).tag;
end
%%
figure(15)
bar(angle)
hold on
%bar(mean_vect/10)
%bar(mean_vect/max(abs(mean_vect)))
title({'Angle to Hyperplane (Degrees)'})
xlabel('Dataset')
ylabel('Angle to Hyperplane (Degrees)')
utils.set_figure(15)

%%
utils.save_figures(15,'SF5',['SVM_angle'])

%% 1V1 BETA WEIGHT ORTHOGONALITY 
bin=60; 
param(1).type='peak';param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;

bsim=nan(3,12);

for d = 1:12
    [X,Y] = get_classification_var([0 bin],param,ds_events(d).onsets,ds_events,d); 
    som=find(Y==1); pv=find(Y==2); mixed=find(Y==4); 

    min_spm = min([length(som),length(pv),length(mixed)]); 
    template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'BoxConstraint', 1, ...
    'Standardize',false);

    svms=fitcecoc(X([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)],:),Y([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)]), ...
        'Coding','onevsone', ...
        'Learners',template);
   
    for i = 1:3
        [~,bs(i),~]=get_beta_similarity('mean',svms.BinaryLearners{i},X([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)],:),Y([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)]),som,pv); 
    end
    bsim(:,d)=bs; 
    partitioned=crossval(svms,'Leaveout','on'); 
    validationAccuracy1(d) = 1 - kfoldLoss(partitioned, 'LossFun', 'ClassifError');
    numtrials(d)=min_spm
    labels{d}=ds_events(d).tag;

end

%% PLOT 1V1 BETA ORTHOGONALITY 
figure(16)
bar(bsim')
hold on
title({'Angle Between Decision Boundary and Mean Vector'})
xlabel('Datasets')
ylabel('Angle to Hyperplane (Degrees)')
legend({'SOM vs PV','SOM vs Mixed','PV vs Mixed'})
utils.set_figure(15)

%%
utils.save_figures(16,'SF5','1v1_hyperplane_angle')

%%


%% ---- OLD --------

%% CALCULATE ANGLES
%outcomes= get_pop_sparseness(ds_events,2,60);
% [ds_unit_angles,ds_within_angles] = get_vector_angles(outcomes,ds_events);

% figure(90)
% utils.set_figure(20)
% hold on 
% 
% bar([1,2,3,4],[mean(ds_unit_angles(1,:),'omitnan'),mean(ds_unit_angles(4,:),'omitnan'),mean(ds_unit_angles(5,:),'omitnan'),mean(ds_unit_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
% for i = 1:length(ds_events)
%     plot ([1 2 3 4],[ds_unit_angles(1,i),ds_unit_angles(4,i),ds_unit_angles(5,i),ds_unit_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
% end
% 
% xticks([1 2 3 4])
% xticklabels({'SOM Events','SOM excluded','PV exlcuded','PV Events'})
% title({' Similarity of Mean Vector from one Event to Unit Vector'})
% ylabel('Cosine Similarity')
% axis([0 5 .2 .7])
% 
% yline(.2)
% 
% figure(180)
% utils.set_figure(20)
% hold on
% bar([1,2,3,4],[mean(ds_within_angles(1,:),'omitnan'),mean(ds_within_angles(4,:),'omitnan'),mean(ds_within_angles(5,:),'omitnan'),mean(ds_within_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
% for i = 1:length(ds_events)
%     plot ([1 2 3 4],[ds_within_angles(1,i),ds_within_angles(4,i),ds_within_angles(5,i),ds_within_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
% end
% 
% xticks([1 2 3 4])
% xticklabels({'SOM Events','SOM excluded','PV exlcuded','PV Events'})
% title('Pairwise Similarity of Event Vectors Within Events')
% 
% axis([0 5 0 .6])
% 
% ylabel('Cosine Similarity')
%%
utils.save_figures(90,'SF5','4type_unity')
utils.save_figures(180,'SF5','4type_within')


%%
[ds_unit_angles,ds_within_angles,unit_angles,within_angles] = get_vector_angles(outcomes,ds_events);

% %% UNPACK ALL PAIRWISE ANGLES
% swithin_angles=[];sunit_angles=[];
% pwithin_angles=[];punit_angles=[];
% ewithin_angles=[];eunit_angles=[];
% 
% for d = 1:12
%     npv=numel(within_angles{2,d});
%     nmix=numel(within_angles{3,d});
%     nsom=numel(within_angles{1,d});
%     pwithin_angles=[pwithin_angles,within_angles{2,d}(1:min([npv, nmix,nsom]))]; 
%     punit_angles=[punit_angles,unit_angles{2,d}];
%     ewithin_angles=[ewithin_angles,within_angles{3,d}(1:min([npv, nmix,nsom]))]; 
%     eunit_angles=[eunit_angles,unit_angles{3,d}];
% 
%     swithin_angles=[swithin_angles,within_angles{1,d}(1:min([npv, nmix,nsom]))]; 
%     sunit_angles=[sunit_angles,unit_angles{1,d}];
% end
% 

%% HISTOGRAMS
% pwithin_angles(isnan(pwithin_angles))=[];
% ewithin_angles(isnan(ewithin_angles))=[];
% swithin_angles(isnan(swithin_angles))=[];
% 
% figure
% hold on
% 
% histogram(swithin_angles,'FaceColor','b')
% histogram(pwithin_angles,'FaceColor','r')
% histogram(ewithin_angles,'FaceColor','m')
% 
% legend({'SOM','PV','Mixed'})
% title('Distribution of Pairwise Similarity Between the Population Vectors Within Each Event Type ')
% utils.set_figure(15)
% %-------
% nbins=20;
% punit_angles(isnan(punit_angles))=[];
% eunit_angles(isnan(eunit_angles))=[];
% sunit_angles(isnan(sunit_angles))=[];
% 
% figure
% hold on
% histogram(sunit_angles,nbins,'FaceColor','b')
% histogram(punit_angles,nbins,'FaceColor','r')
% histogram(eunit_angles,nbins,'FaceColor','m')
% 
% legend({'SOM','PV','Mixed'})
% title('Distribution of Pairwise Similarity Between the Population Vectors and the Unit vector  ')
% utils.set_figure(15)


%% CALCULATE SKEWNESS OF CORRELATIONS 
%load('Y:\Christian\Processed Data\correlations\ms_correlation.mat')
corrs= param_corrs(3).result;

for d = 1:length(ds_events)
    cur_corrs=[];
    cur_corrs(1,:,:)=squeeze(mean(corrs{1,d},3,'omitnan'));
    cur_corrs(2,:,:)=squeeze(mean(corrs{2,d},3,'omitnan'));
    cur_corrs(3,:,:)=squeeze(mean(corrs{3,d},3,'omitnan')); 
    
    num(d)=min([numel(cur_corrs(1,:,:)) numel(cur_corrs(2,:,:)) numel(cur_corrs(3,:,:))]); 
    cc=cur_corrs(1,:,:);
    ds_skewness(1,d)=kurtosis(cc(:));
    cc=cur_corrs(2,:,:);
    ds_skewness(2,d)=kurtosis(cc(:));
    cc=cur_corrs(3,:,:);
    ds_skewness(3,d)=kurtosis(cc(:));

    %ds_skewness(1,d)=skewness(corrs{1,d}(:));
    %ds_skewness(2,d)=skewness(corrs{2,d}(:));
    %ds_skewness(3,d)=skewness(corrs{3,d}(:));

end

%% PLOT SKEWNESS OF CORRELATIONS

figure
hold on
bar([1,2,3],[mean(ds_skewness(1,:)) mean(ds_skewness(3,:)) mean(ds_skewness(2,:))],'FaceColor','w','EdgeColor','k')

for d = 1:length(ds_events)
    plot ([1 2 3],[ds_skewness(:,d), ds_skewness(:,d), ds_skewness(:,d)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
end

utils.set_figure(15)



