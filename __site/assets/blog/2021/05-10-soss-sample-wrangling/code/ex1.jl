# This file was generated, do not modify it. # hide
using Soss
using MeasureTheory
using TupleVectors

m = @model n begin
    α ~ Normal()
    β ~ Normal()
    x ~ Normal() |> iid(n)
    σ ~ Exponential(λ=1)
    y ~ For(x) do xj
        Normal(α + β * xj, σ)
    end
    return y
end