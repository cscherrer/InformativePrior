+++
title = "Probabilistic Modeling with Tilde.jl"
hascode = true
+++
@def date = Date(2022, 3, 23)
@def rss_pubdate = Date(2022, 3, 23)
@def tags=["julia","probprog", "tilde"]
@def rss = """We introduce Tilde, a new probabilistic programming language and successor to Soss."""

# {{title}}
_March 23, 2022_

_We introduce [Tilde](https://github.com/cscherrer/Tilde.jl), a new probabilistic programming language and successor to [Soss](https://github.com/cscherrer/Soss.jl)._

## From Soss to Tilde

[Soss.jl](https://github.com/cscherrer/Soss.jl) makes it easy to work with generative models. "Work with" includes the usual things like sampling from the prior and evaluating the log-density of the posterior (leading naturally to inference methods like HMC), but also to do some less common manipulations like transforming one model into another.

Soss models look very much like a specification you might see in a text or journal article. For example, here's a modified implementation of the model from the [Sample Wrangling](../2021/05-10-soss-sample-wrangling) post:

```julia
soss_example = @model n begin
    α ~ Normal()
    β ~ Normal()
    x ~ Normal() |> iid(n)
    σ ~ Exponential()
    ŷ = α .+ β .* xj
    y ~ For(x) do xj
        Normal(ŷ[j], σ)
    end
    return y
end
```

You might notice that in the body of the model, everything up to `return y` is either of the form `lhs ~ rhs` or `lhs = rhs`. In Soss, the left side of each `~` or `=` must be a symbol. In particular, Soss doesn't allow things like `y[j] ~ Normal()`. The advantage to this approach is that is makes it very easy to determine the graph, and to define model transformations like prior or predictive distributions.

But sometimes we need more flexibility. Maybe we'd like to define dependencies using a `for` loop, or even execute arbitrary Julia code as part of the model. We can do this with [Tilde.jl](https://github.com/cscherrer/Tilde.jl).

```julia
tilde_example = @model (x, s) begin
    σ ~ Exponential()
    @inbounds x[1] ~ Normal(σ = σ)
    n = length(x)
    @inbounds for j = 2:n
        x[j] ~ StudentT(1.5, x[j - 1], σ)
    end
end
```

## Semantics

Semantics in probabilistic programming can be tricky, because a model can be "run" in different ways. That is, there's no single `~` function to tell us what `y[j] ~ Normal()` actually means. A common approach is to use *monadic semantics*, which treat `~` similarly to `<-` in Haskell's `do` notation. But similar to Soss, this requires the left-side to be a new symbol to be bound to a value.

Instead, let's think of some common use cases. From experience, the two most common interpretations are *log-density evaluation* and *sampling*. In Tilde, both of these are implemented in terms of "running the model" a single time. We refer to the abstractions to support such a single execution as _primitives_. In these cases, the primitives are the new methods for `logdensityof` and `rand`, respectively.

To evaluate the log-density of a model, we need to be given values for all of the parameters. Then we set `ℓ = 0.0` and step through the model. When we see something like `σ ~ Exponential()`, it becomes `ℓ += logdensityof(Exponential(), σ)`. Similarly, `y[j] ~ Normal()` can become `ℓ += logdensityof(Normal(), y[j])`. At the end, we return the value of `ℓ`. The `logdensityof` primitive must account for all of this.

By contrast in the sampling interpretation, `σ ~ Exponential()` usually becomes `σ = rand(Exponential())`. Similarly, `y[j] ~ Normal()` becomes `y[j] = rand(Normal())`.

There are a couple of interesting things about this. First, unlike sampling into a new variable like `σ`, sampling into `y[j]` in this way requires that `y` already exist. It could be allocated as part of the model, or (more interestingly, in my opinion) passed as an argument to the model. In the latter case, we can think of this not as passing data, but as passing a block of memory for the model to use.

We should also consider *mutability*. We've implicitly assumed `y` is a `Vector`; what if the user instead passes a `StaticVector`? In this case `y[j] = rand(Normal())` makes no sense; we need something more general.

Fortunately, this problem has already been solved by the [BangBang.jl](https://github.com/JuliaFolds/BangBang.jl) package. The interface is based around an elegant idea, which we can summarize as _always return the modified value (if it's mutable), or a new copy (if it's immutable)_. Because the return values are consistent, we can use the same code for mutable or immutable inputs.

## Accessors

BangBang.jl is built around [Setfield.jl](https://github.com/jw3126/Setfield.jl). But as a successor to Soss, Tilde instead uses [Accessors.jl](https://github.com/JuliaObjects/Accessors.jl). As we'll see, the interface we need is lower-level than BangBang.jl, so this is not really a problem. In the end, we'll implement a thin wrapper in Accessors that takes inspiration from BangBang. But to begin with, let's just take this as motivation to work in terms of [_lenses_](https://juliaobjects.github.io/Accessors.jl/stable/lenses/).

The main idea is that we can treat `x ~ dist` as syntax sugar for the "real" code, where the left side of a `~` is always a pair of a value and a lens. So for example,

- `σ ~ Exponential()` means `(σ, @optic _) ~ Exponential()`, and
- `y[j] ~ Normal` means `(y, @optic _[j])`.

[*N.B.*  There may be subtle technical distinctions, but in this article we use "optic" and "lens" as synonyms.]

It's worth mentioning that these `@optic` expressions simplify further:

- `(@optic _) == identity`, and
- `(@optic _[j]) == Accessors.IndexLens((j,))`.

## Configurations and contexts

As for any program, execution of any primitive on a given model involves passing variables around. Some of these variables are defined or modified by the model itself, and should be expected to behave in the same way irresepective of the interpretation. Beyond these, we can consider two classes, which we call the _context_ and the _configuration_.

The *context* contains interpretation-specific values that change during execution. For sampling, this can include any sampled values (unless the user only wants the return value). For log-density evaluation, it might consist of only the log-density itself.

By contrast, the *configuration* is "static", for example parameter values in a log-density evaluation. The scare quotes here are because the configuration might contain mutable values that are modified as a side effect. In particular, it's sensible for a random number generator to be included as part of the configuration.

The configuration and context could have been lumped into a single data structure. But separating things in this way feels natural given the different access patterns. It separates concerns, and gives us flexibility to use different data structures reflecting the difference in access patterns.

## The `tilde` function

Depending on the primitive (the interpretation of the model, e.g. log-density or sampling), the model statement `y[j] ~ Normal()` might change three things:

1. The *value* of `y`,
2. The *context*, and
3. The *return value*.

These can depend on a few different inputs:

1. The *lens*, in this case `@optic _[j]`
2. The *name* of the current variable. This is coded as `static(:y)`, which evaluates to `StaticSymbol{:y}()`. Having the name at the type level makes it easy to dispatch on the name or use generated functions, which can be important in some cases.
3. The *value* of the current variable (`y`)
4. The *measure* (often, but not always, a distribution) on the right side of the `~`
5. The *configuration*
6. The *context*

This suggests replacing each `lhs ~ rhs` with an assignment of the former three values to some function of the latter six. But if we want the convenience of having a single function for this purpose, also need something to dispatch on that indicates what we're currently doing. So for dispatch purposes, we include an initial argument `f`, typically a function.

Putting all of this together, `tilde` has the form

```
tilde(f, lens, xname, xval, measure, cfg, ctx) 
    -> (new_xval, new_ctx, retn)
```

So for example, when we call `rand` on a model containing `y[j] ~ Normal()`, that line is rewritten as

```julia
(y, _ctx, _retn) = 
    tilde(rand, (@optic _[j]), static(:y), y, Normal(), _cfg, _ctx)
```

The leading underscores are to avoid collision with user-defined names in the model.

## `ReturnNow`

In some cases it's useful to allow a primitive to exit before the model has been fully evaluated. To allow for this, Tilde includes a wrapper
```julia
struct ReturnNow{T}
    value::T
end
```

If the `_retn` from a call to `tilde` is a `ReturnNow`, Tilde will interrupt evaluation and return that value immediately.

## `Lens!!`

As described above, Tilde will automatically determine the lens for the left side of any `~` expression. But this lens already has a defined behavior in Accessors.jl. Sometimes we want to change that, and make things behave as they do in BangBang.jl.

Thankfully, Accessors includes a nice description of how to extend it, which you can find [here](https://juliaobjects.github.io/Accessors.jl/stable/examples/custom_macros/). This, together with some basic understanding of BangBang semantics, made it relatively easy to build the wrapper

```julia
struct Lens!!{L}
    pure::L
end
```

Applying this to any lens results in a new "BangBang-like" lens. You can find details on this in [Tilde.jl/src/optics.jl](https://github.com/cscherrer/Tilde.jl/blob/main/src/optics.jl).

## Defining `rand`

We're finally to a point where we can describe how `rand` is actually implemented. The method is defined like this:

```julia
@inline function Base.rand(rng::AbstractRNG, m::ModelClosure; ctx=NamedTuple())
    cfg = (rng=rng,)
    gg_call(m, rand, cfg, ctx, KeepReturn())
end
```

`gg_call` uses [GeneralizedGenerated.jl](https://github.com/JuliaStaging/GeneralizedGenerated.jl) to "run the model", replacing each `~` with a call to `tilde` as we've discussed.

The last argument, `KeepReturn()`, signals that any `return` statements in the model should be respected. By constrast, functions like `logdensityof` need to ignore these, which is indicated by instead passing `DropReturn()` in this position.

Then it's just a matter of defining `tilde`. In this case that's

```julia
@inline function tilde(::typeof(Base.rand), lens, xname, x, measure, cfg, ctx::NamedTuple)
    xnew = set(x, Lens!!(lens), rand(cfg.rng, measure))
    ctx′ = merge(ctx, NamedTuple{(dynamic(xname),)}((xnew,)))
    (xnew, ctx′, ctx′)
end
```

Well, there's a little more to it. If we have something like `σ ~ Exponential()`, the `σ` variable wouldn't be defined when we get to it, so the `xnew = ...` line will throw an error. But in that case, `lens` is always the identity function, so we can catch this situation by adding another method:

```julia
@inline function tilde(::typeof(Base.rand), lens::typeof(identity), xname, x, measure, cfg, ctx::NamedTuple)
    xnew = rand(cfg.rng, measure)
    ctx′ = merge(ctx, NamedTuple{(dynamic(xname),)}((xnew,)))
    (xnew, ctx′, ctx′)
end
```

And that's it! This is much simpler than defining methods like this in Soss.

## AST manipulations

Just as in Soss, Tilde maintains the original AST. For a model like

```julia:m
using Tilde

m = @model (x, s) begin
    σ ~ Exponential()
    @inbounds x[1] ~ Normal(σ = σ)
    n = length(x)
    @inbounds for j = 2:n
        x[j] ~ StudentT(1.5, x[j - 1], σ)
    end
end
```

`m` has properties

```julia:m-args
m.args
```

\show{m-args}

and 

```julia:m-body
m.body
```

\show{m-body}

One part of upcoming Tilde development will be adding methods to make it easy to turn a given user-defined AST transform into a Tilde model transform.

## Closing Remarks

Tilde is still in the early stages, but I'm very happy with how it's shaping up so far. If you have any questions, please check out the [Julia Zulip](https://julialang.zulipchat.com) (`measuretheory.jl` or `soss.jl` channels, until there's a Tilde-specific one), or ping me on [Twitter](https://twitter.com/ChadScherrer) (public if you can, in case others are interested).

Thanks for making it this far; I hope you'll check out [Tilde](https://github.com/cscherrer/Tilde.jl)!