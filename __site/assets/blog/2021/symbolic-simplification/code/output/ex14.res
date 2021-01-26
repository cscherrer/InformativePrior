function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_14269484959295921178).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_14269484959295921178).getproperty(_args, :x)
        var"##9261" = (*)(-1.0, σ)
        var"##9262" = (log)(σ)
        var"##9263" = (*)(-10000, var"##9262")
        var"##9264" = (^)(β, 2)
        var"##9265" = (*)(-0.5, var"##9264")
        var"##9266" = (*)(15904.747631898405, β)
        var"##9267" = (*)(10110.01091266704, var"##9264")
        var"##9268" = (+)(48659.49356915616, var"##9266", var"##9267")
        var"##9269" = (^)(σ, -2)
        var"##9270" = (*)(-0.5, var"##9268", var"##9269")
        var"##9271" = (+)(var"##9261", var"##9263", var"##9265", var"##9270")
    end
end