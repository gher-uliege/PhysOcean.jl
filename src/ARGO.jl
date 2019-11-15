module ARGO

using NCDatasets
import PhysOcean: addprefix!
if VERSION >= v"0.7.0-beta.0"
    using Dates
else
    using Compat: @info, @debug, @warn
    using Missings
    using Compat
end

const no_qc_performed = '0'
const good_data = '1'
const probably_good_data = '2'
const bad_data_that_are_potentially_correctable = '3'
const bad_data = '4'
const value_changed = '5'
const not_used = '6'
const nominal_value = '7'
const interpolated_value = '8'
const missing_value = '9'

const fillvalueDT = DateTime(1000,1,1)


function varbyattrib_first(ds; kwargs...)
    vs = varbyattrib(ds; kwargs...)
    if length(vs) == 0
        str = join(["attribute '$k' equal to '$v'" for (k,v) in kwargs]," and ")
        error("No NetCDF variable found with $(str) in $(path(ds))")
    end
    return vs[1]
end


"""

If e.g.
a data variable has the dimensions N_LEVELS × N_PROF and the coordinate just
the dimensions N_PROF, then assume that the variable does not change along the
dimension N_LEVELS
"""
function reshapeas(T,sz,dn,datacoord,dncoord)
   coord = Array{T,length(sz)}(undef,sz)
   coord .= reshape(datacoord,ntuple(i -> (dn[i] ∈ dncoord ? sz[i] : 1),length(dn)))
   return coord
end

function loadwithshape(T,ncvar,nccoord)
    dn = dimnames(ncvar)
    sz = size(ncvar)
    datacoord = nccoord[:]
    dncoord = dimnames(nccoord)
    coord = reshapeas(T,sz,dn,datacoord,dncoord)
    return coord
end



function maskbad!(data,data_qc,qualityflags)
    for i in eachindex(data)
        if !(data_qc[i] in qualityflags)
            data[i] = missing
        end
    end
end

function loadgood(T,fillvalue,ds,varname, qualityflags;
                  varname_adjusted = varname * "_ADJUSTED",
                  varname_qc = varname * "_QC",
                  varname_adjusted_qc = varname_adjusted * "_QC")
# function loadgood(T,fillvalue,ds,varname, qualityflags)
#                   varname_adjusted = varname * "_ADJUSTED"
#                   varname_qc = varname * "_QC"
#                   varname_adjusted_qc = varname_adjusted * "_QC"

    ncvar = ds[varname]
    data = ncvar[:]
    data_qc = ds[varname_qc].var[:]

    if haskey(ds,varname_adjusted)
        data_adjusted = ds[varname_adjusted][:]
        data_adjusted_qc = ds[varname_adjusted_qc].var[:]

        sel = .!ismissing.(data_adjusted)
        data[sel] = data_adjusted[sel]
        data_qc[sel] = data_adjusted_qc[sel]
    end

    maskbad!(data,data_qc,Set(qualityflags))
    return T.(coalesce.(data,fillvalue)) :: Array{T}
end

function loadgoodreshape(::Type{T},fillvalue,ds,ncname, qualityflags,sz,dn; varname_qc = "POSITION_QC") where T
    if !haskey(ds,ncname)
        return fill(T(fillvalue),sz)
    end

    obslon_ = loadgood(T,fillvalue,ds,ncname,qualityflags,varname_qc = varname_qc)
    obslon = reshapeas(T,sz,dn,obslon_,dimnames(ds[ncname]))
    return obslon
end


function repeatobsid(dc_reference,nlevels)
    nprof = size(dc_reference,2)
    obsids = Array{String,2}(undef,nlevels,nprof)
    for j = 1:nprof
        str = strip(join(@view dc_reference[:,j]))
        for i = 1:nlevels
            obsids[i,j] = str
        end
    end
    return obsids
end


function load(::Type{T},filename::TS,varname,qualityflags) where TS <: AbstractString where T

    Dataset(filename) do ds
        if !haskey(ds,varname)
            return Array{T,2}(undef,0,0),Array{T,2}(undef,0,0),Array{T,2}(undef,0,0),Array{T,2}(undef,0,0),Array{DateTime,2}(undef,0,0),Array{String,2}(undef,0,0)
        end

        obsvalue = Array{T,2}(loadgood(T,NaN,ds,varname,qualityflags))

        sz = size(obsvalue)
        dn = NTuple{2,String}(dimnames(ds[varname]))
        #ncname = name(varbyattrib_first(ds,standard_name = "longitude"))
        ncname = "LONGITUDE"
        obslon = loadgoodreshape(T,NaN,ds,ncname, qualityflags,sz,dn,varname_qc = "POSITION_QC")

        #ncname = name(varbyattrib_first(ds,standard_name = "latitude"))
        ncname = "LATITUDE"
        obslat = loadgoodreshape(T,NaN,ds,ncname, qualityflags,sz,dn,varname_qc = "POSITION_QC")

        ncname = "DEPH"
        obsdepth = loadgoodreshape(T,NaN,ds,ncname, qualityflags,sz,dn,varname_qc = ncname * "_QC")

        #ncname = name(varbyattrib_first(ds,standard_name = "time"))
        ncname = "JULD"
        obstime = loadgoodreshape(DateTime,fillvalueDT,ds,ncname, qualityflags,sz,dn,varname_qc = ncname * "_QC")

        #obsids = fill(replace(basename(filename),".nc" => ""), size(obsvalue))
        dc_reference = ds["DC_REFERENCE"].var[:] :: Array{Char,2}
        nlevels = ds.dim["N_LEVELS"]::Int
        obsids = repeatobsid(dc_reference,nlevels)

        return obsvalue,obslon,obslat,obsdepth,obstime,obsids
    end
end


function lenprof(filename::TS,varname) where TS <: AbstractString
    Dataset(filename) do ds
        if haskey(ds,varname)
            return length(ds[varname])
        else
            return 0
        end
    end
end

function lenprof(filenames::AbstractVector{TS},varname) where TS <: AbstractString
    count = 0
    for i = 1:length(filenames)
        count += lenprof(filenames[i],varname)
    end
    return count
end

"""
    obsdata,obslon,obslat,obsz,obstime,obsids = ARGO.load(T,fnames,param;
       qualityflags = ...,; prefixid = "")

Load all data in the vector of file names `fnames` corresponding to the parameter
`param` as the data type `T`. Only the data with the quality flags
`ARGO.good_data` and `ARGO.probably_good_data` are loaded per default.
The output parameters correspondata to the data, longitude, latitude,
depth, time (as `DateTime`) and an identifier (as `String`).

If `prefixid` is specified, then the observations identifier are prefixed with `prefixid`.

# Example
```julia
using PhysOcean, Glob

# directory containing only ARGO/CORA netCDF files, e.g.
# <basedir>/CORA-5.2-mediterrane-1950/CO_DMQCGL01_19500103_PR_SH.nc
basedir = "/some/dir"
filenames = glob("*/*nc",basedir)
# load the data as double precision
T = Float64
# name of the variable in the NetCDF files
varname = "TEMP"
# EDMO code of Coriolis
prefixid = "4630-"
obsvalue,obslon,obslat,obsdepth,obstime,obsids = ARGO.load(T,filenames,varname;
      prefixid = prefixid)
```

See also `CMEMS.load`.
"""
function load(::Type{T},fnames::Vector{TS},param;
              qualityflags = [good_data, probably_good_data],
              prefixid = ""
              ) where TS <: AbstractString where T

    obsvalue = T[]
    obslon = T[]
    obslat = T[]
    obsdepth = T[]
    obstime = DateTime[]
    obsids = String[]

    for fname in fnames
        @debug "loading $fname"
        obsvalue_,obslon_,obslat_,obsdepth_,obstime_,obsids_ = load(
            T,fname,param,qualityflags)

        good = falses(size(obsvalue_))
        for i = 1:length(obsvalue_)
            good[i] = !(isnan(obsvalue_[i]) || isnan(obslon_[i]) || isnan(obslat_[i]) || isnan(obsdepth_[i]) || obstime_[i] == fillvalueDT)
        end

        append!(obsvalue,obsvalue_[good])
        append!(obslon,obslon_[good])
        append!(obslat,obslat_[good])
        append!(obsdepth,obsdepth_[good])
        append!(obstime,obstime_[good])
        append!(obsids,obsids_[good])
    end

    addprefix!(prefixid,obsids)

    return obsvalue,obslon,obslat,obsdepth,obstime,obsids
end


end
