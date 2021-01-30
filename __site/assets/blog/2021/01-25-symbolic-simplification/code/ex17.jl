# This file was generated, do not modify it. # hide
before = @elapsed dynamicHMC(post)
after = @elapsed dynamicHMC(post; ℓ=ℓ)

speedup = before / after

@show before, after, speedup