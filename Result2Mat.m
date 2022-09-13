

function [rmsecv, rmsec, rmsev, lv, rc2, rv2, model] = Result2Mat(Result)
    [rn, cn] = size(Result);
    rmsecv = zeros(rn, cn);
    rmsec = zeros(rn, cn);
    rmsev = zeros(rn, cn);
    lv = zeros(rn, cn);
    rc2 = zeros(rn, cn);
    rv2 = zeros(rn, cn);
    model = cell(rn, cn);

    for i = 1:rn

        parfor j = 1:cn
            rmsecv(i, j) = Result{i, j}.PerformanceCal.RMSECV;
            rmsec(i, j) = Result{i, j}.PerformanceCal.RMSE;
            rmsev(i, j) = Result{i, j}.PerformanceVal.RMSE;
            lv(i, j) = Result{i, j}.PerformanceCal.LV;
            rc2(i, j) = Result{i, j}.PerformanceCal.R2;
            rv2(i, j) = Result{i, j}.PerformanceVal.R2;
            model{i, j} = Result{i, j}.ModelObj;
        end

        dis = sprintf("\n------>>>>>>>>> The PerformanceSta of the %dth group has been extracted<<<<<<------", i);
        fprintf(dis)
    end
end
