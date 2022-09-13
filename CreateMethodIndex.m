classdef CreateMethodIndex
    
    properties (GetAccess = 'public', SetAccess = 'public')
        % parameters
        methodNumber; % Number of components to keep.
     end
    
    properties (GetAccess = 'public', SetAccess = 'private')
        % attributes
        methodIndex
    end
    
    methods
        % constructor
        function obj = CreateMethodIndex(params)
            obj.methodNumber = params;
        end
        
        % 该方法返回预处理方法的优化组合次序索引（包括选择哪种预处理方法
        % 以及预处理方法参与计算的次序）
        function methodIndex = getMethodIndex(obj)
           basicIndex = ff2n(obj.methodNumber);
           n = size(basicIndex);
           methodIndex = [];
           for i = 1 : n
              subIndex = basicIndex(i,:);
              %subIndex = [1,1,1,0];
              temp = sum(subIndex);
              if temp <= 1
                  methodIndex = [methodIndex; basicIndex(i,:)];
              else
                  v = 1:temp;
                  p = perms(v);
                  whereNoZero = subIndex==1;
                  for j = 1: size(p)
                      bake = subIndex;
                      bake(whereNoZero) = p(j, :);
                      methodIndex = [methodIndex; bake];
                  end
              end
           end          
        end
    end
end
