[outcomes] = get_pop_sparseness_before(ds_events,2,30,0)

%%
[ds_unit_angles,ds_within_angles,unit_angles,within_angles] = get_vector_angles(outcomes,ds_events); 

%%

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
%axis([0 4 30 95])

yline(.2)

%%
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


