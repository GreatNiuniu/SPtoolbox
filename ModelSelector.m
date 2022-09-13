% @Author: Wang Shenghao
% @Date: 2020-09-25 12:48:00
% @Last Modified by:   Wang Shenghao
% @Last Modified time: 2020-09-24 08:42:18

classdef ModelSelector < BaseOptimizer
    % ModelSelector is used for finding available models based on given Performance (with n times (row),
    %and m kinds of combination of preprocessing methods (column) )

    properties (GetAccess = 'public', SetAccess = 'public')
        % parameters

    end

    properties (GetAccess = 'public', SetAccess = 'private')
        % Performance
        RMSECV
        LV
        RMSEC
        RMSEV
        RC2
        RV2
        yfitCal
        yfitVal
        yErrorCal
        yErrorVal
    end

    methods

        function OptimalPerformance = performanceRandomGrouping(obj, ModelNumber, Ref, Scheme)
            % this function is used for giving the selected model with avaible performance
            % ModelNumber is the number of the selected models
            % Ref is the reference of sorting, the values can be 'RMSEC', or 'RMSEV'
            if ModelNumber > size(obj.RMSEC, 2)-1
                ModelNumber = size(obj.RMSEC, 2)-1;
            end
            
            % get raw spectra performance
            rawSpectraRMSECV = obj.RMSECV(:, 1);
            rawSpectraRMSEC = obj.RMSEC(:, 1);
            rawSpectraRMSEV = obj.RMSEV(:, 1);
            rawSpectraLV = obj.LV(:, 1);

            rmsecv = obj.RMSECV(:, 2:end);
            rmsec = obj.RMSEC(:, 2:end);
            rmsev = obj.RMSEV(:, 2:end);
            lv = obj.LV(:, 2:end);
            AllCombinationName = Scheme(2:end, :);
            RawSpectraName = Scheme(1, :);

            if Ref == "median"
                [~, idx] = sort(median(rmsecv));
            elseif Ref == "mean"
                [~, idx] = sort(mean(rmsecv));
            end
            RMSECVSorted = rmsecv(:, idx);
            RMSECSorted = rmsec(:, idx);
            RMSEVSorted = rmsev(:, idx);
            LVSorted = lv(:, idx);
            SeletedName = AllCombinationName(idx, :);
            % 选出性能最优的前ModelNumber个模型
            SeletedIdx = idx(1:ModelNumber);
            % 选出性能最差的前ModelNumber个模型
            SeletedIdx2 = idx(end-ModelNumber:end);
            SeletedIdx = [SeletedIdx SeletedIdx2];

            OptimalPerformance.RMSECV = [rawSpectraRMSECV, RMSECVSorted(:, 1:ModelNumber), RMSECVSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RMSEC = [rawSpectraRMSEC, RMSECSorted(:, 1:ModelNumber), RMSECSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RMSEV = [rawSpectraRMSEV, RMSEVSorted(:, 1:ModelNumber), RMSEVSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.LV = [rawSpectraLV, LVSorted(:, 1:ModelNumber), LVSorted(:, end-ModelNumber+1:end)];

            OptimalPerformance.MethodsName = [RawSpectraName; SeletedName(1:ModelNumber, :);SeletedName(end-ModelNumber:end, :)];
            OptimalPerformance.idx = [1, SeletedIdx + 1];
            
            figure('Position',[100,100,600,600])
            tiledlayout(4,1);
            
            subplot(4,1,1)
            boxplot(OptimalPerformance.RMSECV)
            set(get(gca, 'XLabel'), 'String', ('Group'));
            set(get(gca, 'YLabel'), 'String', ('RMSECV'));
            hold on
            plot(mean(OptimalPerformance.RMSECV), 'r.-')
            hold off

            subplot(4,1,2)
            boxplot(OptimalPerformance.RMSEC)
            set(get(gca, 'XLabel'), 'String', ('Group'));
            set(get(gca, 'YLabel'), 'String', ('RMSEC'));
            hold on
            plot(mean(OptimalPerformance.RMSEC), 'r.-')
            hold off

            subplot(4,1,3)
            boxplot(OptimalPerformance.RMSEV)
            set(get(gca, 'XLabel'), 'String', ('Group'));
            set(get(gca, 'YLabel'), 'String', ('RMSEV'));
            hold on
            plot(mean(OptimalPerformance.RMSEC), 'r.-')
            hold off

            subplot(4,1,4)
            boxplot(OptimalPerformance.LV)
            set(get(gca, 'XLabel'), 'String', ('Group'));
            set(get(gca, 'YLabel'), 'String', ('LV'));
            hold on
            plot(mean(OptimalPerformance.LV), 'r.-')
            hold off

            [~, ~, stats1] = anova1(OptimalPerformance.RMSECV);
            c1 = multcompare(stats1);
            [~, ~, stats2] = anova1(OptimalPerformance.RMSEC);
            c2 = multcompare(stats2);
            [~, ~, stats3] = anova1(OptimalPerformance.RMSEV);
            c3 = multcompare(stats3);
            OptimalPerformance.TestRMSECResult = c1;
            OptimalPerformance.TestRMSECResult = c2;
            OptimalPerformance.TestRMSECResult = c3;
        end

        function OptimalPerformance = performanceCustomerGrouping(obj, ModelNumber, Scheme)
            % this function is used for giving the selected model with avaible performance
            % ModelNumber is the number of the selected models
            % Ref is the reference of sorting, the values can be 'RMSEC', or 'RMSEV'
            % OptimalPerformance将会返回前ModelNumber个最优模型性能指标和倒数ModelNumber个最差模型指标
            if ModelNumber > size(obj.RMSEC, 2)-1
                ModelNumber = size(obj.RMSEC, 2)-1;
            end
            
            % get raw spectra performance
            rawSpectraRMSECV = obj.RMSECV(:, 1);
            rawSpectraRMSEC = obj.RMSEC(:, 1);
            rawSpectraRMSEV = obj.RMSEV(:, 1);
            rawSpectraLV = obj.LV(:, 1);
            rawSpectraRC2 = obj.RC2(:,1);
            rawSpectraRV2 = obj.RV2(:,1);

            rmsecv = obj.RMSECV(:, 2:end);
            rmsec = obj.RMSEC(:, 2:end);
            rmsev = obj.RMSEV(:, 2:end);
            lv = obj.LV(:, 2:end);
            rc2 = obj.RC2(:, 2:end);
            rv2 = obj.RV2(:, 2:end);
            AllCombinationName = Scheme(2:end, :);
            RawSpectraName = Scheme(1, :);

            % 寻找综合指标最好的点
            a1 = 0;
            a2 = 1;
            a3 = 1;
            [comIndexSorted, idx] = sort(a1*rmsecv + a2*rmsec + a3*rmsev);
            RMSECVSorted = rmsecv(:, idx);
            RMSECSorted = rmsec(:, idx);
            RMSEVSorted = rmsev(:, idx);
            RC2Sorted = rc2(:, idx);
            RV2Sorted = rv2(:, idx);
            LVSorted = lv(:, idx);
            SeletedName = AllCombinationName(idx, :);
            
            % 选出性能最优的前ModelNumber个模型
            SeletedIdx = idx(1:ModelNumber);
            % 选出性能最差的前ModelNumber个模型
            SeletedIdx2 = idx(end-ModelNumber:end);
            SeletedIdx = [SeletedIdx SeletedIdx2];

            OptimalPerformance.comIndexSorted = [ rawSpectraRMSECV*a1 + rawSpectraRMSEC*a2 + rawSpectraRMSEV*a3,comIndexSorted(:, 1:ModelNumber), comIndexSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RMSECV = [rawSpectraRMSECV, RMSECVSorted(:, 1:ModelNumber), RMSECVSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RMSEC = [rawSpectraRMSEC, RMSECSorted(:, 1:ModelNumber), RMSECSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RMSEV = [rawSpectraRMSEV, RMSEVSorted(:, 1:ModelNumber), RMSEVSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.LV = [rawSpectraLV, LVSorted(:, 1:ModelNumber), LVSorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RC2 = [rawSpectraRC2, RC2Sorted(:, 1:ModelNumber), RC2Sorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.RV2 = [rawSpectraRV2, RV2Sorted(:, 1:ModelNumber), RV2Sorted(:, end-ModelNumber+1:end)];
            OptimalPerformance.MethodsName = [RawSpectraName; SeletedName(1:ModelNumber, :);SeletedName(end-ModelNumber:end, :)];
            OptimalPerformance.idx = [1, SeletedIdx + 1];
            
        end

        function fetch(obj, Performance)

            [rn, cn] = size(Performance);
            rmsecv   = zeros(rn, cn);
            rmsec    = zeros(rn, cn);
            rmsev    = zeros(rn, cn);
            lv       = zeros(rn, cn);
            rc2      = zeros(rn, cn);
            rv2      = zeros(rn, cn);

            for i = 1:rn

                parfor j = 1:cn
                    rmsecv(i, j) = Performance{i, j}.PerformanceCal.RMSECV;
                    rmsec(i, j)  = Performance{i, j}.PerformanceCal.RMSE;
                    rmsev(i, j)  = Performance{i, j}.PerformanceVal.RMSE;
                    lv(i, j)     = Performance{i, j}.PerformanceCal.LV;
                    rc2(i, j)    = Performance{i, j}.PerformanceCal.R2;
                    rv2(i, j)    = Performance{i, j}.PerformanceVal.R2;
                end

                dis = sprintf("\n------>>>>>>>>> The performance of the %dth group has been fetched<<<<<<------", i);
                fprintf(dis)
            end

            obj.RMSECV = rmsecv;
            obj.RMSEC  = rmsec;
            obj.RMSEV  = rmsev;
            obj.LV     = lv;
            obj.RC2    = rc2;
            obj.RV2    = rv2;
        end

        function plotTrainingPerformance(obj)

            if size(obj.RMSEC, 2)>10
                x = round(linspace(1, size(obj.RMSEC, 2), 9));
            else
                x = 1:size(obj.RMSEC, 2);
            end

            figure('Position',[100,100,1000,600])              
            subplot(3,1,1)
            hold on
            lw = 0.7;
            yyaxis left
            p1 = plot(mean(obj.RMSECV), 'b-','LineWidth',lw);
            [min_value, min_index] = min(mean(obj.RMSECV));
            plot(xlim,[min_value, min_value],'k--')
            plot([min_index, min_index],ylim,'k--')
            yyaxis right
            p2 = plot(std(obj.RMSECV), 'r-','LineWidth',lw);
            %annotation('textarrow',min_value, min_index,'String',strcat(mat2str(min_value) , mat2str(min_index)))
            %annotation('textarrow', [0.5 0.5 .5 .5],'String','ok')
            %x = [0.3 0.5];
            %y = [0.6 0.5];
            %annotation('textarrow',x,y,'String','y = x ')
            hold off
            legend([p1,p2],'Mean of RMSECV', 'Std. of RMSECV')
            xticks(x)
            xticklabels(x)
            title('Training')
            axis tight
            
            subplot(3,1,2)
            hold on
            yyaxis left
            plot(mean(obj.RC2), 'r-','LineWidth',lw)           
            plot(mean(obj.RV2), 'b-','LineWidth',lw)
            yyaxis right
            comIndex = mean(obj.RC2+obj.RV2);
            plot(comIndex, 'Color',[0.4660 0.6740 0.1880],'LineWidth',lw)
            plot(xlim,[max(comIndex), max(comIndex)],'k--')
            [~, max_index] = max(comIndex);
            plot([max_index, max_index],[0 2],'k--')
            hold off
            legend('RC^2', 'RV^2', 'RI^2')
            xticks(x)
            xticklabels(x)
            axis tight

            subplot(3,1,3)
            plot(mean(obj.LV), 'b-','LineWidth',lw)
            xticks(x)
            xticklabels(x)
            set(get(gca, 'XLabel'), 'String', 'Group');
            set(get(gca, 'YLabel'), 'String', 'LV');
            axis tight

        end
        function plotTestingPerformance(obj, titleName)

            figure('Position',[100,100,1000,600])

            subplot(3,1,1)
            hold on
            lw = 0.7;
            plot(obj.RMSEC, 'r-','LineWidth',lw)
            plot(obj.RMSEV, 'b-','LineWidth',lw)           
            plot(obj.RMSECV, '-','LineWidth',lw, 'Color', [0.4660 0.6740 0.1880] )    
            %plot(xlim,[min(obj.RMSEC), min(obj.RMSEC)],'r--','LineWidth',lw)
            %plot(xlim,[min(obj.RMSEV), min(obj.RMSEV)],'b--','LineWidth',lw)
            plot(xlim,[min(obj.RMSECV), min(obj.RMSECV)],'k--','LineWidth',lw )
            a1 = 1;
            a2 = 0;
            a3 = 0;
            [~, min_index] = min(a1*obj.RMSECV+a2*obj.RMSEC+a3*obj.RMSEV);
            plot([min_index, min_index],ylim,'k--','LineWidth',lw)
            hold off
            legend('RMSET', 'RMSEP','RMSECV')
            title(titleName)
            
            subplot(3,1,2)
            hold on
            yyaxis left
            p1 = plot(obj.RC2, 'r-','LineWidth',lw);
            p2 = plot(obj.RV2, 'b-','LineWidth',lw);
            %plot(xlim,[max(obj.RC2), max(obj.RC2)],'r--')
            %plot(xlim,[max(obj.RV2), max(obj.RV2)],'b--')
            yyaxis right
            a1 = 0;
            a2 = 1;
            a3 = 1;
            [max_value, max_index] = max(a2*obj.RC2+a3*obj.RV2);
            yyy = [0 2];
            plot([max_index, max_index],yyy,'k--','LineWidth',lw)
            plot(xlim,[max_value, max_value],'k--','LineWidth',lw)
            p3 = plot(a2*obj.RC2+a3*obj.RV2, '-','LineWidth',lw, 'Color',[0.4660 0.6740 0.1880]);
            legend([p1,p2,p3],'RT^2', 'RP^2','RI^2')
            
            
            hold off

            subplot(3,1,3)
            plot(obj.LV,'b-')
            set(get(gca, 'YLabel'), 'String', 'LV');
            set(get(gca, 'XLabel'), 'String', 'Group');

        end
    end

end
