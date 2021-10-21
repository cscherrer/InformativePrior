+++
title = "Toward Low-Rank Bayesian Modeling"
hascode = true
+++
@def date = Date(2021,10,21)
@def rss_pubdate = Date(2021,10,21)
@def tags=["julia","probprog", "blurb"]
@def rss = """We discuss some ideas needed for low-rank modeling in probabilistic programming, along the way introducing the Stiefel manifold and the Grassmannian."""

# {{ title }}
_Oct 21, 2021_

_We discuss some ideas needed for low-rank modeling in probabilistic programming, along the way introducing the Stiefel manifold and the Grassmannian._

A common approach for making high-dimensional data more manageable is through [dimensionality
reduction](https://en.wikipedia.org/wiki/Dimensionality_reduction). The most
familiar for most of us is [principal component
analysis](https://en.wikipedia.org/wiki/Principal_component_analysis), though
there are [many other possibilities](https://web.stanford.edu/~boyd/papers/pdf/glrm.pdf).

Our goal here isn't to describe low-rank models in great detail (yet), but to
motivate one important ingredient. So keeping things high-level, we could
consider a generative model like

1. Pick a random $k$-dimensional subspace $s<\mathbb{R}^n$ 
2. Sample a point $x\in s$ from some distribution
3. Sample a point $y$ from a distribution centered at $x$.

We could write this in pseudo-Soss as

```julia
m = @model k,n begin
    s ~ RandomSubspace(k,n)
    x ~ SomeDistribution(s)
    y ~ MvNormal(μ=x)
end
```

As a special case, `SomeDistribution` may not be a distribution at all,
but Lebesgue measure (a "flat prior" over the subspace). If we fit this with
maximum likelihood, the loss is the sum of the squared distances to the
subspace, and we get exactly PCA.

More generally, this approach gives [factor
analysis](https://probml.github.io/pml-book/book0.html), for example
[probabilistic PCA](https://www.robots.ox.ac.uk/~cvrg/hilary2006/ppca.pdf).

# Sampling a Random Subspace

Now we get to the critical question: _How should we sample a random subspace?_

Let's work with a simple example to make things more concrete. We'll take $n=3$
and `SomeDistribution` will be multivariate normal with $\Sigma = \mathrm{I}$.
We'll start with $k=1$, then move on to $k=2$.

## $k = 1$

To determine a subspace (through the origin -- we want a _linear_ space, not an
_affine_ space), it's enough to specify any non-origin point that lies on it.

Well, it's not quite that simple, since many of these points will correspond to
the same subspace. By definition, for any $v\in s$ and $\alpha\in\mathbb{R}$, we
also have $\alpha v\in s$.

So we need some constraints on $v$:
1. $\|v\| = 1$, and
2. The first component of $v$ is positive.

Besides helping pin down the correspondence, (1) is important for making sure the
$\mathbb{R}^k \to \mathbb{R}^n$ embedding is _rigid_. So for example, the
expected norm will be the same before and after embedding. Without this,
reasoning about our model would be very difficult.

(2) is a bit more arbitrary, but will become natural when we express this in
matrix form.

## $k = 2$

So far, so good. At this point we might optimistically hope to do the same thing
twice. Pick $v_1$ and $v_2$, and be done with it. This doesn't work, because we need $v_1$ and $v_2$ to be orthogonal. This is
again part of the rigidity requirement.

If we take every such $v_1$ and $v_2$ (well, without the positivity constraint), the result is the [Stiefel
manifold](https://en.wikipedia.org/wiki/Stiefel_manifold),
a term I hadn't heard before [Sean Pinkney](https://twitter.com/thatpinkney)
mentioned it on Twitter. A call with [Seth Axen](https://twitter.com/sethaxen) helped clear up some
details on the Stiefel manifold. But for this application, I think it's still
not quite what we need.

A big concern in modeling (Bayesian or not) is
[identifiability](https://en.wikipedia.org/wiki/Identifiability). Different
parameters should always yield different distributions.

For our isotropic Gaussian on $s$, we could rotate the basis or flip it around,
and there's no difference. The Stiefel manifold needs to be further constrained.

# The Grassmannian

It turns out the thing we're looking for already has a name. The
[Grassmannian](https://en.wikipedia.org/wiki/Grassmannian) $\mathrm{Gr}(k,n)$ is
the manifold of all $k$-dimensional subspaces of $\mathbb{R}^n$.

Outside of our problem, people doing numerical work with the Grassmannian need
mapping from any subspace to a (unique) matrix. But what's convenient for one
problem might not work well for another.

A common approach is to use the identity matrix "on top of" an abitrary matrix.
For example, an element of $\mathrm{Gr}(4,7)$ might be represented as

```julia:ex0
using LinearAlgebra

k = 4
n = 7

W = [I; randn(n - k, k)]
```
\show{ex0}

Again, this won't quite work for our purposes. We need to be able to take a
4-dimensional standard normal and multiply it to rigidly embed in 7 dimensions.
The span is right, but it fails our criteria from above.

## Making it work

So let's fix it! We can transform this to another set of columns with the
same span, that actually meet our needs. It's still the same Grassmannian, just
a different choice of representative for each subspace.

First, the QR decomposition helps us find an orthonormal basis:
```julia:ex3
Q = Matrix(first(qr(W)))
```
\show{ex3}

Next we can impose lower triangularity:
```julia:ex4
L = first(lq(Q))
```
\show{ex4}

Finally, we need to make sure the diagonal is positive:
```julia:ex5
V = L * Diagonal(sign.(diag(L)))
```
\show{ex5}

Putting all of this into a function, we get
```julia:WtoV
function WtoV(W)
    Q = Matrix(first(qr(W)))
    L = first(lq(Q))
    V = L * Diagonal(sign.(diag(L)))
    return V
end
```

## Checking the span

It's clear from the zeros that $W$ and $V$ both have rank 4. To check that they
have the same span, we can compute
```julia:spancheck
rank([W V])
```
\show{spancheck}

Since the rank hasn't increased, the spans must be the same.

## Going back

The inverse takes a little more hand-coding, but it's still not too bad:
```julia:VtoW
function VtoW(V)
    # Makes ones on the diagonal
    W = V / Diagonal(diag(V))

    # Gaussian elimination to clear the top
    for editcol in 1:k
        for refcol in (editcol + 1):k
            m = -W[refcol, editcol]
            for i in refcol:n
                W[i, editcol] += m * W[i, refcol]
            end
        end
    end
    return W
end
```

And a quick check that we got the inverse right:
```julia:checkcomposition
(WtoV ∘ VtoW)(V) ≈ V  &&  (VtoW ∘ WtoV)(W) ≈ W
```
\show{checkcomposition}

# So what's left?

The standard approach (originating in Stan, I think?) is to work in terms of a
map from unconstrained real vectors to whatever space you're interested in. And
while it's easy to take a length 12 vector, build a $W$, and then just compute
`WtoV(W)`, that has some problems:
1. It's not a very direct path. There are very likely redundant computations, and worse there are lots of allocations along the way. 
2. We also need the log absolute determinant of the Jacobian. This might be easier than it looks, but it's not obvious.

Ideally, we want something that takes a vector $x$ and traverses it only once,
accumulating the log-Jacobian as it goes. Is that possible in this case? If not,
how close can we get?
