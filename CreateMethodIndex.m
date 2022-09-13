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
        
        % �÷�������Ԥ���������Ż���ϴ�������������ѡ������Ԥ������
        % �Լ�Ԥ�������������Ĵ���
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
