using Downloads: download
using PhysOcean: WorldOceanDatabase
using Test

tarname = download("https://dox.uliege.be/index.php/s/2QLL1g6DepKc0TT/download")
woddir = tempname()
mkdir(woddir)

WorldOceanDatabase.extracttar(tarname,woddir)


obsvalue,obslon,obslat,obsdepth,obstime,obsid = WorldOceanDatabase.load(
    Float64,woddir,"Temperature"; prefixid = "1977-")

@test length(obsvalue) == 7298
