function[pref]= get_event_preference(outcomes,ds_events,nperm)

% also write a function to do 3-way anova between SOM/PV/

for d = 1:length(outcomes)
    cur_onsets=ds_events(d).onsets; 
   

    cur_somvect=outcomes(d).som_binned_vect; 
    cur_pvvect=outcomes(d).pv_binned_vect; 
    cur_mixvect=outcomes(d).ex_binned_vect;

    sompv_sig=nan(3,size(cur_somvect,1));
    sommixed_sig=nan(3,size(cur_somvect,1)); 
    pvmixed_sig=nan(3,size(cur_pvvect,1));


    for n = 1:size(cur_somvect,1)
        

        [p,diff,effect]=permutationTest(cur_somvect(n,:),cur_pvvect(n,:),nperm); 
       
        sompv_sig(1,n)= p < .05; 
        sompv_sig(2,n)=diff; 
        sompv_sig(3,n)=effect; 
              
        %-----
        [p,diff,effect]=permutationTest(cur_somvect(n,:),cur_mixvect(n,:),nperm); 
       
        sommixed_sig(1,n)= p < .05; 
        sommixed_sig(2,n)=diff; 
        sommixed_sig(3,n)=effect; 
       
        %----
        
        [p,diff,effect]=permutationTest(cur_pvvect(n,:),cur_mixvect(n,:),nperm); 
        
        pvmixed_sig(1,n)= p < .05; 
        pvmixed_sig(2,n)=diff; 
        pvmixed_sig(3,n)=effect; 
        
    end
   
    pref(d).sompv_sig=sompv_sig; 
    pref(d).sommixed_sig=sommixed_sig; 
    pref(d).pvmixed_sig=pvmixed_sig; 

end













