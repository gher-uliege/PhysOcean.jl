if VERSION >= v"0.7.0-beta.0"
    using Test
else
    using Base.Test
end

using PhysOcean


datadir = joinpath(dirname(@__FILE__),"argo")
filenames = joinpath.(datadir,["CO_DMQCGL01_19720119_PR_ME.nc",
                               "CO_DMQCGL01_20021117_TS_DC.nc",
                               "CO_DMQCGL01_19820218_PR_ME.nc",
                               "CO_DMQCGL01_19511210_PR_SH.nc"])

T = Float32
varname = "TEMP"
obsvalue,obslon,obslat,obsdepth,obstime,obsids = ARGO.load(T,filenames,varname; prefixid = "4630-")

@test startswith(obsids[1],"4630-")
