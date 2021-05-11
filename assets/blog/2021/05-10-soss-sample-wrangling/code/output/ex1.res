@model n begin
        σ ~ Exponential(λ = 1)
        β ~ Normal()
        α ~ Normal()
        x ~ Normal() |> iid(n)
        y ~ For(x) do xj
                Normal(α + β * xj, σ)
            end
        return y
    end
