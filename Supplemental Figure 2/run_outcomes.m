
f_outcomes= nan(1,length(fixed_outcomes)); 

for i = 1:length(fixed_outcomes)
    f_outcomes(i)=fixed_outcomes(i).overall; 

end

sorted_outcomes=cell(1,6); 
sorted_idx=cell(1,6); 
divided_outcomes=cell(1,6); 
leg=cell(1,6); 
br= 32752; 

for i = 1:6 
    init= ((i-1)*br)+1; 
    divided_outcomes{i}=f_outcomes(init:br*i); 
    [sorted_outcomes{i},sorted_idx{i}]=sort(f_outcomes(init:br*i),'descend');
    
    leg{i}=fixed_outcomes(init).tag(1:17); 
end
%% MEAN OF FULL D FOR EACH DATASET
full_d=nan(6,1); 

for i = 1:6
    full_d(i)=fixed_outcomes(i*br).overall; 
end
mean(full_d); 


%%
figure('color','w')
hold on 


used_idx=sorted_idx{3}; 
for i =1:6
    %cur_outcomes=divided_outcomes{i}; 
    %plot(cur_outcomes(used_idx))
    
    plot(sorted_outcomes{i},'lineWidth',3,'Color','k')

end


set(gca,'fontsize', 14)
set(gca,'FontName','helvetica')
xticks([1 br])
xticklabels({'1',num2str(br)})
%xlabel('Subsampled Cluster')
%ylabel('Mean Silhouette Score')
yline(fixed_outcomes(end).overall,'color',[0.8500 0.3250 0.0980 ],'LineWidth',3)
yticks([.7 .8 .9 1])

%title('Cluster Separability Using All Permutations of Excitation Wavelengths')
%legend(leg)
%legend({'Each Permutation','All Wavelengths Together'})

axis square

% saveas(3,'Y:\Christian\SfN2022\clustering_outcomes','pdf')
% saveas(3,'Y:\Christian\SfN2022\clustering_outcomes','fig')
%%
saveas(1,'individual_clustering_outcomes','pdf')
saveas(1,'individual_clustering_outcomes','fig')