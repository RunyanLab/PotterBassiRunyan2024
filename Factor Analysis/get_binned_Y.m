function [Y,D] = get_binned_Y(param,D,condition,bin_size,speed,ds_events,d)
type=param.type; 
stat=param.stat; 
extype=param.extype; 
exthresh=param.exthresh;
be=param.be; 
beginning=be(1); 
ending=be(2); 
% INPUTS
%   D : ds_events
%   condition: 'PV' or 'SOM' 
%   bin_size: argument for getSeq
%   b: how much time to add to condition start 
%   e: how much time from b 

% OUTPUTS
%   Y: concatenated matrix
%   D: structure for running individual neuralTraj

start=100; % reflects the time prior to onset that was taken during binned_fa_workflow  
Y = [];
elimvect=[];
trspeed=nan(length(D),ending+1); 

%% MODIFY D FOR getSeq
for tr = 1:length(D)
    % --- get data for all trials w/o respect to type ----  
    if strcmp(type,'before')   
        spikes=D(tr).data(:,beginning:beginning+ending);
    elseif strcmp(type,'onsets')
        spikes = D(tr).data(:,start+beginning:start+beginning+ending);
    elseif strcmp(type,'events')
        oe_distance=D(tr).event-D(tr).onset; 
        spikes = D(tr).data(:,start+beginning+oe_distance:start+oe_distance+beginning+ending);
    elseif strcmp(type,'peaks')
        peak_distance=D(tr).peak-D(tr).onset; 
        %endpoint=start+peak_distance+beginning+D(tr).width; 
        %if endpoint>501
        %    endpoint=501; 
        %end


        spikes = D(tr).data(:,start+beginning+peak_distance:start+peak_distance+beginning+ending);
        if ~isempty(speed)
            if D(tr).pure<exthresh
                peak=D(tr).peak;
                trspeed(tr,:)=speed(start+peak+peak_distance:start+peak_distance+peak); 
            end           
        end
    end

    %-- put into structure-------------
    D(tr).trialId = tr;
    if strcmp(stat,'avg')
        D(tr).spikes=mean(spikes,2);
    else 
        D(tr).spikes=spikes; 
    end

    %-- elimination criteria----------------- 
    if strcmp(extype,'pure')
        if D(tr).pure>exthresh 
            elimvect=[elimvect,tr];
        end
    elseif strcmp(extype,'event_ratio')
        if D(tr).event_ratio>exthresh
            elimvect=[elimvect,tr]; 
        end
    elseif strcmp(extype,'ratio')
         ratio = utils.get_ratio(D,tr,ds_events,d);
         if ratio<exthresh
             elimvect=[elimvect,tr];
         end
    end   
end

% -------------------------------------- 
ex_D=D(elimvect); 
D(elimvect)=[];
trspeed(elimvect,:)=[];


%% RUN getSeq TO PUT INTO Y 
if strcmp(stat,'avg')
    bin_size=1; 
end

seq = getSeq(D, bin_size);
%catspeed=[]; 
if strcmp(condition,'Mixed')
    seq=getSeq(ex_D,bin_size);
    for tr=1:length(ex_D)
        temp=seq(tr).y;
        Y= cat(2,Y,temp); 
    end
else
    for tr = 1:length(D) 
        if strcmp(D(tr).condition,condition)
            temp = seq(tr).y;        
            Y = cat(2,Y,temp);
            %catspeed=[catspeed,trspeed(tr,:)];    
         end
    end

end
