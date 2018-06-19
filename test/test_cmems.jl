using Base.Test

# mock implementation for testing downloading
function mockdownload(URL,localname = tempname())
    #@show URL,localname

    if URL == "ftp://user:pass@hostname/index"
        open(localname,"w") do f
            print(f,"""#Comment1
#Comment2
MYO-MOON-01,ftp://hostname/file1,32.,32.,5.,5.,2000-09-10T08:58:00Z,2010-11-15T06:48:00Z,MEDS,2017-03-13T15:03:04Z,D, PRES TEMP
MYO-MOON-01,ftp://hostname/file2,32.,32.,95.,95.,2000-09-10T08:58:00Z,2010-11-15T06:48:00Z,MEDS,2017-03-13T15:03:04Z,D, PRES TEMP
""");
        end
    elseif URL == "ftp://user:pass@hostname/file1" || URL == "http://user:pass@hostname/profiler-glider/GL_PR_PF_5901310.nc"
        open(localname,"w") do f
            print(f,"OK");
        end
    else
        error("unexpected download of $(URL)")
    end
    return localname
end



# mock implementation for testing downloading
function mockdownloadCSV(URL,localname = tempname())
    if URL == "ftp://user:pass@hostname/index"
        open(localname,"w") do f
            print(f,"""PARAM,CATEGORY,CATALOG_ID,FILENAME,DAC,GEO_LAT_MIN,GEO_LAT_MAX,GEO_LONG_MIN,GEO_LONG_MAX,TIME_COVERAGE_START,TIME_COVERAGE_END,PROVIDER,DATE_UPDATE,DATA_MODE,PARAMETERS,PLATFORM,WMO_PLATFORM_CODE,LAST_LATITUDE_OBSERVATION,LAST_LONGITUDE_OBSERVATION,DATE_CREATION_DU,DATE_UPDATE_DU,LAST_DATE_OBSERVATION,MONTHLY_FAMILY,FILE_DELETION,PSAL_GOOD_QC,TEMP_GOOD_QC,INSTITUTION_EDMO_CODE
DOX2,history,MYO-GLOBAL-01,GL_PR_PF_5901310.nc,Coriolis,-33.886,-24.905,91.331,108.372,24/09/2006 13:07:43,08/08/2011 19:43:44,University of Washington (Seattle),04/07/2017 23:16:15,D,PRES TEMP PSAL PRES_ADJUSTED PRES_ADJUSTED_ERROR TEMP_ADJUSTED TEMP_ADJUSTED_ERROR PSAL_ADJUSTED PSAL_ADJUSTED_ERROR DOX2,5901310,5901310,-31.428,93.473,24/06/2013 16:08:19,17/07/2017 05:20:09,08/08/2011 19:43:44,profiler-glider,,100,100,3839
DOX2,history,MYO-GLOBAL-01,GL_PR_PF_5901311.nc,Coriolis,-28.37,-21.754,90.514,112.749,25/09/2006 17:56:24,25/10/2012 13:19:27,University of Washington (Seattle),04/07/2017 23:16:15,D,PRES DOX2 PSAL TEMP PSAL_ADJUSTED_ERROR TEMP_ADJUSTED_ERROR TEMP_ADJUSTED PRES_ADJUSTED_ERROR PRES_ADJUSTED PSAL_ADJUSTED,5901311,5901311,-24.811,93.586,24/06/2013 16:08:22,17/07/2017 05:20:10,25/10/2012 13:19:27,profiler-glider,,100,100,3839
""");
        end
    elseif URL == "ftp://user:pass@hostname/file1"
        open(localname,"w") do f
            print(f,"OK");
        end
    else
        error("unexpected download of $(URL)")
    end
end


# check downloading some data (with a mock download function)

username = "user"
password = "pass"

lonr = [0,10]
latr = [30,35]
timerange = [DateTime(2001,1,1),DateTime(2002,1,1)]
param = "TEMP"
basedir = "/tmp/test1"
mkpath(basedir)
#basedir = mktempdir()

logstream = IOBuffer()

files = CMEMS.download(lonr,latr,timerange,param,username,password,basedir;
                       indexURLs = ["ftp://hostname/index"],
                       log = logstream,
                       download = mockdownload)

@test length(files) == 1
@test contains(files[1],"file1")
@test !contains(files[1],"file2")

@test contains(String(logstream),"hostname")

# check loading CMEMS data

files = [joinpath(dirname(@__FILE__),"cmems_testfile1.nc")]

obsdata,obslon,obslat,obsz,obstime,obsids = CMEMS.load(Float64,files,"PSAL");

@test all(obsdata .≈ 123)
@test all(obsids .== "GL_PR_BA_FQRQ_2000")





files = String[]

index = CMEMS.IndexFileCSV(IOBuffer("""PARAM,CATEGORY,CATALOG_ID,FILENAME,DAC,GEO_LAT_MIN,GEO_LAT_MAX,GEO_LONG_MIN,GEO_LONG_MAX,TIME_COVERAGE_START,TIME_COVERAGE_END,PROVIDER,DATE_UPDATE,DATA_MODE,PARAMETERS,PLATFORM,WMO_PLATFORM_CODE,LAST_LATITUDE_OBSERVATION,LAST_LONGITUDE_OBSERVATION,DATE_CREATION_DU,DATE_UPDATE_DU,LAST_DATE_OBSERVATION,MONTHLY_FAMILY,FILE_DELETION,PSAL_GOOD_QC,TEMP_GOOD_QC,INSTITUTION_EDMO_CODE
DOX2,history,MYO-GLOBAL-01,GL_PR_PF_5901310.nc,Coriolis,32.,32.,5.,5.,24/09/2001 13:07:43,08/08/2011 19:43:44,University of Washington (Seattle),04/07/2017 23:16:15,D,PRES TEMP PSAL PRES_ADJUSTED PRES_ADJUSTED_ERROR TEMP_ADJUSTED TEMP_ADJUSTED_ERROR PSAL_ADJUSTED PSAL_ADJUSTED_ERROR DOX2,5901310,5901310,-31.428,93.473,24/06/2013 16:08:19,17/07/2017 05:20:09,08/08/2011 19:43:44,profiler-glider,,100,100,3839
DOX2,history,MYO-GLOBAL-01,GL_PR_PF_5901311.nc,Coriolis,32.,32.,95.,95.,25/09/2001 17:56:24,25/10/2012 13:19:27,University of Washington (Seattle),04/07/2017 23:16:15,D,PRES DOX2 PSAL TEMP PSAL_ADJUSTED_ERROR TEMP_ADJUSTED_ERROR TEMP_ADJUSTED PRES_ADJUSTED_ERROR PRES_ADJUSTED PSAL_ADJUSTED,5901311,5901311,-24.811,93.586,24/06/2013 16:08:22,17/07/2017 05:20:10,25/10/2012 13:19:27,profiler-glider,,100,100,3839
"""),"http://hostname/")

param = "DOX2"
CMEMS.download!(index,lonr,latr,timerange,param,username,password,basedir,files;
                log = logstream,
                download = mockdownload)
