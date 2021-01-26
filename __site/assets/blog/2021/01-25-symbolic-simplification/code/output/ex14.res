function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##23392" = (*)(-1.0, σ)
        var"##23393" = (log)(σ)
        var"##23394" = (*)(-10000, var"##23393")
        var"##23395" = (^)(β, 2)
        var"##23396" = (*)(-0.5, var"##23395")
        var"##23397" = (*)(12351.829381805781, β)
        var"##23398" = (*)(9913.26414391223, var"##23395")
        var"##23399" = (+)(114974.37815831495, var"##23397", var"##23398")
        var"##23400" = (^)(σ, -2)
        var"##23401" = (*)(-0.5, var"##23399", var"##23400")
        var"##23402" = (+)(var"##23392", var"##23394", var"##23396", var"##23401")
    end
end