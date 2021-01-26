function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##4698" = (*)(-1.0, σ)
        var"##4699" = (log)(σ)
        var"##4700" = (*)(-10000, var"##4699")
        var"##4701" = (^)(β, 2)
        var"##4702" = (*)(-0.5, var"##4701")
        var"##4703" = (*)(-7650.666581436265, β)
        var"##4704" = (*)(9853.309083277072, var"##4701")
        var"##4705" = (+)(3920.0185858104355, var"##4703", var"##4704")
        var"##4706" = (^)(σ, -2)
        var"##4707" = (*)(-0.5, var"##4705", var"##4706")
        var"##4708" = (+)(var"##4698", var"##4700", var"##4702", var"##4707")
    end
end