% @Author: Wang Shenghao
% @Date: 2020-09-24 08:42:18
% @Last Modified by:   Wang Shenghao
% @Last Modified time: 2020-09-24 08:42:18

classdef Transform
    % Preprocess the spectra data

    properties (GetAccess = 'public', SetAccess = 'public')

    end

    properties (GetAccess = 'public', SetAccess = 'private')
        % attributes

    end

    methods

        function [Data2, addtionalInfo] = transform(~, Data1, Scheme, FIG)
            % 预处理校正集光谱数据
            % Preprocess the calibration set spectra data.
            % x1 is a table with spectra data and object data
            % Scheme is one kind of preprocessing method combination,
            % for example, ct1, df3, sm2
            % FIG is a FIG object
            n = size(Scheme, 2);
            addtionalInfo = {};
            x1 = Data1.spectra;
            x2 = x1;

            for i = 1:n
                temp = table2array(Scheme(1, i));

                if ismissing(temp)
                    break;
                end

                if temp == ""
                    break;
                else

                    if temp == "ct1"
                        addtionalInfo = {mean(x2)};
                    end

                    funClass = extractBefore(temp, 3);

                    switch funClass
                        case 'sm'
                            funBody = getfield(FIG.sm, temp);
                        case 'df'
                            funBody = getfield(FIG.df, temp);
                        case 'nm'
                            funBody = getfield(FIG.nm, temp);
                        case 'ct'
                            funBody = getfield(FIG.ct, temp);
                        case 'de'
                            funBody = getfield(FIG.de, temp);
                    end

                    funName = funBody.fun;
                    funPara = funBody.para;

                    paraL = length(funPara);

                    if paraL == 0
                        x2 = feval(funName, x2);
                    elseif paraL == 1
                        x2 = feval(funName, x2, funPara(1));
                    elseif paraL == 2
                        x2 = feval(funName, x2, funPara(1), funPara(2));
                    elseif paraL == 3

                        if funPara(2) == 0
                            % if preprocessing method is smoothing
                            len = (funPara(3) - 1) / 2;
                            xstartwindow = x2(:, 1:len);
                            xendwindow = x2(:, (size(x2, 2) - len + 1):end);
                            x2 = feval(funName, x2', funPara(1), funPara(2), funPara(3));
                            x2 = x2';
                            x2(:, 1:len) = xstartwindow;
                            x2(:, (size(x2, 2) - len + 1):end) = xendwindow;
                        else
                            % if preprocessing method is differentiation
                            x2 = feval(funName, x2', funPara(1), funPara(2), funPara(3));
                            x2 = x2';
                            len = (funPara(3) - 1) / 2;
                            x2(:, (size(x2, 2) - len + 1):end) = [];
                            x2(:, 1:len) = [];

                        end

                    end

                end

            end

            Data2.spectra = x2;
            Data2.y = Data1.y;
        end

        function Data2 = transform2(~, Data1, Scheme, FIG, addtionalInfo)
            % 预处理验证集光谱数据
            % Preprocess the validation set spectra data.
            % Scheme is one kind of preprocessing method combination,
            % for example, ct1, df3, sm2
            % FIG is a FIG object
            n = size(Scheme, 2);
            x1 = Data1.spectra;
            x2 = x1;

            for i = 1:n
                temp = table2array(Scheme(1, i));

                if ismissing(temp)
                    break;
                end

                if temp == ""
                    break;
                else

                    if temp == "ct1"
                        x2 = msc2(x2, addtionalInfo{1, 1});
                        continue;
                    end

                    funClass = extractBefore(temp, 3);

                    switch funClass
                        case 'sm'
                            funBody = getfield(FIG.sm, temp);
                        case 'df'
                            funBody = getfield(FIG.df, temp);
                        case 'nm'
                            funBody = getfield(FIG.nm, temp);
                        case 'ct'
                            funBody = getfield(FIG.ct, temp);
                        case 'de'
                            funBody = getfield(FIG.de, temp);
                    end

                    funName = funBody.fun;
                    funPara = funBody.para;

                    paraL = length(funPara);

                    if paraL == 0
                        x2 = feval(funName, x2);
                    elseif paraL == 1
                        x2 = feval(funName, x2, funPara(1));
                    elseif paraL == 2
                        x2 = feval(funName, x2, funPara(1), funPara(2));
                    elseif paraL == 3

                        if funPara(2) == 0
                            % if preprocessing method is smoothing
                            len = (funPara(3) - 1) / 2;
                            xstartwindow = x2(:, 1:len);
                            xendwindow = x2(:, (size(x2, 2) - len + 1):end);
                            x2 = feval(funName, x2', funPara(1), funPara(2), funPara(3));
                            x2 = x2';
                            x2(:, 1:len) = xstartwindow;
                            x2(:, (size(x2, 2) - len + 1):end) = xendwindow;
                        else
                            % if preprocessing method is differentiation
                            x2 = feval(funName, x2', funPara(1), funPara(2), funPara(3));
                            x2 = x2';
                            len = (funPara(3) - 1) / 2;
                            x2(:, (size(x2, 2) - len + 1):end) = [];
                            x2(:, 1:len) = [];
                        end

                    end

                end

            end

            Data2.spectra = x2;
            Data2.y = Data1.y;
        end

    end

end
