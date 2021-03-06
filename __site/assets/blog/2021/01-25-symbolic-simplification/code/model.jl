# This file was generated, do not modify it. # hide
using Soss

N = 10000

m = @model x, λ begin
    σ ~ Exponential(λ)
    β ~ Normal(0,1) 
    y ~ For(1:N) do j
        Normal(x[j] * β, σ)
    end
    return y
end