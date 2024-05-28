%% CREATE VARIABLES
activity_length=120; 
bin_size=10; 
start=0; 
ex_thresh=2; 
type='Peak';

load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets_full.mat')

corrs=cell(2,length(ds_events)); 
rand_corrs=cell(2,length(ds_events)); 
vars=cell(2,length(ds_events)); 
rand_vars=cell(2,length(ds_events));
means=cell(2,length(ds_events)); 
changes=cell(2,length(ds_events)); 


%%
%type='Onset'; 
condition='partialcorr'; 

for d = 1:12
    
    cur_onsets=ds_events(d).onsets;
    ds_som_var_matrix=nan(length(cur_onsets),activity_length); 
    ds_pv_var_matrix=nan(length(cur_onsets),activity_length);
    ds_som_mean_matrix=nan(length(cur_onsets),500);
    ds_pv_mean_matrix=nan(length(cur_onsets),500);
    ds_som_changes=nan(length(cur_onsets),500); 
    ds_pv_changes=nan(length(cur_onsets),500); 

    ds_som_corrs=[];
    ds_pv_corrs=[];
    if strcmp(condition,'partialcorr')

        load(['X:\Potter et al datasets\' ds_events(d).tag 'activity.mat'])
        velocity= combined_info.velocity;
        speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);

    end

    for o = 1:length(cur_onsets)
    
        if cur_onsets(o).pure<ex_thresh
            data=cur_onsets(o).data; 
            dff=cur_onsets(o).dff; 
            
            cmatrix=nan(size(data,1)); 
            var_vect=nan(size(data,2),1); 
            
            %-------- take each pairwise corr / velocity 
            for n = 1:size(data,1)

                for m = 1:size(data,1)

                    if strcmp(type,'Onset')
                        neur1 = data(n,100+start:100+start+activity_length-1); 
                        neur2 = data(m,100+start:100+start+activity_length-1);
                        if strcmp(condition,'partialcorr')
                            trspeed=speed(100+start:100+start+activity_length-1); 
                        end

                    elseif strcmp(type,'Peak')
                        peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
                        neur1 = data(n,100+peak_shift+start:start+100+activity_length+peak_shift-1);
                        neur2 = data(m,100+peak_shift+start:start+100+activity_length+peak_shift-1);
                        if strcmp(condition,'partialcorr')
                            trspeed=speed(100+peak_shift+start:start+100+activity_length+peak_shift-1); 
                        end
                    end 

                    if sum(neur1) > 0 && sum(neur2)>0
                        binned1=nan((length(neur1)/bin_size),1); 
                        binned2=nan((length(neur2)/bin_size),1);
                        binnedv=nan((length(neur2)/bin_size),1);

                        for i = 1:length(binned1)

                            binned1(i)=sum(neur1(1+(i-1)*bin_size:i*bin_size)); 
                            binned2(i)=sum(neur2(1+(i-1)*bin_size:i*bin_size));
                            if strcmp(condition,'partialcorr')
                                binnedv(i)=sum(trspeed(1+(i-1)*bin_size:i*bin_size)); 
                            end

                        end
                        
                        if strcmp(condition,'partialcorr')     
                            curcoef=partialcorr(binned1,binned2,binnedv);                  
                        else
                            curcoef=corrcoef(binned1,binned2); 
                        end
                        cmatrix(n,m)=curcoef; 
                    end

                end
            end

            % ------ take instantaneous variance 

            iso_dff=dff(:,100+start:100+start+activity_length-1);
            %iso_dff=dff(:,100+start+peak_shift:100+start+activity_length+peak_shift-1);
               % use this if you want to do peak_shift             
            
            var_vect=nan(size(iso_dff,2),1); 
            mean_vect=nan(size(dff,2)-1,1); 
            
            for t = 1:size(iso_dff,2)
                var_vect(t)=var(iso_dff(:,t)); 
              
            end
            
            for t = 1: size(dff,2)-1 
                mean_vect(t)=mean(dff(:,t),'omitnan'); 
            end
            
            % ----get mean rate of change ----- 

            [norm_change]=pop_vector_change(data,dff,ds_events,iso_dff,o,cur_onsets); 
        
            % ----assign to pv or som -------

             all_corrs=triu(cmatrix,1); 
             all_corrs(isnan(all_corrs))=[];
             all_corrs(all_corrs==0)=[]; 
             
            if strcmp(ds_events(d).onsets(o).condition,'SOM')
                ds_som_corrs=[ds_som_corrs(:);all_corrs(:)];
                ds_som_var_matrix(o,:)=var_vect; 
                ds_som_mean_matrix(o,:)=mean_vect; 
                ds_som_changes(o,:)=norm_change;


            elseif strcmp(ds_events(d).onsets(o).condition,'PV')
                ds_pv_corrs=[ds_pv_corrs(:);all_corrs(:)];
                ds_pv_var_matrix(o,:)=var_vect;
                ds_pv_mean_matrix(o,:)=mean_vect;
                ds_pv_changes(o,:)=norm_change; 

            end

        end
    end


    elim_som=isnan(ds_som_var_matrix(:,1)); 
    elim_pv=isnan(ds_pv_var_matrix(:,1)); 
    ds_som_var_matrix(elim_som,:)=[];
    ds_pv_var_matrix(elim_pv,:)=[];  

    elim_som=isnan(ds_som_changes(:,1)); 
    elim_pv=isnan(ds_pv_changes(:,1)); 
    ds_som_mean_matrix(elim_som,:)=[];
    ds_pv_mean_matrix(elim_pv,:)=[];

    elim_som=isnan(ds_som_changes(:,1)); 
    elim_pv=isnan(ds_pv_changes(:,1)); 
    ds_som_changes(elim_som,:)=[];
    ds_pv_changes(elim_pv,:)=[];


    corrs{1,d}=ds_som_corrs; 
    corrs{2,d}=ds_pv_corrs; 
    vars{1,d}=ds_som_var_matrix;
    vars{2,d}=ds_pv_var_matrix;
  
    means{1,d}=ds_som_mean_matrix; 
    means{2,d}=ds_pv_mean_matrix; 

    changes{1,d}=ds_som_changes;
    changes{2,d}=ds_pv_changes; 
end
%% VARIABLES TO PLOT CHANGE RATE
mean_change=nan(2,length(ds_events),500); 
mean_activities=nan(2,length(ds_events),500);
for i = 1:length(ds_events)
    cur_somchange=changes{1,i}; 
    cur_pvchange=changes{2,i};
    mean_change(1,i,:)=mean(cur_somchange,1);  
    mean_change(2,i,:)=mean(cur_pvchange,1); 
    
    cur_sommean=means{1,i}; 
    cur_pvmean=means{2,i};
    mean_activities(1,i,:)=mean(cur_sommean,1);  
    mean_activities(2,i,:)=mean(cur_pvmean,1); 

end
%%

figure('Color','w')
hold on 
slice=1:300;
plot(squeeze(mean(mean_change(1,:,slice),2))./(squeeze(mean(mean_activities(1,:,slice),2))),'color','b')
plot(squeeze(mean(mean_change(2,:,slice),2))./(squeeze(mean(mean_activities(2,:,slice),2))),'color','r')

xline(100,'HandleVisibility','off')
legend({'SOM','PV'})
title('Average rate of change at each timepoint (Mean Normalized)')
xticks([10:90:500])
xticklabels([-3:3:30])
xlabel('Seconds')
ylabel('Magnitude of Vector Displacement of Pyramidal Neurons')
%%

figure('Color','w')
hold on 
slice=1:200;
plot(zscore(squeeze(movmean(mean(mean_change(1,:,slice),2),10))),'color','b')
plot(zscore(squeeze(movmean(mean(mean_change(2,:,slice),2),10))),'color','r')
plot(zscore(squeeze(mean(mean_activities(1,:,slice),2))),'color','b','LineStyle','--')
plot(zscore(squeeze(mean(mean_activities(2,:,slice),2))),'color','r','LineStyle','--')

xline(100,'HandleVisibility','off')
legend({'SOM event rate of change','PV event rate of change','SOM event mean activity','PV vent mean activity'})
title('Average rate of change at each timepoint (Normalized)')
xticks([10:90:500])
xticklabels([-3:3:30])
xlabel('Seconds')
ylabel('Magnitude of Vector Displacement of Pyramidal Neurons')



%% MAKE VARIABLES / PLOT CORRELATIONS 

mean_corr=nan(2,length(ds_events)); 
ex_thresh=param.exthresh;
for i = 1:length(ds_events)
    cur_pvcorrs= corrs{2,i};
    cur_somcorrs=corrs{1,i};

    mean_corr(2,i)=mean(mean(cur_pvcorrs,'omitnan'));
    mean_corr(1,i)=mean(mean(cur_somcorrs,'omitnan'));
% 
 end


figure('Color','w')
hold on 
b= bar([mean(mean_corr(1,:)), mean(mean_corr(2,:))]); 
b.CData([1 2],:)=[1 .5 .5;.5 .5 1]; 
plot([1 2],[mean_corr(1,:);mean_corr(2,:)],'Marker','o')

[~,pvalue]=ttest(mean_corr(1,:),mean_corr(2,:)); 
xl=xlim;
yl=ylim
text(xl(1)/4,yl(2)/2,['significance: ',num2str(round(pvalue,4))])
xticks([1 2])
xticklabels({'SOM','PV'})
xlabel('Event Type')
ylabel("Mean Pairwise Correlation of Df/f over event")
title({'Correlations of Deconvolved Data',['Bin Size = ',num2str(bin_size),' frames','| ',num2str(activity_length/60),' seconds from onset','| ex-thresh= ',num2str(ex_thresh)]})

%% PLOT VARIANCE

%*NEED TO UNDERSTAND WHY SO MANY NAN VALUES FOR 

all_som_vars=[];
all_pv_vars=[]; 
all_som_means=[];
all_pv_means=[]; 

for i = 1: length(ds_events)
    cur_som_vars=vars{1,i};
    cur_som_vars(cur_som_vars(:,1)==0,:)=[];
    
    cur_pv_vars=vars{2,i};
    cur_pv_vars(cur_pv_vars(:,1)==0,:)=[];
    
    all_som_vars=vertcat(all_som_vars,cur_som_vars); 
    all_pv_vars=vertcat(all_pv_vars,cur_pv_vars); 

    %--- means 
    cur_som_means=means{1,i};
    cur_som_means(cur_som_means(:,1)==0,:)=[];
    
    cur_pv_means=means{2,i};
    cur_pv_means(cur_pv_means(:,1)==0,:)=[];
    
    all_som_means=vertcat(all_som_means,cur_som_means); 
    all_pv_means=vertcat(all_pv_means,cur_pv_means); 



end

    

%%
type = 'onset'

figure('Color','w')
hold on
plot(mean(all_som_vars,1),'color','b')
plot(mean(all_pv_vars,1),'color','r')
title({'Instantaneous Variance During SOM and PV Events',['Aligned to ',type]})
legend('SOM event','PV event')
xlabel('Frames')
ylabel('Instanteous Variance of Pyr neurons')
xline(30,'HandleVisibility','off')


%%
%-- means 
figure('Color','w')
hold on
plot(mean(all_som_means,1,'omitnan'),'color','b')
plot(mean(all_pv_means,1,'omitnan'),'color','r')
title({'Mean Activity During SOM and PV Events',['Aligned to ',type]})
legend('SOM event','PV event')
xlabel('Frames')
ylabel('Mean Activity of Pyr neurons')
xline(30,'HandleVisibility','off')


%%

figure('Color','w')
hold on
plot(mean(all_som_vars,1)./mean(all_som_means,1,'omitnan'),'color','b')
plot(mean(all_pv_vars,1)./mean(all_pv_means,1,'omitnan'),'color','r')
title({'Mean Normalized Variance During SOM and PV Events',['Aligned to ',type]})
legend('SOM event','PV event')
xlabel('Frames')
ylabel('Instanteous Variance of Pyr neurons')
xline(30,'HandleVisibility','off')













