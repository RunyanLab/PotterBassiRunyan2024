%% LOAD 


for d = 1:12
    ref_matrix=decon_matrices{d}(:,:,4);
    som_matrix=decon_matrices{d}(:,:,1); 
    pv_matrix=decon_matrices{d}(:,:,2); 
    mixed_matrix=decon_matrices{d}(:,:,3);

    % ref_matrix(isnan(ref_matrix))=[];
    % som_matrix(isnan(som_matrix))=[];
    % pv_matrix(isnan(pv_matrix))=[];
    % mixed_matrix(isnan(mixed_matrix))=[];
 
    similarity(1,d)=corr(ref_matrix(:),som_matrix(:),'Type','Spearman','rows','complete'); 
    similarity(2,d)=corr(ref_matrix(:),pv_matrix(:),'Type','Spearman','rows','complete'); 
    similarity(3,d)=corr(ref_matrix(:),mixed_matrix(:),'Type','Spearman','rows','complete'); 

    meanm(1,d)=mean(som_matrix(:),'omitnan');
    meanm(2,d)=mean(pv_matrix(:),'omitnan');
    meanm(3,d)=mean(mixed_matrix(:),'omitnan');

    skewm(1,d)=skewness(som_matrix(:));
    skewm(2,d)=skewness(pv_matrix(:));
    skewm(3,d)=skewness(mixed_matrix(:));

 
end
%%

figure 
hold on
bar([mean(similarity(1,:)), mean(similarity(3,:)),mean(similarity(2,:))])

plot([1 2 3],[similarity(1,:);similarity(3,:);similarity(2,:)],'Color','k','Marker','o')
%%

figure 
hold on
bar([mean(meanm(1,:)), mean(meanm(3,:)),mean(meanm(2,:))])

plot([1 2 3],[meanm(1,:);meanm(3,:);meanm(2,:)],'Color','k','Marker','o')

ylabel('Pairwise Correlation Across All Events')
xticks([1 2 3])
xticklabels({'SOM','Mixed','PV'})

%%

figure 
hold on
bar([mean(skewm(1,:)), mean(skewm(3,:)),mean(skewm(2,:))])

plot([1 2 3],[skewm(1,:);skewm(3,:);skewm(2,:)],'Color','k','Marker','o')