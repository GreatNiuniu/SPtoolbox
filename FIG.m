% @Author: Wang Shenghao
% @Date: 2020-09-24 08:42:18
% @Last Modified by:   Wang Shenghao
% @Last Modified time: 2020-09-24 08:42:18

classdef FIG 
    % Full infromation generator (FIG) is used for giving all combination experiment scheme
    % Parameters of this class constructor: MethodName= ["nm", "de", "df", "sm", "ct"]
    % denotes normlization, detrend, differentiation, smoothing and correction.
    % User should give some abbreviation of above preprocessing method names, for example
    % fig = FIG(struct("MethodName", ["df", "ct", "nm"], "ShowModelling", 0))

    properties (GetAccess = 'public', SetAccess = 'public')
        % abbreviation of above preprocessing method name
        MethodName = ["nm", "de", "df", "sm", "ct"];
        
        MethodList = struct('sm', struct(...
        'sm1', struct('fun', 'savitzkyGolayFilt', 'para', [2, 0, 7]), ...
        'sm2', struct('fun', 'savitzkyGolayFilt', 'para', [3, 0, 7]), ...
        'sm3', struct('fun', 'savitzkyGolayFilt', 'para', [2, 0, 15]), ...
        'sm4', struct('fun', 'savitzkyGolayFilt', 'para', [3, 0, 15]), ...
        'sm5', struct('fun', 'savitzkyGolayFilt', 'para', [2, 0, 21]), ...
        'sm6', struct('fun', 'savitzkyGolayFilt', 'para', [3, 0, 21]) ...
        ), ...
        'df', struct(...
        'df1', struct('fun', 'savitzkyGolayFilt', 'para', [2, 1, 7]), ...
        'df2', struct('fun', 'savitzkyGolayFilt', 'para', [2, 1, 15]), ...
        'df3', struct('fun', 'savitzkyGolayFilt', 'para', [2, 1, 21]), ...
        'df4', struct('fun', 'savitzkyGolayFilt', 'para', [2, 2, 7]), ...
        'df5', struct('fun', 'savitzkyGolayFilt', 'para', [2, 2, 15]), ...
        'df6', struct('fun', 'savitzkyGolayFilt', 'para', [2, 2, 21]), ...
        'df7', struct('fun', 'savitzkyGolayFilt', 'para', [3, 1, 7]), ...
        'df8', struct('fun', 'savitzkyGolayFilt', 'para', [3, 1, 15]), ...
        'df9', struct('fun', 'savitzkyGolayFilt', 'para', [3, 1, 21]), ...
        'df10', struct('fun', 'savitzkyGolayFilt', 'para', [3, 2, 7]), ...
        'df11', struct('fun', 'savitzkyGolayFilt', 'para', [3, 2, 15]), ...
        'df12', struct('fun', 'savitzkyGolayFilt', 'para', [3, 2, 21]) ...
        ), ...
        'nm', struct(...
        'nm1', struct('fun', 'normalization', 'para', 2), ...
        'nm2', struct('fun', 'normalization', 'para', 4) ...
        ), ...
        'ct', struct(...
        'ct1', struct('fun', 'msc', 'para', []), ...
        'ct2', struct('fun', 'normalize', 'para', 2) ...
        ), ...
        'de', struct(...
        'de1', struct('fun', 'detrends', 'para', 1), ...
        'de2', struct('fun', 'detrends', 'para', 2), ...
        'de3', struct('fun', 'detrends', 'para', 3)...
        ));

    end

    properties (GetAccess = 'public', SetAccess = 'private')
        % attributes
        % Here, configure the necessary parameter methodlist for FIOs runtime.
        % This parameter stores the abbreviations of all preprocessing methods
        % and their corresponding functions. Users can modify these parameters as needed


    end

    methods
        % constructor
        function obj = FIG(p1, p2)
            obj.MethodName = p1;
            obj.MethodList = p2;
        end

        function AllScheme = generate(obj)
            % Giving all combination experiment scheme

            MethodNameUserDefined = obj.MethodName;
            % MethodNameUserDefined has the method name list user used
            m           = CreateMethodIndex(size(MethodNameUserDefined, 2));
            SchemeClass = m.getMethodIndex();
            n           = size(SchemeClass, 1);
            AllScheme   = table();

            AllScheme(1,1) = str2cell("");

            for i = 2:n
                % Get a special processing order of preprocessing methods
                MethodClass       = SchemeClass(i, :);

                MethodIdxSelected = MethodClass ~= 0;
                MethodNameSelected = MethodNameUserDefined(MethodIdxSelected);
                
                % sort MethodNameSelected by MethodClass: 1 means the first
                % used preprocesssing method, 2 means the second, ect..
                MethodClass((find(MethodClass == 0))) = [];
                MethodNameSelected = MethodNameSelected(:, MethodClass);
                
                MethodSelectedNumber = length(MethodNameSelected);
                MethodSeed = zeros(1, MethodSelectedNumber);

                for j = 1:MethodSelectedNumber
                    NameIdx = MethodNameSelected(j);

                    switch NameIdx
                        case 'sm'
                            MethodSeed(j) = length(fieldnames(obj.MethodList.sm));
                        case 'df'
                            MethodSeed(j) = length(fieldnames(obj.MethodList.df));
                        case 'nm'
                            MethodSeed(j) = length(fieldnames(obj.MethodList.nm));
                        case 'ct'
                            MethodSeed(j) = length(fieldnames(obj.MethodList.ct));
                        case 'de'
                            MethodSeed(j) = length(fieldnames(obj.MethodList.de));
                    end

                end

                MethodSubclassIdx = fullfact(MethodSeed);
                [rn1, cn1]        = size(MethodSubclassIdx);
                MethodSubclass    = table();
                for k = 1 : rn1
                    for h = 1 : cn1
                        MethodSubclass(k,h) = str2cell(strcat(MethodNameSelected(h), num2str(MethodSubclassIdx(k,h))));

                    end
                end
                
                [rm, cm] = size(MethodSubclass);
                ra       = size(AllScheme,1);
                for h = 1 : rm
                    for x = 1 : cm
                        AllScheme(ra + h, x) = MethodSubclass(h, x);
                    end
                end
            end

        end

    end

end
