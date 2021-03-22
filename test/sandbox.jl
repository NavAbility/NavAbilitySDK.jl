
# host = "https://api.d1.navability.io"
# This must be an ID token yo! Damnit Cognito is weirder than a three-headed alpaca...
# To get this, open app.navability.io, log in, press F12, go to Application, click Local Storage, click https://app.navability.io, click idToken, copy the value of ID token into here.
token = "eyJraWQiOiJaenY3M040OUJKOVwvMHd2Z2dGelpIck1yM0lGV2NPXC9hWkNpM0FRaFFxTW89IiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiSVNSOXoyUVNFZ2JRMUI1UTRLQWY3dyIsInN1YiI6IjY2NWUzMTgzLTMyZWQtNDMzYS1hYTEyLTg2OTI5ZTAxODFmNyIsImF1ZCI6InQ5NG9qZzZzMzFtNnJkbDlxbHJ1MW43NnAiLCJldmVudF9pZCI6ImQ2MjljNmY3LWFjZDAtNGY4My1hZDE0LTk4NzU5NDMyN2QyYSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjE2NDUzNjk0LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0yLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMl9LWk94UGxUbm4iLCJjb2duaXRvOnVzZXJuYW1lIjoiVGVzdFVzZXIiLCJleHAiOjE2MTY0NTcyOTQsImlhdCI6MTYxNjQ1MzY5NH0.jTQKE60xCplxrEBS5Cat7E6LGggeNRRT8p1mItQxbKhsDJo496MuKovYEhWWVkXaj7t0_Urb_IfzMLEGlhXHXM1cwPZBW2FPifSyybb1xtDyQs5zwpDhRYvMfq7qIACHYX8Xo78N4UBw0yEBPCRZc_eBitUAWlGhRVKE_aZtOQ1oxivuJLs_oL9L6QVQ0aSQ_yZfv0wdMZBHbGhSepf59Ud3RPY-iVh2EqNAJVXK2zloB8OnJFFLW9XMjcja1rOBKyrGPTVD3H8-yrHzRKu_v-7oO5xAoVDMk2SA3MjqZy_IE7D-vZCr5YrDx0pisSpfgFY7JXf3cy-QyQH5V8WObQ"

using DistributedFactorGraphs
using NavAbilitySDK

## shortcut to packed variable Julia, will do Python / JS after this works.
using IncrementalInference, RoME
# create temp in memory graph that we will tee up to server via cfg
lfg = initfg() # LightDFG
v0 = addVariable!(lfg, :x0, Pose2)


## Now let pack to something that other languages would recognize
# lets duplicate up
# We have v0, let's send it up the wire to the cloud...
cdfg = CloudDFG(token=token)
addVariable!(cdfg, v0)


##