%% LOAD
load('ds_events.mat')
%%
[outcomes] = get_pop_sparseness(ds_events,2)

%% GET LIST OF BETA WEIGHTS FOR EACH NEURON
starts=-99:1:100; 
bin=30; 
ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];
t=100; 
type='onsets';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;
beta_similarity=[];
mean_vect=[]; 

for d = 1:12 
    [X,Y] = get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d); 
    som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4);
    
    Y(Y==2)=1; 
    trials= X([som,pv,null],:);
    response=Y([som,pv,null]);
   
    models(d).svm=fitcsvm(trials,response,'KernelFunction','linear'); 
    [bs,mv]= get_beta_similarity('mean',models(d).svm,trials,response,som,pv);
    beta_similarity(d)=bs; mean_vect(d)=mv; 
    labels{d}=ds_events(d).tag;
end
%%
figure('Color','w')
bar(beta_similarity)
hold on
%bar(mean_vect/10)
%bar(mean_vect/max(abs(mean_vect)))
title({'Similarity Between Hyperplane and Increasing Mean Vector','1 => Increasing Mean is Orthogonal to Hyperplane'})
xticklabels(labels)
ylabel('Cosine Similarity between Beta vector and Increasing Mean activity')

%%
%subtract the mean PV and mean SOM out of each PV and SOM group of events before
%classifying 

% also look at perpedicularness to just increasing magnitude of the vector of mean activity 
% - use the random responses for this 

%can try to predict with cells that are just SOM event preferring 
%% BETA WEIGHTS FOR EACH SVM TO EACH OTHER AND TO MEAN VECTOR
bin=60; 
param(1).type='peak';param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;

bsim=nan(3,12);

for d = 1:12
    [X,Y] = get_classification_var([0 bin],param,ds_events(d).onsets,ds_events,d); 
    som=find(Y==1); pv=find(Y==2); mixed=find(Y==4); 
    
    %X(pv,:)=X(pv,:)+10; 
    %X(mixed,:)=X(mixed,:)+30; 

    min_spm = min([length(som),length(pv),length(mixed)]); 
    template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'BoxConstraint', 1, ...
    'Standardize',false);

    svms=fitcecoc(X([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)],:),Y([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)]), ...
        'Coding','onevsone', ...
        'Learners',template);
   
    for i = 1:3
        [bs(i),~]=get_beta_similarity('mean',svms.BinaryLearners{i},X([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)],:),Y([som(1:min_spm) pv(1:min_spm) mixed(1:min_spm)]),som,pv); 
    end
    bsim(:,d)=bs; 
    partitioned=crossval(svms,'Leaveout','on'); 
    validationAccuracy1(d) = 1 - kfoldLoss(partitioned, 'LossFun', 'ClassifError');
    numtrials(d)=min_spm
    labels{d}=ds_events(d).tag;

end



%%
figure('Color','w')
bar(bsim')
hold on
%bar(mean_vect/10)
%bar(mean_vect/max(abs(mean_vect)))
title({'Similarity Between Hyperplane and Increasing Mean Vector','1 => Increasing Mean is Orthogonal to Hyperplane'})
xticklabels(labels)
ylabel('Cosine Similarity between Beta vector and Increasing Mean activity')
legend({'Beta 1','Beta 2','Beta 3'})
utils.set_figure(15)

%%

figure
bar(validationAccuracy1-validationAccuracy2,'FaceColor','w')
title({'Accuracy of SVM Classifier for Each Dataset','2 Seconds After Peak'})
xticklabels(labels)
ylabel('Classification Percent')
yline(.3333)


utils.set_figure(25)


%%
figure 
bar(numtrials,'FaceColor','k')
title('Number of n-matched Trials per Dataset')
utils.set_figure(20)

xticklabels(labels)






