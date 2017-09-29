using Base.Test

# mock implementation for testing downloading
function mockdownload(URL,localname = tempname())
    if URL == "ftp://user:pass@hostname/index"
        open(localname,"w") do f
            print(f,"""#Comment1
#Comment2
MYO-MOON-01,ftp://hostname/file1,32.,32.,5.,5.,2000-09-10T08:58:00Z,2010-11-15T06:48:00Z,MEDS,2017-03-13T15:03:04Z,D, PRES TEMP
MYO-MOON-01,ftp://hostname/file2,32.,32.,95.,95.,2000-09-10T08:58:00Z,2010-11-15T06:48:00Z,MEDS,2017-03-13T15:03:04Z,D, PRES TEMP
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

username = "user"
password = "pass"

lonr = [0,10]
latr = [30,35]
timerange = [DateTime(2001,1,1),DateTime(2002,1,1)]
param = "TEMP"
basedir = tempdir()

logstream = IOBuffer()
    
files = CMEMS.download(lonr,latr,timerange,param,username,password,basedir;
                       indexURLs = ["ftp://hostname/index"],
                       log = logstream,
                       download = mockdownload)

@test length(files) == 1
@test contains(files[1],"file1")
@test !contains(files[1],"file2")

@test contains(String(logstream),"hostname")
