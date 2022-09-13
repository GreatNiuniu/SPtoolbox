classdef SpectraSample < handle
    % parameters
    % data X need the style a sample in one row, a variable in one column
    % samplingMode is the sample select mode, for example,random, K-S
    % samplingMode = 1 means random sampling
    % samplingMode = 3 means select samples from raw sample order by
    % (1- N) and (N+1, end)
    % if setNumber = 2, then generate calibration set and validation set
    % if setNumber = 3, then generate calibration set, validation set and, test set
    % if setNumber = 3, the number of calibration set is sampleRatio, and the number
    % of validation set and test set is (1 - sampleRatio)

    properties (GetAccess = 'public', SetAccess = 'public')

    end

    properties (GetAccess = 'public', SetAccess = 'private')
        % attributes

    end

    methods
        % constructor
        function obj = SpectraSample()

            if nargin > 0

            end

        end

        % random sampling into 2 blocks:
        function [cal, val] = randomSample2(~, Data, sampleRatio)

            if nargin == 1

            end

            cal_N = floor(size(Data, 1) * sampleRatio);
            [cal, cal_idx] = datasample(Data, cal_N, 'Replace', false);
            Data(cal_idx, :) = [];
            val = Data;

        end

        % random sampling into 3 blocks.The number of first block is all Number * sampleRatio1
        % the number of the second is equal to all Number *(1-sampleRatio1) *  sampleRatio2
        function [cal, val, test] = randomSample3(obj, Data, sampleRatio1, sampleRatio2)
            [cal, Data2] = obj.randomSample2(Data, sampleRatio1);
            [val, test] = obj.randomSample2(Data2, sampleRatio2);
        end

        % sampling data into 2 by ks
        function [cal, val] = rankSample(~, Data, fold, sampleRatio)
            meanSpetra = mean(Data.spectra);
            disData = [meanSpetra; Data.spectra];
            dt = dist(disData');
            dx = dt(2:end, 1);
            dy = abs(mean(Data.y) - Data.y);
            dxy = dx / max(dx) + dy / max(dy);

            % dxy2 is the distance after sorting, and Data2 is its corresponing spectra data
            [dxy2, ind] = sort(dxy);
            Data2 = Data(ind, :);

            group = cell(1, fold);
            selectNumber = zeros(1, fold);
            [N, edges] = histcounts(dxy2, fold);
            selectAllSample = [];

            for i = 1:fold
                group{i} = find(dxy2 > edges(i) & dxy2 < edges(i + 1));
                selectNumber(i) = ceil(N(i) * sampleRatio);
                selectGroupSampleIndex = randsample(N(i), selectNumber(i));
                temp = cell2mat(group(i));
                selectAllSample = [selectAllSample; temp(selectGroupSampleIndex)] ;
            end

            cal = Data(selectAllSample, :);
            Data(selectAllSample, :) = [];
            val = Data;
        end

        % sampling data into 2 by spxy
        function [cal, val] = spxySample2(~, Data, sampleRatio)
            cal_N = floor(size(Data, 1) * sampleRatio);
            cal_idx = spxy(Data.spectra, Data.y, cal_N);
            cal = Data(cal_idx, :);
            Data(cal_idx, :) = [];
            val = Data;
        end

        % sampling data into 2 by ks
        function [cal, val] = ksSample2(~, Data, sampleRatio)
            cal_N = floor(size(Data, 1) * sampleRatio);
            cal_idx = kenstone(Data.spectra, cal_N);
            %cal_idx = kennardstone(Data.spectra, cal_N);
            %cal = Data(cal_idx, :);
            cal = Data(cal_idx, :);
            Data(cal_idx, :) = [];
            val = Data;
        end

        % sampling data into 3 by spxy and random
        % the first set and second set is classified with spxy
        % the second set and the third set id classified with random
        function [cal, val, test] = spxySample3(obj, Data, sampleRatio1, sampleRatio2)
            [cal, Data2] = obj.spxySample2(Data, sampleRatio1);
            [val, test] = obj.randomSample2(Data2, sampleRatio2);
        end

    end

end
