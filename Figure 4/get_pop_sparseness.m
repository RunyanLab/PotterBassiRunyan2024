function [outcomes] = get_pop_sparseness(ds_events,ex_thresh,time_bin)
%%
% Gives sparseness based on period of time after  

% OUTPUT:
% Outcomes:
% -  


%%

for d=1:12
    cur_onsets=ds_events(d).onsets;
    [rand_resp,pv_resp,som_resp,som_onsets,pv_onsets,ex_onsets,ex_resp,ex_type] = extract_onsets(cur_onsets,ds_events,d,ex_thresh);
    nsom_e=size(som_resp,3);
    npv_e=size(pv_resp,3); 
    nex_e=size(ex_resp,3); 

    %-- calculate sparseness for each neuron in each event type
    sparseness_vect=[];
    for n = 1:size(som_resp,1)
        
        % -- for som events
        numerator=0;
        denominator=0; 
        for tr= 1:size(som_resp,3)
            peak_diff=som_onsets(tr).peak-som_onsets(tr).onset; 
            numerator=numerator + mean(som_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))/nsom_e;
            denominator= denominator + mean(som_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))^2/nsom_e;
        end
        
        numerator=numerator^2;
        %demoninator=(denominator/size(som_resp,3));
        sparseness_vect(1,n)=(1/(1-1/nsom_e))*(1-numerator/denominator);

        % -- for pv events
        numerator=0;
        denominator=0; 
        for tr= 1:size(pv_resp,3)
            peak_diff=pv_onsets(tr).peak-pv_onsets(tr).onset; 
            numerator=numerator + mean(pv_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))/npv_e; %activity binned over 2s after peak
            denominator= denominator + mean(pv_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))^2/npv_e;
        end
        
        numerator=(numerator)^2;
        %demoninator=(denominator/npv_e);
        sparseness_vect(2,n)=(1/(1-1/npv_e)) *(1-numerator/denominator);

        % -- for mixed events 
           numerator=0;
        denominator=0; 
        for tr= 1:size(ex_resp,3)
            peak_diff=ex_onsets(tr).peak-ex_onsets(tr).onset; 
            numerator=numerator + mean(ex_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))/npv_e; %activity binned over 2s after peak
            denominator= denominator + mean(ex_resp(n,100+peak_diff:100+peak_diff+time_bin,tr))^2/nex_e;
        end
        
        numerator=(numerator)^2;
        %demoninator=(denominator/npv_e);
        sparseness_vect(3,n)=(1/(1-1/npv_e)) *(1-numerator/denominator);
        
    end
    outcomes(d).sparseness=mean(sparseness_vect,2,'omitnan'); 

end

%% SPARSENESS USING THRESHOLD

for d=1:12
    cur_onsets=ds_events(d).onsets;
    [rand_resp,pv_resp,som_resp,som_onsets,pv_onsets,ex_onsets,ex_resp,ex_type] = extract_onsets(cur_onsets,ds_events,d,ex_thresh);
    nsom_e=size(som_resp,3);
    npv_e=size(pv_resp,3);
    nex_e=size(ex_resp,3); 
    
    sd_vect=nan(1,size(som_resp,1)); 

    %-- calculate sd for each neuron
    
    bin_size=time_bin; 
    for n = 1:size(som_resp,1)
        cur_activity=sum(rand_resp(n,1:bin_size,:),2);
        sd_vect(n)=std(cur_activity);
    end

    above_vect=zeros(2,size(som_resp,1)); 
    som_binned_vect=nan(size(som_resp,1),size(som_resp,3)); 
    pv_binned_vect=nan(size(pv_resp,1),size(pv_resp,3)); 
    ex_binned_vect=nan(size(pv_resp,1),size(ex_resp,3)); 
   
    %%- Calculate above threshold for each neuron
    for n=1:size(som_resp,1)
        
        for tr=1:size(som_resp,3)
            peak_diff=som_onsets(tr).peak-som_onsets(tr).onset;
            binned_resp=sum(som_resp(n,100+peak_diff:100+peak_diff+bin_size,tr),2);
            if binned_resp>above_vect(n)
                above_vect(1,n)=above_vect(1,n)+1;    

            end
            som_binned_vect(n,tr)=binned_resp; 
        end

        for tr=1:size(pv_resp,3)
            peak_diff=pv_onsets(tr).peak-pv_onsets(tr).onset;
            binned_resp=sum(pv_resp(n,100+peak_diff:100+peak_diff+bin_size,tr),2);
            if binned_resp>above_vect(n)
                above_vect(2,n)=above_vect(2,n)+1;         

            end
            pv_binned_vect(n,tr)=binned_resp;
            
        end

           for tr=1:size(ex_resp,3)
            peak_diff=ex_onsets(tr).peak-ex_onsets(tr).onset;
            binned_resp=sum(ex_resp(n,100+peak_diff:100+peak_diff+bin_size,tr),2);
            if binned_resp>above_vect(n)
                above_vect(2,n)=above_vect(2,n)+1;         

            end
            ex_binned_vect(n,tr)=binned_resp;
            
        end


    end
     outcomes(d).ex_type=ex_type; 
     outcomes(d).som_binned_vect=som_binned_vect;
     outcomes(d).pv_binned_vect=pv_binned_vect;
     outcomes(d).ex_binned_vect=ex_binned_vect;
     outcomes(d).mean_som_vect=mean(som_binned_vect,2,'omitnan');%,'omitnan'); 
     outcomes(d).mean_pv_vect=mean(pv_binned_vect,2,'omitnan');%,'omitnan'); 
     outcomes(d).mean_ex_vect=mean(ex_binned_vect,2,'omitnan'); 
     outcomes(d).above_vect=above_vect;    
end







end





