# This file was generated, do not modify it. # hide
ℓ = symlogdensity(post)
f = codegen(post; ℓ=ℓ)
fast = @benchmark $f($(;x,λ), $(;y), $trace)