

# requires at least RoME v0.15.1
using RoME
using NavAbilitySDK


##


# To get this, open app.navability.io, log in, press F12, go to Application, click Local Storage, click https://app.navability.io, click idToken, copy the value of ID token into here.
token = "" 

cdfg = CloudDFG(token=token)

# build a graph with 20 poses
RoME.generateCanonicalFG_Beehive(20,graphinit=false, fg=cdfg)



#
