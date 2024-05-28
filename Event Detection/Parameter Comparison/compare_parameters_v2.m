%% CREATE VARIABLES/ SET PARAMETERS
if ismac
    base = '/Volumes/Runyan/Potter et al datasets/';
else
    base= 'Z:\Potter et al datasets\';
end
datasets = {'EC1-1R/2021-11-05/', 'EC1-1R/2022-01-13/','FL5-3L/2022-03-09/','FL5-3L/2022-04-18/','FU1-00/2022-03-17/','FU1-00/2022-05-10/','GE3-00/2022-10-27/',...
        'GE7-1L1R/2022-10-20/','GE7-1L1R/2022-12-20/','GS2-1L/2022-11-21/','GS8-00/2022-11-23/','GS8-00/2022-12-20/'};

params=[1,90,2,300,10;
        1,90,2,300,20;
        1,90,2,300,50;
        1,90,2,200,10;
        1,90,2,200,20;
        1,90,2,200,50]; %height,dist,prom

activity_type='dff'; 

ds=[1:12];
%%  RUN EVENT CODE FOR EACH DATASETS

for d = ds

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
        pyr_pop_signal = zscore(preprocess_pop_activity(dff(pyr,:))); 
    elseif strcmp(activity_type,'deconv')
        tdt_pop_signal = zscore(preprocess_pop_activity(decon(tdt,:)));
        mch_pop_signal = zscore(preprocess_pop_activity(decon(mch,:)));
        pyr_pop_signal = zscore(preprocess_pop_activity(decon(pyr,:))); 
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

    for p=1:size(params,1)
        
        cp=params(p,:); 

        if cp(5)>0
            [tdt_h,tdt_peaks,tdt_w,tdt_prom] = findpeaks(tdt_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));
            [mch_h,mch_peaks,mch_w,mch_prom] = findpeaks(mch_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));
        
        else
            [tdt_h,tdt_peaks,tdt_w,tdt_prom] = findpeaks(tdt_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4));
            [mch_h,mch_peaks,mch_w,mch_prom] = findpeaks(mch_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4));

        end

       
        [mch_full_events,mch_full_onsets,mch_events,mch_onsets,mch_ends,mch_doubles]=find_onsets(mch_pop_signal,mch_peaks,mch_w,mch_h,mch_prom,.5);
        [tdt_full_events,tdt_full_onsets,tdt_events,tdt_onsets,tdt_ends,tdt_doubles]=find_onsets(tdt_pop_signal,tdt_peaks,tdt_w,tdt_h,tdt_prom,.5);

        onsets(p).params=cp; 
        onsets(p).mch_onsets=mch_onsets;
        onsets(p).mch_events=mch_events; 
        onsets(p).mch_full_onsets=mch_full_onsets;
        onsets(p).mch_full_events=mch_full_events; 
        onsets(p).mch_widths=mch_w; 
        onsets(p).mch_peaks=mch_peaks; 
        onsets(p).mch_h=mch_h; 
        onsets(p).mch_prom=mch_prom;
        onsets(p).mch_ends=mch_ends;
        onsets(p).mch_doubles=mch_doubles;
    
        onsets(p).tdt_onsets=tdt_onsets;
        onsets(p).tdt_events=tdt_events; 
        onsets(p).tdt_full_onsets=tdt_full_onsets;
        onsets(p).tdt_full_events=tdt_full_events; 
        onsets(p).tdt_widths=tdt_w; 
        onsets(p).tdt_peaks=tdt_peaks; 
        onsets(p).tdt_h=tdt_h;
        onsets(p).tdt_prom=tdt_prom;
        onsets(p).tdt_ends=tdt_ends;
        onsets(p).tdt_doubles=tdt_doubles;
     
           
    end
    
    ds_events(d).tag=datasets{d}; 
    ds_events(d).onsets=onsets; 
    ds_events(d).params=params; 
    ds_events(d).dff=dff; 
    ds_events(d).decon=decon; 
    ds_events(d).som=mch; 
    ds_events(d).pv=tdt; 
    ds_events(d).pyr=pyr; 
    ds_events(d).mch_pop_signal=mch_pop_signal; 
    ds_events(d).tdt_pop_signal=tdt_pop_signal; 
    ds_events(d).pyr_pop_signal=pyr_pop_signal;


end




