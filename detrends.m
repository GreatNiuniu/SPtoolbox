function xdetrend = detrends(x, mode)
% x ����Ҫ����Ĺ���
% mode �ǲ��õĶ���ʽ����
    if nargin < 2
        mode = 1;
    end
    xdetrend = detrend(x', mode)';
end

