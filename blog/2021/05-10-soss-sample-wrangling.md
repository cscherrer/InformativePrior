+++
title = "Blurb: Forward Sample Exploration in Soss"
hascode = true
+++
@def date = Date(2021,5, 10)
@def rss_pubdate = Date(2021,5, 10)
@def tags=["julia","probprog", "blurb"]
@def rss = """Over the past few months, we've made some big improvements to our tools for working with samples in Soss. This short post gives an update."""

# {{ title }}
_May 10, 2021_

_Over the past few months, we've made some big improvements to our tools for working with samples in Soss. This short post gives an update._

Say you have a linear model

```julia:ex1
using Soss
using MeasureTheory
using TupleVectors

m = @model n begin
    α ~ Normal()
    β ~ Normal()
    x ~ Normal() |> iid(n)
    σ ~ Exponential(λ=1)
    y ~ For(x) do xj
        Normal(α + β * xj, σ)
    end
    return y
end
```

You can "run" the model like this:

```julia:ex2
rand(m(3))
```
\show{ex2}

If you want more (iid) samples from the model, you can do

```julia:ex3
rand(m(3),5)
```
\show{ex3}

Note the `ArraysOfArrays`. The underlying storage is a single `Matrix`. Still, this quickly becomes a wall of numbers that's hard to track. We'll  be adding more tools to make `rand` output easy to work with (Note to self...). But for now, let's compare `simulate`:

```julia:ex4
simulate(m(3), 5)
```
\show{ex4}

Much better! Now we can easily do things like

```julia:ex5
mysim = simulate(m(3), 1000)
```
\show{ex5}

Just to be clear, what we're looking at here is a summary of 1000 samples. Here's one of them:
```julia:ex6
mysim[1]
```
\show{ex6}

It can be handy to make the names of a `TupleVector` available as variables, transform them, and then wrap the result into a new `TupleVector`. For that, we have `@with`. Here are the expected `y` values and studentized residuals

```julia:ex7
mytrace = mysim.trace
@with mytrace begin
    Ey = α .+ β .* x
    r = (y - Ey) / σ
    (;Ey, r)
end
```
\show{ex7}

We could even be a little fancy and do 

```julia:ex8
@with mysim begin
    @with trace begin
        Ey = α .+ β .* x
        r = (y - Ey) / σ
        (;Ey, r)
    end
end
```
\show{ex8}

You can do this with posterior samples too! Let's save that one for next time.
