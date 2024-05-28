%% GET mDECONV FOR EACH DATASET

all_mSOM=cell(1,6); 
all_mPV=cell(1,6); 
all_mPYR=cell(1,6); 

for ds=1:6
    curdeconv=all_deconv{ds};
    curct=all_cell_types{ds};
    cursom=all_deconv{ds}(curct==1,:);
    curpv=all_deconv{ds}(curct==2,:);
    curpyr=all_deconv{ds}(curct==0,:); 
    all_mSOM{ds}=mean(cursom,1);
    all_mPV{ds}=mean(curpv,1);
    all_mPYR{ds}=mean(curpyr,1);
end



%%
all_deconv_angles=nan(6,11); 
all_pc_angles=nan(6,11); 


dsno=4;

[som_bout_info, pv_bout_info]=get_relative_bouts(all_pca(dsno),97,1,60,all_mSOM{dsno},all_mPV{dsno}); 


[bout_struct,all_events] =get_all_bouts(som_bout_info,pv_bout_info,all_pca(dsno));

t= [mice{dsno}, ': Traces of Mean Event-Related Activity'];
plot_mean_bouts('PYR',all_pca(dsno),bout_struct,20,300,t)

%%
[event_axes_struct]=get_event_axes(all_events,all_deconv{dsno},all_pca(dsno),all_cell_types{dsno},10); 

t=[mice{dsno},'--',dates{dsno}];
[all_deconv_angles(dsno,:),all_pc_angles(dsno,:)]=plot_event_similarity(event_axes_struct,t)

t='FL5-3L Population Vectors Based on Relative Activity'
plot_3d_event_vectors(event_axes_struct,t)

%%

figure('color','w')
histogram(all_events.sp_ratio_pc,50,'DisplayStyle','stairs','EdgeColor','k','LineWidth',2)

for i = 1:10    
    c=[1/(11-i) 0 1/i]
    xline(event_axes_struct.event_percentiles(i),'color',c,'LineWidth',2)
end

%% CONTROL

all_mSOM_c=cell(1,60); 
all_mPV_c=cell(1,60); 
all_cell_types_c=cell(1,60);

for ds=1:60
    ds
    real_ds=floor((ds-1)/10)+1
    all_cell_types_c{ds}=all_pca_c10(ds).shuffled_cell_types;
    curdeconv=all_deconv{real_ds};
    curct=all_cell_types_c{ds};
    cursom=all_deconv{real_ds}(curct==1,:);
    curpv=all_deconv{real_ds}(curct==2,:);
    all_mSOM_c{ds}=mean(cursom,1);
    all_mPV_c{ds}=mean(curpv,1);
end



%%
all_deconv_angles_control=nan(60,11); 
all_pc_angles_control=nan(60,11); 

run=[1:49,51:60]
for dsno=1:60
    real_ds=floor((dsno-1)/10)+1
    dsno
    [som_bout_info_c, pv_bout_info_c]=get_relative_bouts(all_pca_c10(dsno),70,10,120,all_mSOM_c{dsno},all_mPV_c{dsno}); 
    
    
    
    [bout_struct_c,all_events_c] =get_all_bouts(som_bout_info_c,pv_bout_info_c,all_pca_c10(dsno));
    
    
    %plot_mean_bouts('PYR',all_pca(dsno),bout_struct,1,300,'t')
    
    dsno
    [event_axes_struct_c]=get_event_axes(all_events_c,all_deconv{real_ds},all_pca_c10(dsno),all_cell_types_c{dsno},10); 
    
    t=[mice{real_ds},'--',dates{real_ds},', Control'];
    %plot_event_similarity(event_axes_struct_c,t);
    [all_deconv_angles_control(dsno,:),all_pc_angles_control(dsno,:)]=plot_event_similarity(event_axes_struct_c,t);

    dsno
end

%plot_3d_event_vectors(event_axes_struct_c,t)


%%
all_deconv_angles(:,1)=[];

all_deconv_angles_control(:,1)=[];

all_pc_angles(:,1)=[];

all_pc_angles_control(:,1)=[];

%%
ms_deconv_angles=nan(6,10);
ms_pc_angles=nan(6,10);
ms_deconv_angles_control=nan(60,10);
ms_pc_angles_control=nan(60,10); 

for i = 1:6

    ms_deconv_angles(i,:)= all_deconv_angles(i,:)-mean(all_deconv_angles,1)
    ms_pc_angles(i,:)= all_pc_angles(i,:)-mean(all_pc_angles,1)
    
  
end


for i = 1:60

    ms_deconv_angles_control(i,:)= all_deconv_angles_control(i,:)-mean(all_deconv_angles_control,1)
    ms_pc_angles_control(i,:)= all_pc_angles_control(i,:)-mean(all_pc_angles_control,1)
    
  
end


%%


figure
plot(mean(all_deconv_angles(2:6,:),1),'color','m')
hold on
plot(mean(all_deconv_angles_control(20:60,:),1),'color','b')


figure
plot(mean(all_pc_angles(2:6,:),1),'color','r')
hold on
plot(mean(all_pc_angles_control(20:60,:),1),'color','b')



