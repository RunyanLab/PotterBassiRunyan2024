load fisheriris
inds = ~strcmp(species,'setosa');
X = meas(inds,2:3);
y = species(inds);

SVMModel = fitcsvm(X,y)

classOrder = SVMModel.ClassNames
sv = SVMModel.SupportVectors;
figure
hold on 
gscatter(X(:,1),X(:,2),y)
plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
hold on

hold on 
plot ([0 SVMModel.Beta(1)*2],[0 SVMModel.Beta(2)*2])
xline(0)
yline(0)

x1vals=linspace(min(X(:,1)),max(X(:,1)));

svm=SVMModel;
x2fun =@(x1) -svm.Beta(1)/svm.Beta(2) * x1 - svm.Bias/svm.Beta(2);
x2vals = x2fun(x1vals);

plot(x1vals,x2vals,'--','HandleVisibility','off')
legend('Data1','Data2','Support Vector')

%%

betavect=([SVMModel.Bias/svm.Beta(2) SVMModel.Beta(2)]-[SVMModel.Bias SVMModel.Beta(1)]);

%%

scatter(svm.Beta(1),svm.Beta(2))


%%

hypervect=[x1vals(2) x2vals(2)]-[x1vals(1) x2vals(1)];

%%
cosineSimilarity(svm.Beta',hypervect)

