function xdetrend = detrends(x, mode)
% x 是需要处理的光谱
% mode 是采用的多项式次数
    if nargin < 2
        mode = 1;
    end
    xdetrend = detrend(x', mode)';
end

