function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_14269484959295921178).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :x)
        var"##4397" = (*)(-1.0, σ)
        var"##4398" = (log)(σ)
        var"##4399" = (*)(-10000, var"##4398")
        var"##4400" = (^)(β, 2)
        var"##4401" = (*)(-0.5, var"##4400")
        var"##4402" = (*)(15904.747631898405, β)
        var"##4403" = (*)(10110.01091266704, var"##4400")
        var"##4404" = (+)(48659.49356915616, var"##4402", var"##4403")
        var"##4405" = (^)(σ, -2)
        var"##4406" = (*)(-0.5, var"##4404", var"##4405")
        var"##4407" = (+)(var"##4397", var"##4399", var"##4401", var"##4406")
    end
end