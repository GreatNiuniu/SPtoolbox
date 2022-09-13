
classdef ModelBase < handle
    % Base class for all model in FIOS.
    
    properties (GetAccess = 'public', SetAccess = 'public')
 
    end
    
    methods
        % get parameter names for the classs
        function names = get_param_names(obj)
            names = fieldnames(obj);
        end
        
        % get parameters
        function params = get_params(obj)
            params = struct;
            for fn = fieldnames(obj)'
                params.(fn{1}) = obj.(fn{1});
            end
        end
        
        % set parameters
        function set_params(obj,params)
            if (nargin > 0) % copy valid parameters
                for fn = fieldnames(params)'
                    if ismember(fn{1},fieldnames(obj))
                        values = params.(fn{1});
                        obj.(fn{1}) = values;
                    else
                        warning('Unknown parameter: %s.',fn{1});
                    end
                end
            end
        end
    end

    methods (Abstract)
        % method for building model
        [Model, Performance]  = buildModel(obj, Xdata, ydata);
        Reuslt = predict(Model, Xdata, ydata);
    end
end
