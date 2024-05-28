function [subY] = sub_sqrt_y(Y,Nc);
  
Y = sqrt(Y);

neurons = 1:size(Y,1);
if Nc==0
    Nc=size(Y,1); 
end

neurons = neurons(randperm(size(Y,1)));
subY=Y(neurons(1:Nc),:);

end

