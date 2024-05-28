%  run after SimulationFig4E.m & spkcounts.m
% spike counts data provided for nws=1 (set Nnws=1)

%% PARAMETERS
conditions = {'SOM', 'PV'};
Np=2;  %%number of conditions?
Nsample=length(ds);  % 10 samples per weight matrix realization
rs = 5; %%random resamples of the neurons
M=40; % latent dimensionality to fit data
Nc=75; % neuron number
numFolds=2; % number of cross-validation folds

%% MAKE VARIABLES 
%base = '/Volumes/Runyan/Potter et al datasets/';
%datasets = {'EC1-1R/2021-11-05/', 'EC1-1R/2022-01-13/','FL5-3L/2022-03-09/','FL5-3L/2022-04-18/','FU1-00/2022-03-17/','FU1-00/2022-05-10/'};

corr=zeros(Nsample*rs,Np);  %mean correlation
sumLL=zeros(M,Nsample*rs,Np); % cross-validated log likelihood
LLopt=zeros(Nsample*rs,Np); % mode that maximizes the cross-validated log likelihood
Lambda=zeros(M,Nsample*rs,Np);  % eigenvalues
COVm=zeros(Nsample*rs,Np);  % mean covariance  (raw)
Qm=zeros(Nsample*rs,Np);   % residual covarince
eigvector1=NaN(Nc,Nsample*rs,Np);  % first eigenvector
SIGN=zeros(Nsample*rs,Np);  % sign of the mean of the first eigenvector
zDimList=1:M;

%%
type= 'events'
bin_size = 10;
ind = 0;
for rs = 5
    for d=ds
        ind = ind+1;
        %load([base datasets{d} 'D_onsets.mat'])
        D_onsets=ds_events(ds).onsets; 
        % Nsample=80;  % 10 samples per weight matrix realization
        
        %     fname=sprintf('%sRF2D3layer_fixW_%sInh_Jex25_Jix15_inI_dt0d01_Nc500_spkcount_nws%d',data_folder,Inh,nws);
        %     data=load(fname);
        %     idx=randperm(Nc*10);
        
        for pid=1:2
            condition = conditions(pid);
            for k=1
               
                bin_size=2; 
                beginning=0; 
                ending=300;
                [Y,D_onsets] = get_D_matrix_condition(D_onsets,condition,type,bin_size,beginning,ending);  %%to do, bin and get rid of bad cells
                %             good_cells = find(max(Y')>.5);
                %             Y = Y(good_cells,:);
                Y = sqrt(Y);

                
                %             Y = zscore(Y')';
                neurons = 1:size(Y,1);
                neurons = neurons(randperm(size(Y,1)));
                Y=Y(neurons(1:Nc),:);
                
                %COV=cov(Y');
                %U=triu(ones(size(COV)),1);
                %R=corrcov(COV);
                %corr(ss,pid)=mean(R(U==1));
                dim = crossvalidate_fa(Y, 'zDimList', zDimList,'showPlots',false,'numFolds',numFolds);
                result = neuralTraj(1, D_onsets, 'method','gpfa','xDim',40);
                sumLL(:,ss,pid)=[dim.sumLL];
                LLopt(ss,pid) = find(sumLL(:,ss,pid) == max(sumLL(:,ss,pid)),1);
                
                L=dim(M).estParams.L;
                LL=L*L';
                [V,D]=eig(LL);
                la=diag(D);
                %[m,I]=max(la);
                la=sort(la,'descend');
                Lambda(:,ind,pid)=la(1:M);
                %eigvector1(:,ind,pid)=V(:,I)*sign(sum(V(:,I)));
                %SIGN(ss,pid)=sign(sum(V(:,I)));
                
                %L1=dim(1).estParams.L;
                %LL1=L1*L1';
                %Q=COV-LL1;
                %COVm(ss,pid)=mean(COV(U==1));
                %Qm(ss,pid)=mean(Q(U==1));
                
            end
        end
    end
end

%%
figure(96)
clf
title('30 frames after event ')
colorAU= [0    0    1;
    1    0    0];
state={'SOM','PV'};
hold on
for pid=1:Np
    errorbar(1:M, mean(Lambda(:,:,pid),2),std(Lambda(:,:,pid),[],2)/sqrt(size(Lambda,1)),'-','color',colorAU(pid,:))
%     text(.8, 1-pid*.1,state{pid},'unit','n','Horiz','center','color',colorAU(pid,:))
end
legend({'SOM Events', 'PV Events'},'location','northeast')
% text(.8, 1-pid*.1,state{pid},'unit','n','Horiz','center','color',colorAU(pid,:))
xlabel('Eigenmode')
ylabel('Eigenvalue')
set(gca,'fontsize',14)
xlim([0 25])
axis square
%saveas(99,'Eigenval vs Eigenmode PV SOM','fig')
%saveas(99,'Eigenval vs Eigenmode PV SOM','pdf')
for d = 1:length(datasets)
    norm_Lambda(:,d,:) = squeeze(Lambda(:,d,:))./squeeze(Lambda(1,d,1));
end


%%
%-------------------------------
figure(99)
clf
hold on
plot(squeeze(norm_Lambda(:,:,1)),'b')
plot(squeeze(norm_Lambda(:,:,2)),'r')
clf

for d = 1:length(datasets)
    clf
    
    hold on
    plot(squeeze(Lambda(:,d,1)))
    plot(squeeze(Lambda(:,d,2)))
    pause
end






%[p, observeddifference, effectsize] = permutationTest(squeeze(Lambda(:,1,1)), squeeze(Lambda(:,1,2)), 1000)


%fnamesave = 'NoNorm_FA_results';
%save(fnamesave,'corr','COVm','Qm','LLopt','Lambda','eigvector1','M','Nc','numFolds','Nsample')