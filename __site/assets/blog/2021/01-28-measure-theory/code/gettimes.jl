# This file was generated, do not modify it. # hide
mμσ = time_normal((μ,σ) -> Normal(μ,σ)) 
dμσ = time_normal((μ,σ) -> Dists.Normal(μ,σ; check_args=false))

mμ1 = time_normal((μ,σ) -> Normal(μ=μ)) 
dμ1 = time_normal((μ,σ) -> Dists.Normal(μ))

m0σ = time_normal((μ,σ) -> Normal(σ=σ)) 
d0σ = time_normal((μ,σ) -> Dists.Normal(0.0,σ; check_args=false))

m01 = time_normal((μ,σ) -> Normal())
d01 = time_normal((μ,σ) -> Dists.Normal())