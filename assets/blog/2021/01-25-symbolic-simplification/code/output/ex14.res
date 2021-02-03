function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##1374" = (*)(-1.0, σ)
        var"##1375" = (log)(σ)
        var"##1376" = (*)(-10000, var"##1375")
        var"##1377" = (^)(β, 2)
        var"##1378" = (*)(-0.5, var"##1377")
        var"##1379" = (*)(-10516.391601146239, β)
        var"##1380" = (*)(9926.088553874832, var"##1377")
        var"##1381" = (+)(4397.346085970019, var"##1379", var"##1380")
        var"##1382" = (^)(σ, -2)
        var"##1383" = (*)(-0.5, var"##1381", var"##1382")
        var"##1384" = (+)(var"##1374", var"##1376", var"##1378", var"##1383")
    end
end