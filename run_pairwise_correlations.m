%% LOAD 
if ismac
    load('/Volumes/Runyan2/Christian/Processed Data/Event Analysis/standard_ds_onsets.mat')
else
    load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat'); 
end

%% MAKE VARIABLES
start=-30; 
activity_length=10; 
rg='yes';
corrs=cell(2,length(ds_events)); 
conditions={'SOM','PV'};
bin_size=10; 
corrtype='partialcorr';
%% RUN
for d=1:length(ds_events)

        D_onsets=ds_events(d).onsets;   
      
       if strcmp(rg,'yes')      
            if ismac
                load(['/Volumes/Runyan/Potter et al datasets/' ds_events(d).tag 'activity.mat'])
            else
                load(['Z:\Potter et al datasets\' ds_events(d).tag 'activity.mat'])
            end
            velocity= combined_info.velocity;
            speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);    
        end

        param.type='peaks';
        param.stat='reg';
        param.extype='pure';
        param.exthresh=2; 
        param.be= [start activity_length];

        for pid=1:2
            condition=conditions(pid);
            [fullY,D_onsets,catspeed] = get_binned_Y(param,D_onsets,condition,1,speed);
    
            cmatrix=nan(size(fullY,1)); 

            for n = 1:size(fullY,1)
                for m = 1:size(fullY,1)
                    neur1=fullY(n,:);
                    neur2=fullY(m,:); 
                     % to 1/2 time include condition where n > m 
                    if sum(neur1) > 0 && sum(neur2)>0
                            binned1=nan(floor((length(neur1)/bin_size)),1); 
                            binned2=nan(floor((length(neur2)/bin_size)),1);
                            binnedv=nan(floor((length(neur2)/bin_size)),1);
    
                            for i = 1:length(binned1)
    
                                binned1(i)=sum(neur1(1+(i-1)*bin_size:i*bin_size)); 
                                binned2(i)=sum(neur2(1+(i-1)*bin_size:i*bin_size));
                                if strcmp(corrtype,'partialcorr')
                                    binnedv(i)=sum(catspeed(1+(i-1)*bin_size:i*bin_size)); 
                                end
                            end
  
                            if strcmp(corrtype,'partialcorr')                        
                                curcoef=partialcorr(binned1,binned2,binnedv);                                
                            else
                                curcoef=corrcoef(binned1,binned2);
                                curcoef=curcoef(2); 
                            end

                            cmatrix(n,m)=curcoef;
                    end
                end
            end
            
        
            all_corrs=triu(cmatrix,1); 
            all_corrs(isnan(all_corrs))=[];
            all_corrs(all_corrs==1)=[]; 
            %all_corrs(all_corrs==0)=[]; 
            
            if strcmp(condition,'SOM')
                corrs{1,d}=all_corrs; 
            elseif strcmp(condition,'PV')
                corrs{2,d}=all_corrs;
            end 
        
        end

end



%% MAKE VARIABLES/ PLOT 

mean_corr=nan(2,length(ds_events)); 

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
title({'Correlations of Deconvolved Data',['Bin Size = ',num2str(bin_size),' frames','| ',num2str(activity_length/30),' seconds from onset','| ex-thresh= ',num2str(ex_thresh)]})









                

