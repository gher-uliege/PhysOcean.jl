
using ZipFile
using Downloads: download
using PhysOcean: WorldOceanDatabase
using Test

tmpfname = download("https://dox.uliege.be/index.php/s/QBFPUJvOMGOlOvS/download")
woddir = tempname()
mkdir(woddir)

zarchive = ZipFile.Reader(tmpfname)
for f in zarchive.files
    fullpath = joinpath(woddir,f.name)
    if (endswith(f.name,"/") || endswith(f.name,"\\"))
        mkdir(fullpath)
    else
        write(fullpath, read(f))
    end
end
close(zarchive)


obsvalue,obslon,obslat,obsdepth,obstime,obsid = WorldOceanDatabase.load(
    Float64,woddir,"Temperature"; prefixid = "1977-")

@test length(obsvalue) == 7298
