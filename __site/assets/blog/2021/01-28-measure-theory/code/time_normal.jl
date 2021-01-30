# This file was generated, do not modify it. # hide
using BenchmarkTools

function array_work(f, μ, σ, x, y)
    @inbounds for i in eachindex(x)
        y[i] = logdensity(f(μ[i], σ[i]), x[i])
    end
end

time_normal(f) = @belapsed $array_work($f, $μ, $σ, $x, $y)