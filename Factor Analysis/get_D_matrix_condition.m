function [Y,D] = get_D_matrix_condition(D,condition,type,bin_size,beginning,ending)

start_frame = 1
Y = [];
elimvect=[];
for tr = 1:length(D)
    if strcmp(type,'onsets')
        D(tr).spikes = D(tr).data_o(:,start_frame+beginning:start_frame+beginning+ending);
    elseif strcmp(type,'events')
        D(tr).spikes = D(tr).data_e(:,start_frame+beginning:start_frame+beginning+ending);
    end
    
    D(tr).trialId = tr;
    if D(tr).pure>2; 
        elimvect=[elimvect, tr];
    end


end

D(elimvect)=[];

seq = getSeq(D, bin_size);
for tr = 1:length(D)
     if strcmp(D(tr).condition,condition
        temp = seq(tr).y;
        
        Y = cat(2,Y,temp);
    end
end
        

end


