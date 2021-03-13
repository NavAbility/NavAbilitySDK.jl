
# host = "https://api.d1.navability.io"
# This must be an ID token yo! Damnit Cognito is weirder than a three-headed alpaca...
# To get this, open app.navability.io, log in, press F12, go to Application, click Local Storage, click https://app.navability.io, click idToken, copy the value of ID token into here.
token = "eyJraWQiOiJaenY3M040OUJKOVwvMHd2Z2dGelpIck1yM0lGV2NPXC9hWkNpM0FRaFFxTW89IiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiMFFZLUlVTWlSaXZhQ25BdDJZdnBnUSIsInN1YiI6IjY2NWUzMTgzLTMyZWQtNDMzYS1hYTEyLTg2OTI5ZTAxODFmNyIsImF1ZCI6InQ5NG9qZzZzMzFtNnJkbDlxbHJ1MW43NnAiLCJldmVudF9pZCI6IjE5MzBiYjg3LWExNjYtNGZlZC04M2E0LTk0NGE2NWRhZjAxYyIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjE1Njc0MzY5LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0yLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMl9LWk94UGxUbm4iLCJjb2duaXRvOnVzZXJuYW1lIjoiVGVzdFVzZXIiLCJleHAiOjE2MTU2Nzc5NjksImlhdCI6MTYxNTY3NDM2OX0.Kn8feBJQbiiU79VQZoDHFXeNSbMOYPkKOecJkCytE5PGC1dUvDOq25n4JvayYj1YA8dQXYZrV9cwZZt0DfXpA-pBwxEYJWDO1WTlgZaxu8rJf2GGVMRF006k10S_RqoyuvcfiFLzSbe472LXpSNbovPK1ke9M9v0g6ZeiEjjF0ygD2qyl12QsI95We5G1HDfKB9iC5_phJD5_MrX1Eu8oSxhZlMRwzHHH2o6KGbsdUVamkU1rRUywbvH0-g_cudTGDJcWSoULwKL4-jAgqts9hFY4i5q8vhBbp80H1IgfOeTWxHZ0IsdmDfNYaF_mxpzVrCTUoQt8MASJVlP7jU5xg"

using DistributedFactorGraphs
using NavAbilitySDK

## shortcut to packed variable Julia, will do Python / JS after this works.
using IncrementalInference, RoME
# create temp in memory graph that we will tee up to server via cfg
lfg = initfg() # LightDF
v0 = addVariable!(lfg, :x0, Pose2)


## Now let pack to something that other languages would recognize
# lets duplicate up
# We have v0, let's send it up the wire to the cloud...
cdfg = CloudDFG(token=token)
addVariable!(cdfg, v0)


##