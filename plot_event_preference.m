[pref]= get_event_preference(outcomes,ds_events,2)

%%
somcount=0; 
nullcount=0; 
pvcount=0; 

for d = 1:length(pref)
    cur_sig=pref(d).sompv_sig; 
    for i =1: size(cur_sig,2)
        if cur_sig(1,i)==0
            nullcount=nullcount+1; 
        else
            if cur_sig(2,i)>0
                somcount=somcount+1;
            else
                pvcount=pvcount+1; 
            end
        end
    end
end

%%
figure
pie([somcount,pvcount,nullcount])

legend({'SOM Preferring','PV Preferring','No Preference'})

