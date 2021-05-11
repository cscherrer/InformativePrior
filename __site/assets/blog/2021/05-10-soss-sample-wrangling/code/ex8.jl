# This file was generated, do not modify it. # hide
@with mysim begin
    @with trace begin
        Ey = α .+ β .* x
        r = (y - Ey) / σ
        (;Ey, r)
    end
end