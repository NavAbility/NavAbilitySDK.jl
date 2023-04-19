@testset "Distribution Tests" begin
    normal = NvaSDK.Normal(0, 1)
    @test JSON3.write(normal) ==
          "{\"mu\":0.0,\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedNormal\"}"

    rayleigh = NvaSDK.Rayleigh(1)
    @test JSON3.write(rayleigh) ==
          "{\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedRayleigh\"}"

    fullnormal = NvaSDK.FullNormal([1.0, 2.0, 3.0], [1.0 2.0 3.0; 4.0 5.0 6.0])
    @test JSON3.write(fullnormal) ==
          "{\"mu\":[1.0,2.0,3.0],\"cov\":[1.0,4.0,2.0,5.0,3.0,6.0],\"_type\":\"IncrementalInference.PackedFullNormal\"}"

    uniform = NvaSDK.Uniform(0, 1)
    @test JSON3.write(uniform) ==
          "{\"a\":0.0,\"b\":1.0,\"_type\":\"IncrementalInference.PackedUniform\"}"

    categorical = NvaSDK.Categorical([0.4, 0.6])
    @test JSON3.write(categorical) ==
          "{\"p\":[0.4,0.6],\"_type\":\"IncrementalInference.PackedCategorical\"}"
end
