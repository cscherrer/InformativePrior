@model (x, s) begin
        σ ~ Exponential()
        @inbounds x[1] ~ Normal(σ = σ)
        n = length(x)
        @inbounds for j = 2:n
                x[j] ~ StudentT(1.5, x[j - 1], σ)
            end
    end
