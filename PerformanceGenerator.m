% @Author: Wang Shenghao
% @Date: 2020-09-25 12:48:00
% @Last Modified by:   Wang Shenghao
% @Last Modified time: 2020-09-24 08:42:18

classdef PerformanceGenerator
    % Performance calculator  is used for giving all performance of given data

    properties (GetAccess = 'public', SetAccess = 'public')
        % parameters

    end

    properties (GetAccess = 'public', SetAccess = 'private')
        

    end

    methods
        

        function Performance = generate(~, DataCal, DataVal, Scheme, fig)

            PLSR = PLSRegression();
            tf = Transform();
            
            if nargin == 2
                [~, Performance] = PLSR.buildModel(DataCal);
                return;
            end
            
            if nargin == 5
                [DataProcessed, addtionalInfo] = tf.transform(DataCal, Scheme, fig);
                [Model, PerformanceCal] = PLSR.buildModel(DataProcessed);
                DataValProcessed = tf.transform2(DataVal, Scheme, fig, addtionalInfo);
                PerformanceVal   = PLSR.predict(Model, DataValProcessed);

                Performance.PerformanceCal = PerformanceCal;
                Performance.PerformanceVal = PerformanceVal;
                Performance.MethodName     = Scheme;
            end

        end

    end

end
