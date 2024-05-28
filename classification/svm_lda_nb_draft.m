%%
bin=30; 
type='onsets';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;
starts=-50:1:50; 

%%
[outputSVM]= event_classifier(starts,bin,param(1),ds_events,'SVM','noshuffle','nodecay'); 
%%
[outputLDA]= event_classifier(starts,bin,param(1),ds_events,'LDA','noshuffle','nodecay'); 
[outputBT]= event_classifier(starts,bin,param(1),ds_events,'Bagged Trees','noshuffle','nodecay'); 
%%
[outputNB]= event_classifier(starts,bin,param(1),ds_events,'NBayes','noshuffle','nodecay'); 

%%

[output1v1]= event_classifier(starts,bin,param(1),ds_events,'1v1','noshuffle','nodecay'); 
%%

plot_accuracy(outputLDA,bin,starts,param,'noshuffle')
%%
figure('Color','w');
utils.set_figure(15)
plot(mean(output1v1.smp_accuracy))
hold on 
%plot(outputNB.smp_accuracy)
xline(50,'HandleVisibility','off')

xlabel('Time (frames)')
ylabel('Decoding Accuracy')
title('Decoding PV vs SOM vs Mixed Events')

yline(.333,'LineStyle','--')
legend({'1v1','Chance'})
%%

figure;plot(mean(outputLDA.smp_accuracy))

%%

starts=100; 
param.type=peaks

%% 
t=100;
param.type='peak';
[X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);

som=find(Y==1); pv=find(Y==2); null=find(Y==3);mixed=find(Y==4);
min_spm= min([length(som),length(pv),length(mixed)]); 

curX=X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:);
curY=Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]);

Mdl=fitcnet(curX,curY,'LayerSizes',[273])
%%

partitionedModel = crossval(Mdl, 'KFold', 10);

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');


%%
classificationLearner(X([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)],:),Y([som(1:min_spm),pv(1:min_spm),mixed(1:min_spm)]));