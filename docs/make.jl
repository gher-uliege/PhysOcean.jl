using Documenter, PhysOcean

makedocs(
         format = :html,
         sitename = "PhysOcean",
         pages = [
                  "index.md"]
)

deploydocs(
           repo = "github.com/gher-ulg/PhysOcean.jl.git",
           target = "build",
           deps = nothing,
           make = nothing,    
)
