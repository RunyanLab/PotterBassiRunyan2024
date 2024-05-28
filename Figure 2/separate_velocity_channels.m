function [roll_pos,roll_neg, pitch_pos, pitch_neg, yaw_pos, yaw_neg] = separate_velocity_channels(velocity)

roll_pos = zeros(1,size(velocity,2));
roll_neg = zeros(1,size(velocity,2));

pitch_pos = zeros(1,size(velocity,2));
pitch_neg = zeros(1,size(velocity,2));

yaw_pos = zeros(1,size(velocity,2));
yaw_neg = zeros(1,size(velocity,2));

%%
pos_inds = find(velocity(1,:)>0);
roll_pos(pos_inds) = velocity(1, pos_inds);

neg_inds = find(velocity(1,:)<0);
roll_pos(neg_inds) = velocity(1, neg_inds);


pos_inds = find(velocity(2,:)>0);
pitch_pos(pos_inds) = velocity(2, pos_inds);

neg_inds = find(velocity(2,:)<0);
pitch_pos(neg_inds) = velocity(2, neg_inds);

pos_inds = find(velocity(3,:)>0);
yaw_pos(pos_inds) = velocity(3, pos_inds);

neg_inds = find(velocity(3,:)<0);
yaw_pos(neg_inds) = velocity(3, neg_inds);

%%

