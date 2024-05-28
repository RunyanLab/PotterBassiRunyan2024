%% LOAD
if ismac
    load('/Volumes/runyan2/Christian/Processed Data/shuffled_classifier_final.mat')
    load('/Volumes/runyan2/Christian/Processed Data/sp_spm_final.mat')
else
    load('Y:\Christian\Processed Data\shuffled_classifier_final.mat')
    load('Y:\Christian\Processed Data\sp_spm_final.mat')
end

%% Combine Results Across 
for d = 1:12
    sp_shuffled (1+(d-1)*100:d*100,:) = squeeze(output.sp_shuffled(d,:,:))';
    spm_shuffled (1+(d-1)*100:d*100,:) = squeeze(output.spm_shuffled(d,:,:))';
    sp(d,:) = output_sp.sp_accuracy(d,:);
    spm(d,:) = squeeze(output_spm.smp_accuracy(d,:));
end
%% 
for t = 1:150
    [sp_p(t),~,~]=permutationTest(sp(:,t),sp_shuffled(:,t),10000); 
    [spm_p(t),~,~]=permutationTest(spm(:,t),spm_shuffled(:,t),10000); 
end

%% Bonferroni Correct

[corrected_spp]=bonf_holm(sp_p,.05);
[corrected_spm]=bonf_holm(spm_p,.05);
%%
%SvP
figure(1)
hold on
spp_all=1:length(sp_p);
scatter(spp_all(corrected_spp<.05),ones(1,sum(corrected_spp<.05)),'k','filled','Marker','*','MarkerEdgeColor','k')
scatter(spp_all(corrected_spp>=.05),ones(1,sum(corrected_spp>=.05)),'MarkerEdgeColor','k')
scatter(100,1,'r','filled')
title('SOM vs PV')

%SvPvM
figure(2)
hold on
spp_all=1:length(sp_p);
scatter(spp_all(corrected_spm<.05),ones(1,sum(corrected_spm<.05)),'k','filled','MarkerEdgeColor','k')
scatter(spp_all(corrected_spm>=.05),ones(1,sum(corrected_spm>=.05)),'MarkerEdgeColor','k')
scatter(100,1,'r','filled')
title('SOM vs PV vs Mixed')
%% save
utils.save_figures(1,'Figure 4','SOMvsPV_significance')

utils.save_figures(2,'Figure 4','SOMvsPVvsMixed_significance')

