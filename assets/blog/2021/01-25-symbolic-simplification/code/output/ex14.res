function = (_args, _data, _pars;) -> begin
    begin
        β = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :β)
        σ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_pars, :σ)
        y = (Main.FD_SANDBOX_8265385389467078856).getproperty(_data, :y)
        λ = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :λ)
        x = (Main.FD_SANDBOX_8265385389467078856).getproperty(_args, :x)
        var"##664" = (*)(-1.0, σ)
        var"##665" = (log)(σ)
        var"##666" = (*)(-10000, var"##665")
        var"##667" = (^)(β, 2)
        var"##668" = (*)(-0.5, var"##667")
        var"##669" = (*)(-3049.4832999058835, β)
        var"##670" = (*)(9973.49212906119, var"##667")
        var"##671" = (+)(1153.5447289383212, var"##669", var"##670")
        var"##672" = (^)(σ, -2)
        var"##673" = (*)(-0.5, var"##671", var"##672")
        var"##674" = (+)(var"##664", var"##666", var"##668", var"##673")
    end
end