function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##22680" = (*)(-1.0, σ)
        var"##22681" = (log)(σ)
        var"##22682" = (*)(-10000, var"##22681")
        var"##22683" = (^)(β, 2)
        var"##22684" = (*)(-0.5, var"##22683")
        var"##22685" = (*)(12351.829381805781, β)
        var"##22686" = (*)(9913.26414391223, var"##22683")
        var"##22687" = (+)(114974.37815831495, var"##22685", var"##22686")
        var"##22688" = (^)(σ, -2)
        var"##22689" = (*)(-0.5, var"##22687", var"##22688")
        var"##22690" = (+)(var"##22680", var"##22682", var"##22684", var"##22689")
    end
end