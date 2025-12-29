# CasADi.jl

[![Join the chat at https://julialang.zulipchat.com #sciml-bridged](https://img.shields.io/static/v1?label=Zulip&message=chat&color=9558b2&labelColor=389826)](https://julialang.zulipchat.com/#narrow/stream/279055-sciml-bridged)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor%27s%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)

## Introduction

This package is an interface to CasADi, a powerful symbolic framework for automatic differentiation and optimal control.
More information are available on the [official website](https://web.casadi.org).
Although Julia has excellent libraries for optimization, they have not reached the maturity of CasADi for nonlinear optimization and optimal control yet.
This library aims to give easy access to its powerful capabilities.

Please note: This repo is unofficial, not maintained by the original CasADi authors, and not affiliated with the CasADi project.

## Example: Create NLP solver

We will use CasADi to find the minimum of the [Rosenbrock function](https://en.wikipedia.org/wiki/Rosenbrock_function).
This can be done as follows

```julia
using CasADi

x = SX("x")
y = SX("y")
α = 1
b = 100
f = (α - x)^2 + b*(y - x^2)^2

nlp = Dict("x" => vcat([x; y]), "f" => f);
S = nlpsol("S", "ipopt", nlp);

sol = solve(S, x0 = [0, 0]);

println("Optimal solution: x = ", sol["x"][1], ", y = ", sol["x"][2])
```

## Example: Using Opti stack

We will use Opti stack to solve the example problem in CasADi's documentation

```julia
using CasADi

opti = Opti()
x = variable!(opti)
y = variable!(opti)

minimize!(opti, (y - x^2)^2)
subject_to!(opti, x^2 + y^2 == 1)
subject_to!(opti, x + y >= 1)

solver!(opti, "ipopt")
sol = solve!(opti)

println("Optimal solution: x = ", sol.value(x), ", y = ", sol.value(y))
```

## Acknowledgments

This package is built almost entirely off of code written by Iordanis Chatzinikolaidis. Many thanks to his implementation. The purpose of this package is to register it publicly.

