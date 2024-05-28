mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-03-17','2022-05-10','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};

decon_matrices=cell(12,1);

for i = 1:12
    activity=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\activity']);
    decon_matrices{i}=get_nonevent_partialcorr(activity.combined_info,ds_events,i);
end

%%
