function[rand_resp,pv_resp,som_resp,som_onsets,pv_onsets,ex_onsets,ex_resp,ex_type] = extract_onsets(cur_onsets,ds_events,d,ex_thresh)

pv_count=0;
som_count=0;
ex_count=0; 

for o = 1:length(cur_onsets) 
        data=cur_onsets(o).data;
        %dff=cur_onsets(o).dff;
        rand_resp(:,:,o)=cur_onsets(o).randdata; 

        if strcmp (cur_onsets(o).condition,'SOM')   
            ratio=utils.get_ratio(cur_onsets,o,ds_events,d); 
            if ratio > ex_thresh 
                som_count=som_count+1; 
                som_onsets(som_count)=cur_onsets(o);
                som_resp(:,:,som_count)=data;                
                %som_dff_resp(:,:,som_count)=dff; 
            else
                ex_count=ex_count+1; 
                ex_onsets(ex_count)=cur_onsets(o); 
                ex_resp(:,:,ex_count)=data; 
                ex_type(ex_count)=1; 
            end

        elseif strcmp (cur_onsets(o).condition,'PV')
            ratio=utils.get_ratio(cur_onsets,o,ds_events,d); 
            if ratio > ex_thresh 
                pv_count=pv_count+1; 
                pv_onsets(pv_count)=cur_onsets(o);
                pv_resp(:,:,pv_count)=data; 
                %pv_dff_resp(:,:,pv_count)=dff; 
            else
                ex_count=ex_count+1; 
                ex_onsets(ex_count)=cur_onsets(o); 
                ex_resp(:,:,ex_count)=data;
                ex_type(ex_count)=2; 
            end
        end
 end
