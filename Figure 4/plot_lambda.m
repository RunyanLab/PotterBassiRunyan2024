function[] =plot_lambda(Lambda,M)

figure(3)


colorAU= [0    0    1;
    1    0    0;
    1 0 1];
state={'SOM','PV','Mixed'};
hold on    
for pid=1:Np
    errorbar(1:M, mean(Lambda(:,:,pid,i),2),std(Lambda(:,:,pid,i),[],2)/sqrt(size(Lambda,2)),'-','color',colorAU(pid,:),'LineWidth',2)
end

legend({'SOM Events', 'PV Events','Mixed Events'},'location','northeast')

xlabel('Eigenmode')
ylabel('Eigenvalue')
%set(gca,'fontsize',14)
xlim([0 M])
%axis square

utils.set_figure(15)
