+++
title = "Symbolic Simplification"
hascode = true
rss = "Upcoming features in Soss.jl include static model simplification. After a one-time compilation cost, posterior log-densities for many models become constant cost, independent of the number of observations. Bayesian analysis for such models can easily scale to big data. The symbolic representation of the posterior log-density can also be useful for pedagogical purposes."
+++
@def date = Date(2021,1,25)
@def rss_pubdate = Date(2021,1,25)
@def tags=["julia","probprog"]

# Symbolic Simplification
_January 25, 2021_

_Upcoming features in [Soss.jl](https://github.com/cscherrer/Soss.jl) include static model simplification. After a one-time compilation cost, posterior log-densities for many models become "constant cost", independent of the number of observations. Bayesian analysis for such models can easily scale to big data._

_The symbolic representation of the posterior log-density can also be useful for pedagogical purposes._


\toc

## First, a Model

Let's start with something simple, say a linear regression with 10,000 observations.

```julia:model
using Soss

N = 10000

m = @model x, λ begin
    σ ~ Exponential(λ)
    β ~ Normal(0,1) 
    y ~ For(1:N) do j
        Normal(x[j] * β, σ)
    end
    return y
end
```

Soss models are _generative_, so we can use one to generate data. This is useful to help make sure the model assumptions are reasonable (fake data should look similar to real data), and it's also handy for little examples like this.

To generate data from `m`, we need to have values for the _input arguments_ `x` and `λ`:

```julia:ex4
x = randn(N)
λ = 1.0
```

Given this, we could just call `rand(m(x=x,λ=λ))`. But this would "forget" the values of `σ` and `β`. To instead keep track of these, we can do

```julia:ex5
trace = simulate(m(x=x, λ=1.0)).trace
y = trace.y
```

```julia:ex6
using Statistics #hide
@show trace.σ #hide
@show trace.β #hide
@show mean(y) #hide
@show std(y)  #hide
```

As a result, we now have
     
\show{ex6}

## Evaluating the Log-Density (The Punchline)

In Bayesian modeling, we're usually in a situation of having observed `y`, and wanting to infer what we can about latent parameters like `σ` and `β`. So let's construct the posterior distribution. We could write this as `post = m(x=x, λ=λ) | (y=y,)`, or using the shorthand

```julia:ex7
post = m(; x, λ) | (; y)
```

To evaluate this, say on the `trace` from the original sample, we just call

```julia:ex8
logdensity(post, trace)
```

which in this case gives 

\show{ex8}

Let's see how fast it is.

```julia:ex9
using BenchmarkTools
slow = @benchmark $logdensity($post, $trace)
```

\show{ex9}

Ok, clearly some things can be improved, for example we should be able to do this without allocation.

But rather than dwell too much on that, let's jump to the punchline:

```julia:ex10
ℓ = symlogdensity(post)
f = codegen(post; ℓ=ℓ)
fast = @benchmark $f($(;x,λ), $(;y), $trace)
```

\show{ex10}


```julia:ex11
speedup = round(Int,minimum(slow).time / minimum(fast).time) #hide
print("**$speedup× speedup**") #hide
```

Note the units; we started out in milliseconds, but now we're in nanoseconds. A quick `minimum(slow).time / minimum(fast).time` shows we've gotten a \textoutput{ex11}.

## How it Works

`ℓ` is a symbolic expression from [`SymbolicUtils.jl`](https://juliasymbolics.github.io/SymbolicUtils.jl/). To build it, we first generate a trace, as we did above. Now we have all of the types, so we can evaluate the log-density again, this time replacing the values with symbolic variables of the appropriate type.

At this point, we have a symbolic expression, and we also have a dictionary of fixed values from the arguments and observed values. So we expand the expression and then walk the result, looking for subexpressions that evaluate to scalars with no free variables. When we find one, we use the dictionary to rewrite it.

Next, we do [common subexpression elimination](https://en.wikipedia.org/wiki/Common_subexpression_elimination), which just makes sure we don't evaluate the same thing twice.

```julia:ex12
Soss.cse(ℓ)
```

\show{ex12}

It's a very short step to get from that to a Julia `Expr` that does what we want:

```julia:ex13
sourceCodegen(post)
```

\show{ex13}

Finally we add some code to tell us where to get the variables, and use [`GeneralizedGenerated.jl`](https://github.com/JuliaStaging/GeneralizedGenerated.jl) to make it callable:

```julia:ex14
codegen(post; ℓ=ℓ)
```

\show{ex14}

# Accelerating Inference

After calling `symlogdensity` as above, you can manipulate the result however you like using [SymbolicUtils.jl](https://github.com/JuliaSymbolics/SymbolicUtils.jl). When you're happy with the result, it's easy to use this in inference. Here it is with Tamas Papp's [DynamicHMC.jl](https://github.com/tpapp/DynamicHMC.jl):

```julia:ex15
t_inference = print(round(@elapsed begin #hide
postsample = dynamicHMC(post; ℓ=ℓ)
end; sigdigits=4)) #hide
```

On my machine, this takes **\textoutput{ex15} seconds**. Not bad for MCMC on 10,000 observations.

# Limiting Inlining

In the above example, we took every opportunity for [constant folding](https://en.wikipedia.org/wiki/Constant_folding), as long as the result is a scalar. In some cases, that might be too much. For example, we expect to be able to use this approach to also accelerate [variational inference](https://en.wikipedia.org/wiki/Variational_Bayesian_methods), in which case we ought to avoid recompiling every time we change the variational parameters.

To account for this, we have a `noinline` switch that allows specification of variables to leave alone. For example,

```julia:ex12
ℓλ = symlogdensity(post; noinline=(:λ,))
```

which results in 

\show{ex12}

# When Does This Work?

Cases where `symlogdensity` "works" in the sense of "doesn't break" are growing quickly; I expect that with some modest effort we can get to a point where every models gives _some_ result that's at least as efficient as the direct approach.

The great speedups we're seeing in this example come thanks in large part to the normal distribution (for the observations) is an exponential family. This means sufficient statistics are of a fixed dimenionality independent of the number of observations. The most obvious applicability I see is for [generalized linear models](https://en.wikipedia.org/wiki/Generalized_linear_model).

There's still some possibility to get big speedups outside of exponential families by rewriting distributions to use exponential families as building blocks. For example, [Student's T distribution can be written as a mixture of normals](https://www.johndcook.com/t_normal_mixture.pdf). The mixture components come from an inverse gamma distribution, so in this case we'd expect to be able to "sum away" the normal components, so what we're left with is in terms of inverse gammas.

## HMC Timing

On Twitter, Colin Carroll had a great question:

~~~
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">You mention the timing for DynamicHMC is 2.309 seconds -- do you know what it is without the symbolic simplification? I would expect the log probability does not dominate here, but maybe this also speeds up gradient evaluations?</p>&mdash; Colin Carroll (@colindcarroll) <a href="https://twitter.com/colindcarroll/status/1353915466444640257?ref_src=twsrc%5Etfw">January 26, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 
~~~

[Franklin re-runs the code, so the timings will vary a bit]

```julia:ex13
before = @elapsed dynamicHMC(post)
after = @elapsed dynamicHMC(post; ℓ=ℓ)

speedup = before / after

@show before, after, speedup
```

\show{ex13}

The result is not nearly as dramatic as we saw for evaluation, but it's still substantial. Like all the best questions, the answer to this one raises plenty more questions, which we'll look into another time.

## Related Research

[Hakaru](https://hakaru-dev.github.io/), a Haskell-based probabilistic programming language, also has a strong focus on symbolic simplification. Hakaru is excellent work and is much more ambitious in the available transformations, but for our purposes we find the advantages of the Julia language and ecosystem too great to step away from.

Avi Bryant's Scala-based [Rainier](https://rainier.fit/docs/probprog) system is very similar in its goals and the available rewrites, and is more mature than this work. There are likely differences in both extensibility and performance, though that's not yet clear. We'll need to consider this in future work.

## Final Thoughts

This work is still in relatively early stages, but I think there's a huge potential. If you think this can be helpful for your work, please get in touch!
