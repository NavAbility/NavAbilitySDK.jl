# REF: Copied directly from https://github.com/tpapp/DefaultApplication.jl/blob/master/src/DefaultApplication.jl to save a dependency
"""
  $(SIGNATURES)
Open a file with the default application determined by the OS.
The argument `wait` is passed to `run`.
"""
function os_open(filename; wait = false)
  @static if Sys.isapple()
      run(`open $(filename)`; wait = wait)
  elseif Sys.islinux() || Sys.isbsd()
      run(`xdg-open $(filename)`; wait = wait)
  elseif Sys.iswindows()
      cmd = get(ENV, "COMSPEC", "cmd.exe")
      run(`$(cmd) /c start $(filename)`; wait = wait)
  else
      @warn("Opening files the default application is not supported on this OS.",
            KERNEL = Sys.KERNEL)
  end
end

"""
  $(SIGNATURES)
Gets the NavAbility environment, which is set by the environment
variable NVA_ENVIRONMENT and is d1 by default.
"""
function nvaEnv()
  return get(ENV, "NVA_ENVIRONMENT", "d1") 
end

"""
  $(SIGNATURES)
Gets the NavAbility Cognito client.
"""
function nvaCognitoClient()
  nvaEnv() == "d1" && return "t94ojg6s31m6rdl9qlru1n76p"
  return "t94ojg6s31m6rdl9qlru1n76p"
end

"""
  $(SIGNATURES)
Extracts the claims from a JWT token without checking the signature.
"""
function extractJwtClaims(token::String)
  # TODO: Validate token using JWK https://cognito-idp.us-east-2.amazonaws.com/us-east-2_KZOxPlTnn/.well-known/jwks.json
  # and JSONWebTokens
  jwt_elements = split(token, '.')
  length(jwt_elements) != 3 && error("Token is not a valid JWT token")
  str_claims = String(base64url_decode(jwt_elements[2]))
  return JSON.parse(str_claims)
end