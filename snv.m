% 该函数用于对光谱进行SVN校正
function xed = snv(x)
% SNV is a transformation usually applied to spectroscopic data, to remove scatter effects 
% by centering and scaling each individual spectrum (i.e. a sample-oriented standardization).
% It is sometimes used in combination with de-trending (DT) to reduce multicollinearity,
% baseline shift and curvature in spectroscopic data.
xed = normalize(x,2);
xmean = mean(x,1);
xstd = std(x,[],1);
    
end