@testset "Distribution Tests" begin
  normal = Normal(0, 1)
  @test JSON.json(normal) == "{\"mu\":0.0,\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedNormal\"}"

  rayleigh = Rayleigh(1)
  @test JSON.json(rayleigh) == "{\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedRayleigh\"}"

  fullnormal = FullNormal([1.0,2.0,3.0], [1.0 2.0 3.0; 4.0 5.0 6.0])
  @test JSON.json(fullnormal) == "{\"mu\":[1.0,2.0,3.0],\"cov\":[1.0,4.0,2.0,5.0,3.0,6.0],\"_type\":\"IncrementalInference.PackedFullNormal\"}"

  uniform = Uniform(0, 1)
  @test JSON.json(uniform) == "{\"a\":0.0,\"b\":1.0,\"_type\":\"IncrementalInference.PackedUniform\"}"

  categorical = Categorical([0.4, 0.6])
  @test JSON.json(categorical) == "{\"p\":[0.4,0.6],\"_type\":\"IncrementalInference.PackedCategorical\"}"
end