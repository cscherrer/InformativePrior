function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##25528" = (*)(-1.0, σ)
        var"##25529" = (log)(σ)
        var"##25530" = (*)(-10000, var"##25529")
        var"##25531" = (^)(β, 2)
        var"##25532" = (*)(-0.5, var"##25531")
        var"##25533" = (*)(12351.829381805781, β)
        var"##25534" = (*)(9913.26414391223, var"##25531")
        var"##25535" = (+)(114974.37815831495, var"##25533", var"##25534")
        var"##25536" = (^)(σ, -2)
        var"##25537" = (*)(-0.5, var"##25535", var"##25536")
        var"##25538" = (+)(var"##25528", var"##25530", var"##25532", var"##25537")
    end
end