function[beta_similarity,angle,mean_vect]=get_beta_similarity(type,svm,trials,response,som,pv)

%% 
b=svm.Beta;

if strcmp(type,'mean')
    comparison_vect=mean(trials,1);%
elseif strcmp(type,'unit')
    unit_vector=ones(1,length(b)); 
end

beta_similarity=cosineSimilarity(b',comparison_vect);
CosTheta = max(min(dot(b',comparison_vect)/(norm(b')*norm(comparison_vect)),1),-1);
angle = abs(90-real(acosd(CosTheta)));

%% Calculate difference in magnitudes of mean vectors between SOM and PV events 
ntrials=length(response); 
somtrials=1:length(som);
pvtrials=ntrials-length(pv):ntrials; 

%mean_som=mean(trials(somtrials,:)); 
%mean_pv=mean(trials(pvtrials,:)); %

%mean_vect=norm(mean_som)-norm(mean_pv); 
mean_vect=[]; 
%%

