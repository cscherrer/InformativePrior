quote
    var"##4555" = (*)(-1.0, σ)
    var"##4556" = (log)(σ)
    var"##4557" = (*)(-10000, var"##4556")
    var"##4558" = (^)(β, 2)
    var"##4559" = (*)(-0.5, var"##4558")
    var"##4560" = (*)(15904.747631898405, β)
    var"##4561" = (*)(10110.01091266704, var"##4558")
    var"##4562" = (+)(48659.49356915616, var"##4560", var"##4561")
    var"##4563" = (^)(σ, -2)
    var"##4564" = (*)(-0.5, var"##4562", var"##4563")
    var"##4565" = (+)(var"##4555", var"##4557", var"##4559", var"##4564")
end