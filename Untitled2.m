load Paras.mat
load Octane.mat
% MethodList.de.de4= struct("fun","detrends","para",4)

sp = SP(MethodList,Data, ["df", "ct"], "SPXY")
sp.run()