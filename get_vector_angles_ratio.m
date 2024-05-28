function [unit_angles,means,types,ratios,lengths,ds_vect,som_trials,pv_trials] = get_vector_angles_ratio(ds_events,id_list,activity_length)

count=0; 
unit_angles=[];
ratios=[];
means=[];
types=[];

start=0; 

for d = 1:12
    %load(['Z:\Potter et al datasets\' ds_events(d).tag 'activity.mat'])
    cell_ids=id_list{d};
    %velocity= combined_info.velocity;
    %speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);
    som=ds_events(d).mch_pop_signal;
    nsom=(som-min(som))/(max(som)-min(som));

    pv=ds_events(d).tdt_pop_signal;
    npv=(pv-min(pv))/(max(pv)-min(pv));

    [sompercs]=prctile(som,[1:.1:100]);
    [pvpercs]=prctile(pv,[1:.1:100]);
    cur_onsets=ds_events(d).onsets; 
    perclist=1:.1:100;

        for o = 1:length(cur_onsets)
            ex= utils.get_ratio(cur_onsets,o,ds_events,d);
            type=cur_onsets(o).condition;
            peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
            data=cur_onsets(o).dff;
            
            u_vect=ones(size(data,1),1);
            count=count+1;
                     
            pyr_trial=mean(data(:,100+peak_shift+start:start+100+activity_length+peak_shift-1));
            %pyr_trial=ds_events(d).pyr_pop_signal(100+peak_shift+start:start+100+activity_length+peak_shift-1);

            %som_trial=mean(som(:,100+peak_shift+start:start+100+activity_length+peak_shift-1)); 
            %som_trial=ds_events(d).mch_pop_signal(100+peak_shift+start:start+100+activity_length+peak_shift-1);
            som_trial=mean(som(cur_onsets(o).peak:cur_onsets(o).peak+activity_length));
            pv_trial=mean(pv(cur_onsets(o).peak:cur_onsets(o).peak+activity_length));


            %pv_trial=mean(pv(:,100+peak_shift+start:start+100+activity_length+peak_shift-1)); 
            %pv_trial=ds_events(d).tdt_pop_signal(100+peak_shift+start:start+100+activity_length+peak_shift-1);
            [~,sp] = min(abs(sompercs-som_trial));
            [~,pp] = min(abs(pvpercs-pv_trial));
            ratios(count)=perclist(sp)/perclist(pp);
            %ratios(count)=som_trial/pv_trial;


            som_trials(count)=som_trial;
            pv_trials(count)=pv_trial; 
            mean_pyrs=mean(data(:,100+peak_shift+start:start+100+activity_length+peak_shift-1),2);

            unit_angles(count)=cosineSimilarity(mean_pyrs',u_vect');

            if ex>2; 
                if strcmp(type,'SOM')
                    types(count)=1; 
                elseif strcmp(type,'PV')
                    types(count)=2; 
                end

            else
                 types(count)=3; 
            end
                                
            means(count)= mean(pyr_trial); 
            %ratios(count)=ratio; 
            lengths(count)=norm(mean_pyrs);
            ds_vect(count)=d;
        end

end
