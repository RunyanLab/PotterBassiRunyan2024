function[partialcorr_results] =  get_partialcorr(combined_info)

%%load data
dff = combined_info.dff;
decon = combined_info.deconv;
%%get forward, reverse, left, right velocity
velocity = combined_info.velocity;
[roll_pos,roll_neg, pitch_pos, pitch_neg, yaw_pos, yaw_neg] = separate_velocity_channels(velocity);

% roll_pos=velocity(2,:); 
% roll_pos(roll_pos<0)=0; 
% roll_neg=velocity(2,:); 
% roll_neg(roll_pos<0)=0; 
% 
% pitch_pos=velocity(1,:); 
% pitch_pos(pitch_pos<0)=0; 
% pitch_neg=velocity(1,:); 
% pitch_neg(pitch_pos<0)=0; 
% 
% yaw_pos=velocity(3,:); 
% yaw_pos(yaw_pos<0)=0; 
% yaw_neg=velocity(3,:); 
% yaw_neg(yaw_pos<0)=0; 

all_velocity = [roll_pos;roll_neg;pitch_pos;pitch_neg;yaw_pos;yaw_neg];

%%for each pair of cells, get partial correlation, controlling for velocity
for cel = 1:size(decon,1)
    decon_smoothed(cel,:) = movmean(decon(cel,:),10);
end

dff_r_matrix = nan(size(dff,1),size(dff,1));
decon_r_matrix = nan(size(dff,1),size(dff,1));
decon_smoothed_r_matrix = nan(size(dff,1),size(dff,1));
for c1 = 1:size(dff,1)
    for c2 = c1+1:size(dff,1)
        rho = partialcorr(dff(c1,:)',dff(c2,:)',all_velocity');  
        dff_r_matrix(c1,c2) = rho;
        
        rho = partialcorr(decon(c1,:)',decon(c2,:)',all_velocity');  
        decon_r_matrix(c1,c2) = rho;
        
        rho = partialcorr(decon_smoothed(c1,:)',decon_smoothed(c2,:)',all_velocity');  
        decon_smoothed_r_matrix(c1,c2) = rho;  
    end
end


%%shuffling
dff_ends_reflected = cat(2,dff(:,750:-1:1), dff, dff(:,end:-1:end-750));
decon_ends_reflected = cat(2,decon(:,750:-1:1), decon, decon(:,end:-1:end-750));
decon_smoothed_ends_reflected = cat(2,decon_smoothed(:,750:-1:1), decon_smoothed, decon_smoothed(:,end:-1:end-750));
partialcorr_results.dff_r_matrix = dff_r_matrix;
partialcorr_results.decon_r_matrix = decon_r_matrix;
partialcorr_results.decon_smoothed_r_matrix = decon_smoothed_r_matrix;


% shuffled_dff_r_matrix = nan(500,size(dff,1),size(dff,1));
% shuffled_decon_r_matrix = nan(500,size(dff,1),size(dff,1));
% shuffled_decon_smoothed_r_matrix = nan(500,size(dff,1),size(dff,1));
% 
% parfor shuffles = 1:500
%     shuffles
%     shift1 = randi([800 1400],1);
%     dff_shifted_c1 = dff_ends_reflected(:,1+shift1:1:shift1+size(dff,2));
%     decon_shifted_c1 = decon_ends_reflected(:,1+shift1:1:shift1+size(decon,2));
%     decon_smoothed_shifted_c1 = decon_smoothed_ends_reflected(:,1+shift1:1:shift1+size(decon,2));
%     
%     shift2 = randi([1 700],1);
%     dff_shifted_c2 = dff_ends_reflected(:,1+shift2:1:shift2+size(dff,2));
%     decon_shifted_c2 = decon_ends_reflected(:,1+shift2:1:shift2+size(decon,2));
%     decon_smoothed_shifted_c2 = decon_smoothed_ends_reflected(:,1+shift2:1:shift2+size(decon,2));
%     rho1 = nan(size(dff,1),size(dff,1));
%     rho2 = nan(size(dff,1),size(dff,1));
%     rho3 = nan(size(dff,1),size(dff,1));
%     for c1 = 1:size(dff,1)
%         for c2 = c1+1:size(dff,1)
%             rho1(c1,c2) = partialcorr(dff_shifted_c1(c1,:)',dff_shifted_c2(c2,:)',all_velocity');
%             
%             
%             rho2(c1,c2) = partialcorr(decon_shifted_c1(c1,:)',decon_shifted_c2(c2,:)',all_velocity');
%             
%             
%             rho3(c1,c2) = partialcorr(decon_smoothed_shifted_c1(c1,:)',decon_smoothed_shifted_c2(c2,:)',all_velocity');
%             
%         end
%     end
%     shuffled_dff_r_matrix(shuffles,:,:) = rho1;
%     shuffled_decon_r_matrix(shuffles,:,:) = rho2;
%     shuffled_decon_smoothed_r_matrix(shuffles,:,:) = rho3;
% %     shuffled_stuff.dff_r_matrix = rho1;
% %     shuffled_stuff.decon_r_matrix = rho2;
% %     shuffled_stuff_decon_smoothed_r_matrix = rho3;
%     parsave(['single_shuffle_num' num2str(shuffles) '.mat'],rho1,rho2,rho3)
% end
% 
% corr_cat_dff = [];
% corr_cat_decon = [];
% corr_cat_decon_smoothed = [];
% for c1 = 1:size(dff,1)
%     for c2 = c1+1:size(dff,1)
%         
%         if dff_r_matrix(c1,c2)>prctile(squeeze(shuffled_dff_r_matrix(:,c1,c2)),97.5)
%            corr_cat_dff(c1,c2) = 1;
%         elseif dff_r_matrix(c1,c2)<prctile(squeeze(shuffled_dff_r_matrix(:,c1,c2)),2.5)
%             corr_cat_dff(c1,c2) = -1;
%         else
%             corr_cat_dff(c1,c2) = 0;
%         end
%     end
%     for c2 = c1+1:size(decon,1)
%         
%         if decon_r_matrix(c1,c2)>prctile(squeeze(shuffled_decon_r_matrix(:,c1,c2)),97.5)
%            corr_cat_decon(c1,c2) = 1;
%         elseif decon_r_matrix(c1,c2)<prctile(squeeze(shuffled_decon_r_matrix(:,c1,c2)),2.5)
%             corr_cat_decon(c1,c2) = -1;
%         else
%             corr_cat_decon(c1,c2) = 0;
%         end
%     end
%     for c2 = c1+1:size(decon_smoothed,1)
%         
%         if decon_smoothed_r_matrix(c1,c2)>prctile(squeeze(shuffled_decon_smoothed_r_matrix(:,c1,c2)),97.5)
%            corr_cat_decon_smoothed(c1,c2) = 1;
%         elseif decon_smoothed_r_matrix(c1,c2)<prctile(squeeze(shuffled_decon_smoothed_r_matrix(:,c1,c2)),2.5)
%             corr_cat_decon_smoothed(c1,c2) = -1;
%         else
%             corr_cat_decon_smoothed(c1,c2) = 0;
%         end
%     end
% end
% 
% %%get pairwise distances
% %%get pairwise distances
% ind = 0;
% try
%     ids = find(combined_info.updated_iscell);
% catch
%     %     ids = find(combined_info.Fall.iscell(:,1));
%     ids = find(clustering_info.iscell);
% end
% for c1 = 1:size(dff,1)
%     
%     c1_x = mean(clustering_info.Fall.stat{ids((c1))}.xpix);
%     c1_y = mean(clustering_info.Fall.stat{ids((c1))}.ypix);
%     for c2 = 1:size(dff,1)
%         c2_x = mean(clustering_info.Fall.stat{ids((c2))}.xpix);
%         c2_y = mean(clustering_info.Fall.stat{ids((c2))}.ypix);
%         c1_c2_dist(c1,c2) = sqrt((c1_x-c2_x)^2+(c1_y-c2_y)^2)*combined_info.metaData.microns_per_pix;
%     end
% end
% 
% 
% 
% partialcorr_results.shuffled_dff_r_matrix = shuffled_dff_r_matrix;
% partialcorr_results.shuffled_decon_r_matrix = shuffled_decon_r_matrix;
% partialcorr_results.shuffled_decon_smoothed_r_matrix = shuffled_decon_smoothed_r_matrix;
% 
% partialcorr_results.corr_cat_dff = corr_cat_dff;
% partialcorr_results.corr_cat_decon = corr_cat_decon;
% partialcorr_results.corr_cat_decon_smoothed = corr_cat_decon_smoothed;
% 
% partialcorr_results.c1_c2_dist = c1_c2_dist;
