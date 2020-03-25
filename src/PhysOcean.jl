# Collections of tools for physical oceanography

# Authors:
# Aida Alvera Azcarate
# Alexander Barth


module PhysOcean

using Dates
using Statistics


# temperature in Kelvin of 0 degree Celsius
const TK = 273.15

# angularspeed of earth with respect to fixed star
const OMEGA = 7.2921150E-5

# mean radius of earth  (A.E. Gill, 1982. Atmosphere-Ocean Dynamics)
const MEAN_RADIUS_EARTH = 6371000 # m

function nansum(x)
    return sum(x[.!isnan.(x)])
end

function nansum(x,dim)
    m = isnan.(x)
    x2 = copy(x)
    x2[m] .= 0
    return sum(x2,dims = dim)
end

function nanmean(x)
    return mean(x[.!isnan.(x)])
end

function nanmean(x,dim)
    m = isnan.(x)
    x2 = copy(x)
    x2[m] .= 0

    return sum(x2,dims = dim) ./ sum(.!m,dims = dim)
end


"""
    datetime_matlab(datenum)

Return DateTime from matlab's and octave's datenum
"""
function datetime_matlab(datenum)
    # even if datenum is Int32, the computations must be done with Int64 to
    # prevent overflow
    return DateTime(1970,1,1) + Dates.Millisecond(round(Int64,(datenum-Int64(719529)) * 24*60*60*1000))
end


include("EOS80.jl")

"""
    latentflux(Ts,Ta,r,w,pa)

Compute the latent heat flux (W/m²) using
the sea surface temperature `Ts` (degree Celsius),
the air temperature `Ta` (degree Celsius),
the relative humidity `r` (0 ≤ r ≤ 1, pressure ratio, not percentage),
the wind speed `w` (m/s)
and the air pressure (hPa).
"""
function latentflux(Ts,Ta,r,w,pa)


    Da = 1.5e-3;
    rhoa = 1.3; # kg m-3
    Lh = 2.5e6; # J
    epsilon = 0.622;

    esta = vaporpressure(Ta);
    ests = vaporpressure(Ts);

    qqa = r * esta * epsilon / pa;
    qqs = ests * epsilon / pa;


    Qe = Da * rhoa * abs(w) * (qqs-qqa) * Lh;

    return Qe
end

"""
    longwaveflux(Ts,Ta,e,tcc)

Compute the long wave heat flux (W/m²) using
the sea surface temperature `Ts` (degree Celsius),
the air temperature `Ta` (degree Celsius),
the wate vapour pressure `e` (hPa) and the total cloud coverage `ttc` (0 ≤ tcc ≤ 1).
"""
function longwaveflux(Ts,Ta,e,tcc)
    epsilon = 0.98;
    sigma = 5.67e-8;
    lambda = 0.69;

    # degree C to degree K
    Ts = Ts + TK
    Ta = Ta + TK

    Qb = epsilon * sigma  * Ts^4 * (0.39-0.05*sqrt(e))*(1-lambda*tcc^2)+4 * epsilon * sigma * Ts^3 *(Ts-Ta)

    return Qb
end

"""
    sensibleflux(Ts,Ta,w)

Compute the sensible heat flux (W/m²) using
the wind speed `w` (m/s),
the sea surface temperature `Ts` (degree Celsius),
the air temperature `Ta` (degree Celsius).
"""
function sensibleflux(Ts,Ta,w)
    Sta = 1.45e-3;
    ca = 1000;
    rhoa = 1.3;

    Qc = Sta * ca * rhoa * w * (Ts-Ta);

    return Qc
end

"""
    solarflux(Q,al)

Compute the solar heat flux (W/m²)
"""
function solarflux(Q,al)
    Qs = Q*(1-al)
    return Qs
end

"""
    vaporpressure(T)

Compute vapour pressure of water at the temperature `T` (degree Celsius) in hPa using Tetens equations.
The temperature must be postive.

Monteith, J.L., and Unsworth, M.H. 2008. Principles of Environmental Physics. Third Ed. AP, Amsterdam. http://store.elsevier.com/Principles-of-Environmental-Physics/John-Monteith/isbn-9780080924793
"""
function vaporpressure(T)
    # Monteith and Unsworth (2008), https://en.wikipedia.org/wiki/Tetens_equation
    e = 6.1078 * exp((17.27 * T)./(T + 237.3));
    return e
end


"""
    gausswin(N, α = 2.5)

Return a Gaussian window with `N` points with a standard deviation of
(N-1)/(2 α).
"""
function gausswin(N, α = 2.5)
    sigma = (N-1)/(2 * α)
    return [exp(- n^2 / (2*sigma^2)) for n = -(N-1)/2:(N-1)/2]
end

"""
    gaussfilter(x,N)

Filter the vector `x` with a `N`-point Gaussian window.
"""
function gaussfilter(x,N)
    b = gausswin(N);
    c = b/sum(b);
    imax = size(x,1);
    xf = zeros(imax)
    s=1;

    for i=1:imax
        xf[i] = sum(x[s:s+N-1] .* c);

        s = s+1;
        if s>=size(x,1)-N
            s=size(x,1)-N;
        end
    end

    return xf
end

"""
    coriolisfrequency(latitude)

Provides coriolisfrequency et given latidudes in DEGREES from -90 Southpole to +90 Northpole
"""
function coriolisfrequency(latitude)
    return 2*OMEGA*sind(latitude)
end

"""
    earthgravity(latitude)

Provides gravity in m/s2 at ocean surface at given latidudes in DEGREES from -90 Southpole to +90 Northpole
"""
function earthgravity(latitude)
    return 9.780327*(1.0026454-0.0026512*
	         cosd(2*latitude)+0.0000058*(cosd(2*latitude))^2
	)
end



# """
#     meof(masks,vars; nsv = 20)
# Compute `nsv` multivariate EOFs. `masks` and `vars` are tuples.
# """
# function meof(masks,vars; nsv = 20)
#     sv = divand.statevector(masks)


#     X = divand.packens(sv,vars);

#     Xm = mean(X,2);
#     Xp = X .- Xm;
#     #@show mean(Xp,2)

#     S = svds(Xp; nsv = nsv);
#     eofs = divand.unpackens(sv,S[1][:U]);

#     m = divand.unpack(sv,Xm[:,1]);

#     totvar = sum(abs2,Xp)

#     # relative variance in percent
#     relvar = 100 * S[1][:S].^2 / totvar

#     return (m,eofs,relvar,totvar)
# end

function addprefix!(prefix,obsids)
    if prefix == ""
        return
    end

    for i in 1:length(obsids)
        obsids[i] = prefix * obsids[i]
    end
end


include("integraterhoprime.jl")
include("stericheight.jl")
include("deepestpoint.jl")
include("floodfill!.jl")
include("addlowtoheighdimension.jl")
include("geostrophy.jl")
include("streamfunctionvolumeflux.jl")

export nanmean, nansum, gausswin, vaporpressure, solarflux, sensibleflux, gaussfilter, longwaveflux, latentflux, datetime_matlab, freezing_temperature, density, secant_bulk_modulus, coriolisfrequency, earthgravity, integraterhoprime, stericheight, deepestpoint, floodfill!, addlowtoheighdimension, geostrophy, streamfunctionvolumeflux

include("tides.jl")

include("castaway.jl")
export loadcastaway

include("CMEMS.jl")
export CMEMS

include("WorldOceanDatabase.jl")
export WorldOceanDatabase

include("ARGO.jl")
export ARGO


end
