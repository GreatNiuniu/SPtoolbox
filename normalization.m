% 该函数用于光谱的“归一化”预处理（采用的是单位矢量归一化）
% 预处理后的光谱数据都有相同的长度，其长度为1
function xed = normalization(x, mode)
    % x   是输入光谱
    % xed 变换后的光谱
    % mode 是规范化的模式
    % The following normalization mode are available:
    %     1. Area normalization;
    %     2. Unit vector normalization;
    %     3. Mean normalization;
    %     4. Range normalization;
    %     5. Maximum normalization;

    [m, n] = size(x);
    if nargin < 2
        mode = 2;
    end
    for i = 1 : m 
        % this mode sometimes will generate sum(x(i,:), 2)==0
        if mode == 1
            xed(i,:) = x(i,:)/sum(x(i,:), 2);
        end
        if mode == 2
            xed(i,:) = (x(i,:))/norm(x(i,:));
        end
        if mode == 3
            xed(i,:) = (x(i,:))/mean(x(i,:));
        end
        if mode == 4
            xed(i,:) = (x(i,:))/(max(x(i,:))-min(x(i,:)));
        end
        if mode == 5
            xed(i,:) = (x(i,:))/max(x(i,:));
        end
    end
end
