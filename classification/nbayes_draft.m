%% LOAD
load('ds_events.mat')
[outcomes] = get_pop_sparseness(ds_events,2); 
%%
starts=-99:1:100; 
bin=30; 
ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];
t=100; 
type='peak';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2;
d=10;
[X,Y] = get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d); 

%%
total=sum(outcomes(d).above_vect,1);
X(:,total==0)=[];

%%
som=find(Y==1); pv=find(Y==2);mixed=find(Y==4);  
trials= X([som,pv]);%,mixed],:);
response=Y([som,pv]);%,mixed]);

if length(som)>length(pv) % make the number of events between each cell type match 
    trials=X([som(1:length(pv)),pv],:); 
    response=Y([som(1:length(pv)),pv]); 
elseif length(som)<length(pv)
    trials=X([som,pv(1:length(som))],:);
    response=Y([som,pv(1:length(som))]);
end

trials=normr(trials);
%%
Mdl= fitcnb(curX,curY); 
partitionedModel = crossval(Mdl);%,'Leaveout','on');

% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
%%
trials=curX(curY~=4,:);
response=curY(curY~=4); 
%
Mdl = fitcsvm(trials,response)
partitionedModel = crossval(Mdl);%,'Leaveout','on');
% Compute validation predictions
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');


%%
curX=[];
curY=[];
t=100; 
iters=6; 
bin=5;
for i =1:iters
    [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
    %total=sum(outcomes(d).above_vect,1);
    t=t+bin;
    X(Y==3,:)=[];
    Y(Y==3)=[];
    curX=[curX;X];
    curY=[curY,Y];
end
%%
%trials=curX(curY~=4,:);
%response=curY(curY~=4); 

Mdl = fitcdiscr(curX,curY)
partitionedModel = crossval(Mdl,'Leaveout','on');
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
