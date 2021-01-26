function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##25172" = (*)(-1.0, σ)
        var"##25173" = (log)(σ)
        var"##25174" = (*)(-10000, var"##25173")
        var"##25175" = (^)(β, 2)
        var"##25176" = (*)(-0.5, var"##25175")
        var"##25177" = (*)(12351.829381805781, β)
        var"##25178" = (*)(9913.26414391223, var"##25175")
        var"##25179" = (+)(114974.37815831495, var"##25177", var"##25178")
        var"##25180" = (^)(σ, -2)
        var"##25181" = (*)(-0.5, var"##25179", var"##25180")
        var"##25182" = (+)(var"##25172", var"##25174", var"##25176", var"##25181")
    end
end