# This file was generated, do not modify it. # hide
x = randn(1000)
y = randn(1000)

function time_normal(y, x, d)
    for i in eachindex(x)
        @inbounds y[i] = logdensity(d, x[i])
    end
end

using MeasureTheory, BenchmarkTools

dtime = @belapsed time_normal($y, $x, $(Dists.Normal(0.2,0.5)))
mtime = @belapsed time_normal($y, $x, $(Normal(0.2,0.5)))

@show dtime #hide
@show mtime #hide