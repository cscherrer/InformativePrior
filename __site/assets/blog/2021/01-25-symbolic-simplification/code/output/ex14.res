function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##26596" = (*)(-1.0, σ)
        var"##26597" = (log)(σ)
        var"##26598" = (*)(-10000, var"##26597")
        var"##26599" = (^)(β, 2)
        var"##26600" = (*)(-0.5, var"##26599")
        var"##26601" = (*)(12351.829381805781, β)
        var"##26602" = (*)(9913.26414391223, var"##26599")
        var"##26603" = (+)(114974.37815831495, var"##26601", var"##26602")
        var"##26604" = (^)(σ, -2)
        var"##26605" = (*)(-0.5, var"##26603", var"##26604")
        var"##26606" = (+)(var"##26596", var"##26598", var"##26600", var"##26605")
    end
end