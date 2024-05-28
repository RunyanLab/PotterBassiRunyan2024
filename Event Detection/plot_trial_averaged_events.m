function [mean_selected_activity]=plot_trial_averaged_events(dff,ct_inds,event_inds,color,varargin)
% %% MAKE VARIABLES
% start=varargin{1};
% finish=varargin{2};
% 
start=varargin{1};
finish=varargin{2};
trial_dff=nan(length(event_inds),length(start:finish)); 
ct_dff=mean(dff(ct_inds,:),1);

for i=1:length(event_inds)
    trial_dff(i,:)=ct_dff(event_inds(i)+start:event_inds(i)+finish);
end

if strcmp(varargin{3},'traces')
    for e = 1:length(event_inds)
        plot(mean(dff(ct_inds,event_inds(e)+start:event_inds(e)+finish)),'color',color)
    end

elseif strcmp(varargin{3},'average')
    %plot(mean(trial_dff(i,:),1),'color',color)
    mean_selected_activity=mean(trial_dff,1);
    %plot(mean_selected_activity,'color',color)

    std_selected_activity=std(trial_dff,1); 
    ySEM=std_selected_activity./sqrt(size(std_selected_activity,2));
    xconf= [1:size(ySEM,2) fliplr(1:size(ySEM,2))];
    ci95=tinv([.025 .975],size(std_selected_activity,2)-1);
        
    yci95 = bsxfun(@times, ySEM, ci95(:));
    yconf=[yci95(1,:)+mean_selected_activity fliplr(yci95(2,:)+mean_selected_activity)];
    p = fill(xconf,yconf,color,'FaceAlpha',.5)

    mean_selected_activity=mean(trial_dff,1);
    plot(mean_selected_activity,'color','k')
end

xline(size(trial_dff,2)-finish,'LineStyle','--')

end
