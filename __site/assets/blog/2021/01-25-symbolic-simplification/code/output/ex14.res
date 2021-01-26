function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##23748" = (*)(-1.0, σ)
        var"##23749" = (log)(σ)
        var"##23750" = (*)(-10000, var"##23749")
        var"##23751" = (^)(β, 2)
        var"##23752" = (*)(-0.5, var"##23751")
        var"##23753" = (*)(12351.829381805781, β)
        var"##23754" = (*)(9913.26414391223, var"##23751")
        var"##23755" = (+)(114974.37815831495, var"##23753", var"##23754")
        var"##23756" = (^)(σ, -2)
        var"##23757" = (*)(-0.5, var"##23755", var"##23756")
        var"##23758" = (+)(var"##23748", var"##23750", var"##23752", var"##23757")
    end
end