function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_14269484959295921178).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :x)
        var"##15926" = (*)(-1.0, σ)
        var"##15927" = (log)(σ)
        var"##15928" = (*)(-10000, var"##15927")
        var"##15929" = (^)(β, 2)
        var"##15930" = (*)(-0.5, var"##15929")
        var"##15931" = (*)(15904.747631898405, β)
        var"##15932" = (*)(10110.01091266704, var"##15929")
        var"##15933" = (+)(48659.49356915616, var"##15931", var"##15932")
        var"##15934" = (^)(σ, -2)
        var"##15935" = (*)(-0.5, var"##15933", var"##15934")
        var"##15936" = (+)(var"##15926", var"##15928", var"##15930", var"##15935")
    end
end