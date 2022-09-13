function sp = createSP(Data, methodName, times)
    load Paras.mat
    sp = SP(MethodList,Data, methodName, times);
end