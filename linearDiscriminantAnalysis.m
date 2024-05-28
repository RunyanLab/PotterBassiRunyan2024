% A simple wrapper for MATLAB's linear discriminant analysis functionality.
%
% Inputs: 
%
%   input - a matrix of feature vectors.  Each row is a sample.  Should by 
%   S by D, where S is the number of samples and D is the dimensionality of
%   the data. 
%
%   labels - a vector of class labels.  Should be of length S. 
%
%
% Outputs: 
%
%   w - A D by C-1 matrix, where C is the number of classes giving the
%   projection vectors. If the dimensionality of the data is less than C,
%   then C-1 will equal the dimensionality of the original data minus one. 
%
%   objVal - value of the discriminant objective for the optimal projection
%
%   eigVls - Eigenvalues from the generalized eigenvalue problem on the
%   scatter matrices. Roughly represents the "importance" of each
%   projection dimension
%
% Adam Smoulder, 12/12/18 (edit 5/7/19)
%
function [w, objVal, eigVls] = linearDiscriminantAnalysis(input, labels)

% MATLAB's LDA/MDA; we just use this to quickly get the scatter matrices
discMdl = fitcdiscr(input,labels);%,'discrimType','diagLinear'); 
sB = discMdl.BetweenSigma;
sW = discMdl.Sigma;

% Solve the generalized eigenvalue problem on the scatter matrices; this is 
% LDA/MDA's solution
[LDAVecs, eigVls] = eig(sB, sW);
% these are in reverse order for some reason... let's fix that
[eigVls, order] = sort(diag(eigVls),'descend');
LDAVecs = LDAVecs(:,order);
%sorted_labels=labels(order);
% find the rank (# labels - 1 or #dims - 1) and extract w accordingly
m = min(length(unique(labels)), size(input,2));
w = LDAVecs(:, 1:(m-1));
w = w./sqrt(sum(w.^2));  % Normalize it

% MATLAB doesn't provide this, so we have to find it ourselves
objVal = det(w'*sB*w)/det(w'*sW*w); 
return
