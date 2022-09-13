
classdef PCR < PLSR
    methods

        function [Model, Performance] = buildModel(obj, Data)
            % Fit the model with X and y.   X is the spectra data, and y is the object
            X = Data.spectra;
            y = Data.y;
            [nsample, ~] = size(X);

            % Search the best component base on the F-test or the first minimum cross
            % validation value
            bestComponent = 1;

            if obj.LVMode == "MinCV"
                % t-test?
                yfitCal = zeros(nsample, obj.MaxLV);
                yError = zeros(nsample, obj.MaxLV);

                if obj.CVMode == "kfold"
                    cv = cvpartition(nsample, 'KFold', obj.FoldNumber);
                elseif obj.CVMode == "loo"
                    cv = cvpartition(nsample, 'KFold', nsample);
                end

                for compNumber = 1:obj.MaxLV

                    for i = 1:cv.NumTestSets
                        trIdx = cv.training(i);
                        teIdx = cv.test(i);
                        [BETAtemp] = pcaregress(X(trIdx, :), y(trIdx, :), compNumber);
                        tempData.spectra = X(teIdx, :);
                        tempData.y       = y(teIdx, :);
                        tempPerformance = obj.predict(BETAtemp,tempData);
                        %[~, ~, yfitCal(teIdx, compNumber), yError(teIdx, compNumber)] = obj.predict(BETAtemp,tempData);
                        yfitCal(teIdx, compNumber) = tempPerformance.yfit;
                        yError(teIdx, compNumber)  = tempPerformance.yError;
                    end

                end


                MSECV = zeros(1, obj.MaxLV);

                for i = 1:obj.MaxLV
                    MSECV(i) = sum(yError(:, i).^2) / nsample;
                end

                bestComponent = 1;

                for i = 2:obj.MaxLV

                    if MSECV(i) >= MSECV(i -1)
                        bestComponent = i;
                    end

                end

            elseif obj.LVMode == "Ftest"
                % using F-test for testing whether the error is significantly reduced
                yfitCal = zeros(nsample, obj.MaxLV);
                yError = zeros(nsample, obj.MaxLV);

                if obj.CVMode == "kfold"
                    cv = cvpartition(nsample, 'KFold', obj.FoldNumber);
                elseif obj.CVMode == "loo"
                    cv = cvpartition(nsample, 'KFold', nsample);
                end

                for compNumber = 1:obj.MaxLV

                    for i = 1:cv.NumTestSets
                        trIdx = cv.training(i);
                        teIdx = cv.test(i);
                        [BETAtemp] = pcaregress(X(trIdx, :), y(trIdx, :), compNumber);
                        tempData.spectra = X(teIdx, :);
                        tempData.y       = y(teIdx, :);
                        tempPerformance = obj.predict(BETAtemp,tempData);
                        %[~, ~, yfitCal(teIdx, compNumber), yError(teIdx, compNumber)] = obj.predict(BETAtemp,tempData);
                        yfitCal(teIdx, compNumber) = tempPerformance.yfit;
                        yError(teIdx, compNumber)  = tempPerformance.yError;
                    end

                end

                MSECV = zeros(1, obj.MaxLV);
                % MSECV(1) corresponding to lv = 1
                for i = 1:obj.MaxLV
                    MSECV(i) = sum(yError(:, i).^2) / nsample;
                end
                %yError2 = yError.^2;
                yError2 = yError;
                test = zeros(1, obj.MaxLV - 1);

                for i = 1:obj.MaxLV - 1
                    test(i) = vartest2(yError2(:, i), yError2(:, i + 1));
                end
                [~, pctvarTemp] = pcaregress(X, y, obj.MaxLV - 1);
                pctvar = pctvarTemp;
                
                
                for i = 1:obj.MaxLV-1
                    bestComponent = i;
                    pctvarSum = sum(pctvar(1:i));
                    
                    if pctvarSum > 0.80
                        if test(i) == 0
                            break;
                        end
                        
                    else
                        continue;
                    end                    

                end

            end

            cum_pctvar = cumsum(pctvar);
            % PRESS
            for i = 1:obj.MaxLV
                RSS(i) = sum(yError(:, i).^2);
            end
            PRESS = cumsum(RSS);
            for i = 2 : obj.MaxLV
                if RSS(i)/RSS(i-1)>0.9
                    break;
                end
            end
            bestComponent2 = i;
            bc = min(bestComponent,bestComponent2);

            [BETA, PCTVAR] = pcaregress(X, y, bc);
            pf   = obj.predict(BETA, Data);
            
            Model              = BETA;
            
            Performance.RMSECV  = (MSECV(bc))^.5;
            Performance.PCTVar = PCTVAR;
            Performance.RMSE   = pf.RMSE;
            Performance.R2     = pf.R2;
            Performance.LV     = bc;
            Performance.yfit   = pf.yfit;
            Performance.yError = pf.yError;

        end
    end
end