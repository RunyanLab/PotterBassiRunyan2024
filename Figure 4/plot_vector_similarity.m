function []= plot_vector_similarity (ds_unit_angles,ds_within_angles)

figure(90)
utils.set_figure(20)
hold on 

bar([1,2,3],[mean(ds_unit_angles(1,:),'omitnan'),mean(ds_unit_angles(3,:),'omitnan'),mean(ds_unit_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
for i = 1:12
    plot ([1 2 3],[ds_unit_angles(1,i),ds_unit_angles(3,i),ds_unit_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')

end

xticks([1 2 3])
xticklabels({'SOM Events','Mixed Events','PV Events'})
title({' Similarity of Mean Vector from one Event to Unit Vector'})
ylabel('Cosine Similarity')
axis([0 4 .2 .7])

yline(.2)

figure(180)
utils.set_figure(20)
hold on
bar([1,2,3],[mean(ds_within_angles(1,:),'omitnan'),mean(ds_within_angles(3,:),'omitnan'),mean(ds_within_angles(2,:),'omitnan')],'FaceColor','w','EdgeColor','k')
for i = 1:12
    plot ([1 2 3],[ds_within_angles(1,i),ds_within_angles(3,i),ds_within_angles(2,i)],'k','LineStyle','-','Marker','o','MarkerFaceColor','w','HandleVisibility','off')
end


xticks([1 2 3])
xticklabels({'SOM Events','Mixed Events','PV Events'})
title('Pairwise Similarity of Event Vectors Within Events')

axis([0 4 0 .6])

ylabel('Cosine Similarity')

%%


