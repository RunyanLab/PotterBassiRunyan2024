%% LOAD 
load('ds_events.mat')
load('ds_partialcorrsn.mat')
load('id_list.mat')

%% ORGANIZE/ COMBINE
[ds_ct_corr,sep_corrs]=organize_corrs(ds_partialcorrs,id_list); 
all_corrs{1,2}=[sep_corrs{1,2},sep_corrs{2,1}]; 
all_corrs{1,3}=[sep_corrs{1,3},sep_corrs{3,1}]; 
all_corrs{2,3}=[sep_corrs{2,3},sep_corrs{3,2}]; 

%% FIGURE 2
nperms=10000; 
%   1       2      3      4       5      6
% PYRPYR, SOMSOM, PVPV, SOMPV, PYRSOM, PYRPV 

% % 
% stat(1).label='PYRPYR vs SOMSOM'
% [stat(1).p, stat(1).diff, stat(1).effect] = permutationTest(all_corrs{1,1}, all_corrs{2,2}, nperms);
% 
% stat(2).label='PYRPYR vs PVPV'
% [stat(2).p, stat(2).diff, stat(2).effect] = permutationTest(all_corrs{1,1}, all_corrs{3,3}, nperms);
% 
% stat(3).label='PYRPYR vs SOMPV'
% [stat(3).p, stat(3).diff, stat(3).effect] = permutationTest(all_corrs{1,1}, all_corrs{2,3}, nperms);
% 
% stat(4).label='PYRPYR vs PYRSOM'
% [stat(4).p, stat(4).diff, stat(4).effect] = permutationTest(all_corrs{1,1}, all_corrs{1,2}, nperms);
% 
% stat(5).label='PYRPYR vs PYRPV'
% [stat(5).p, stat(5).diff, stat(5).effect] = permutationTest(all_corrs{1,1}, all_corrs{1,3}, nperms);
% 
% %-----
% stat(6).label='SOMSOM vs PVPV'
% [stat(6).p, stat(6).diff, stat(6).effect] = permutationTest(all_corrs{2,2}, all_corrs{3,3}, nperms);
% 
% stat(7).label='SOMSOM vs SOMPV'
% [stat(7).p, stat(7).diff, stat(7).effect] = permutationTest(all_corrs{2,2}, all_corrs{2,3}, nperms);
% 
% stat(8).label='SOMSOM vs PYRSOM'
% [stat(8).p, stat(8).diff, stat(8).effect] = permutationTest(all_corrs{2,2}, all_corrs{1,2}, nperms);
% 
% stat(9).label='SOMSOM vs PYRPV'
% [stat(9).p, stat(9).diff, stat(9).effect] = permutationTest(all_corrs{2,2}, all_corrs{1,3}, nperms);
% 
% 
% %----
% stat(10).label='PVPV vs SOMPV'
% [stat(10).p, stat(10).diff, stat(10).effect] = permutationTest(all_corrs{3,3}, all_corrs{2,3}, nperms);
% 
% stat(11).label='PVPV vs PYRSOM'
% [stat(11).p, stat(11).diff, stat(11).effect] = permutationTest(all_corrs{3,3}, all_corrs{1,2}, nperms);
% 
% stat(12).label='PVPV vs PYRPV'
% [stat(12).p, stat(12).diff, stat(12).effect] = permutationTest(all_corrs{3,3}, all_corrs{1,3}, nperms);
% 
% %----
% 
% stat(13).label='SOMPV vs PYRSOM'
% [stat(13).p, stat(13).diff, stat(13).effect] = permutationTest(all_corrs{2,3},all_corrs{1,2}, nperms);
% 
% stat(14).label='PYRSOM vs PYRPV'
% [stat(14).p, stat(14).diff, stat(14).effect] = permutationTest(all_corrs{1,2}, all_corrs{1,3}, nperms);

o.mPYRPYR=mean(sep_corrs{1,1});
o.sPYRPYR=std(sep_corrs{1,1});
o.nPYRPYR=numel(sep_corrs{1,1});

o.mSOMSOM=mean(sep_corrs{2,2});
o.sSOMSOM=std(sep_corrs{2,2});
o.nSOMSOM=numel(sep_corrs{2,2});

o.mPVPV=mean(sep_corrs{3,3});
o.sPVPV=std(sep_corrs{3,3});
o.nPVPV=numel(sep_corrs{3,3});

o.mSOMPV=mean(all_corrs{2,3});
o.sSOMPV=std(all_corrs{2,3});
o.nSOMPV=numel(all_corrs{2,3});

o.mPYRSOM=mean(all_corrs{1,2});
o.sPYRSOM=std(all_corrs{1,2});
o.nPYRSOM=numel(all_corrs{1,2});

o.mPYRPV=mean(all_corrs{1,3});
o.sPYRPV=std(all_corrs{1,3});
o.nPYRPV=numel(all_corrs{1,3});


%% FIGURE 3 calculate mean activity differences 2

[unit_angles,means,types,ratios,lengths,ds_vect,som_trials,pv_trials] = get_vector_angles_ratio(ds_events,id_list,60);

for d = 1:12
    cur_lengths=lengths(ds_vect==d);
    cur_types=types(ds_vect==d);
    cur_means=means(ds_vect==d); 
  
    dsM(1,d)=mean(cur_means(cur_types==1));
    dsM(2,d)=mean(cur_means(cur_types==2));
    dsM(3,d)=mean(cur_means(cur_types==3));
       
end

figure
title('Mean Activity During Events')
set(gcf,'Color','w')
ylabel('Deconv')

xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})


hold on 
bar([1 2 3],[mean(dsM(1,:)) mean(dsM(3,:)) mean(dsM(2,:))])

for d = 1:12
    plot([1 2 3], [(dsM(1,d)) (dsM(3,d)) (dsM(2,d))],'Marker','o')
end
%% MEAN DIFFERENCE STATISTICS
nperms=10000; 
event_mean(1).label='SOMvsPV'
[event_mean(1).p, event_mean(1).h, event_mean(1).stats]= signrank(dsM(1,:),dsM(2,:)); 
event_mean(2).label='SOMvsMixed'
[event_mean(2).p, event_mean(2).h, event_mean(2).stats]= signrank(dsM(1,:),dsM(3,:)); 
event_mean(3).label='PVvsMixed'
[event_mean(3).p, event_mean(3).h, event_mean(3).stats]= signrank(dsM(2,:),dsM(3,:)); 

corrected_p=bonf_holm([event_mean(1).p,event_mean(2).p,event_mean(3).p],.05);

event_mean(1).p=corrected_p(1); event_mean(2).p=corrected_p(2); event_mean(3).p=corrected_p(3); 


%% FIGURE 4



%%




