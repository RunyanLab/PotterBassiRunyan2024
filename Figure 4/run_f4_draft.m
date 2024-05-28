% Figure 4 Draft
%%
load('ds_partialcorrsn.mat')
load('ds_events.mat')

%%
[outcomes] = get_pop_sparseness(ds_events,2,60)


[pref]= get_event_preference(outcomes,ds_events,1000); 


%%
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
%%
figure;
utils.set_figure(15)
pie([somcount,pvcount,nullcount])
legend({'SOM Preferring','PV Preferring','No Preference'})

%%
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
%%
figure
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
%%

figure
hold on 
nbins=20;
histogram(ppref_means(1:length(spref_means)),nbins,'FaceColor','r')
histogram(spref_means,nbins,'FaceColor','b')
%histogram(npref_means(1:length(spref_means)),nbins,'FaceColor','k'); 

%%
%%
mean(spref_means)
mean(ppref_means)
mean(npref_means)


%% COMPARE CORRELATIONS BETWEEN NEURONS THAT ARE MORE SIMILARLY ACTIVATED BY SOM OR PV EVENTS
% sompref_corrs=cell(1,12);
% pvprev_corrs=cell(1,12); 
% antipref_corrs=cell(1,12); 
% 


for d = 1:12
    diff_vect=outcomes(d).mean_som_vect./outcomes(d).mean_pv_vect;
    cell_ids=id_list{d};
    cmatrix=ds_partialcorrs(d).decon_smoothed_r_matrix; 
    pyr_cmatrix=cmatrix(cell_ids==0,cell_ids==0); 


    prefsom_thresh=prctile(diff_vect,95);
    prefpv_thresh=prctile(diff_vect,5); 

    prefsom_ids=find(diff_vect>prefsom_thresh); 
    prefpv_ids=find(diff_vect<prefpv_thresh);

    spref_pyrs=pyr_cmatrix(prefsom_ids,prefsom_ids);
    ppref_pyrs=pyr_cmatrix(prefpv_ids,prefpv_ids);
    select_matrix=zeros(size(pyr_cmatrix,1),size(pyr_cmatrix,2)); 

    select_matrix(prefpv_ids,prefsom_ids) = 1; 
    %select_matrix(prefsom_ids,prefpv_ids)=1; 
    anti_matrix=pyr_cmatrix(prefsom_ids,prefpv_ids);

    sompref_mean(d)=mean(spref_pyrs(:),'omitnan');
    pvpref_mean(d)=mean(ppref_pyrs(:),'omitnan'); 
    all_mean(d)=mean(pyr_cmatrix(:),'omitnan');
    anti_mean(d)=mean(anti_matrix(:),'omitnan'); 

end



%%
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




  
%%
figure
utils.set_figure(20)
hold on

bar([1 2 3],[mean(sompref_mean),mean(anti_mean),mean(pvpref_mean)],'FaceColor','w','EdgeColor','k');%,mean(all_mean)])

for d = 1:12
    plot([1 2 3],[sompref_mean(d),anti_mean(d),pvpref_mean(d)],'Marker','o','Color','k');%,all_mean(d)])
end

xlabel('Pairwise Interaction')
ylabel('Mean Pairwise Correlation')
xticks([1 2 3])
xticklabels({'SOM-SOM Preferring','PV-SOM Preferring','PV-PV Preferring'})




%%

figure
histogram(spref_pyrs,'FaceColor','b','BinWidth',.01);
hold on
histogram(ppref_pyrs,'FaceColor','r','BinWidth',.01); 
histogram(anti_matrix,'FaceColor','k','BinWidth',.01);
