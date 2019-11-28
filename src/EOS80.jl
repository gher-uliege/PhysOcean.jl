# Equation of State (EOS)
# http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf


"""
    temperature68(T)

Convert temperature `T` from ITS-90 scale to the IPTS-68 scale following Saunders, 1990.

Saunders, P.M. 1990, The International Temperature Scale of 1990, ITS-90. No.10, p.10.
https://web.archive.org/web/20170304194831/http://webapp1.dlib.indiana.edu/virtual_disk_library/index.cgi/4955867/FID474/wocedocs/newsltr/news10/news10.pdf
"""
temperature68(T) = 1.00024 * T

"""
    density_reference_pure_water(T)

density of pure water at the temperature `T` (degree Celsius, ITS-90)
"""
function density_reference_pure_water(T)

    t = temperature68(T)

    # page 21, equation 14 of
    # http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf

    a0 = 999.842594 # why [-28.263737]
    a1 = 6.793952e-2
    a2 = -9.095290e-3
    a3 = 1.001685e-4
    a4 = -1.120083e-6
    a5 = 6.536332e-9

    ρ_w = a0 + (a1 + (a2 + (a3 + (a4 + a5 * t) * t) * t) * t) * t
    return ρ_w
end

function density0(S,T)
    t = temperature68(T)
    # page 21, equation (13) of
    # http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf

    b0 = 8.24493e-1
    b1 = -4.0899e-3
    b2 = 7.6438e-5
    b3 = -8.2467e-7
    b4 = 5.3875e-9
    c0 = -5.72466e-3
    c1 = 1.0227e-4
    c2 = -1.6546e-6
    d0 = 4.8314e-4

    ρ = density_reference_pure_water(T) + ((b0 + (b1 + (b2 + (b3 + b4 * t) * t) * t) * t) + (c0 + (c1 + c2 * t) * t) * sqrt(S) + d0 * S) * S;
    return ρ
end


"""
    density(S,T,p)

Compute the density of sea-water (kg/m³) at the salinity `S` (psu, PSS-78), temperature `T` (degree Celsius, ITS-90) and pressure `p` (decibar) using the UNESCO 1983 polynomial.

Fofonoff, N.P.; Millard, R.C. (1983). Algorithms for computation of fundamental properties of seawater. UNESCO Technical Papers in Marine Science, No. 44. UNESCO: Paris. 53 pp.
http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf
"""
function density(S,T,p)
    ρ = density0(S,T)

    if (p == 0)
        return ρ
    end

    K = secant_bulk_modulus(S,T,p)
    # convert decibars to bars
    p = p/10
    return ρ / (1 - p/K)
end


"""
    secant_bulk_modulus(S,T,p)

Compute the secant bulk modulus of sea-water (bars) at the salinity `S` (psu, PSS-78), temperature `T` (degree Celsius, ITS-90) and pressure `p` (decibar) using the UNESCO polynomial 1983.

Fofonoff, N.P.; Millard, R.C. (1983). Algorithms for computation of fundamental properties of seawater. UNESCO Technical Papers in Marine Science, No. 44. UNESCO: Paris. 53 pp.
http://web.archive.org/web/20170103000527/http://unesdoc.unesco.org/images/0005/000598/059832eb.pdf
"""
function secant_bulk_modulus(S,T,p)
    # convert decibars to bars
    p = p/10

    t = temperature68(T)

    # page 18, equation (19)
    e0 = +19652.21 # [-1930.06]
    e1 = +148.4206
    e2 = -2.327105
    e3 = +1.360477E-2
    e4 = -5.155288E-5
    Kw = e0 + (e1  + (e2 + (e3  + e4 * t) * t) * t) * t

    # page 18, equation (16)
    # probably typo f3 vs f2
    f0 = +54.6746;    g0 = +7.944E-2
    f1 = -0.603459;   g1 = +1.6483E-2
    f2 = +1.09987E-2; g2 = -5.3009E-4
    f3 = -6.1670E-5

    K0 = Kw + ((f0 + (f1 + (f2  + f3 * t) * t) * t) + (g0 + (g1 + g2 * t) * t) * sqrt(S)) * S

    if (p == 0)
        return K0
    end

    # page 19
    h0 = +3.239908 # [-0.1194975]
    h1 = +1.43713E-3
    h2 = +1.16092E-4
    h3 = -5.77905E-7
    Aw = h0 + (h1 + (h2 + h3 * t) * t) * t


    k0 = +8.50935E-5 # [+ 3.47718E-5]
    k1 = -6.12293E-6
    k2 = +5.2787E-8
    Bw = k0 + (k1 + k2 * t) * t

    # page 18, equation (17)
    i0 = +2.2838E-3; j0 = +1.91075E-4
    i1 = -1.0981E-5
    i2 = -1.6078E-6
    A = Aw + ((i0 + (i1 + i2 * t) * t) + j0 * sqrt(S)) * S

    # page 18, equation (18)
    m0 = -9.9348E-7
    m1 = +2.0816E-8
    m2 = +9.1697E-10
    B = Bw + (m0 + (m1 + m2 * t) * t) * S

    K = K0 + (A + B * p) * p

    return K
end



"""
    freezing_temperature(S)

Compute the freezing temperature (in degree Celsius) of sea-water based on the salinity `S` (psu).
"""
freezing_temperature(S) = (-0.0575 + 1.710523e-3 * sqrt(S) - 2.154996e-4 * S) * S


function _adiabatic_temperature_gradient_t68(S,T,P)
    ΔS = S - 35.

    ATG = ((((-2.1687e-16*T + 1.8676e-14)*T - 4.6206e-13)*P
            + ((2.7759e-12 * T - 1.1351e-10) * ΔS +
               ((-5.4481e-14*T + 8.733E-12)*T
                -6.7795e-10)*T + 1.8741e-8))*P
           +(-4.2393e-8 * T + 1.8932e-6) * ΔS
           +((6.6228e-10 * T - 6.836e-8)*T + 8.5258e-6)*T + 3.5803e-5)
    return ATG
end

"""
    adiabatic_temperature_gradient(S,T,P)

Compute the adiabatic temperature gradient (degree Celsius/decibar)
of a water mass with the salinity `S` (psu, PSS-78) ) and
temperature `T` (degree Celsius, ITS-90)) at the pressure `P` (db)
using the UNESCO polynomial 1983, page 44.

"""
function adiabatic_temperature_gradient(S,T,P)
    # convert to T68
    t = temperature68(T)
    _adiabatic_temperature_gradient_t68(S,t,P)
end
export adiabatic_temperature_gradient

"""
    potential_temperature(S,T,P,PR)

Potential temperature (degree Celsius, ITS-90) as per UNESCO 1983 report of a water
mass with the salinity `S` (psu, PSS-78) and temperature `T` (degree Celsius, ITS-90) at the pressure `P` (db)
relative to the reference pressure `PR` (db).
"""
function potential_temperature(S,T,P,PR)
    T68 = temperature68(T)

    # 4th order Runge-Kutta
    ΔP = PR - P
    Δθ₁ = ΔP * _adiabatic_temperature_gradient_t68(S,T68,P)
    θ₁ = T68 + Δθ₁ / 2

    Δθ₂ = ΔP * _adiabatic_temperature_gradient_t68(S,θ₁,P + ΔP/2)
    q₁ = Δθ₁
    θ₂ = θ₁ + (1 - 1/sqrt(2)) * (Δθ₂ - q₁)

    Δθ₃ = ΔP * _adiabatic_temperature_gradient_t68(S,θ₂,P + ΔP/2)
    q₂ = (2 - sqrt(2)) * Δθ₂ + (-2 + 3/sqrt(2)) * q₁
    θ₃ = θ₂ + (1 + 1/sqrt(2)) * (Δθ₃ - q₂)

    Δθ₄ = ΔP * _adiabatic_temperature_gradient_t68(S,θ₃,P + ΔP)
    q₃ = (2 + sqrt(2)) * Δθ₃ + (-2 - 3/sqrt(2)) * q₂
    θ₄ = θ₃ + (Δθ₄ - 2q₃)/6

    return θ₄ / 1.00024
end

export potential_temperature

"""
    potential_density(S,T,P,PR)
Potential density (kg/m^3) of a water mass with the salinity `S`
(psu, PSS-78) and temperature `T` (degree Celsius, ITS-90) at the pressure `P` (db)
relative to the reference pressure `PR` (db).
"""
function potential_density(S,T,P,PR)
    θ = potential_temperature(S,T,P,PR)
    return density(S,θ,PR)
end
export potential_density


function g(lat)
    X = sind(lat)
    X² = X^2
    # GRAVITY VARIATION WITH LAT: ANON (1970) BULLETIN GEODESIQUE
    return 9.780318*(1.0+(5.2788E-3+2.36E-5*X²)*X²)
end

"""
z is positive above the sea surface and negative below

A.E. Gill 1982, "Atmosphere-Ocean Dynamics", ISBN: 0-12-283522-0
"""
g(lat,z) = g(lat)/((1+z/MEAN_RADIUS_EARTH)^2)


"""
    depth(P,lat)

Depth (meters) from pressure (db) using Saunders and Fofonoff's method
and latitude `lat` is degrees.

https://web.archive.org/web/20191128093534/http://usjgofs.whoi.edu/datasys/depthTM-calculated.html
"""
function depth(P,lat)
    X = sind(lat)
    X² = X^2
    # GRAVITY VARIATION WITH LAT: ANON (1970) BULLETIN GEODESIQUE
    GR = 9.780318*(1.0+(5.2788E-3+2.36E-5*X²)*X²) + 1.092E-6*P
    depth = (((-1.82E-15*P+2.279E-10)*P-2.2512E-5)*P+9.72659)*P
    return depth/GR
end


function N²!(S,T,P,latitude,N2)
    kmax = length(S)

    z0 = depth(P[1],latitude)
    g0 = g(latitude,-z0)

    for k = 1:kmax-1
        z1 = depth(P[k+1],latitude)
        g1 = g(latitude,-z1)

        p_center = (P[k] + P[k+1])/2

        pdens0 = potential_density(S[k],T[k],P[k],p_center)
        pdens1 = potential_density(S[k+1],T[k+1],P[k+1],p_center)

        pdens_center = (pdens0 + pdens1)/2
        g_center = (g0+g1)/2

        N2[k]  = g_center/pdens_center * (pdens1 - pdens0)/(z1-z0)

        g0 = g1
        z0 = z1
    end

    return N2
end


"""
    PhysOcean.N²(S,T,P,latitude)

Brunt-Väisälä or buoyancy frequency squared (1/s²) at mid-depth for a profile
with
the salinity `S` (psu, PSS-78), temperature `T` (degree Celsius, ITS-90) and pressure `P` (decibar). The latitude `lat` (degrees) is used to compute the
acceleration due to gravity.

```math
N^2 = - \\frac{g}{ρ}  \\frac{∂ρ}{∂z}
```

where z is negative in water.
"""
N²(S,T,P,latitude) =  N²!(S,T,P,latitude,similar(S,length(S)-1))
