+++
title = "Measure Theory for Probabilistic Modeling"
hascode = true
rss = "Modern probabilistic modeling puts strong demands on the interface and implementation of libraries for probability distributions. MeasureTheory.jl is an effort to address limitations of existing libraries. In this post, we'll motivate the need for a new library and give an overview of the approach and its benefits."
+++
@def date = Date(2021,1,29)
@def rss_pubdate = Date(2021,1,29)
@def tags=["julia","probprog"]

# {{ title }}
_January 29, 2021_

_{{ rss }}_

**Contents**

\toc

## Introduction

Say you're working on a problem that requires some distribution computations. Probability density, tail probabilities, that sort of thing. So you find a library that's supposed to be good for this sort of thing, and get to it.

Along the way, there are bound to be some hiccups. Maybe you need to call `pmf` for discrete distributions and `pdf` for continuous ones. Or maybe the library has bounds checking for some distributions but not others, so you have to try to remember which is which.

This may be fine for writing this sort of thing "by hand". Probabilistic programming goes a step beyond this, taking a high-level representation of a model and automating much of the process.

That's great, but this automation comes at a price. Any quirks of the interface suddenly become painful sources of bugs, and take lots of case-by-case analysis to work around. Worse, it's not a one-time cost; any new distributions will require associated code to know how to call them. The whole thing becomes a bloated mess.

This calls for a library with goals like

- Creating new distributions should be straightforward,
- Calling conventions should be consistent across distributions,
- Types should be used for dispatch, and not as a restriction or documentation, and
- When possible (it usually is), log-densities should be algebraic expressions with no non-trivial control flow.

While we're at it, we'll address some issues with working in terms of distributions _at all_, and see some benefits of generalizing just a bit to instead work in terms of _measures_.

First, let's make things a little more concrete.

## Example: The Normal Distribution

[Distributions.jl](https://github.com/JuliaStats/Distributions.jl) is a popular Julia library for working with probability distributions. At ths time I'm writing this, its GitHub repository has 625 stars and 305 forks. It's highly visible, and many packages have it as a dependency. This also means changing it in any way can be very difficult.

Here's the [Distributions implementation](https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/continuous/normal.jl) of `Normal`:

```julia
struct Normal{T<:Real} <: ContinuousUnivariateDistribution
    μ::T
    σ::T
    Normal{T}(µ::T, σ::T) where {T<:Real} = new{T}(µ, σ)
end

function Normal(μ::T, σ::T; check_args=true) where {T <: Real}
    check_args && @check_args(Normal, σ >= zero(σ))
    return Normal{T}(μ, σ)
end
```

See the `T <: Real` sprinkled around? In `SymbolicUtils`, a symbolic representation of, say, a `Float64` would have type `Symbolic{Float64}`. But it's not `<: Real`, so this is a real headache (no pun intended).

There's also that `check_args`. This makes sure we don't end up with a negative standard deviation. And yes, it also causes problems for symbolic values, and has some small performance cost. But you can disable it, just by calling with `check_args=false`.

The bigger problem with this is that it's not consistent! Sure, you can call `Normal` with `check_args=false`. But for some other distributions, this would throw an error. So you end up needing a lookup table specifying how each distribution needs to be called. 

Anyway, checking the arguments isn't necessary! Any call to `pdf` or `logpdf` will need to compute `log(σ)`, which will throw an error if `σ < 0`.

Moving on, let's look at the implementation of `logpdf`:

```julia
function logpdf(d::Normal, x::Real)
    μ, σ = d.μ, d.σ
    if iszero(d.σ)
        if x == μ
            z = zval(Normal(μ, one(σ)), x)
        else
            z = zval(d, x)
            σ = one(σ)
        end
    else
        z = zval(Normal(μ, σ), x)
    end
    return _normlogpdf(z) - log(σ)
end

_normlogpdf(z::Real) = -(abs2(z) + log2π)/2
```

In addition to the `::Real` type constraint, there's some overhead for checking against special cases. As before, the issues are incompatibility with symbolic types, and some small overhead for the extra control flow.

## Normalization Factors

It's also worth noting the `-log2π/2` term in `_normlogpdf`. This is of course correct; it's a normalization factor that comes from the $\sqrt{2\pi}$ in the pdf

$$
f_{\text{Normal}}(x|μ,σ) = \frac{1}{σ \sqrt{2 \pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}\ \ .
$$

The thing is, we often don't need to normalize! For MCMC, we usually only know the log-density up to addition of a constant anyway. So any time spent computing this, however small, is a waste.

But sometimes we _do_ need it! So it seems silly to just discard this. What we really need is to have

- No extra cost for computing the normalization, but
- An easy way to recover it.

## The Normal Measure, in Four Lines of Code

Here's the implementation in MeasureTheory.jl:
 
```julia
@measure Normal(μ,σ) ≪ (1/sqrt2π) * Lebesgue(ℝ)

logdensity(d::Normal{()} , x) = - x^2 / 2 

Base.rand(rng::Random.AbstractRNG, T::Type, d::Normal{()}) = randn(rng, T)

@μσ_methods Normal()
``` 

Let's take these one by one.

### `@measure Normal(μ,σ) ≪ (1/sqrt2π) * Lebesgue(ℝ)`

This can be read roughly as

> _Define a new parameterized measure called `Normal` with default parameters `μ` and `σ`. The (log-)density will be defined later, and will have a normalization factor of $\frac{1}{\sqrt{2\pi}}$ with respect to Lebesgue measure on $\mathbb{R}$._

So then for example,

```!
using MeasureTheory
basemeasure(Normal())
```

and

```!
Normal() ≪ Lebesgue(ℝ)
```


### `logdensity(d::Normal{()} , x) = - x^2 / 2`

This defines the log-density relative to the base measure. There's no `μ` or `σ` yet, this is just for a standard normal.

If we really wanted this in "the usual way" (that is, with respect to Lebesgue measure), there's a three-argument form that lets us specify the base measure:

```!
logdensity(Normal(), Lebesgue(ℝ), 1.0)
```

which ought to match up with

```!
Dists.logpdf(Dists.Normal(), 1.0)
```

By the way, `MeasureTheory` exports `Distributions` as `Dists` for easy typing. And yes, exery `Dists.Distribution` can be used from MeasureTheory; you'll just miss out on some flexibility and performance.

### `Base.rand(rng::Random.AbstractRNG, T::Type, d::Normal{()}) = randn(rng, T)`

Hopefully this one is clear. One fine point worth mentioning is that some dispatch happening outside of this gives us some methods for free. So for example, we could do

```!
using Random # hide
rng = Random.GLOBAL_RNG
rand(rng, Float32, Normal())
```

but also

```!
rand(rng, Normal())
```

or

```!
rand(Float16, Normal())
```

or just

```!
rand(Normal())
```

### `@μσ_methods Normal()`

This is our last line, and we still haven't touched anything outside a standard normal (mean zero, standard deviation one).

But there's nothing about this last step that's specific to normal distributions; it's just one example of a [location-scale family](https://en.wikipedia.org/wiki/Location%E2%80%93scale_family). There's so much common behavior here across distributions, we should be able to abstract it.

So that's what we do! Here's the code generated by `@μσ_methods Normal()`:

```julia
function Base.rand(rng::AbstractRNG, T::Type, d::Normal{(:μ, :σ)})
    d.σ * rand(rng, T, Normal()) + d.μ
end

function logdensity(d::Normal{(:μ, :σ)}, x)
    z = (x - d.μ) / d.σ
    return logdensity(Normal(), z) - log(d.σ)
end

function Base.rand(rng::AbstractRNG, T::Type, d::Normal{(:σ,)})
    d.σ * rand(rng, T, Normal())
end

function logdensity(d::Normal{(:σ,)}, x)
    z = x / d.σ
    return logdensity(Normal(), z) - log(d.σ)
end

function Base.rand(rng::AbstractRNG, T::Type, d::Normal{(:μ,)})
    rand(rng, T, Normal()) + d.μ
end

function logdensity(d::Normal{(:μ,)}, x)
    z = x - d.μ
    return logdensity(Normal(), z)
end
```

Using this approach, we have just one family of measures call `Normal`, but several parameterizations. So far we have four:
- `Normal{()}`
- `Normal{(:μ,)}`
- `Normal{(:σ,)}`
- `Normal{(:μ, :σ)}`

And adding more is easy! Here are a few that might be convenient, depending on the application:
- `Normal{(:μ, :σ²)}` (mean and variance)
- `Normal{(:μ, :τ)}` (mean and inverse variance, also called _precision_)
- `Normal{(:μ, :logσ)}` (mean and log-standard-deviation, sometimes useful for MCMC)
- `Normal{(:q₀₁, :q₉₉)}` (quantiles)


## Performance

Let's set up a little benchmark. Given some arrays

```julia:randarrays
μ = randn(1000)
σ = rand(1000)
x = randn(1000)
y = randn(1000)
```

For each `i`, we'll
1. Build a `Normal(μ[i], σ[i])`
2. Evaluate the log-density of this at `x[i]`
3. Store the result in `y[i]`

We should expect big time differences for this versus a standard normal, so let's also measure this with fixed `μ`, fixed `σ`, and with both fixed. The only thing we really need to vary is the way we build the distribution or measure. So we can do this:

```julia:time_normal
using BenchmarkTools

function array_work(f, μ, σ, x, y)
    @inbounds for i in eachindex(x)
        y[i] = logdensity(f(μ[i], σ[i]), x[i])
    end
end

time_normal(f) = @belapsed $array_work($f, $μ, $σ, $x, $y)
```

The we can get the timings like this:

```julia:gettimes
mμσ = time_normal((μ,σ) -> Normal(μ,σ)) 
dμσ = time_normal((μ,σ) -> Dists.Normal(μ,σ; check_args=false))

mμ1 = time_normal((μ,σ) -> Normal(μ=μ)) 
dμ1 = time_normal((μ,σ) -> Dists.Normal(μ,1.0; check_args=false))

m0σ = time_normal((μ,σ) -> Normal(σ=σ)) 
d0σ = time_normal((μ,σ) -> Dists.Normal(0.0,σ; check_args=false))

m01 = time_normal((μ,σ) -> Normal())
d01 = time_normal((μ,σ) -> Dists.Normal())
```

And finally, a plot:

```julia:plottimes
using StatsPlots

times_d = [dμσ, dμ1, d0σ, d01]
times_m = [mμσ, mμ1, m0σ, m01]

times = [times_d ;times_m] / 1e3 * 1e9

pkg = repeat(["Distributions.jl", "MeasureTheory.jl"], inner=4)
dist = repeat(["Normal(μ,σ)", "Normal(μ,1)", "Normal(0,σ)", "Normal(0,1)"], outer=2)
groupedbar(dist, times, group=pkg, legend=:topleft)
ylabel!("Time per element (ns)")
savefig(joinpath(@OUTPUT, "dists-measuretheory-times.svg")) # hide
```

\fig{dists-measuretheory-times}

## Final Notes

We've really only scratched the surface of MeasureTheory.jl. There's also
- Multiple parameterizations for a given measure
- Using measures for "improper priors"
- Radon-Nikodym derivatives
- Singular measures, like spike and slab priors
- Markov kernels

The library is still changing quickly, and we'd love to have more community involvement. Please check it out!

[https://github.com/cscherrer/MeasureTheory.jl](https://github.com/cscherrer/MeasureTheory.jl)
