classdef SP < handle
    %SP ?????Ptoolbox????????????????????????????????

    properties (SetAccess = protected, GetAccess = protected)

    end

    properties (SetAccess = public)
        CalibrationModel
        SamplingMethod
        SamplingRatio
        MethodClass
        MethodList
        Data
        MethodCombination
        % PerformanceSta is the performance result with random sampling
        PerformanceSta
        ModelSta
        % PerformanceSta is the performance result with special sampling after random sampling
        PerformanceSta2
        ModelSta2
        % Preprocessed method selected
        OptimalProcessingName
        % Preprocessed method Index selected
        OptimalProcessingIndex
        % OptimalResult is a cell with k * runtime
        OptimalResult
    end

    methods

        function obj = SP(methodlist, specdata, methodclass, samplemode, model)

            if nargin <= 1
                error("At least two parameters are required!");
            elseif nargin == 2
                obj.MethodList = methodlist;
                obj.Data = specdata;
                obj.MethodClass = ["df", "ct"];
                obj.SamplingMethod = "Rand";
                obj.CalibrationModel = PLSR();
            elseif nargin == 3
                obj.MethodList = methodlist;
                obj.Data = specdata;
                obj.MethodClass = methodclass;
                obj.SamplingMethod = "Rand";
                obj.CalibrationModel = PLSR();
            elseif nargin == 4
                obj.MethodList = methodlist;
                obj.Data = specdata;
                obj.MethodClass = methodclass;
                obj.SamplingMethod = samplemode;
                obj.CalibrationModel = PLSR();
            elseif nargin == 5
                obj.MethodList = methodlist;
                obj.Data = specdata;
                obj.MethodClass = methodclass;
                obj.SamplingMethod = samplemode;
                obj.CalibrationModel = model;
            end

        end

        function autorun(obj)
            fprintf("\n生成预处理方案")
            obj.getMethodCombination();

            fprintf("\n计算模型性能")
            obj.getPerformance("rand", 10);

            fprintf("\n推荐的预处理算法分别为:");
            obj.OptimalProcessingName

            fprintf("\n获取最优预处理方法对应的性能和模型")
            obj.buildModel("rank",10);

            % 在这里添加自定义autorun代码
            
        end

        % plot relation condition of processed spectra
        function plotR2(obj, idx, idy, w)
            % 绘制第idx次独立运行的idy个预处理后的光谱和性质相关系统图
            m = length(idy);

            if m > 20
                error("要输出的图形过多，请减少第二个参数的长度！")
            end

            OriginalXLength = length(w);
            figure()
            fc = 'abcdefghigklmnopqrstuvwxyz';

            for i = 1:m
                CurrentXLength = size(obj.OptimalResult{idx, idy(i)}.DataProcessed.spectra, 2);
                XLengthDiff = (OriginalXLength - CurrentXLength);

                if XLengthDiff == 0
                    CurrentWavelength = w;
                else
                    len = (XLengthDiff) / 2;
                    temp = w;
                    temp(:, (size(temp, 2) - len + 1):end) = [];
                    temp(:, 1:len) = [];
                    CurrentWavelength = temp;
                end

                x = obj.OptimalResult{idx, idy(i)}.DataProcessed.spectra;
                y = obj.OptimalResult{idx, idy(i)}.DataProcessed.y;

                n = size(x, 2);
                r2 = zeros(1, n);

                for j = 1:n
                    temp = x(:, j);
                    lm = fitlm(temp, y);
                    r2(j) = lm.Rsquared.Ordinary;
                end

                subplot(m, 1, i)
                yyaxis left
                plot(CurrentWavelength, r2, 'b')
                str1 = table2str(obj.OptimalResult{idx, idy(i)}.MethodName);
                text('string', strcat('(', fc(i), ')'), 'Units', 'normalized', 'Position', [0.01, 0.95], 'Fontsize', 10)

                if str1 == ""
                    str1 = "Raw";
                end

                set(get(gca, 'YLabel'), 'String', str1);
                box on
                xmean = mean(x);
                yyaxis right
                plot(CurrentWavelength, xmean, '--g')

                if i == m
                    set(get(gca, 'XLabel'), 'String', 'Wavelength');
                end

                box on
                hold off
            end

        end

        % plot relation condition of processed spectra
        function plotplscoe(obj, idx, idy, w)
            % 绘制第idx次独立运行的idy个预处理后的光谱PLSR模型的系数
            m = length(idy);

            if m > 20
                error("要输出的图形过多，请减少第二个参数的长度！")
            end

            OriginalXLength = length(w);
            figure()
            fc = 'abcdefghigklmnopqrstuvwxyz';

            for i = 1:m
                CurrentXLength = size(obj.OptimalResult{idx, idy(i)}.DataProcessed.spectra, 2);
                XLengthDiff = (OriginalXLength - CurrentXLength);

                if XLengthDiff == 0
                    CurrentWavelength = w;
                else
                    len = (XLengthDiff) / 2;
                    temp = w;
                    temp(:, (size(temp, 2) - len + 1):end) = [];
                    temp(:, 1:len) = [];
                    CurrentWavelength = temp;
                end

                x = obj.OptimalResult{idx, idy(i)}.DataProcessed.spectra;
                y = obj.OptimalResult{idx, idy(i)}.ModelObj.Coeff(2:end);

                subplot(m, 1, i)
                yyaxis left
                plot(CurrentWavelength, y, 'b')
                str1 = table2str(obj.OptimalResult{idx, idy(i)}.MethodName);
                text('string', strcat('(', fc(i), ')'), 'Units', 'normalized', 'Position', [0.01, 0.95], 'Fontsize', 10)

                if str1 == ""
                    str1 = "Raw";
                end

                set(get(gca, 'YLabel'), 'String', str1);
                box on
                xmean = mean(x);
                yyaxis right
                plot(CurrentWavelength, xmean, '--g')

                if i == m
                    set(get(gca, 'XLabel'), 'String', 'Wavelength');
                end

                box on
                hold off
            end

        end

        function plotAllPerformance(~, PerformanceSta)
            % 绘制程序全部模型结果
            RMSECV = PerformanceSta.RMSECV;
            RMSEC = PerformanceSta.RMSEC;
            RMSEV = PerformanceSta.RMSEV;
            LV = PerformanceSta.LV;
            %[m, n] = size(RMSECV);

            figure()
            set(gcf, "position", [200, 200, 2000, 1000])

            subplot(4, 1, 1)
            boxplot(RMSECV)
            hold on
            plot(mean(RMSECV))
            [miny, yindex] = min(mean(RMSECV));
            plot(xlim, [miny, miny], 'k')
            plot([yindex, yindex], ylim, 'k')
            set(get(gca, 'YLabel'), 'String', 'RMSECV');
            text('string', '(a)', 'Units', 'normalized', 'Position', [0.01, 0.9], 'Fontsize', 10);
            set(gca,'xtick',[])

            subplot(4, 1, 2)
            boxplot(RMSEC)
            hold on
            plot(mean(RMSEC))
            [miny, yindex] = min(mean(RMSEC));
            plot(xlim, [miny, miny], 'k')
            plot([yindex, yindex], ylim, 'k')
            set(get(gca, 'YLabel'), 'String', 'RMSEC');
            text('string', '(b)', 'Units', 'normalized', 'Position', [0.01, 0.9], 'Fontsize', 10);
            set(gca,'xtick',[])

            subplot(4, 1, 3)
            boxplot(RMSEV)
            hold on
            plot(mean(RMSEV))
            [miny, yindex] = min(mean(RMSEV));
            plot(xlim, [miny, miny], 'k')
            plot([yindex, yindex], ylim, 'k')
            set(get(gca, 'YLabel'), 'String', 'RMSEV');
            text('string', '(c)', 'Units', 'normalized', 'Position', [0.01, 0.9], 'Fontsize', 10);
            set(gca,'xtick',[])

            subplot(4, 1, 4)
            boxplot(LV)
            hold on
            plot(mean(LV))
            [miny, yindex] = min(mean(LV));
            plot(xlim, [miny, miny], 'k')
            plot([yindex, yindex], ylim, 'k')
            set(get(gca, 'YLabel'), 'String', 'LV');
            set(get(gca, 'XLabel'), 'String', 'Group');
            text('string', '(d)', 'Units', 'normalized', 'Position', [0.01, 0.9], 'Fontsize', 10);  
            colnum = size(LV,2);
            if colnum > 10
                xt = floor(linspace(1, colnum,10)); 
                xtstr = num2str(xt);
                xtcell = str2cell(xtstr);
                xticks(xt)
                xticklabels(xtcell)
            end
            hold off

        end

        function plotProcessedSpec(obj, w, th, whichone)
            % w是绘制预处理光谱时的横坐标，th是第th运行的最优结果
            % 因为程序搜索最优预处理光谱后，对全部数据进行Rank样本划分，所以第th
            % 抽出的样本是不一样的
            OriginalXLength = length(w);
            [~, n] = size(obj.OptimalResult);

            if nargin == 2
                th = 1;

                if n > 10
                    whichone = 1:10;
                else
                    whichone = 1:n;
                end

            elseif nargin == 3

                if n > 10
                    whichone = 1:10;
                else
                    whichone = 1:n;
                end

            end

            figure()
            set(gcf, "position", [200, 200, 1000, 250])

            for i = 1:length(whichone)
                %这里有可能出错，因为第一个变量不一定是原始光谱
                CurrentXLength = size(obj.OptimalResult{th, whichone(i)}.DataProcessed.spectra, 2);
                XLengthDiff = (OriginalXLength - CurrentXLength);

                if XLengthDiff == 0
                    CurrentWavelength = w;
                else
                    len = (XLengthDiff) / 2;
                    temp = w;
                    temp(:, (size(temp, 2) - len + 1):end) = [];
                    temp(:, 1:len) = [];
                    CurrentWavelength = temp;
                end

                spectra = obj.OptimalResult{th, whichone(i)}.DataProcessed.spectra;
                name = obj.OptimalResult{th, whichone(i)}.MethodName;
                subplot(1, length(whichone), i)
                plot(CurrentWavelength, spectra')
                fc = 'abcdefghigklmnopqrstuvwxyz';
                text('string', strcat('(', fc(i), ')'), 'Units', 'normalized', 'Position', [0.07, 0.95], 'Fontsize', 10)
                s = table2str(name);

                if s == ""
                    s = "Raw";
                end

                title(s)

                %set(get(gca, 'XLabel'), 'String', 'Wavelength(nm)');
            end

        end

        function [DataCal, DataVal] = sample(obj, SamplingMethod)
            % 该方法可以将SP内置的光谱数据集Data按照指定的抽样方法进行样本数据划分
            samp = SpectraSample();

            if SamplingMethod == "rand"
                [DataCal, DataVal] = samp.randomSample2(obj.Data, 0.8);
            elseif SamplingMethod == "ks"
                [DataCal, DataVal] = samp.ksSample2(obj.Data, 0.8);
            elseif SamplingMethod == "spxy"
                [DataCal, DataVal] = samp.spxySample2(obj.Data, 0.8);
            elseif SamplingMethod == "rank"
                [DataCal, DataVal] = samp.rankSample(obj.Data, 5, 0.8);
            end

        end

        function [Result] = buildModel(obj, samplemode, runtime, mc)
            % 利用前面已经预处理方法，默认采用SPXY方法对数据进行划分，然后建立PLSR模型
            % sampleMode是采用方法，mc是建模方法（如PLSR，PCR等）
            if nargin == 1
                samplemode = "rand";
                runtime = 20;
                mc = PLSR();
            elseif nargin == 2
                runtime = 20;
                mc = PLSR();
            elseif nargin == 3
                mc = PLSR();
            end

            MethodSelected = obj.MethodCombination(obj.OptimalProcessingIndex, :);
            k = size(MethodSelected, 1);
            ml = obj.MethodList;
            Result = cell(runtime, k);

            for j = 1:runtime

                [DataCal, DataVal] = obj.sample(samplemode);

                parfor i = 1:k
                    tf = Transform();
                    CalModel = mc;
                    [DataProcessed, addtionalInfo] = tf.transform(DataCal, MethodSelected(i, :), ml);
                    [ModelBeta, PerformanceCal] = CalModel.buildModel(DataProcessed);
                    DataValProcessed = tf.transform2(DataVal, MethodSelected(i, :), ml, addtionalInfo);
                    PerformanceVal = CalModel.predict(ModelBeta, DataValProcessed);
                    Result{j, i}.PerformanceCal = PerformanceCal;
                    Result{j, i}.PerformanceVal = PerformanceVal;
                    Result{j, i}.MethodName = MethodSelected(i, :);
                    Result{j, i}.ModelBeta = ModelBeta;
                    Result{j, i}.DataProcessed = DataProcessed;
                    Result{j, i}.ycal = DataCal.y;
                    Result{j, i}.yval = DataVal.y;
                    Result{j, i}.ModelObj = CalModel;
                end

                dis = sprintf("\n------>>>>>>>>>The %dth iteration has been completed<<<<<<------", j);
                fprintf(dis)
            end

            obj.OptimalResult = Result;

            [PF.RMSECV, PF.RMSEC, PF.RMSEV, PF.LV, PF.RC2, PF.RV2, MD.Model] = Result2Mat(Result);

            obj.PerformanceSta2 = PF;
            obj.ModelSta2 = MD;

        end

        function plotModel_RefVSPre(obj, th, whichone)
            % 画出指定模型的建模和预测效果，th是第th独立运行，whichone是指定的模型序号
            figure()
            set(gcf, "position", [200, 200, 400, 300])

            preCal = obj.OptimalResult{th, whichone}.PerformanceCal.yfit;
            refCal = obj.OptimalResult{th, whichone}.ycal;
            preVal = obj.OptimalResult{th, whichone}.PerformanceVal.yfit;
            refVal = obj.OptimalResult{th, whichone}.yval;

            name = obj.OptimalResult{th, 1}.MethodName;

            hold on
            s1 = scatter(refCal, preCal);
            s2 = scatter(refVal, preVal);
            set(get(gca, 'XLabel'), 'String', 'Reference');
            set(get(gca, 'YLabel'), 'String', 'Prediction');
            xl = xlim;
            yl = ylim;
            xx = [xl(1), xl(1)];
            yy = [yl(2), yl(2)];
            line(xl, xl);
            s2.Marker = '*';
            str1 = strcat("R_c^2: ", num2str(obj.OptimalResult{th, whichone}.PerformanceCal.R2, 3));
            str2 = strcat("R_v^2: ", num2str(obj.OptimalResult{th, whichone}.PerformanceVal.R2, 3));
            str3 = strcat("RMSEC: ", num2str(obj.OptimalResult{th, whichone}.PerformanceCal.RMSE, 3));
            str4 = strcat("RMSEV: ", num2str(obj.OptimalResult{th, whichone}.PerformanceVal.RMSE, 3));
            str5 = strcat("LV: ", num2str(obj.OptimalResult{th, whichone}.PerformanceCal.LV));
            str = [str1, str2, str3, str4, str5];
            text('string', str, 'Units', 'normalized', 'Position', [0.7, 0.2], 'Fontsize', 7);

            box on
            hold off
            s = table2str(name);

            if s == ""
                s = "Raw";
            end

            title(s)

        end

        function plotModels_RefVSPre(obj, th, which)
            % 画出前几个最有模型的建模和预测效果
            m = length(which);
            figure()
            set(gcf, "position", [200, 200, 1000, 250])
            fc = 'abcdefghigklmnopqrstuvwxyz';

            for i = 1:m
                preCal = obj.OptimalResult{th, which(i)}.PerformanceCal.yfit;
                refCal = obj.OptimalResult{th, which(i)}.ycal;
                preVal = obj.OptimalResult{th, which(i)}.PerformanceVal.yfit;
                refVal = obj.OptimalResult{th, which(i)}.yval;

                name = obj.OptimalResult{th, which(i)}.MethodName;
                subplot(1, m, i)

                hold on
                s1 = scatter(refCal, preCal);
                s2 = scatter(refVal, preVal);
                set(get(gca, 'XLabel'), 'String', 'Reference');
                set(get(gca, 'YLabel'), 'String', 'Prediction');
                xl = xlim;
                yl = ylim;
                xx = [xl(1), xl(1)];
                yy = [yl(2), yl(2)];
                line(xl, xl)
                s2.Marker = '*';
                str1 = strcat("R_c^2: ", num2str(obj.OptimalResult{th, which(i)}.PerformanceCal.R2, 3));
                str2 = strcat("R_v^2: ", num2str(obj.OptimalResult{th, which(i)}.PerformanceVal.R2, 3));
                str3 = strcat("RMSEC: ", num2str(obj.OptimalResult{th, which(i)}.PerformanceCal.RMSE, 3));
                str4 = strcat("RMSEV: ", num2str(obj.OptimalResult{th, which(i)}.PerformanceVal.RMSE, 3));
                str5 = strcat("LV: ", num2str(obj.OptimalResult{th, which(i)}.PerformanceCal.LV));
                str = [str1, str2, str3, str4, str5];
                text('string', str, 'Units', 'normalized', 'Position', [0.45, 0.2], 'Fontsize', 7)
                text('string', strcat('(', fc(i), ')'), 'Units', 'normalized', 'Position', [0.07, 0.95], 'Fontsize', 10)
                box on
                hold off
                s = table2str(name);

                if s == ""
                    s = "Raw";
                end

                title(s)
            end

        end

        function [OPMID, OPMN] = getOptimalMethod(obj)
            % 按照交互验证的结果列出最有的模型及其性能指标
            RMSECV = obj.PerformanceSta.RMSECV;
            %RMSEC = obj.PerformanceSta.RMSEC;
            %RMSEV = obj.PerformanceSta.RMSEV;
            %LV = obj.PerformanceSta.LV;
            %RC2 = obj.PerformanceSta.RC2;
            %RV2 = obj.PerformanceSta.RV2;

            [~, OPMID] = sort(mean(RMSECV));
            OPMN = obj.MethodCombination(OPMID, :);
            obj.OptimalProcessingIndex = OPMID';
            obj.OptimalProcessingName = OPMN;

        end

        function AllScheme = getMethodCombination(obj)
            % Giving all combination experiment scheme
            warning('off', 'all')
            MethodNameUserDefined = obj.MethodClass;
            % MethodNameUserDefined has the method name list user used
            m = CreateMethodIndex(size(MethodNameUserDefined, 2));
            SchemeClass = m.getMethodIndex();
            n = size(SchemeClass, 1);
            AllScheme = table();

            AllScheme(1, 1) = str2cell("");

            for i = 2:n
                % Get a special processing order of preprocessing methods
                MC = SchemeClass(i, :);

                MethodIdxSelected = MC ~= 0;
                MethodNameSelected = MethodNameUserDefined(MethodIdxSelected);

                % sort MethodNameSelected by MethodClass: 1 means the first
                % used preprocesssing method, 2 means the second, ect..
                MC((find(MC == 0))) = [];
                MethodNameSelected = MethodNameSelected(:, MC);

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
                [rn1, cn1] = size(MethodSubclassIdx);
                MethodSubclass = table();

                for k = 1:rn1

                    for h = 1:cn1
                        MethodSubclass(k, h) = str2cell(strcat(MethodNameSelected(h), num2str(MethodSubclassIdx(k, h))));

                    end

                end

                [rm, cm] = size(MethodSubclass);
                ra = size(AllScheme, 1);

                for h = 1:rm

                    for x = 1:cm
                        AllScheme(ra + h, x) = MethodSubclass(h, x);
                    end

                end

            end

            obj.MethodCombination = AllScheme;

        end

        function [PF, MD] = getPerformance(obj, samplemode, runtime)
            %
            if nargin == 1
                samplemode = "rand";
                runtime = 10;
            end
            if nargin == 2
                runtime = 10;
            end

            n = size(obj.MethodCombination, 1);
            OriginalResult = cell(runtime, n);
            cm = obj.CalibrationModel;
            mc = obj.MethodCombination;

            ml = obj.MethodList;

            for i = 1:runtime
                [dc, dv] = obj.sample(samplemode);

                parfor j = 1:n
                    MethodSelected = mc(j, :);
                    tf = Transform();
                    CalModel = cm;
                    [DataProcessed, addtionalInfo] = tf.transform(dc, MethodSelected, ml);
                    [CalModelCoeff, PerformanceCal] = CalModel.buildModel(DataProcessed);
                    DataValProcessed = tf.transform2(dv, MethodSelected, ml, addtionalInfo);
                    PerformanceVal = CalModel.predict(CalModelCoeff, DataValProcessed);
                    OriginalResult{i, j}.PerformanceCal = PerformanceCal;
                    OriginalResult{i, j}.PerformanceVal = PerformanceVal;
                    OriginalResult{i, j}.MethodName = MethodSelected;
                    OriginalResult{i, j}.ModelObj = CalModel;
                end

                dis = sprintf("\n------>>>>>>>>>The %dth iteration has been completed<<<<<<------", i);
                fprintf(dis)
            end

            [PF.RMSECV, PF.RMSEC, PF.RMSEV, PF.LV, PF.RC2, PF.RV2, MD.Model] = Result2Mat(OriginalResult);

            [~, OPMID] = sort(mean(PF.RMSECV));
            OPMN = obj.MethodCombination(OPMID, :);
            obj.OptimalProcessingIndex = OPMID';
            obj.OptimalProcessingName = OPMN;
            
            PF.RMSECV = PF.RMSECV(:, OPMID);
            PF.RMSEC = PF.RMSEC(:, OPMID);
            PF.RMSEV = PF.RMSEV(:, OPMID);
            PF.LV = PF.LV(:, OPMID);
            PF.RC2 = PF.RC2(:, OPMID);
            PF.RV2 = PF.RV2(:, OPMID);
            MD.Model = MD.Model(:, OPMID);

            obj.PerformanceSta = PF;
            obj.ModelSta = MD;
        end

    end

end
