%% LOAD 
load('ds_events.mat')

%%
ex_thresh=2;
for d = 1:12

    ds_som_explained=[];
    ds_pv_explained=[];
    ds_ex_explained=[]; 
    somcount=0; 
    pvcount=0; 
    excount=0; 
    cur_onsets=ds_events(d).onsets; 
    
    for o = 1:length(cur_onsets)
        data=cur_onsets(o).dff; 
       
        ratio= utils.get_ratio(cur_onsets,o,ds_events,d);
    
        if ratio >2 
            if strcmp(cur_onsets(o).condition,'SOM')
                etype=1;
            elseif strcmp (cur_onsets(o).condition,'PV')
                etype=2;
            end
        elseif ratio <= 2
           etype=3;
        end
        peak_shift=cur_onsets(o).peak-cur_onsets(o).onset;
        
        %--- run PCA
        %data=movmean(data,2,10);
        sdata=sqrt(data); 
        [~,~,~,~,explained]=pca(data(:,100+peak_shift:100+peak_shift+150)); 



        %--- assign to matrix
        if strcmp(ds_events(d).onsets(o).condition,'SOM')
            if ratio > ex_thresh
                somcount=somcount+1; 
                ds_som_explained(:,somcount)=explained; 
            elseif ratio < ex_thresh
                excount=excount+1; 
                ds_ex_explained(:,excount)=explained; 
            end
     
        elseif strcmp(ds_events(d).onsets(o).condition,'PV')
            if ratio > ex_thresh
                pvcount=pvcount+1;
                ds_pv_explained(:,pvcount)=explained; 
            elseif ratio < ex_thresh
                excount=excount+1; 
                ds_ex_explained(:,excount)=explained; 
            end
        end

    end

    exp{1,d}=ds_som_explained; 
    exp{2,d}=ds_pv_explained; 
    exp{3,d}=ds_ex_explained;



end

%%
f=5; 
sc=0;pc=0;mc=0; 
for d = 1 :12
    som_exp=exp{1,d};
    for tr=1:size(som_exp,2)
        sc=sc+1; 
        tot_som_exp(sc,:)=som_exp(1:f,tr);
    end

    pv_exp=exp{2,d};
    for tr=1:size(pv_exp,2)
        pc=pc+1; 
        tot_pv_exp(pc,:)=pv_exp(1:f,tr);
    end

    mix_exp=exp{3,d};
    for tr=1:size(mix_exp,2)
        mc=mc+1; 
        tot_mix_exp(mc,:)=mix_exp(1:f,tr);
    end

end

%%

figure
hold on 
errorbar(mean(tot_pv_exp,1),std(tot_pv_exp,1)/size(tot_pv_exp,1),'color','r')
errorbar(mean(tot_som_exp,1),std(tot_som_exp,1)/size(tot_som_exp,1),'color','b')
errorbar(mean(tot_mix_exp,1),std(tot_mix_exp,1)/size(tot_mix_exp,1),'color','m')






