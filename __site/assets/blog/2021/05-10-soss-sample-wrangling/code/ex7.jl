# This file was generated, do not modify it. # hide
mytrace = mysim.trace
@with mytrace begin
    Ey = α .+ β .* x
    r = y - Ey
    (;Ey, r)
end