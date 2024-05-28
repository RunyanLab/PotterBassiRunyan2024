function [decon_smoothed_r_matrix]=get_nonevent_partialcorr(combined_info,ds_events,d)
%% LOAD 

cur_onsets=ds_events(d).onsets; 

decon = combined_info.deconv;
%%get forward, reverse, left, right velocity
velocity = combined_info.velocity;
[roll_pos,roll_neg, pitch_pos, pitch_neg, yaw_pos, yaw_neg] = separate_velocity_channels(velocity);


%% MAKE VELOCITY AND SMOOTHED DECONVOLVED
all_velocity = [roll_pos;roll_neg;pitch_pos;pitch_neg;yaw_pos;yaw_neg];

%%for each pair of cells, get partial correlation, controlling for velocity
for cel = 1:size(decon,1)
    decon_smoothed(cel,:) = movmean(decon(cel,:),10);
end

decon_smoothed_r_matrix = nan(size(decon_smoothed,1),size(decon_smoothed,1),4);

%%
ne_times=1:size(decon_smoothed,2); 


som_event_times=[]; 
pv_event_times=[]; 
mixed_event_times=[]; 

for tr=1: length(cur_onsets)    
    ratio= utils.get_ratio(cur_onsets,tr,ds_events,d);
    
    %etimes=cur_onsets(tr).peak:cur_onsets(tr).peak+(cur_onsets(tr).onset-cur_onsets(tr).peak)+cur_onsets(tr).width; 
    etimes=cur_onsets(tr).peak:cur_onsets(tr).peak+60;

    
    if ratio <2
        mixed_event_times=[mixed_event_times,etimes]; 
    elseif ratio >= 2 
        if strcmp(cur_onsets(tr).condition,'SOM')
            som_event_times=[som_event_times,etimes];
        elseif strcmp(cur_onsets(tr).condition,'PV')
            pv_event_times=[pv_event_times,etimes]; 
        end
    end

    ne_times(ismember(ne_times,etimes))=[];
end



%%
for c1 = 1:size(decon_smoothed,1)
    for c2 = c1+1:size(decon_smoothed,1)
        rho = partialcorr(decon_smoothed(c1,som_event_times)',decon_smoothed(c2,som_event_times)',all_velocity(:,som_event_times)');  
        decon_smoothed_r_matrix(c1,c2,1) = rho;
        
        rho = partialcorr(decon_smoothed(c1,pv_event_times)',decon_smoothed(c2,pv_event_times)',all_velocity(:,pv_event_times)');  
        decon_smoothed_r_matrix(c1,c2,2) = rho;
        
        rho = partialcorr(decon_smoothed(c1,mixed_event_times)',decon_smoothed(c2,mixed_event_times)',all_velocity(:,mixed_event_times)');  
        decon_smoothed_r_matrix(c1,c2,3) = rho;  

        rho = partialcorr(decon_smoothed(c1,ne_times)',decon_smoothed(c2,ne_times)',all_velocity(:,ne_times)');  
        decon_smoothed_r_matrix(c1,c2,4) = rho;  
    end
end

