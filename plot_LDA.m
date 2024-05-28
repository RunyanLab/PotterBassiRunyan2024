function []= plot_LDA(X,Y,w,iters)

% figure
% hold on
% utils.set_figure(15)
lda_d1=X*w(:,1);
lda_d2=X*w(:,2);

mixed=find(Y==4);
som=find(Y==1);
pv=find(Y==2); 
%null=find(Y==3);

cur_mixed=cell(1,iters);
cur_som=cell(1,iters);
cur_pv=cell(1,iters);
cur_null=cell(1,iters);

total=length(Y); 
for i =1:iters
    tm=length(mixed);
    cur_mixed{i}=mixed(1+floor((tm/iters*(i-1))):floor(tm/iters*i));
    tm=length(som);
    cur_som{i}=som(1+floor((tm/iters*(i-1))):floor(tm/iters*i));
    tm=length(pv);
    cur_pv{i}=pv(1+floor((tm/iters*(i-1))):floor(tm/iters*i));
    %tm=length(null);
    %cur_null{i}=null(1+floor((tm/iters*(i-1))):floor(tm/iters*i));
end


scatter(lda_d1(cur_som{1}),lda_d2(cur_som{1}),[],[0 0 1],'filled')
scatter(lda_d1(cur_pv{1}),lda_d2(cur_pv{1}),[],[1 0 0],'filled')
scatter(lda_d1(cur_mixed{1}),lda_d2(cur_mixed{1}),[],[1 0 1],'filled')
%scatter(lda_d1(cur_null{1}),lda_d2(cur_null{1}),[],[0 0 0],'filled')

for i = 1:iters-1
    
    scatter(lda_d1(cur_som{i+1}),lda_d2(cur_som{i+1}),[],[i/iters i/iters 1],'filled','HandleVisibility','off')
    scatter(lda_d1(cur_pv{i+1}),lda_d2(cur_pv{i+1}),[],[1 i/iters i/iters],'filled','HandleVisibility','off')
    scatter(lda_d1(cur_mixed{i+1}),lda_d2(cur_mixed{i+1}),[],[1 i/iters 1],'filled','HandleVisibility','off')
    %scatter(lda_d1(cur_null{i+1}),lda_d2(cur_null{i+1}),[],[i/iters i/iters i/iters],'filled','HandleVisibility','off')
end


axis manual
scalars=-10:.1:10;
unit_lda1=nan(length(scalars),1);
unit_lda2=nan(length(scalars),1);
mean_vect=mean(X(som,:),1); 
rand_vect=mean_vect(randperm(length(mean_vect)));

for i = 1:length(scalars)
    unit_vect=ones(size(X,2),1).*scalars(i);
    mean_vect=rand_vect'.*scalars(i); 
    unit_lda1(i)=dot(unit_vect',w(:,1)); 
    unit_lda2(i)=dot(unit_vect',w(:,2));
    mean_lda1(i)=dot(mean_vect',w(:,1)); 
    mean_lda2(i)=dot(mean_vect',w(:,2));
end


plot(unit_lda1,unit_lda2,'black')
plot(mean_lda1,mean_lda2,'green')