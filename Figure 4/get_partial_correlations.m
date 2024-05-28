function [corrs] = get_partial_correlations(ds_events,activity_length,bin_size,type,ex_thresh)


start=0; 
corrs=cell(3,length(ds_events)); 

%%
for d = 1:12

    ds_som_corrs=[];
    ds_pv_corrs=[];
    ds_ex_corrs=[]; 

    load(['Z:\Potter et al datasets\' ds_events(d).tag 'activity.mat'])
    velocity= combined_info.velocity;
    speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);
    
    somcount=0; 
    pvcount=0; 
    excount=0; 
    cur_onsets=ds_events(d).onsets; 

    for o = 1:length(cur_onsets)
        data=cur_onsets(o).dff; 
       
        ratio= utils.get_ratio(cur_onsets,o,ds_events,d);
        cmatrix=nan(size(data,1),size(data,1)); 
%         if ratio > ex_thresh 
            % ------ compute partial correlation   
        for n = 1:size(data,1)
                for m = 1:size(data,1)
                    if m>n
                        if strcmp(type,'Onsets')
                            neur1 = data(n,100+start:100+start+activity_length-1); 
                            neur2 = data(m,100+start:100+start+activity_length-1);
                            trspeed=speed(100+start:100+start+activity_length-1); 
                    
                        elseif strcmp(type,'Peaks')
                            peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
                            neur1 = data(n,100+peak_shift+start:start+100+activity_length+peak_shift-1);
                            neur2 = data(m,100+peak_shift+start:start+100+activity_length+peak_shift-1);                  
                            trspeed=speed(100+peak_shift+start:start+100+activity_length+peak_shift-1);              
                        end 
                        
                        %if sum(neur1) > 0 && sum(neur2)>0
                            binned1=nan((length(neur1)/bin_size),1); 
                            binned2=nan((length(neur2)/bin_size),1);
                            binnedv=nan((length(neur2)/bin_size),1);
    
                            for i = 1:length(binned1)
                                binned1(i)=sum(neur1(1+(i-1)*bin_size:i*bin_size)); 
                                binned2(i)=sum(neur2(1+(i-1)*bin_size:i*bin_size));
                                binnedv(i)=sum(trspeed(1+(i-1)*bin_size:i*bin_size)); 
                            end
                                         
                            cmatrix(n,m)=partialcorr(binned1,binned2,binnedv);
                        %end
                    end
                end
        end
%         end

        if strcmp(ds_events(d).onsets(o).condition,'SOM')
            if ratio > exthresh
                somcount=somcount+1; 
                ds_som_corrs(:,:,somcount)=cmatrix; 
            elseif ratio < exthresh
                excount=excount+1; 
                ds_ex_corrs(:,:,excount)=cmatrix; 
            end
     
        elseif strcmp(ds_events(d).onsets(o).condition,'PV')
            if ratio > exthresh
                pvcount=pvcount+1;
                ds_pv_corrs(:,:,pvcount)=cmatrix; 
            elseif ratio < exthresh
                excount=excount+1; 
                ds_ex_corrs(:,:,excount)=cmatrix; 
            end
        end
    end
    
    %---- assign to PV or SOM 
        corrs{1,d}=ds_som_corrs; 
        corrs{2,d}=ds_pv_corrs; 
        corrs{3,d}=ds_ex_corrs; 


end
        




       

        





    
    


