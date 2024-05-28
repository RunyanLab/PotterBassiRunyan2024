%% LOAD 
[ds_events]= utils.load_ds_events('standard');

%% SPECIFIY PARAMETERS FOR CLASSIFICATION 
type='onsets';
param(1).type=type;param(1).stat='avg';param(1).extype='pure';param(1).exthresh=1;
param(2).type=type;param(2).stat='avg';param(2).extype='pure';param(2).exthresh=1.5; 
param(3).type=type;param(3).stat='avg';param(3).extype='pure';param(3).exthresh=2; 
param(4).type=type;param(4).stat='avg';param(4).extype='pure';param(4).exthresh=2.5; 
param(5).type=type;param(5).stat='avg';param(5).extype='pure';param(5).exthresh=3; 

%% RUN CLASSIFIER 
% try changing bin size to be smaller if you want to do decay stuff 
starts=-99:1:50; 
bin=10; 

for i = 1:length(param)
    [output(i)]= event_classifier(starts,bin,param(i),ds_events,'noshuffle','nodecay');
end


%% PLOT ACCURACY
plot_accuracy(output,bin,starts,param(1))

%%

