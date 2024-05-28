%% CREATE VARIABLES/ SET PARAMETERS
if ismac
    base = '/Volumes/Runyan/Potter et al datasets/';
else
    base= 'Z:\Potter et al datasets\'; 
end
datasets = {'EC1-1R/2021-11-05/', 'EC1-1R/2022-01-13/','FL5-3L/2022-03-09/','FL5-3L/2022-04-18/','FU1-00/2022-03-17/','FU1-00/2022-05-10/','GE3-00/2022-10-27/',...
        'GE7-1L1R/2022-10-20/','GE7-1L1R/2022-12-20/','GS2-1L/2022-11-21/','GS8-00/2022-11-23/','GS8-00/2022-12-20/'};

cp=[1,90,2,300,10]; 
activity_type='dff'; 
ds=[1:12]; 

%%

for d = ds
    keep base datasets d activity_type cp ds_onsets cp ds activity_type ds_events ds_events1


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
    end

    [tdt_h,tdt_peaks,tdt_w,tdt_prom] = findpeaks(tdt_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));
    [mch_h,mch_peaks,mch_w,mch_prom] = findpeaks(mch_pop_signal,'MinPeakHeight',cp(1),'MinPeakDistance',cp(2),'MinPeakProminence',cp(3),'MaxPeakWidth',cp(4),'MinPeakWidth',cp(5));

    [mch_full_events,mch_full_onsets,mch_events,mch_onsets,mch_ends,mch_doubles,mch_peaks]=find_onsets(mch_pop_signal,mch_peaks,mch_w,mch_h,mch_prom,.5);
    [tdt_full_events,tdt_full_onsets,tdt_events,tdt_onsets,tdt_ends,tdt_doubles,tdt_peaks]=find_onsets(tdt_pop_signal,tdt_peaks,tdt_w,tdt_h,tdt_prom,.5);
    
    % ---- put SOM onsets into structure
    tr = 0;
    for e = 1:length(mch_onsets)
        if mch_onsets(e)>120 & mch_onsets(e)<size(decon,2)-400  
            tr = tr+1;
        
            D_onsets(tr).condition = 'SOM';
            
            D_onsets(tr).pure=tdt_pop_signal(mch_peaks(e));
            D_onsets(tr).event_diff= mean(mch_pop_signal(mch_full_events{e})) - mean (tdt_pop_signal(mch_full_events{e})); 
            D_onsets(tr).onset_diff= mean(mch_pop_signal(mch_full_onsets{e})) - mean(tdt_pop_signal(mch_full_onsets{e})); 
            D_onsets(tr).data = decon(pyr,mch_onsets(e)-100:mch_onsets(e)+400);
            seed=randi(length(pyr_pop_signal)-600)+100;
            D_onsets(tr).randdata=decon(pyr,seed-100:seed+400);
            D_onsets(tr).dff=dff(pyr,mch_onsets(e)-100:mch_onsets(e)+400)
            D_onsets(tr).randdff=dff(pyr,seed-100:seed+400); 
            D_onsets(tr).somdata=decon(mch,mch_onsets(e)-100:mch_onsets(e)+400);
            D_onsets(tr).pvdata=decon(tdt,mch_onsets(e)-100:mch_onsets(e)+400);
            D_onsets(tr).somdff=dff(mch,mch_onsets(e)-100:mch_onsets(e)+400); 
            D_onsets(tr).pvdff= dff(tdt,mch_onsets(e)-100:mch_onsets(e)+400); 

            D_onsets(tr).onset= mch_onsets(e); 
            D_onsets(tr).event=mch_events(e); 
            D_onsets(tr).peak=mch_peaks(e); 
            D_onsets(tr).width=length(mch_full_events{e}); 

        end
    end

    %  ---- put PV onsets into structure 
    for e = 1:length(tdt_onsets)
        if tdt_onsets(e)>120 & tdt_onsets(e)<size(decon,2)-400 % if onsets aren't too close to beginning or end 
            tr = tr+1;
            
            D_onsets(tr).condition = 'PV';
            
            D_onsets(tr).pure=mch_pop_signal(tdt_peaks(e)); 
            D_onsets(tr).event_diff= mean(mch_pop_signal(tdt_full_events{e})) - mean (tdt_pop_signal(tdt_full_events{e})); 
            D_onsets(tr).onset_diff= mean(mch_pop_signal(tdt_full_onsets{e})) - mean(tdt_pop_signal(tdt_full_onsets{e}));
            
            D_onsets(tr).data = decon(pyr,tdt_onsets(e)-100:tdt_onsets(e)+400);
            seed=randi(length(pyr_pop_signal)-600)+100;
            D_onsets(tr).randdata=decon(pyr,seed-100:seed+400);
            D_onsets(tr).dff=dff(pyr,tdt_onsets(e)-100:tdt_onsets(e)+400)
            D_onsets(tr).randdff=dff(pyr,seed-100:seed+400); 
            D_onsets(tr).somdata=decon(mch,tdt_onsets(e)-100:tdt_onsets(e)+400);
            D_onsets(tr).pvdata=decon(tdt,tdt_onsets(e)-100:tdt_onsets(e)+400);
            D_onsets(tr).somdff=dff(mch,tdt_onsets(e)-100:tdt_onsets(e)+400); 
            D_onsets(tr).pvdff= dff(tdt,tdt_onsets(e)-100:tdt_onsets(e)+400); 


            D_onsets(tr).onset= tdt_onsets(e); 
            D_onsets(tr).event=tdt_events(e); 
            D_onsets(tr).peak=tdt_peaks(e); 
            D_onsets(tr).width=length(tdt_full_events{e}); 

        end

    end

    ds_events(d).onsets=D_onsets; 
    ds_events(d).tag=datasets{d};
    ds_events(d).params=cp;
    ds_events(d).mch_pop_signal=mch_pop_signal; 
    ds_events(d).tdt_pop_signal=tdt_pop_signal; 
    ds_events(d).pyr_pop_signal=pyr_pop_signal;
    
end






