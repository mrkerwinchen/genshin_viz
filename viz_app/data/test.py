import termtables as tt
import pandas as pd
import numpy

#numpy.random.seed(0)
#data = numpy.random.rand(5, 2)

#tt.print(data.iloc[2])

f = pd.read_csv("character_summary.csv", index_col = 0)

print(f.loc[f.name.isin(["Zhongli", "Beidou"])])
tt.print(f.iloc[2])
