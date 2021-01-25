function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_14269484959295921178).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :x)
        var"##4654" = (*)(-1.0, σ)
        var"##4655" = (log)(σ)
        var"##4656" = (*)(-10000, var"##4655")
        var"##4657" = (^)(β, 2)
        var"##4658" = (*)(-0.5, var"##4657")
        var"##4659" = (*)(15904.747631898405, β)
        var"##4660" = (*)(10110.01091266704, var"##4657")
        var"##4661" = (+)(48659.49356915616, var"##4659", var"##4660")
        var"##4662" = (^)(σ, -2)
        var"##4663" = (*)(-0.5, var"##4661", var"##4662")
        var"##4664" = (+)(var"##4654", var"##4656", var"##4658", var"##4663")
    end
end