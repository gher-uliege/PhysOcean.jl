module CMEMS

using NCDatasets

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
    index = readdlm(io,','; comment_char = '#')

    dateformat = DateFormat("y-m-dTH:M:SZ")
    return IndexFile(index,dateformat)
end

function parsetime(str,dateformat)
    #MYO-BLACKSEA-01,ftp://vftpmo.io-bas.bg/Core/INSITU_BS_TS_REP_OBSERVATIONS_013_042/history/mooring/BS_TS_MO_CG.nc,43.8022,43.8022,28.6025,28.6025,2016-01-01T00:15:00Z,2016-12-31T23:45:00ZZ,Institutul National de Cercetare-Dezvoltare pentru Geologie si Geoecologie Marina (GeoEcoMar) Romania,2017-03-03T09:23:50Z,R,DEPH TEMP CNDC FLU2 DOX1 ATMS DRYT WSPD WDIR GSPD HCSP HCDT
    if contains(str,"ZZ")
        return DateTime(replace(str,"ZZ","Z"),dateformat)
    else
        return DateTime(str,dateformat)
    end
end

Base.length(iter::IndexFile) = size(iter.index,1)

Base.start(iter::IndexFile) = 0

function Base.next(iter::IndexFile,i)
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


    localname = replace(url,r"^.*://","")

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
Base.done(iter::IndexFile,i) = i == size(iter.index,1)




mutable struct IndexFileCSV{T}
    index::Array{Any,2}
    baseurl::String
    iparam::Int
    ifilename::Int
    igeo_lat_min::Int
    igeo_lat_max::Int
    igeo_long_min::Int
    igeo_long_max::Int
    itime_coverage_start::Int
    itime_coverage_end::Int
    imonthly_family::Int
    dateformat::T
end

Base.length(iter::IndexFileCSV) = size(iter.index,1)

function IndexFileCSV(io::IO,baseurl::AbstractString)
    index, header = readdlm(io,','; header = true, comment_char = '#')

    # PARAM,CATEGORY,CATALOG_ID,FILENAME,DAC,GEO_LAT_MIN,GEO_LAT_MAX,GEO_LONG_MIN,GEO_LONG_MAX,TIME_COVERAGE_START,TIME_COVERAGE_END,PROVIDER,DATE_UPDATE,DATA_MODE,PARAMETERS,PLATFORM,WMO_PLATFORM_CODE,LAST_LATITUDE_OBSERVATION,LAST_LONGITUDE_OBSERVATION,DATE_CREATION_DU,DATE_UPDATE_DU,LAST_DATE_OBSERVATION,MONTHLY_FAMILY,FILE_DELETION,PSAL_GOOD_QC,TEMP_GOOD_QC,INSTITUTION_EDMO_CODE

    iparam = findfirst("PARAM" .== header)
    ifilename = findfirst("FILENAME" .== header)
    igeo_lat_min = findfirst("GEO_LAT_MIN" .== header)
    igeo_lat_max = findfirst("GEO_LAT_MAX" .== header)
    igeo_long_min = findfirst("GEO_LONG_MIN" .== header)
    igeo_long_max = findfirst("GEO_LONG_MAX" .== header)
    itime_coverage_start = findfirst("TIME_COVERAGE_START" .== header)
    itime_coverage_end = findfirst("TIME_COVERAGE_END" .== header)
    imonthly_family = findfirst("MONTHLY_FAMILY" .== header)
    df = dateformat"dd/mm/yyyy HH:MM:SS"

    return IndexFileCSV(index,baseurl,iparam,
                        ifilename,
                        igeo_lat_min,
                        igeo_lat_max,
                        igeo_long_min,
                        igeo_long_max,
                        itime_coverage_start,
                        itime_coverage_end,
                        imonthly_family,
                        df)

end

Base.start(iter::IndexFileCSV) = 0

function Base.next(iter::IndexFileCSV,i)
    i = i+1

    filename           = iter.index[i,iter.ifilename] :: SubString{String}
    monthly_family = iter.index[i,iter.imonthly_family] :: SubString{String}

    localname = joinpath(monthly_family,filename)

    url = iter.baseurl * monthly_family * "/" * filename
    geospatial_lat_min  = Float64(iter.index[i,iter.igeo_lat_min])
    geospatial_lat_max  = Float64(iter.index[i,iter.igeo_lat_max])
    geospatial_lon_min  = Float64(iter.index[i,iter.igeo_long_min])
    geospatial_lon_max  = Float64(iter.index[i,iter.igeo_long_max])
    time_coverage_start = DateTime(iter.index[i,iter.itime_coverage_start],iter.dateformat)
    time_coverage_end   = DateTime(iter.index[i,iter.itime_coverage_end],iter.dateformat)
    parameter           = iter.index[i,iter.iparam] :: SubString{String}

    #@show i,filename,url,localname

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
Base.done(iter::IndexFileCSV,i) = i == size(iter.index,1)


function downloadpw(URL,username,password,log,mydownload,localname = tempname())
        print(log,"Downloading ");
        print_with_color(:green,log,URL)
        print(log,"\n")

        if startswith(URL,"ftp")
            mydownload(replace(URL,r"^ftp://","ftp://$(username):$(password)@"),localname)
        elseif startswith(URL,"https")
            mydownload(replace(URL,r"^https://","https://$(username):$(password)@"),localname)
        else
            mydownload(replace(URL,r"^http://","http://$(username):$(password)@"),localname)
        end

        return localname
end


"""
    CMEMS.download(lonr,latr,timerange,param,username,password,basedir[; indexURLs = ...])

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
                       "ftp://cmems.smhi.se/Core/INSITU_BAL_TS_REP_OBSERVATIONS_013_038/index_history.txt",
                       # Arctic
                       "ftp://ftp.nodc.no/Core/INSITU_ARC_TS_REP_OBSERVATIONS_013_037/index_history.txt",
                       # North West Shelf
                       "ftp://myocean.bsh.de/Core/INSITU_NWS_TS_REP_OBSERVATIONS_013_043/index_history.txt",
                       # IBI
                       "ftp://arcas.puertos.es/Core/INSITU_IBI_TS_REP_OBSERVATIONS_013_040/index_history.txt",
                       # Mediteranean Sea
                       "ftp://medinsitu.hcmr.gr/Core/INSITU_MED_TS_REP_OBSERVATIONS_013_041/index_history.txt",
                       # Black Sea
                       "ftp://vftpmo.io-bas.bg/Core/INSITU_BS_TS_REP_OBSERVATIONS_013_042/index_history.txt"
                   ],
                  log = STDOUT,
                  download = Base.download,
                  kwargs...)

    files = String[]

    for indexURL in indexURLs
        indexfname = downloadpw(indexURL,username,password,log,download)
        open(indexfname) do f
            download!(IndexFile(f),lonr,latr,timerange,param,username,password,basedir,files;
                      log = log,
                      download = download,
                      kwargs...)
        end
    end
    return files
end

function download!(index,lonr,latr,timerange,param,username,password,basedir,files;
                  log = STDOUT,
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

                    if !isfile(abslocalname) || !skipifpresent
                        downloadpw(url,username,password,log,download,abslocalname)
                    end

                    push!(files,localname)
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

    data = nomissing(ds[param][:],fillvalue)

    if qfname in ds
        qf = ds[qfname].var[:]

        keep_data = falses(size(qf))

        for flag in qualityflags
            keep_data[:] =  keep_data .| (qf .== flag)
        end

        data[(.!keep_data)] = fillvalue
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
        @assert size(lon,1) == size(data,2)
        lon = repmat(reshape(lon,1,size(lon,1)),size(data,1),1)
    end

    lat = loadvar(ds,"LATITUDE";
                  fillvalue = fillvalue,
                  qfname = "POSITION_QC",
                  qualityflags = qualityflags)
    if ndims(lat) == 1
        @assert size(lat,1) == size(data,2)
        lat = repmat(reshape(lat,1,size(lat,1)),size(data,1),1)
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
        time = repmat(reshape(time,1,size(time,1)),size(data,1),1)
    end

    ids = fill(ds.attrib["id"],size(data))
    close(ds)

    return data,lon,lat,z,time,ids
end

"""
    data,lon,lat,z,time,ids = CMEMS.load(T,fnames,param; qualityflags = ...)

Load all data in the vector of file names `fnames` corresponding to the parameter
`param` as the data type `T`. Only the data with the quality flags
`CMEMS.good_data` and `CMEMS.probably_good_data` are loaded per default.
The output parameters correspondata to the data, longitude, latitude,
depth, time (as `DateTime`) and an identifier (as `String`).

See also `CMEMS.download`.
"""

function load(T,fnames::Vector{TS},param;
              qualityflags = [good_data, probably_good_data]) where TS <: AbstractString
    data = T[]
    lon = T[]
    lat = T[]
    z = T[]
    time = DateTime[]
    ids = String[]

    for fname in fnames
        data_,lon_,lat_,z_,time_,ids_ = load(T,fname,param;
                                             qualityflags = qualityflags)

        good = falses(size(data_))
        for i = 1:length(data_)
            good[i] = !(isnan(data_[i]) || isnan(lon_[i]) || isnan(lat_[i]) || isnan(z_[i]) || time_[i] == fillvalueDT)
        end

        append!(data,data_[good])
        append!(lon,lon_[good])
        append!(lat,lat_[good])
        append!(z,z_[good])
        append!(time,time_[good])
        append!(ids,ids_[good])
    end

    return data,lon,lat,z,time,ids
end


end
