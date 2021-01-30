# This file was generated, do not modify it. # hide
using StatsPlots

times_d = [dμσ, dμ1, d0σ, d01]
times_m = [mμσ, mμ1, m0σ, m01]

times = [times_d ;times_m]* 1e6

pkg = repeat(["Distributions.jl", "MeasureTheory.jl"], inner=4)
dist = repeat(["Normal(μ,σ)", "Normal(μ,1)", "Normal(0,σ)", "Normal(0,1)"], outer=2)
groupedbar(dist, times, group=pkg, legend=:topleft)
ylabel!("Time (μs)")
savefig(joinpath(@OUTPUT, "dists-measuretheory-times.svg")) # hide