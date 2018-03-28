var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Sea-water properties",
    "title": "Sea-water properties",
    "category": "page",
    "text": "PhysOcean"
},

{
    "location": "index.html#PhysOcean.density-Tuple{Any,Any,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.density",
    "category": "method",
    "text": "density(S,T,p)\n\nCompute the density of sea-water (kg/m³) at the salinity S (psu, PSS-78), temperature T (degree Celsius, ITS-90) and pressure p (decibar) using the UNESCO 1983 polynomial.\n\nFofonoff, N.P.; Millard, R.C. (1983). Algorithms for computation of fundamental properties of seawater. UNESCO Technical Papers in Marine Science, No. 44. UNESCO: Paris. 53 pp. http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.secant_bulk_modulus-Tuple{Any,Any,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.secant_bulk_modulus",
    "category": "method",
    "text": "secant_bulk_modulus(S,T,p)\n\nCompute the secant bulk modulus of sea-water (bars) at the salinity S (psu, PSS-78), temperature T (degree Celsius, ITS-90) and pressure p (decibar) using the UNESCO polynomial 1983.\n\nFofonoff, N.P.; Millard, R.C. (1983). Algorithms for computation of fundamental properties of seawater. UNESCO Technical Papers in Marine Science, No. 44. UNESCO: Paris. 53 pp. http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.freezing_temperature-Tuple{Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.freezing_temperature",
    "category": "method",
    "text": "freezing_temperature(S)\n\nCompute the freezing temperature (in degree Celsius) of sea-water based on the salinity S (psu).\n\n\n\n"
},

{
    "location": "index.html#Sea-water-properties-1",
    "page": "Sea-water properties",
    "title": "Sea-water properties",
    "category": "section",
    "text": "density(S,T,p)secant_bulk_modulus(S,T,p)freezing_temperature(S)"
},

{
    "location": "index.html#PhysOcean.latentflux-NTuple{5,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.latentflux",
    "category": "method",
    "text": "latentflux(Ts,Ta,r,w,pa)\n\nCompute the latent heat flux (W/m²) using the sea surface temperature Ts (degree Celsius), the air temperature Ta (degree Celsius), the relative humidity r (0 ≤ r ≤ 1, pressure ratio, not percentage), the wind speed w (m/s) and the air pressure (hPa).\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.longwaveflux-NTuple{4,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.longwaveflux",
    "category": "method",
    "text": "longwaveflux(Ts,Ta,e,tcc)\n\nCompute the long wave heat flux (W/m²) using the sea surface temperature Ts (degree Celsius), the air temperature Ta (degree Celsius), the wate vapour pressure e (hPa) and the total cloud coverage ttc (0 ≤ tcc ≤ 1).\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.sensibleflux-Tuple{Any,Any,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.sensibleflux",
    "category": "method",
    "text": "sensibleflux(Ts,Ta,w)\n\nCompute the sensible heat flux (W/m²) using the wind speed w (m/s), the sea surface temperature Ts (degree Celsius), the air temperature Ta (degree Celsius).\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.solarflux-Tuple{Any,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.solarflux",
    "category": "method",
    "text": "solarflux(Q,al)\n\nCompute the solar heat flux (W/m²)\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.vaporpressure-Tuple{Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.vaporpressure",
    "category": "method",
    "text": "vaporpressure(T)\n\nCompute vapour pressure of water at the temperature T (degree Celsius) in hPa using Tetens equations. The temperature must be postive.\n\nMonteith, J.L., and Unsworth, M.H. 2008. Principles of Environmental Physics. Third Ed. AP, Amsterdam. http://store.elsevier.com/Principles-of-Environmental-Physics/John-Monteith/isbn-9780080924793\n\n\n\n"
},

{
    "location": "index.html#Heat-fluxes-1",
    "page": "Sea-water properties",
    "title": "Heat fluxes",
    "category": "section",
    "text": "latentflux(Ts,Ta,r,w,pa)longwaveflux(Ts,Ta,e,tcc)sensibleflux(Ts,Ta,w)solarflux(Q,al)vaporpressure(T)"
},

{
    "location": "index.html#PhysOcean.gausswin",
    "page": "Sea-water properties",
    "title": "PhysOcean.gausswin",
    "category": "function",
    "text": "gausswin(N, α = 2.5)\n\nReturn a Gaussian window with N points with a standard deviation of  (N-1)/(2 α).\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.gaussfilter-Tuple{Any,Any}",
    "page": "Sea-water properties",
    "title": "PhysOcean.gaussfilter",
    "category": "method",
    "text": "gaussfilter(x,N)\n\nFilter the vector x with a N-point Gaussian window.\n\n\n\n"
},

{
    "location": "index.html#Filtering-1",
    "page": "Sea-water properties",
    "title": "Filtering",
    "category": "section",
    "text": "gausswin(N, α = 2.5)gaussfilter(x,N)"
},

{
    "location": "index.html#Data-download-1",
    "page": "Sea-water properties",
    "title": "Data download",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#PhysOcean.CMEMS.download",
    "page": "Sea-water properties",
    "title": "PhysOcean.CMEMS.download",
    "category": "function",
    "text": "CMEMS.download(lonr,latr,timerange,param,username,password,basedir[; indexURLs = ...])\n\nDownload in situ data within the longitude range lonr (an array or tuple with  two elements: the minimum longitude and the maximum longitude), the latitude range latr (likewise), time range timerange (an array or tuple with two DateTime  structures: the starting date and the end date) from the CMEMS (Copernicus Marine environment monitoring service) in situ service [1].   param is one of the parameter codes as defined in [2] or [3]. username and password are the credentials to access data [1] and basedir  is the directory under which the data is saved. indexURLs is a list of the URL to the index_history.txt file. Per default, it includes the URLs of the Baltic, Arctic, North West Shelf, Iberian, Mediteranean and Black Sea Thematic  Assembly Center.\n\nAs these URLs might change, the latest version of the URLs to the indexes can be obtained at [1].\n\nExample\n\njulia> username = \"...\"\njulia> password = \"...\"\njulia> lonr = [7.6, 12.2]\njulia> latr = [42, 44.5]\njulia> timerange = [DateTime(2016,5,1),DateTime(2016,8,1)]\njulia> param = \"TEMP\"\njulia> basedir = \"/tmp\"\njulia> files = CMEMS.download(lonr,latr,timerange,param,username,password,basedir)\n\n[1]: http://marine.copernicus.eu/\n\n[2]: http://www.coriolis.eu.org/Documentation/General-Informations-on-Data/Codes-Tables\n\n[3]: http://doi.org/10.13155/40846\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.CMEMS.load",
    "page": "Sea-water properties",
    "title": "PhysOcean.CMEMS.load",
    "category": "function",
    "text": "data,lon,lat,z,time,ids = load(T,fname::TS,param; qualityflags = [good_data, probably_good_data]) where TS <: AbstractString\n\n\n\ndata,lon,lat,z,time,ids = CMEMS.load(T,fnames,param; qualityflags = ...)\n\nLoad all data in the vector of file names fnames corresponding to the parameter  param as the data type T. Only the data with the quality flags  CMEMS.good_data and CMEMS.probably_good_data are loaded per default. The output parameters correspondata to the data, longitude, latitude, depth, time (as DateTime) and an identifier (as String).\n\nSee also CMEMS.download.\n\n\n\n"
},

{
    "location": "index.html#CMEMS-1",
    "page": "Sea-water properties",
    "title": "CMEMS",
    "category": "section",
    "text": "CMEMS.download\nCMEMS.load"
},

{
    "location": "index.html#PhysOcean.WorldOceanDatabase.download",
    "page": "Sea-water properties",
    "title": "PhysOcean.WorldOceanDatabase.download",
    "category": "function",
    "text": "dirnames,indexnames = WorldOceanDatabase.download(lonrange,latrange,timerange,\n  variable,email,basedir)\n\nDownload data using the NODC web-service. The range parameters are vectors from with the frist element is the lower bound and the last element is the upper bound. The parameters of the functions will  be transmitted to nodc.noaa.gov (http://www.noaa.gov/privacy.html). Note that no XBT corrections are applied. The table below show the avialable variable and their units.\n\nVariables Unit\nTemperature °C\nSalinity unitless\nOxygen ml l⁻¹\nPhosphate µM\nSilicate µM\nNitrate and Nitrate+Nitrite µM\npH unitless\nChlorophyll µg l⁻¹\nPlankton multiple\nAlkalinity meq l⁻¹\nPartial Pressure of Carbon Dioxide µatm\nDissolved Inorganic Carbon mM\nTransmissivity m⁻¹\nPressure dbar\nAir temperature °C\nCO2 warming °C\nCO2 atmosphere ppm\nAir pressure mbar\nTritium TU\nHelium nM\nDelta Helium-3 %\nDelta Carbon-14 ᵒ/ᵒᵒ\nDelta Carbon-13 ᵒ/ᵒᵒ\nArgon nM\nNeon nM\nChlorofluorocarbon 11 (CFC 11) pM\nChlorofluorocarbon 12 (CFC 12) pM\nChlorofluorocarbon 113 (CFC 113) pM\nDelta Oxygen-18 ᵒ/ᵒᵒ\n\n\n\n"
},

{
    "location": "index.html#PhysOcean.WorldOceanDatabase.load",
    "page": "Sea-water properties",
    "title": "PhysOcean.WorldOceanDatabase.load",
    "category": "function",
    "text": " load(T,dirname,indexname,varname)\n\nLoad all profiles with the NetCDF variable varname in dirname indexed with  the NetCDF file indexname. T is the type (e.g. Float64) for numeric return values.\n\n\n\nvalue,lon,lat,depth,obstime,id = load(T,dirnames,varname)\n\nLoad a list  of directories dirnames.\n\n\n\nvalue,lon,lat,depth,obstime,id = WorldOceanDatabase.load(T,basedir::AbstractString,varname)\n\nLoad a list profiles under the directory basedir assuming basedir was  populated by WorldOceanDatabase.download.\n\n\n\n"
},

{
    "location": "index.html#World-Ocean-Database-(NODC)-1",
    "page": "Sea-water properties",
    "title": "World Ocean Database (NODC)",
    "category": "section",
    "text": "WorldOceanDatabase.download\nWorldOceanDatabase.load"
},

]}
