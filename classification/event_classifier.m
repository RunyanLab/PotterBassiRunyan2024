function [output]= event_classifier(starts,bin,param,ds_events,class_type,shuffle_yn,decay_yn)
% Description:
%   Function that takes information from ds_events about the events and
%   parameters about what should be classified and outputs how well the
%   classifier does 

% Inputs: 
%   starts = Points of time to classify events based on time relative to
%   period of time specified by param 

%   bin = frames that the activity for training/testing is averaged over
%   param = parameters for event classification 

% Output:
%   output = structure with sn/ sp/ pn / spn accuracy 
if strcmp(shuffle_yn,'shuffle')
    fprintf("Running with Shuffle")
end

ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];
%% GENERATE OUTCOMES
%[outcomes] = get_pop_sparseness(ds_events,2)

%% SVM
if strcmp(class_type,'SVM')
    sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
    sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spm_accuracy=nan(length(ds_events),size(timepoints,2));

       
    for d= 1 : length(ds_events)
        for t= 1:size(timepoints,2)
            [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);            
            
            X= normr(X); 
            % -- If Shuffling 
            if strcmp(shuffle_yn,'shuffle')
                Y=Y(randperm(length(Y)));
            end
            % ------        
            som=find(Y==1); pv=find(Y==2); null=find(Y==3); %red_null=null(1:floor(end/2)); 
                      
            if length(som)>length(pv) % make the number of events between each cell type match 
                [~, sp_accuracy(d,t)] = trainClassifier(X([som(1:length(pv)),pv],:), Y([som(1:length(pv)),pv]),[1;2],'SVM'); 
            else
                [~, sp_accuracy(d,t)] = trainClassifier(X([som,pv(1:length(som))],:), Y([som,pv(1:length(som))]),[1;2],'SVM'); 
            end
            
            %-- Classify PV and SOM events compared to null 
            [~, sn_accuracy(d,t)] = trainClassifier(X([som,null(1:length(som))],:), Y([som,null(1:length(som))]),[1;3],'SVM');
            [~, pn_accuracy(d,t)] = trainClassifier(X([pv,null(1:length(pv))],:), Y([pv,null(1:length(pv))]),[2;3],'SVM'); 
            
            %-- Combine PV and SOM events 
            spY=Y; 
            spY(Y==2)=1; 
            [~, spn_accuracy(d,t)] = trainClassifier(X([som,pv,null],:), spY([som,pv,null]),[1;3],'SVM');     
        end
    end
%% ----- LDA 

elseif strcmp(class_type,'LDA')
    sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
    sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spm_accuracy=nan(length(ds_events),size(timepoints,2));

    for d = 1:length(ds_events)
        for t= 1:size(timepoints,2)
            [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
              % -- If Shuffling 
            if strcmp(shuffle_yn,'shuffle')
                Y=Y(randperm(length(Y)));
            end
            %X=normr(X); 
            %- remove inactive neurons
            %total=sum(outcomes(d).above_vect,1);
            %X(:,total==0)=[];

            som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4); 
    
            min_sp= min([length(som),length(pv)]); 
            [~, sp_accuracy(d,t)] = trainClassifier(X([som(1:min_sp),pv(1:min_sp)],:), Y([som(1:min_sp),pv(1:min_sp)]),[1;2],'LDA');
    
            min_spm= min([length(som),length(pv),length(mixed)]); 
            [~,spm_accuracy(d,t)] = trainClassifier(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]),[1;2;4],'LDA');

        end
    end
%% ------ NAIVE BAYES
elseif strcmp (class_type,'NBayes')
    sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
    sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spm_accuracy=nan(length(ds_events),size(timepoints,2));
    
    for d = 1:length(ds_events)

        for t= 1:size(timepoints,2)
            [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
              % -- If Shuffling 
            if strcmp(shuffle_yn,'shuffle')
                Y=Y(randperm(length(Y)));
            end
            %- remove inactive neurons 
            total=sum(outcomes(d).above_vect,1);
            X(total==0)=[]; 
            %prct= prctile(total, 25); 
            %X(:,total<prct)=[];
    
            som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4); 
    
            min_sp = min([length(som),length(pv)]); 
            [~, sp_accuracy(d,t)] = trainClassifier(X([som(1:min_sp),pv(1:min_sp)],:), Y([som(1:min_sp),pv(1:min_sp)]),[1;2],'NBayes');
    
            min_spm = min([length(som),length(pv),length(mixed)]); 
            [~,spm_accuracy(d,t)] = trainClassifier(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]),[1;2;4],'NBayes'); 
        end
    end
    %% BAGGED TREES

elseif strcmp(class_type,'Bagged Trees')
    sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
    sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spm_accuracy=nan(length(ds_events),size(timepoints,2));
    for d = 1:length(ds_events)

        for t= 1:size(timepoints,2)
            [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
              % -- If Shuffling 
            if strcmp(shuffle_yn,'shuffle')
                Y=Y(randperm(length(Y)));
            end
            %- remove inactive neurons 
            total=sum(outcomes(d).above_vect,1);
            %X(total==0)=[]; 
            %prct= prctile(total, 25); 
            %X(:,total<prct)=[];
    
            som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4); 
    
            min_sp = min([length(som),length(pv)]); 
            [~, sp_accuracy(d,t)] = trainClassifier(X([som(1:min_sp),pv(1:min_sp)],:), Y([som(1:min_sp),pv(1:min_sp)]),[1;2],'Bagged Trees');
    
            min_spm = min([length(som),length(pv),length(mixed)]); 
            [~,spm_accuracy(d,t)] = trainClassifier(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]),[1;2;4],'Bagged Trees'); 
        end
    end

elseif strcmp(class_type,'1v1')
    sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
    sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
    spm_accuracy=nan(length(ds_events),size(timepoints,2));
    
    for d = 1:length(ds_events)
        for t = 1:size(timepoints,2)
            [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
            
            if strcmp(shuffle_yn,'shuffle')
                Y=Y(randperm(length(Y)));
            end
            som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4); 
    
            min_spm = min([length(som),length(pv),length(mixed)]); 
            [~,spm_accuracy(d,t)] = trainClassifier(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]),[1;2;4],'1v1'); 
        end    
    end
end



%% STORE VARIABLES 
output.sp_accuracy=sp_accuracy; 
output.sn_accuracy=sn_accuracy; 
output.pn_accuracy=pn_accuracy; 
output.spn_accuracy=spn_accuracy; 
output.smp_accuracy=spm_accuracy; 

if strcmp(decay_yn,'decay')
    output.sp_decay=sp_decay; 
    output.sn_decay=sn_decay; 
    output.pn_decay=pn_decay;
end

%% OLD DECAY CODE 

% if strcmp(decay_yn,'decay')
% % --- MULTIPLE TIMEPOINTS 
%     fprintf('Running with Decay')
%     
%     if strcmp(shuffle_yn,'shuffle')
%         fprintf("Running with Shuffle")
%     end    
%    
%     ends=zeros(1,length(starts))+bin;
%     timepoints=[starts;ends];
%     sp_accuracy=nan(length(ds_events),size(timepoints,2)); 
%     sn_accuracy=nan(length(ds_events),size(timepoints,2)); 
%     pn_accuracy=nan(length(ds_events),size(timepoints,2)); 
%     spn_accuracy=nan(length(ds_events),size(timepoints,2)); 
%     
%     sp_decay=nan(length(ds_events),size(timepoints,2),size(timepoints,2)); 
%     sn_decay=nan(length(ds_events),size(timepoints,2),size(timepoints,2)); 
%     pn_decay=nan(length(ds_events),size(timepoints,2),size(timepoints,2)); 
%     
%     for d=1:length(ds_events)
%         all_X=cell(1,size(timepoints,2)); 
%         all_Y=cell(1,size(timepoints,2)); 
%     
%         for t= 1:size(timepoints,2)
%             [all_X{t},all_Y{t}]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets);
%         end
%         for t=1:size(timepoints,2)
%             X=all_X{t};
%             Y=all_Y{t}; 
%     
%             som=find(Y==1); pv=find(Y==2);null=find(Y==3); 
%             
%             % -- If Shuffling 
%             if strcmp(shuffle_yn,'shuffle')
%                 Y=Y(randperm(length(Y))); 
%             end
%             % ---
%             if length(som)>length(pv)
%                 [~, sp_accuracy(d,t),sp_decay(d,t,:)] = trainClassifier(X([som(1:length(pv)),pv],:), Y([som(1:length(pv)),pv]),[1;2],all_X,all_Y,t,som(1:length(pv)),pv); 
%             else
%                 [~, sp_accuracy(d,t),sp_decay(d,t,:)] = trainClassifier(X([som,pv(1:length(som))],:), Y([som,pv(1:length(som))]),[1;2],all_X,all_Y,t,som,pv(1:length(som))); 
%             end
%             
%             [~, sn_accuracy(d,t),sn_decay(d,t,:)] = trainClassifier(X([som,null(1:length(som))],:), Y([som,null(1:length(som))]),[1;3],all_X,all_Y,t,som,null(1:length(som))); 
%             [~, pn_accuracy(d,t),pn_decay(d,t,:)] = trainClassifier(X([pv,null(1:length(pv))],:), Y([pv,null(1:length(pv))]),[2;3],all_X,all_Y,t,pv,null(1:length(pv))); 
%                    
%             spY=Y; 
%             spY(Y==2)=1; 
%     
%             [~, spn_accuracy(d,t)] = trainClassifier(X([som,pv,null],:), spY([som,pv,null]),[1;3]); 
%     
%             all_X{t}=X; 
%             all_Y{t}=Y;
%         end
%         
%     end
% %--- SINGLE TIMEPOINT ---------
% 
% else 
%     fprintf('Running Without Decay')

%% PLOTTING DECAY CODE

% cr.parameters=param(pnum); 
% cr.pn=pn_accuracy; 
% cr.sp=sp_accuracy;
% cr.pn=pn_accuracy; 
% 
% %%
% mx1=mean(X(Y==1,:),1);
% mx2=mean(X(Y==2,:),1); 
% %%
% sp_decay=output.sp_decay; 
% sn_decay=output.sn_decay;
% pn_decay=output.pn_decay; 
% 
% sp_img=mean(sp_decay,1);
% sn_img=mean(sn_decay,1); 
% pn_img=mean(pn_decay,1); 
% 
% 
% 
% figure ('color','w')
% imagesc(squeeze(sp_img))
% colorbar
% title('Classifier: SOM vs PV')
% xlabel('Test Timepoint')
% ylabel('Train Timepoint')
% xline(90)
% yline(90)
% 
% 
% figure ('color','w')
% imagesc(squeeze(sn_img))
% colorbar
% title('Classifier: SOM vs Null')
% xlabel('Test Timepoint')
% ylabel('Train Timepoint')
% xline(90)
% yline(90)
% 
% 
% figure ('color','w')
% imagesc(squeeze(pn_img))
% colorbar
% title('Classifier: PV vs Null')
% xlabel('Test Timepoint')
% ylabel('Train Timepoint')
% xline(90)
% yline(90)
% %%
% 
% smp=sn_img-pn_img;
% 
% figure ('color','w')
% imagesc(squeeze(smp))
% colorbar
% title('SOM - PV')
% xlabel('Test Timepoint')
% ylabel('Train Timepoint')
% xline(90)
% yline(90)
% 
% %%
% 
% figure
% histogram(smp)
% hold on
% xline(mean(mean(smp,'omitnan')))




