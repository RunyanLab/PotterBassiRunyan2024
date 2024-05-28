function[] = plot_accuracy_final(output_sp,output_spm,starts)


%% UNPACK VARIABLES 
sp_accuracy=output_sp.sp_accuracy;
spm_accuracy=output_spm.smp_accuracy; 

sp_err=std(sp_accuracy)/sqrt(size(sp_accuracy,1)); 
spm_err=std(spm_accuracy)/sqrt(size(spm_accuracy,1));

%%

figure(1)
subplot()
clf
utils.set_figure(15) 
hold on 
frames=length(sp_err); 
x = linspace(1,frames,frames)';

y= mean(sp_accuracy,1)'; 
dy=sp_err;
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.8 .8 .8],'linestyle','none','HandleVisibility','off','FaceAlpha',.3); 
plot(x,y,'Color','k')
yline(.5,'handleVisibility','off')

y= mean(spm_accuracy,1)'; 
dy=spm_err;
fill([x;flipud(x)],[y-dy;flipud(y+dy)],[.7 .7 .7],'linestyle','none','HandleVisibility','off','FaceAlpha',.3); 
plot(x,y,'Color','k','LineStyle','--')

xlabel('Start of Time Bin Prior to Event Onset (Seconds)')
ylabel('Classification Accuracy')

title({'Classification Accuracy of SOM and PV Events at Different Time Points'})
xticks(10:30:length(sp_accuracy))
xticklabels(-3:1)
legend({'SOM vs PV','SOM vs PV vs Mixed'})
xline(find(starts==0),'handleVisibility','off')


yline(.333,'LineStyle','--','HandleVisibility','off')

%%





