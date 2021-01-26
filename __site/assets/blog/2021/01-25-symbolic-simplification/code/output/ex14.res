function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##5608" = (*)(-1.0, σ)
        var"##5609" = (log)(σ)
        var"##5610" = (*)(-10000, var"##5609")
        var"##5611" = (^)(β, 2)
        var"##5612" = (*)(-0.5, var"##5611")
        var"##5613" = (*)(-7650.666581436265, β)
        var"##5614" = (*)(9853.309083277072, var"##5611")
        var"##5615" = (+)(3920.0185858104355, var"##5613", var"##5614")
        var"##5616" = (^)(σ, -2)
        var"##5617" = (*)(-0.5, var"##5615", var"##5616")
        var"##5618" = (+)(var"##5608", var"##5610", var"##5612", var"##5617")
    end
end