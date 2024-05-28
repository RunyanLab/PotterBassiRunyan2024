function [ds_ct_corr,all_ct_corr,ds_ct_matrix] = organize_corrs (ds_partialcorrs,id_list)
ds_num=length(ds_partialcorrs); 

%change this to just load a pooled_clustering file
% mice = {'EC1-1R','EC1-1R','FL5-3L','FL5-3L','FU1-00','FU1-00','GE3-00','GE7-1L1R','GE7-1L1R','GS2-1L','GS8-00','GS8-00'};
% dates= {'2021-11-05','2022-01-13','2022-03-09','2022-04-18','2022-05-10','2022-03-17','2022-10-27','2022-10-20','2022-12-20','2022-11-21','2022-11-23','2022-12-20'};
% id_list= cell(1,ds_num); 
% 
% for i = 1:ds_num
%     temp=load(['Z:\Potter et al datasets\',mice{i},'\',dates{i},'\clustering']);   
%     id_list{i}=temp.clustering_info.cellids; 
% end

ds_ct_corr=cell(ds_num,3,3);
ds_ct_matrix=cell(ds_num,3,3);

for i = 1:ds_num
    cur_corrs= ds_partialcorrs(i).decon_smoothed_r_matrix;
    cur_ids= id_list{i}; 
    % 
    % for c1 = 0:2
    %     for c2 = 0:2
    %         selected=cur_corrs(cur_ids==c1,cur_ids==c2); 
    %         selected(isnan(selected))=[]; 
    %         ds_ct_corr{i,c1+1,c2+1}=selected(:);
    %     end
    % end
%end

    for c1 = 0:2
        for c2 = 0:2
            matrix= zeros(length(cur_ids),length(cur_ids));
            for ii = 1: length(cur_ids) 
                for jj = 1:length(cur_ids)
                    if cur_ids(ii) == c1 && cur_ids(jj) == c2
                        matrix(ii,jj)=1; 
                    end
                end
            end
            ds_ct_matrix{i,c1+1,c2+1}=cur_corrs;
            selected=cur_corrs(matrix==1); 
            selected(isnan(selected))=[]; 
            ds_ct_corr{i,c1+1,c2+1}=selected;
        end
    end
end


all_ct_corr= cell(3,3); 

for i = 1:ds_num
    for c1= 1:3
        for c2= 1:3
            cur_ct_corr= all_ct_corr(c1,c2); 
            add_corrs= ds_ct_corr(i,c1,c2); 
            cur_ct_corr=[cur_ct_corr{:},add_corrs{:}']; 
            all_ct_corr{c1,c2}=cur_ct_corr; 
        end
    end
end















             


            


  


