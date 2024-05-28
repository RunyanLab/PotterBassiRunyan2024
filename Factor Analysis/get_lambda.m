function[la,LLopt] = get_lambda(Y,zDimList,numFolds,M)

dim = crossvalidate_fa(Y, 'zDimList', zDimList,'showPlots',false,'numFolds',numFolds);
sumLL=[dim.sumLL];
LLopt= find(sumLL== max(sumLL),1);
L=dim(M).estParams.L;
LL=L*L';
[V,D]=eig(LL);
la=diag(D);

la=sort(la,'descend');
la=la(1:M);
end

