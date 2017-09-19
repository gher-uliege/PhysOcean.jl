using Documenter
using PhysOcean

makedocs(
         format = :html,
         sitename = "PhysOcean",
         pages = [
                  "index.md"]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.

deploydocs(
    repo = "github.com/gher-ulg/PhysOcean.jl.git",
    target = "build",
    julia  = "0.6",
    deps = nothing,
    make = nothing,    
)
