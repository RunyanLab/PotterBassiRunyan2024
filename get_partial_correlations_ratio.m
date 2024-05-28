function [ds_corrs,ds_ratio,ds_xct,ds_xca,ds_skew,ds_mean,ds_vect] = get_partial_correlations_ratio(ds_events,activity_length,bin_size,type,id_list)

start=0; 
corrs=cell(3,length(ds_events)); 

%%
count=0;
ds_corrs=[];
ds_ratio=[];
ds_mean=[];
ds_vect=[];

for d = 1:12
    load(['Z:\Potter et al datasets\' ds_events(d).tag 'activity.mat'])
    cell_ids=id_list{d};
    velocity= combined_info.velocity;
    speed= sqrt(velocity(1,:).^2 + velocity(2,:).^2);
    som=combined_info.deconv(cell_ids==1,:); 
    pv=combined_info.deconv(cell_ids==2,:); 
    cur_onsets=ds_events(d).onsets; 

    for o = 1:length(cur_onsets)
        peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
        data=cur_onsets(o).data;
        count=count+1;
        som_trial=mean(som(:,100+peak_shift+start:start+100+activity_length+peak_shift-1)); 
        pv_trial=mean(pv(:,100+peak_shift+start:start+100+activity_length+peak_shift-1)); 
        ratio=sum(som_trial)/sum(pv_trial);

        xct= xcorr(som_trial,pv_trial); 
        
        som_all=ds_events(d).mch_pop_signal(cur_onsets(o).onset:cur_onsets(o).onset+cur_onsets(o).width); 
        pv_all= ds_events(d).tdt_pop_signal(cur_onsets(o).onset:cur_onsets(o).onset+cur_onsets(o).width); 
        
        xca= xcorr(som_all,pv_all); 
        %ratio= utils.get_ratio(cur_onsets,o,ds_events,d);
        cmatrix=nan(size(data,1),size(data,1)); 

        mean_vect=nan(size(data,1),1);
        for n = 1:size(data,1)
                for m = 1:size(data,1)
                    if m>n
                        if strcmp(type,'Onsets')
                            neur1 = data(n,100+start:100+start+activity_length-1); 
                            neur2 = data(m,100+start:100+start+activity_length-1);
                            trspeed=speed(100+start:100+start+activity_length-1); 
                        elseif strcmp(type,'Events')
                            peak_shift=cur_onsets(o).event-cur_onsets(o).onset;
                            neur1 = data(n,100+peak_shift+start:start+100+activity_length+peak_shift-1);
                            neur2 = data(m,100+peak_shift+start:start+100+activity_length+peak_shift-1);                  
                            trspeed=speed(100+peak_shift+start:start+100+activity_length+peak_shift-1); 
                    
                        elseif strcmp(type,'Peaks')
                            peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
                            % activity_length=cur_onsets(o).width; 
                            % 
                            % activity_length=start+100+cur_onsets(o).width+peak_shift-1;
                            % if activity_length>501
                            %     activity_length=501;
                            % elseif activity_length<60
                            %     activity_length=60; 
                            % end
                            mean_vect(n)=mean(mean(data(n,100+peak_shift+start:start+100+activity_length+peak_shift-1))); 

                            neur1 = data(n,100+peak_shift+start:start+100+activity_length+peak_shift-1);
                            neur2 = data(m,100+peak_shift+start:start+100+activity_length+peak_shift-1);                  
                            trspeed= speed(100+peak_shift+start:start+100+activity_length+peak_shift-1);
                            trvelo= velocity(100+peak_shift+start:start+100+activity_length+peak_shift-1);
                        end 
                        
                        %if sum(neur1) > 0 && sum(neur2)>0
                            binned1=nan((length(neur1)/bin_size),1); 
                            binned2=nan((length(neur2)/bin_size),1);
                            binneds=nan((length(neur2)/bin_size),1);
                            binnedv=nan(3,(length(neur2)/bin_size));
    
                            for i = 1:length(binned1)
                                binned1(i)=sum(neur1(1+(i-1)*bin_size:i*bin_size)); 
                                binned2(i)=sum(neur2(1+(i-1)*bin_size:i*bin_size));
                                binneds(i)=sum(trspeed(1+(i-1)*bin_size:i*bin_size));
                                binnedv(:,i)=sum(trvelo(:,1+(i-1)*bin_size:i*bin_size),2);
                            end
                                         
                            %cmatrix(n,m)=partialcorr(binned1,binned2,binneds);
                            cmatrix(n,m)=partialcorr(binned1,binned2,binnedv');

                        %end
                    end
                end
        end
%         end
        if strcmp(ds_events(d).onsets(o).condition,'PV')
            ratio = 1/ratio;
        end

    ds_corrs(count)=mean(cmatrix(:),'omitnan');
    ds_skew(count)=skewness(cmatrix(:));

    ds_ratio(count)=ratio;
    ds_mean(count)=mean(mean_vect,'omitnan');
    ds_vect(count)=d; 
    ds_xct{count}=xct;
    ds_xca{count}=xca; 

        

    end
    %---- assign to PV or SOM 
    
       

    
end