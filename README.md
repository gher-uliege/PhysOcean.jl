# PhysOcean

[![Build Status](https://github.com/gher-uliege/PhysOcean.jl/workflows/CI/badge.svg)](https://github.com/gher-uliege/PhysOcean.jl/actions)
[![Build Status Windows](https://ci.appveyor.com/api/projects/status/github/gher-uliege/PhysOcean.jl?branch=master&svg=true)](https://ci.appveyor.com/project/Alexander-Barth/physocean-jl)
[![codecov](https://codecov.io/gh/gher-uliege/PhysOcean.jl/graph/badge.svg?token=NvclfCEMyQ)](https://codecov.io/gh/gher-uliege/PhysOcean.jl)
[![documentation stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gher-uliege.github.io/PhysOcean.jl/stable/)
[![documentation latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://gher-uliege.github.io/PhysOcean.jl/latest/)    
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)         
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) ![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/gher-uliege/PhysOcean.jl) ![GitHub contributors](https://img.shields.io/github/contributors/gher-uliege/PhysOcean.jl) ![GitHub last commit](https://img.shields.io/github/last-commit/gher-uliege/PhysOcean.jl) 

# Content

You will find here some general tools for Physical Oceanography (state equations, bulk formulas, geostrophic velocity calculations ...). 

# Installing

Your need [Julia](http://julialang.org) to use `PhysOcean`. The command line version is sufficient for `PhysOcean`.
Inside Julia, you can download and install the package by issuing:

```julia
using Pkg
Pkg.add("PhysOcean")
```

Or if you want to use the latest version, you can use the following command:

```julia
using Pkg
Pkg.add(PackageSpec(name="PhysOcean", rev="master"))
```
or in the Pkg REPL
```julia
(@v1.11) pkg> add PhysOcean#master
``` 

# Testing

A test script is included to verify the correct functioning of the toolbox.
The script should be run in a Julia session.

```julia
using Pkg
Pkg.test("PhysOcean")
```

