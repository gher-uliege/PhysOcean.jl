# PhysOcean

[![Build Status](https://github.com/gher-uliege/PhysOcean.jl/workflows/CI/badge.svg)](https://github.com/gher-uliege/PhysOcean.jl/actions)
[![Build Status Windows](https://ci.appveyor.com/api/projects/status/github/gher-uliege/PhysOcean.jl?branch=master&svg=true)](https://ci.appveyor.com/project/Alexander-Barth/physocean-jl)
[![codecov.io](http://codecov.io/github/gher-uliege/PhysOcean.jl/coverage.svg?branch=master)](http://codecov.io/github/gher-uliege/PhysOcean.jl?branch=master)

[![documentation stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gher-uliege.github.io/PhysOcean.jl/stable/)
[![documentation latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://gher-uliege.github.io/PhysOcean.jl/latest/)

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

# Testing

A test script is included to verify the correct functioning of the toolbox.
The script should be run in a Julia session.

```julia
using Pkg
Pkg.test("PhysOcean")
```

