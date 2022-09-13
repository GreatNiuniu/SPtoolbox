
function [Model, explained] = pcaregress(X, Y, pc)

    [n,p] = size(X);
    [coeff,score,latent,tsquared,explained,mu] = pca(X,'Economy',false);
    betaPCR = regress(Y-mean(Y), score(:,1:pc));
    betaPCR = coeff(:,1:pc)*betaPCR;
    betaPCR = [mean(Y) - mean(X)*betaPCR; betaPCR];
    yfitPCR = [ones(n,1) X]*betaPCR;


    Model = betaPCR;
end