#
# Collections of tools for physical oceanography

# Authors: 
# Aida Alvera Azcarate
# Alexander Barth


module PhysOcean


function nansum(x)
    return sum(x[!isnan.(x)])
end

function nanmean(x)
    return mean(x[!isnan.(x)])
end


"""
Return DateTime from matlab's and octave's datenum 
"""
function datetime_matlab(datenum)    
    return DateTime(1970,1,1) + Dates.Millisecond(round(Int,(datenum-719529) *24*60*60*1000))
end


freezing_temperature(S) = (-0.0575 + 1.710523e-3 * sqrt(S) - 2.154996e-4 * S) * S


function latentflux(r,Ta,Ts,w,pa)

    #pa hPa
    #w m/s
    #  Ta, Ts degC
    #r unitless

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

function longwaveflux(Ts,Ta,e,tcc)
    epsilon = 0.98;
    sigma = 5.67e-8;
    lambda = 0.69;

    Qb = epsilon * sigma  * Ts^4 * (0.39-0.05*e^(1/2))*(1-lambda*tcc.^2)+4 * epsilon * sigma * Ts^3 *(Ts-Ta)

    return Qb
end

function sensibleflux(w,Ts,Ta)
    Sta = 1.45e-3;
    ca = 1000;
    rhoa = 1.3;

    Qc = Sta * ca * rhoa * w * (Ts-Ta);

    return Qc
end
"""
solarflux(Q,al)


"""

function solarflux(Q,al)
    Qs = Q*(1-al)
    return Qs
end
"""
T degC
e hPa

Monteith and Unsworth (2008), https://en.wikipedia.org/wiki/Tetens_equation
"""

function vaporpressure(T)
    # Monteith and Unsworth (2008), https://en.wikipedia.org/wiki/Tetens_equation
    e = 6.1078* exp((17.27.*T)./(T+237.3));
    return e
end


# Implementation from the documentation at
# https://nl.mathworks.com/help/signal/ref/gausswin.html

function gausswin(N, α = 2.5)
    sigma = (N-1)/(2 * α)
    return [exp(- n^2 / (2*sigma^2)) for n = -(N-1)/2: (N-1)/2]
end


function gaussfilter(vbe,param)
    #param=6 for hourly to hourly
    #param=36 for 10-minute to 6-hourly

    b = gausswin(param);
    c = b/sum(b);

    imax = size(vbe,1);

    Filt = zeros(imax)

    s=1;

    for i=1:imax                
        Filt[i] = sum(vbe[s:s+param-1].*c);
                
        s = s+1;
        if s>=size(vbe,1)-param
            s=size(vbe,1)-param;            
        end                
    end
            
    return Filt
end


export nanmean, nansum, gausswin, vaporpressure, solarflux, sensibleflux, gaussfilter, longwaveflux, latentflux, datetime_matlab

end
