import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.preprocessing import scale
from sklearn import model_selection
from sklearn.model_selection import RepeatedKFold
from sklearn.model_selection import train_test_split
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import mean_squared_error
import os

def skplsr(X, y):
    # define cross-validation method
    cv = RepeatedKFold(n_splits=5, n_repeats=10, random_state=None)
    mse = []
    n = len(X)

    # Calculate MSE using cross-validation, adding one component at a time
    for i in np.arange(1, 10):
        pls = PLSRegression(n_components=i)
        score = -1 * model_selection.cross_val_score(pls, scale(X), y, cv=cv,
                                                     scoring='neg_mean_squared_error').mean()
        mse.append(score)

    # plot test MSE vs. number of components
    return mse


df = pd.read_excel("Octane.xlsx")
X = df.iloc[0:61, 0:401]
y = df.iloc[0:61, 401]
for i in range(1):
    MSE = skplsr(X, y)
    RMSE = np.sqrt(MSE)
    print(RMSE)

filePath = '/Users/wangshenghao/Project/Matlab/'
dbtype_list = os.listdir(filePath)
for dbtype in dbtype_list:
    if os.path.isfile(os.path.join(filePath,dbtype)):
        dbtype_list.remove(dbtype)
f=open("A.txt","w")
str = "\n"
dbtype_list = sorted(dbtype_list, key=lambda x: os.path.getmtime(os.path.join(filePath, x)))
f.write(str.join(dbtype_list))
f.close()