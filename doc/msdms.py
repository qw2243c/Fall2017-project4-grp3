import pandas as pd
import numpy as np
from copy import deepcopy
from multiprocessing import Pool

df = pd.read_csv('modified_ms_train.csv')
df = df.fillna(0)
df = df.set_index('Unnamed: 0', drop = True)

s = deepcopy(df)
c = df

c[c>0] = 1

def MSD(i, j):
    num = 0
    dem = 0 
    for n in range(s.shape[1]):
        num += c.iloc[i, n]*c.iloc[j,n]*(s.iloc[i, n]-s.iloc[j, n])**2
        dem += c.iloc[i, n]*c.iloc[j,n]
    return(num/dem)

def calc_MSD(part):
    start = part
    if ((part + 50) > s.shape[0]):
        finish = s.shape[0]
    else:
        finish = part+50
        
    
    D = [[0 for i in range(s.shape[0])] for i in range(finish-start)]        
    for x, i in enumerate(range(start, finish, 1)):
        for y, j in enumerate(range(s.shape[0])):
            D[x][y] = MSD(i, j)
    return(D)

p = Pool(64)
a = p.map(calc_MSD, list(range(0, s.shape[0], 50)))

output = pd.DataFrame([item for sublist in a for item in sublist])
output.columns = list(df.index)
output.index = list(df.index)
output.to_csv('MSDsim_ms.csv')