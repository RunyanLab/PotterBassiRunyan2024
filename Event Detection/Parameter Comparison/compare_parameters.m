%% CREATE VARIABLES/ SET PARAMETERS
if ismac
    base = '/Volumes/Runyan/Potter et al datasets/';
else
    base= 'Z:\Potter et al datasets\';
end
datasets = {'EC1-1R/2021-11-05/', 'EC1-1R/2022-01-13/','FL5-3L/2022-03-09/','FL5-3L/2022-04-18/','FU1-00/2022-03-17/','FU1-00/2022-05-10/','GE3-00/2022-10-27/',...
        'GE7-1L1R/2022-10-20/','GE7-1L1R/2022-12-20/','GS2-1L/2022-11-21/','GS8-00/2022-11-23/','GS8-00/2022-12-20/'};

params=[1,90,2]; %height,dist,prom
activity_type='dff'; 

ds=[1:12];ds(11)=[];
%%  RUN EVENT CODE FOR EACH DATASETS
for d = ds
    %keep base datasets d activity_type params 
%     load([base datasets{d} 'partialcorr_results.mat'])
    load([base datasets{d} 'clustering.mat'])
    load([base datasets{d} 'activity.mat'])
    tdt = find(clustering_info.cellids==2);
    mch = find(clustering_info.cellids==1);
    pyr = find(clustering_info.cellids==0);
    
    decon = combined_info.deconv;
    dff = combined_info.dff;
    
    if strcmp(activity_type,'dff')
        tdt_pop_signal = zscore(preprocess_pop_activity(dff(tdt,:)));
        mch_pop_signal = zscore(preprocess_pop_activity(dff(mch,:)));
    elseif strcmp(activity_type,'deconv')
        tdt_pop_signal = zscore(preprocess_pop_activity(decon(tdt,:)));
        mch_pop_signal = zscore(preprocess_pop_activity(decon(mch,:)));
    elseif strcmp(activity_type,'dff_avg') 
        tdt_pop_signal = zscore(preprocess_pop_activity(dff(tdt,:),'avg')); 
        mch_pop_signal = zscore(preprocess_pop_activity(dff(mch,:),'avg'));
    elseif strcmp(activity_type,'deconv_avg')
        tdt_pop_signal = zscore(preprocess_pop_activity(decon(tdt,:),'avg'));
        mch_pop_signal = zscore(preprocess_pop_activity(decon(mch,:),'avg')); 
    elseif strcmp(activity_type,'pca')
        load(['Y:\Christian\Processed Data\functional-dual_red\PCA\',datasets{d},'PCA30.mat'])
        tdt_pop_signal=pca30.pv.score(:,1); 
        mch_pop_signal=pca30.som.score(:,1); 
  

    end

    %%find periods of high tdt, high mch, and high both
    [tdt_h,tdt_peaks,tdt_w,tdt_prom] = findpeaks(tdt_pop_signal,'MinPeakHeight',params(1),'MinPeakDistance',params(2),'MinPeakProminence',params(3));
    [mch_h,mch_peaks,mch_w,mch_prom] = findpeaks(mch_pop_signal,'MinPeakHeight',params(1),'MinPeakDistance',params(2),'MinPeakProminence',params(3));
    
  
    tdt_onsets=zeros(length(tdt_w),1); 
    for e = 1:length(tdt_w)  %%%finding tdtomato event onsets, could probably be improved
        if   tdt_onsets(e)>120 & tdt_onsets(e)<size(decon,2)-120
            temp = tdt_pop_signal(tdt_peaks(e)-floor(tdt_w(e)*2):tdt_peaks(e)-floor(tdt_w(e)/2));
            %                      peaktime -   3x width: peak start 
            i = find(temp<0,1,'last');
            %   find most recent time this gets to zero 
            
            if isempty(i)==0
                tdt_onsets(e) = tdt_peaks(e)-floor(tdt_w(e))*2+i;
                % if it gets to 0, take  peaktime- 3x width + most recent time
                % it got to 0 
            else
                [y,i] = min(temp);
                tdt_onsets(e) = tdt_peaks(e)-floor(tdt_w(e))*2+i;
                % if it doesnt get to 0, just subtract 3x width from peak 
            end
        end
    end
    
    mch_onsets=zeros(length(mch_w),1); 
    for e = 1:length(mch_w)  %%%finding mcherry event onsets
        if   mch_)>120 & mch_onsets(e)<size(decon,2)-120
            temp = mch_pop_signal(mch_peaks(e)-floor(mch_w(e)*2):mch_peaks(e)-floor(mch_w(e)/2));
            i = find(temp<0,1,'last');
            if isempty(i)==0
                mch_onsets(e) = mch_peaks(e)-floor(mch_w(e))*2+i;
            else
                [y,i] = min(temp);
                mch_onsets(e) = mch_peaks(e)-floor(mch_w(e))*2+i;
            end
        end
      
    end
    
    onsets.mch_onsets=mch_onsets; 
    onsets.mch_widths=mch_w; 
    onsets.mch_peaks=mch_peaks; 
    onsets.mch_pop_signal=mch_pop_signal; 
    onsets.mch_h=mch_h; 
    onsets.mch_prom=mch_prom;

    onsets.tdt_onsets=tdt_onsets; 
    onsets.tdt_widths=tdt_w; 
    onsets.tdt_peaks=tdt_peaks; 
    onsets.tdt_pop_signal=tdt_pop_signal;
    onsets.tdt_h=tdt_h;
    onsets.tdt_prom=tdt_prom; 
    
    %onsets.pyr_pop_signal=pyr_pop_signal; 
    ds_events(d).tag=datasets{d}; 
    ds_events(d).onsets=onsets; 
    ds_events(d).params=params; 
    ds_events(d).dff=dff; 
    ds_events(d).decon=decon; 
    ds_events(d).som=mch; 
    ds_events(d).pv=tdt; 

  

    
    
    
    
end 
    
    
    