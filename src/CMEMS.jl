module CMEMS

using NCDatasets
using DataArrays

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


#indexfname = download("ftp://$(username):$(password)@medinsitu.hcmr.gr/Core/INSITU_MED_TS_REP_OBSERVATIONS_013_041/index_history.txt")


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
                  skipifpresent = true
                   )

    const dateformat = DateFormat("y-m-dTH:M:SZ")

    function parsetime(str)
        #MYO-BLACKSEA-01,ftp://vftpmo.io-bas.bg/Core/INSITU_BS_TS_REP_OBSERVATIONS_013_042/history/mooring/BS_TS_MO_CG.nc,43.8022,43.8022,28.6025,28.6025,2016-01-01T00:15:00Z,2016-12-31T23:45:00ZZ,Institutul National de Cercetare-Dezvoltare pentru Geologie si Geoecologie Marina (GeoEcoMar) Romania,2017-03-03T09:23:50Z,R,DEPH TEMP CNDC FLU2 DOX1 ATMS DRYT WSPD WDIR GSPD HCSP HCDT
        if contains(str,"ZZ")
            return DateTime(replace(str,"ZZ","Z"),dateformat)            
        else
            return DateTime(str,dateformat)
        end
    end
    
    function downloadpw(URL,localname = tempname())
        print(log,"Downloading ");
        print_with_color(:green,log,URL)
        print(log,"\n")
        
        if startswith(URL,"ftp")
            download(replace(URL,r"^ftp://","ftp://$(username):$(password)@"),localname)
        elseif startswith(URL,"https")
            download(replace(URL,r"^https://","https://$(username):$(password)@"),localname)
        else
            download(replace(URL,r"^http://","http://$(username):$(password)@"),localname)
        end

        return localname
    end

    files = String[]
    
    for indexURL in indexURLs

        indexfname = downloadpw(indexURL)        
        #open(indexfname) do f
        f = open(indexfname);
        index = readdlm(f,','; comment_char = '#')
        close(f)

        for i = 1:size(index,1)
            catalog_id          = index[i,1] :: SubString{String}
            file_name           = index[i,2] :: SubString{String}
            geospatial_lat_min  = Float64(index[i,3])
            geospatial_lat_max  = Float64(index[i,4])
            geospatial_lon_min  = Float64(index[i,5])
            geospatial_lon_max  = Float64(index[i,6])
            time_coverage_start = index[i,7] :: SubString{String}
            time_coverage_end   = index[i,8] :: SubString{String}
            provider            = index[i,9] :: SubString{String}
            date_update         = index[i,10] :: SubString{String}
            data_mode           = index[i,11] :: SubString{String}
            parameter           = index[i,12] :: SubString{String}
            
            # selection based on coordinate
            if ((lonr[1] <= geospatial_lon_max) && (geospatial_lon_min <= lonr[end]) &&
                (latr[1] <= geospatial_lat_max) && (geospatial_lat_min <= latr[end]))
                
                # ignore bogous time
                if (time_coverage_start != "TZ") && (time_coverage_end != "TZ")
                    # selection based on time
                    
                    time_start = parsetime(time_coverage_start)
                    time_end = parsetime(time_coverage_end)
                    
                    if (timerange[1] <= time_end) && (time_start <= timerange[2])
                        parameters = split(parameter)
                        
                        # selection based on parameter
                        if param in parameters
                            #@show catalog_id, file_name, geospatial_lat_min, geospatial_lat_max, geospatial_lon_min, geospatial_lon_max, time_coverage_start, time_coverage_end, provider, date_update, data_mode, parameter

                            
                            parts = splitdir(replace(file_name,r"^.*://",""))
                            localname = joinpath(basedir,parts...)
                            dir = joinpath(basedir,parts[1:end-1]...)
                            mkpath(dir)

                            if !isfile(localname) || !skipifpresent
                                downloadpw(file_name,localname)
                            end
                            
                            push!(files,localname)
                        end
                    end                
                end
            end
        end
    end

    return files
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
    
    dataarray = ds[param][:]
    data = fill(fillvalue,size(dataarray))
    data[.!ismissing.(dataarray)] =  dataarray.data[.!ismissing.(dataarray)]
       
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

    #@show fname
    
    ds = Dataset(fname)
    data = loadvar(ds,param;
                   fillvalue = fillvalue,
                   qualityflags = qualityflags)

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

        append!(data,data_[:])
        append!(lon,lon_[:])
        append!(lat,lat_[:])
        append!(z,z_[:])
        append!(time,time_[:])
        append!(ids,ids_[:])        
    end

    return data,lon,lat,z,time,ids
end


end


