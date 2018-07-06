if VERSION >= v"0.7.0-beta.0"
    using Test
else
    using Base.Test
end

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
@test occursin("file1",files[1])
@test !occursin("file2",files[1])

@test occursin("hostname",String(take!(logstream)))

# check loading CMEMS data

files = [joinpath(dirname(@__FILE__),"cmems_testfile1.nc")]

obsdata,obslon,obslat,obsz,obstime,obsids = CMEMS.load(Float64,files,"PSAL");

@test all(obsdata .≈ 123)
@test all(obsids .== "GL_PR_BA_FQRQ_2000")





