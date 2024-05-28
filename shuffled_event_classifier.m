function[output]=shuffled_event_classifier(starts,bin,param,ds_events,nshuf)
%% SET UP 

ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];


%%
sp_shuffled=nan(length(ds_events),size(timepoints,2),nshuf); 
spm_shuffled=nan(length(ds_events),size(timepoints,2),nshuf);

for d = 1:length(ds_events)
    for t = 1:size(timepoints,2)
        for s = 1:nshuf
        [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
        %-- Shuffle
        Y=Y(randperm(length(Y)));
        %-- 
        som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4);
        %-------- SVM 
        min_sp=min([length(som),length(pv)]); 
        [~,sp_shuffled(d,t,s)] = trainClassifier(X([som(1:min_sp),pv(1:min_sp)],:),Y([som(1:min_sp),pv(1:min_sp)]),[1;2],'1v1'); 

        %------- 1v1 SVM         
        min_spm = min([length(som),length(pv),length(mixed)]);
        [~,spm_accuracy(d,t,s)] = trainClassifier(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]),[1;2;4],'1v1'); 

        end
    end
end

output.sp_shuffled=sp_shuffled;
output.spm_shuffled=spm_shuffled; 

%%





        
