function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##23036" = (*)(-1.0, σ)
        var"##23037" = (log)(σ)
        var"##23038" = (*)(-10000, var"##23037")
        var"##23039" = (^)(β, 2)
        var"##23040" = (*)(-0.5, var"##23039")
        var"##23041" = (*)(12351.829381805781, β)
        var"##23042" = (*)(9913.26414391223, var"##23039")
        var"##23043" = (+)(114974.37815831495, var"##23041", var"##23042")
        var"##23044" = (^)(σ, -2)
        var"##23045" = (*)(-0.5, var"##23043", var"##23044")
        var"##23046" = (+)(var"##23036", var"##23038", var"##23040", var"##23045")
    end
end