function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##2122" = (*)(-1.0, σ)
        var"##2123" = (log)(σ)
        var"##2124" = (*)(-10000, var"##2123")
        var"##2125" = (^)(β, 2)
        var"##2126" = (*)(-0.5, var"##2125")
        var"##2127" = (*)(-6820.0864094810695, β)
        var"##2128" = (*)(9612.144339734084, var"##2125")
        var"##2129" = (+)(65131.71858394731, var"##2127", var"##2128")
        var"##2130" = (^)(σ, -2)
        var"##2131" = (*)(-0.5, var"##2129", var"##2130")
        var"##2132" = (+)(var"##2122", var"##2124", var"##2126", var"##2131")
    end
end