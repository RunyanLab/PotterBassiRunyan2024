%% LOAD 
if ismac
    load('/Volumes/Runyan2/Christian/Processed Data/Event Analysis/standard_ds_onsets.mat')
else
    load('Y:\Christian\Processed Data\Event Analysis\standard_ds_onsets.mat'); 
end


%% PARAMETERS
ds=1:12;
conditions = {'SOM', 'PV','Mixed'};
Np=3;  %%number of conditions?
Nsample=length(ds);  % 10 samples per weight matrix realization
resamples = 5; %%random resamples of the neurons
M=5; % latent dimensionality to fit data
Nc=75; % neuron number
numFolds=10; % number of cross-validation folds
ntypes=1; 

%% MAKE VARIABLES

zDimList=1:M;
sumLL=zeros(M,Nsample*resamples,Np); % cross-validated log likelihood
LLopt=zeros(M,Nsample*resamples,Np); % mode that maximizes the cross-validated log likelihood
Lambda=zeros(M,Nsample*resamples,Np,ntypes);  % eigenvalues

type= 'peaks';
bin_size = 1;
lengths=[60 90 120 60 90 90];
exthresh=[2 1.5 1 1.5 1.5];% do exthresh next
starts=[-30 -10 0 10 30];

param(1).type=type;param(1).stat='reg';param(1).extype='ratio';param(1).exthresh=exthresh(1);param(1).be=[starts(3) lengths(1)];  

param(2).type=type;param(2).stat='reg';param(2).extype='ratio';param(2).exthresh=exthresh(2);param(2).be=[starts(3) lengths(2)]; 
param(3).type=type;param(3).stat='reg';param(3).extype='ratio';param(3).exthresh=exthresh(3);param(3).be=[starts(3) lengths(3)]; 
param(4).type=type;param(4).stat='reg';param(4).extype='ratio';param(4).exthresh=exthresh(2);param(4).be=[starts(3) lengths(4)]; 
param(5).type=type;param(5).stat='reg';param(5).extype='ratio';param(5).exthresh=exthresh(2);param(5).be=[starts(2) lengths(5)]; 

rg='no'; 
speed=[];

%% RUN FA
ind=0; 
ds=3:12; %ds(2)=[];

for rs = 1:resamples
    for d=ds
        ind = ind+1;
        D_onsets=ds_events(d).onsets;   

        for pid=1:3
            condition = conditions(pid);       
            
            for t= 1:ntypes
                [Y,~] = get_binned_Y(param(t),D_onsets,condition,bin_size,speed,ds_events,d);
                %rgY=nan(size(fullY,1),size(fullY,2)); 
%                 if strcmp(rg,'yes')                 
%                     for i=1:size(fullY,1)
%                         mdl= fitlm(catspeed,fullY(i,:));
%                         [x,y,stats]=glmfit(catspeed,fullY(i,:),'poisson');
%                         rgY(i,:)=stats.resid; 
%                     end
%                     Y=rgY; 
%                 else
%                     Y=fullY; 
%                 end
            
                [subY] = sub_sqrt_y(Y,Nc);
                [la] = get_lambda(subY,zDimList,numFolds,M)
                Lambda(:,ind,pid,t)=la;
            end
            
        end
    end
end

%%
figure(3)

for i = 1:ntypes
    subplot(2,3,i)
    
    [sptitle]= utils.make_title(param(i),bin_size);

    title(sptitle)
    colorAU= [0    0    1;
        1    0    0;
        1 0 1];
    state={'SOM','PV','Mixed'};
    hold on    
    for pid=1:Np
        errorbar(1:M, mean(Lambda(:,:,pid,i),2),std(Lambda(:,:,pid,i),[],2)/sqrt(size(Lambda,2)),'-','color',colorAU(pid,:),'LineWidth',2)

    end
    
    legend({'SOM Events', 'PV Events'},'location','northeast')
 
    xlabel('Eigenmode')
    ylabel('Eigenvalue')
    %set(gca,'fontsize',14)
    xlim([0 M])
    %axis square
end

%% PLOT MEAN EIGENVALUES
untrained= [1 2 7 8 9]; 

figure('Color','w')
hold on 
ticks=1:5:60;
labels={};
for d=1:12
    i=ticks(d);  
    labels=[labels,ds_events(d).tag];
        if ismember(d,untrained)
            scatter(i, mean(Lambda(1,i:i+4,1,1),2),[],'b','Marker','x')
            scatter(i, mean(Lambda(1,i:i+4,2,1),2),[],'r','Marker','x')
            line([i i],[mean(Lambda(1,i:i+4,1,1),2),mean(Lambda(1,i:i+4,2,1),2)],'--k','HandleVisibility','off')
        else 
            scatter(i, mean(Lambda(1,i:i+4,1,1),2),[],'b','Marker','o')
            scatter(i, mean(Lambda(1,i:i+4,2,1),2),[],'r','Marker','o')
            line([i i],[mean(Lambda(1,i:i+4,1,1),2),mean(Lambda(1,i:i+4,2,1),2)],'--k','HandleVisibility','off')
        end
   
end

xticks(1:5:60)
xticklabels(labels)
legend({'SOM untrained','PV untrained','SOM trained','PV trained'})
title("Eigenvalues of the first Eigenmode across datasets")

%% SAVE
fn= [type,'_bs-',num2str(bin_size),'_length-',num2str(lengths),'_dim-',num2str(M),'_exthresh-',num2str(exthresh),'_crossval-',num2str(numFolds)];
save(['Y:\Christian\Processed Data\Factor Analysis\v4\',fn,'.mat'],'Lambda','param','bin_size','ntypes','Np','M')

%% PLOT JUST ONE LAMBDA 
% figure('color','w')
% title({'Factor Analysis on Pyramidal Neuron Activity', 'One Second Before Peak'})
% hold on 
% colorAU= [0    0    1;
%         1    0    0];
% i=1; 
% for pid=1:Np
%     errorbar(1:M, mean(Lambda(1:10,:,pid,i),2),std(Lambda(1:10,:,pid,i),[],2)/sqrt(size(Lambda,1)),'-','color',colorAU(pid,:),'LineWidth',1.2)      
% end
% 
% legend({'SOM Events', 'PV Events'},'location','northeast')
% xlabel('Eigenmode')
% ylabel('Eigenvalue')
% xlim([0 M])

