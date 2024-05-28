%% LOAD
load('ds_events.mat')

%% DETERMINE RESPONSIVE NEURONS
[outcomes] = get_pop_sparseness(ds_events,2); 
%%
starts=-99:1:50; 
bin=60; 
ends=zeros(1,length(starts))+bin;

timepoints=[starts;ends];
type='peak';

t = 100; 
d=8; 
[X,Y]=get_classification_var(timepoints(:,1),param,ds_events(d).onsets,ds_events,d)
%% REMOVE INACTIVE CELLS
total=sum(outcomes(d).above_vect,1);
X(:,total==0)=[];
curX=X;
curY=Y;
%%
curX=X;
curY=Y;
%%
curY(Y==3)=[];
curX(Y==3,:)=[];
%curX(curY==4,:)=3;
curY(curY==4)=3; 
%w=LDA(curX,curY); 
%%
curX(curY==3,:)=[];
curY(curY==3)=[];
%%
%curX=X(:,1:200);
[w, objVal, eigVls] = linearDiscriminantAnalysis(curX, curY)

%% PLOT LDA

plot_LDA(curX,curY,w)

%% PLOT WEIGHTS
figure
utils.set_figure(15)
hold on
histogram(w(:,1),'FaceColor','m')
histogram(w(:,2),'FaceColor','g')
legend({'LDA axis 1','LDA axis 2'})

%%
type='peak';
param(1).type=type;param(1).stat='avg';param(1).extype='ratio';param(1).exthresh= 2; 
starts=-99:1:100; 
bin=5; 
ends=zeros(1,length(starts))+bin;
timepoints=[starts;ends];

figmod=4;
hold on
%figure(figmod+1)

set(gcf,'Color','w')
%figure(figmod+2)
%clf
set(gcf,'Color','w')

iters=6; 

for d = 1:length(ds_events)
    figure(1+figmod)
    %clf
    curX=[];
    curY=[];
    t=100;
    for i =1:iters
        [X,Y]=get_classification_var(timepoints(:,t),param,ds_events(d).onsets,ds_events,d);
        %total=sum(outcomes(d).above_vect,1);
        t=t+bin;
        X(Y==3,:)=[];
        Y(Y==3)=[];
        curX=[curX;X];
        curY=[curY,Y];
    end

    %X(:,total==0)=[];
    
    [w, objVal, eigVls] = linearDiscriminantAnalysis(curX, curY);
    %coef=pca(curX);
    %w=coef(:,[1 2]); 
    subplot(3,4,d)
    grid on 
    hold on
    plot_LDA(curX,curY,w,6);
    title(ds_events(d).tag)
    if d ==1
        legend({'SOM','PV','Mixed'})
    end
    
%     figure(2+figmod)
%     subplot(3,4,d)
%     hold on
%     title(ds_events(d).tag)
%     histogram(w(:,1),'FaceColor','m')
%     histogram(w(:,2),'FaceColor','g')
%     xline(0)
%     if d ==1
%         legend({'LDA axis 1','LDA axis 2'})
%     end

end


