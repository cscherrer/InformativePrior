function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##24104" = (*)(-1.0, σ)
        var"##24105" = (log)(σ)
        var"##24106" = (*)(-10000, var"##24105")
        var"##24107" = (^)(β, 2)
        var"##24108" = (*)(-0.5, var"##24107")
        var"##24109" = (*)(12351.829381805781, β)
        var"##24110" = (*)(9913.26414391223, var"##24107")
        var"##24111" = (+)(114974.37815831495, var"##24109", var"##24110")
        var"##24112" = (^)(σ, -2)
        var"##24113" = (*)(-0.5, var"##24111", var"##24112")
        var"##24114" = (+)(var"##24104", var"##24106", var"##24108", var"##24113")
    end
end