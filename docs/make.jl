using Documenter
using PhysOcean

makedocs(
         modules = [PhysOcean],
         sitename = "PhysOcean",
         pages = ["index.md"]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.

deploydocs(
    repo = "github.com/gher-ulg/PhysOcean.jl.git",
)
