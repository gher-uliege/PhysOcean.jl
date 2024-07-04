module CMEMS

using NCDatasets
using Dates
using DelimitedFiles
import PhysOcean: addprefix!

const no_qc_performed = 0
const good_data = 1
const probably_good_data = 2
const bad_data_that_are_potentially_correctable = 3
const bad_data = 4
const value_changed = 5
const not_used = 6
const nominal_value = 7
const interpolated_value = 8
const missing_value = 9


const fillvalueDT = DateTime(1000,1,1)
#indexfname = download("ftp://$(username):$(password)@medinsitu.hcmr.gr/Core/INSITU_MED_TS_REP_OBSERVATIONS_013_041/index_history.txt")


mutable struct IndexFile{T}
    index::Array{Any,2}
    dateformat::T
end

function IndexFile(io::IO)
    index = readdlm(io,','; comment_char = '#', comments = true)

    dateformat = DateFormat("y-m-dTH:M:SZ")
    return IndexFile(index,dateformat)
end

function parsetime(str,dateformat)
    #MYO-BLACKSEA-01,ftp://vftpmo.io-bas.bg/Core/INSITU_BS_TS_REP_OBSERVATIONS_013_042/history/mooring/BS_TS_MO_CG.nc,43.8022,43.8022,28.6025,28.6025,2016-01-01T00:15:00Z,2016-12-31T23:45:00ZZ,Institutul National de Cercetare-Dezvoltare pentru Geologie si Geoecologie Marina (GeoEcoMar) Romania,2017-03-03T09:23:50Z,R,DEPH TEMP CNDC FLU2 DOX1 ATMS DRYT WSPD WDIR GSPD HCSP HCDT
    if occursin("ZZ",str)
        return DateTime(replace(str,"ZZ","Z"),dateformat)
    else
        return DateTime(str,dateformat)
    end
end

Base.length(iter::IndexFile) = size(iter.index,1)

function nextitem(iter::IndexFile,i)
    i = i+1

    # ignore bogous time
    while (iter.index[i,7] == "TZ") || (iter.index[i,7] == "TZ")
        i = i+1
    end

    catalog_id          = iter.index[i,1] :: SubString{String}
    url                 = iter.index[i,2] :: SubString{String}
    geospatial_lat_min  = Float64(iter.index[i,3])
    geospatial_lat_max  = Float64(iter.index[i,4])
    geospatial_lon_min  = Float64(iter.index[i,5])
    geospatial_lon_max  = Float64(iter.index[i,6])
    time_coverage_start = parsetime(iter.index[i,7],iter.dateformat)
    time_coverage_end   = parsetime(iter.index[i,8],iter.dateformat)
    provider            = iter.index[i,9] :: SubString{String}
    date_update         = iter.index[i,10] :: SubString{String}
    data_mode           = iter.index[i,11] :: SubString{String}
    parameter           = iter.index[i,12] :: SubString{String}


    localname = replace(url,r"^.*://" => "")

    #@show i,url

    return ((url,
             localname,
             geospatial_lat_min,
             geospatial_lat_max,
             geospatial_lon_min,
             geospatial_lon_max,
             time_coverage_start,
             time_coverage_end,
             parameter),i)
end

function Base.iterate(iter::IndexFile, i = 0)
    if i == size(iter.index,1)
        return nothing
    end

    return nextitem(iter,i)
end

function downloadpw(URL,username,password,log,mydownload,localname = tempname(); ntries = 5)
    print(log,"Downloading ");
    printstyled(log,URL; color = :green)
    print(log,"\n")

    for i=1:ntries
        try
            if startswith(URL,"ftp")
                mydownload(replace(URL,r"^ftp://" => "ftp://$(username):$(password)@"),localname)
            elseif startswith(URL,"https")
                mydownload(replace(URL,r"^https://" => "https://$(username):$(password)@"),localname)
            else
                mydownload(replace(URL,r"^http://" => "http://$(username):$(password)@"),localname)
            end
        catch err
            if i == ntries
                @warn "got error $(err). Will give up and rethrow the error."
                rethrow(err)
            else
                waittime = 10*i*i
                @warn "got error $(err). Retrying after $(waittime) seconds."
                sleep(waittime);
            end

            continue
        end

        break
    end
    return localname
end


"""
    CMEMS.download(lonr,latr,timerange,param,username,password,basedir[; indexURLs = ...])

The data service has been [discontinued by CMEMS](https://web.archive.org/web/20240530142808/https://marine.copernicus.eu/news/introducing-new-copernicus-marine-data-store) and replaced by a python-specific API.



Download in situ data within the longitude range `lonr` (an array or tuple with
two elements: the minimum longitude and the maximum longitude), the latitude
range `latr` (likewise), time range `timerange` (an array or tuple with two `DateTime`
structures: the starting date and the end date) from the CMEMS (Copernicus
Marine environment monitoring service) in situ service [^1].
`param` is one of the parameter codes as defined in [^2] or [^3].
`username` and `password` are the credentials to access data [^1] and `basedir`
is the directory under which the data is saved. `indexURLs` is a list of the URL
to the `index_history.txt` file. Per default, it includes the URLs of the
Baltic, Arctic, North West Shelf, Iberian, Mediteranean and Black Sea Thematic
Assembly Center.

As these URLs might change, the latest version of the URLs to the indexes can be
obtained at [^1].

# Example
```julia-repl
julia> username = "..."
julia> password = "..."
julia> lonr = [7.6, 12.2]
julia> latr = [42, 44.5]
julia> timerange = [DateTime(2016,5,1),DateTime(2016,8,1)]
julia> param = "TEMP"
julia> basedir = "/tmp"
julia> files = CMEMS.download(lonr,latr,timerange,param,username,password,basedir)
```

[^1]: http://marine.copernicus.eu/
[^2]: http://www.coriolis.eu.org/Documentation/General-Informations-on-Data/Codes-Tables
[^3]: http://doi.org/10.13155/40846


"""
function download(lonr,latr,timerange,param,username,password,basedir;
                  indexURLs = [
                       # Baltic
                       "ftp://my.cmems-du.eu/Core/INSITU_BAL_TS_REP_OBSERVATIONS_013_038/index_history.txt",
                       # Arctic
                       "ftp://my.cmems-du.eu/Core/INSITU_ARC_TS_REP_OBSERVATIONS_013_037/index_history.txt",
                       # North West Shelf
                       "ftp://my.cmems-du.eu/Core/INSITU_NWS_TS_REP_OBSERVATIONS_013_043/index_history.txt",
                       # IBI
                       "ftp://my.cmems-du.eu/Core/INSITU_IBI_TS_REP_OBSERVATIONS_013_040/index_history.txt",
                       # Mediteranean Sea
                       "ftp://my.cmems-du.eu/Core/INSITU_MED_TS_REP_OBSERVATIONS_013_041/index_history.txt",
                       # Black Sea
                       "ftp://my.cmems-du.eu/Core/INSITU_BS_TS_REP_OBSERVATIONS_013_042/index_history.txt"
                   ],
                  log = stdout,
                  download = Base.download,
                  kwargs...)

    # INSITU_GLO_NRT_OBSERVATIONS_013_030
    # INSITU_ARC_NRT_OBSERVATIONS_013_031
    files = String[]

    for indexURL in indexURLs
        indexfname = downloadpw(indexURL,username,password,log,download)
        open(indexfname) do f
            download!(IndexFile(f),lonr,latr,timerange,param,username,password,basedir,files;
                      log = log,
                      download = download,
                      kwargs...)
        end
        rm(indexfname)
    end
    return files
end

function download!(index,lonr,latr,timerange,param,username,password,basedir,files;
                  log = stdout,
                  download = Base.download,
                  skipifpresent = true
                   )

    for (url,
         localname,
         geospatial_lat_min,
         geospatial_lat_max,
         geospatial_lon_min,
         geospatial_lon_max,
         time_coverage_start,
         time_coverage_end,
         parameter) in index
        # selection based on coordinate
        if ((lonr[1] <= geospatial_lon_max) && (geospatial_lon_min <= lonr[end]) &&
            (latr[1] <= geospatial_lat_max) && (geospatial_lat_min <= latr[end]))

            # selection based on time

            if (timerange[1] <= time_coverage_end) && (time_coverage_start <= timerange[2])
                parameters = split(parameter)

                # selection based on parameter
                if param in parameters
                    #@show catalog_id, url, geospatial_lat_min, geospatial_lat_max, geospatial_lon_min, geospatial_lon_max, time_coverage_start, time_coverage_end, provider, date_update, data_mode, parameter
                    abslocalname = joinpath(basedir,localname)
                    dir = splitdir(abslocalname)[1]
                    mkpath(dir)

                    downloadsuccess = true

                    if !isfile(abslocalname) || !skipifpresent
                        try
                            downloadpw(url,username,password,log,download,abslocalname)
                        catch
                            downloadsuccess = false
                            @warn "failed to download $url"
                        end
                    end

                    if downloadsuccess
                        push!(files,localname)
                    end
                end
            end
        end
    end
end

"""
    data = loadvar(ds,param;
                   fillvalue::T = NaN,
                   qualityflags = [good_data, probably_good_data],
                   qfname = param * "_QC",
                   )

Load the NetCDF variable `param` from the NCDataset `ds`.
Data points not having the provide quality flags will be masked by `fillvalue`.
`qfname` is the NetCDF variable name for the quality flags.

"""
function loadvar(ds,param;
                 fillvalue::T = NaN,
                 qualityflags = [good_data, probably_good_data],
                 qfname = param * "_QC",
                 ) where T

    if !(param in ds)
        #@show "no data for",param
        return T[]
    end

    data = nomissing(Array(ds[param]),fillvalue)

    if qfname in ds
        qf = Array(ds[qfname].var)

        keep_data = falses(size(qf))

        for flag in qualityflags
            keep_data[:] =  keep_data .| (qf .== flag)
        end

        data[.!keep_data] .= fillvalue
    end

    return data
end

"""
    data,lon,lat,z,time,ids = load(T,fname::TS,param; qualityflags = [good_data, probably_good_data]) where TS <: AbstractString


"""
function load(T,fname::TS,param; qualityflags = [good_data, probably_good_data]) where TS <: AbstractString
    fillvalue = NaN
    fillvalueDT = DateTime(1000,1,1)

    ds = Dataset(fname)

    data = loadvar(ds,param;
                   fillvalue = fillvalue,
                   qualityflags = qualityflags)

    if isempty(data)
        return data,T[],T[],T[],DateTime[],String[]
    end

    lon = loadvar(ds,"LONGITUDE";
                  fillvalue = fillvalue,
                  qfname = "POSITION_QC",
                  qualityflags = qualityflags)

    if ndims(lon) == 1
        if size(lon,1) != size(data,2)
            error("unexpected size in $(fname), size(data) = $(size(data)), size(lon) = $(size(lon))")
        end

        @assert size(lon,1) == size(data,2)
        lon = repeat(reshape(lon,1,size(lon,1)),inner = (size(data,1),1))
    end

    lat = loadvar(ds,"LATITUDE";
                  fillvalue = fillvalue,
                  qfname = "POSITION_QC",
                  qualityflags = qualityflags)
    if ndims(lat) == 1
        @assert size(lat,1) == size(data,2)
        lat = repeat(reshape(lat,1,size(lat,1)), inner = (size(data,1),1))
    end

    z =
        if "DEPH" in ds
            loadvar(ds,"DEPH";
                    fillvalue = fillvalue,
                    qualityflags = qualityflags)
        else
            # assume 1 decibar is 1 meter
            loadvar(ds,"PRES";
                    fillvalue = fillvalue,
                    qualityflags = qualityflags)
        end

    time = loadvar(ds,"TIME";
                   fillvalue = fillvalueDT,
                   qualityflags = qualityflags)
    #@show time
    if ndims(time) == 1
        @assert size(time,1) == size(data,2)
        time = repeat(reshape(time,1,size(time,1)), inner = (size(data,1),1))
    end

    ids = fill(ds.attrib["id"],size(data))
    close(ds)

    return data,lon,lat,z,time,ids
end

"""
    obsdata,obslon,obslat,obsz,obstime,obsids = CMEMS.load(T,fnames,param;
       qualityflags = ...,; prefixid = "")

Load all data in the vector of file names `fnames` corresponding to the parameter
`param` as the data type `T`. Only the data with the quality flags
`CMEMS.good_data` and `CMEMS.probably_good_data` are loaded per default.
The output parameters correspondata to the data, longitude, latitude,
depth, time (as `DateTime`) and an identifier (as `String`).

If `prefixid` is specified, then the observations identifier are prefixed with `prefixid`.

See also `CMEMS.download`.
"""
function load(T,fnames::Vector{TS},param;
              qualityflags = [good_data, probably_good_data],
              prefixid = ""
              ) where TS <: AbstractString
    obsvalue = T[]
    obslon = T[]
    obslat = T[]
    obsdepth = T[]
    obstime = DateTime[]
    obsids = String[]

    for fname in fnames
        obsvalue_,obslon_,obslat_,obsdepth_,obstime_,obsids_ = load(T,fname,param;
                                             qualityflags = qualityflags)

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
