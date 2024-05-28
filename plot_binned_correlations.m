function [all_ref,all_som,all_pv] = plot_binned_correlations(corrs,ds_ct_matrix)

all_ref=[];
all_som=[]; 
all_pv=[]; 
all_comp=[]; 

for d = 1:length(ds_ct_matrix)
    reference=ds_ct_matrix{d,1,1}; 
    som_rsc=mean(corrs{1,d},3,'omitnan');
    pv_rsc=mean(corrs{2,d},3,'omitnan');
    
    select=ones(size(som_rsc,1),size(som_rsc,2)); 
    select=triu(select,1); 
    
   

%     reference(reference==0)=[];
%     som_rsc(som_rsc==0)=[];
%     pv_rsc(pv_rsc==0)=[]; 
    som_rsc=som_rsc(select==1);
    pv_rsc=pv_rsc(select==1); 
    reference=reference(select==1); 
    comp_rsc=pv_rsc-som_rsc; 

    all_ref=[all_ref,reference']; 
    all_som=[all_som,som_rsc']; 
    all_pv=[all_pv,pv_rsc']; 
    all_comp=[all_comp,comp_rsc']; 
end
%%
figure(1)
utils.set_figure(15)
%subplot(3,1,1)
scatter(all_ref,all_comp)
xlabel('Full Correlation')
ylabel('PV-SOM Event Correlation')
xline(0)
yline(0)
title('All vs Comparison')
xlabel('Correlation Across Session')
ylabel('Difference between Correlation in PV and SOM Events')

% subplot(3,1,2)
% scatter(all_ref,all_som)
% xlabel('Full Correlation')
% ylabel('SOM Event Correlation')
% xline(0)
% yline(0)
% title('All vs SOM')
% 
% subplot(3,1,3)
% scatter(all_ref,all_pv)
% xlabel('Full Correlation')
% ylabel('PV Event Correlation')
% xline(0)
% yline(0)
% title('All vs PV')

%% 
bin_size=.05; 

span=range(all_ref);

nbins=floor(span/bin_size);
binned_comp=nan(1,nbins); 

for n = 2:nbins
    cur_bin = [min(all_ref)+bin_size*(n-1),min(all_ref)+bin_size*(n)]; 
    above=find(all_ref>cur_bin(1)); 
    below=find(all_ref<cur_bin(2)); 
    select=intersect(above,below)

    binned_comp(n)=mean(all_comp(select),'omitnan'); 
    binned_som(n)=mean(all_som(select),'omitnan')
    binned_pv(n)=mean(all_pv(select),'omitnan')
end


figure
utils.set_figure(15)
title('SOM vs All')
plot(1:nbins,binned_comp,'Marker','o','Color','k')
xticks([5:5:nbins])
xlabel('Correlation Across Session')
ylabel('Difference between Correlation in PV and SOM Events')


figure
utils.set_figure(15)
subplot(2,1,1)
title('SOM vs All')
plot(1:nbins,binned_som,'Marker','o','Color','k')
xticks([5:5:nbins])
%xticklabels([min(all_ref)+1:bin_size])

subplot(2,1,2)
title('PV vs All')
plot(1:nbins,binned_pv,'Marker','o','Color','k')
xticks([5:5:nbins])
%xticklabels([min(all_ref)+1:bin_size])











    


    