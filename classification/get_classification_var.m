function [X,Y] = get_classification_var(be,param,D,ds_events,d)

% INPUTS
type=param.type; 
stat=param.stat; 
extype=param.extype; 
exthresh=param.exthresh;

b=be(1); 
e=be(2); 

%%
nneuron= size(D(1).data,1);
nobs=size(D(1),2);
start=100; 

%%
idx =1; 

if strcmp(extype,'ratio')
    for tr = 1 : length(D)
        ratio=utils.get_ratio(D,tr,ds_events,d); 

        if ratio > exthresh
            if strcmp (type,'onsets')
                spikes = D(tr).data(:,start+b:start+b+e);
                rspikes=D(tr).randdata(:,start+b:start+b+e);
            elseif strcmp(type,'peak')
                peak_distance=D(tr).peak-D(tr).onset;
                spikes = D(tr).data(:,start+b+peak_distance:peak_distance+start+b+e);
                rspikes=D(tr).randdata(:,start+b+peak_distance:peak_distance+start+b+e);

            end

            X(idx,:)=sum(spikes,2); 
            X(idx+1,:)=sum(rspikes,2); 
            
            if strcmp(D(tr).condition,'SOM')
                Y(idx)=1;
            elseif strcmp(D(tr).condition,'PV')
                Y(idx)=2; 
            end
  
            Y(idx+1)=3; 
          
        elseif ratio < exthresh
            %assumes peaks
            if strcmp (type,'onsets')
                spikes = D(tr).data(:,start+b:start+b+e);
                rspikes=D(tr).randdata(:,start+b:start+b+e);
            elseif strcmp(type,'peak')
                peak_distance=D(tr).peak-D(tr).onset;
                spikes = D(tr).data(:,start+b+peak_distance:peak_distance+start+b+e);
                rspikes=D(tr).randdata(:,start+b+peak_distance:peak_distance+start+b+e);

            end
             
            X(idx,:)=sum(spikes,2); 
            X(idx+1,:)=sum(rspikes,2); 
            Y(idx)=4;
            Y(idx+1)=3;
        end

         

        idx=idx+2;
        

    end
% elseif strcmp(extype,'pure')
% 
%     for tr= 1: length(D)
%         if D(tr).pure<exthresh; 
%     
%             if strcmp(type,'before')   
%                 spikes=D(tr).data(:,b:b+e);
%                 rspikes=D(tr).randdata(:,b:b+e);
%             elseif strcmp(type,'onsets')
%                 spikes = D(tr).data(:,start+b:start+b+e);
%                 rspikes=D(tr).randdata(:,start+b:start+b+e);  
%             elseif strcmp(type,'events')
%                 oe_distance=D(tr).event-D(tr).onset; 
%                 spikes = D(tr).data(:,start+b+oe_distance:start+b+e+oe_distance);
%                 rspikes=D(tr).randdata(:,start+b+oe_distance:start+b+e+oe_distance);     
%             end
%             
%             X(idx,:)=mean(spikes,2); 
%             X(idx+1,:)=mean(rspikes,2); 
%             
%             if strcmp(D(tr).condition,'SOM')
%                 Y(idx)=1;
%             elseif strcmp(D(tr).condition,'PV')
%                 Y(idx)=2; 
%             end
%         
%             Y(idx+1)=3; 
%             idx=idx+2; 
%         end
% 
%     end
% 

end

    
