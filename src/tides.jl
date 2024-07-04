"""

    semimajor, eccentricity, inclination, phase = ap2ep(u::Complex,v::Complex)
    semimajor, eccentricity, inclination, phase = ap2ep(amplitude_u,phase_u,amplitude_v,phase_v)

Return the tidal elipise parameter semi-major axis (`semimajor`), `eccentricity`, inclination (degrees, angle between east and the maximum current) and phase (degrees)
from the amplitude and phase of the meridional and zonal velocity. The velocities are related to the amplitude and phase by:

u(t) = aᵤ cos(ω t - ϕᵤ)
v(t) = aᵥ cos(ω t - ϕᵥ)

where ω is the tidal angular frequency and t the time.

The code is based on the technical report [Ellipse Parameters Conversion and Velocity Profile For Tidal Currents](https://www.researchgate.net/publication/312234150_Ellipse_Parameters_Conversion_and_Velocity_Profile_For_Tidal_Currents) from Zhigang Xu.

```
semiminor = semimajor * eccentricity
```

## Example

```julia
using PyPlot, PhysOcean
amplitude_u = 1.3
amplitude_v = 1.12
phase_u = 190
phase_v = 350

semimajor,  eccentricity, inclination, phase = ap2ep(amplitude_u,phase_u,amplitude_v,phase_v)
semiminor = semimajor * eccentricity

phase_ = 0:1:360
u = amplitude_u * cosd.(phase_ .- phase_u)
v = amplitude_v * cosd.(phase_ .- phase_v)

plot(u,v,"-",label="tidal ellipse")
plot([0,semimajor * cosd(inclination)],[0,semimajor * sind(inclination)],"-",label = "semi-major axis")
plot([0,semiminor * cosd(inclination+90)],[0,semiminor * sind(inclination+90)],"-",label = "semi-minor axis")
legend()
```

"""
function ap2ep(u::Complex,v::Complex)
    wp = (u + im*v)/2
    wm = conj((u - im*v)/2)

    semimajor = abs(wp) + abs(wm)
    semiminor = abs(wp) - abs(wm)

    eccentricity = semiminor/semimajor

    inclination = (angle(wm) + angle(wp))/2
    phase = (angle(wm) - angle(wp))/2

    # convert to degrees
    inclination = mod(inclination*180/π,360)
    phase = mod(phase*180/π,360)
    return semimajor, eccentricity, inclination, phase
end

function ap2ep(amplitude_u,phase_u,amplitude_v,phase_v)
    u = amplitude_u * exp(-im * phase_u * π/180)
    v = amplitude_v * exp(-im * phase_v * π/180)
    return ap2ep(u,v)
end

export ap2ep

"""
    amplitude_u,phase_u,amplitude_v,phase_v = ep2ap(semimajor, eccentricity, inclination, phase)

Inverse of `ap2eps`.
"""
function ep2ap(semimajor, eccentricity, inclination, phase)
    # convert to radian
    inclination = inclination*π/180
    phase = phase*π/180

    thetam = inclination+phase
    thetap = inclination-phase

    semiminor = semimajor * eccentricity
    abs_wp = (semimajor + semiminor)/2
    abs_wm = (semimajor - semiminor)/2

    wp = abs_wp * exp(im * thetap)
    wm = abs_wm * exp(im * thetam)

    u = wp + conj(wm)
    v = (wp - conj(wm))/im

    amplitude_u = abs(u)
    amplitude_v = abs(v)

    phase_u = mod(-angle(u) * 180/π,360)
    phase_v = mod(-angle(v) * 180/π,360)

    return amplitude_u,phase_u,amplitude_v,phase_v
end

export ep2ap

"""
    Tmin = PhysOcean.rayleigh_criterion(f1,f2)

Compute the minimum duration `Tmin` to separate the frequency `f1` and `f2`
following the Rayleigh criterion.
`Tmin` has the inverse of the units of `f1` and `f2`.

For example to resolve the M2 and S2 tides, the duration of the time series has
to be at least 14.765 days:

```
using PhysOcean
f_M2 = 12.4206 # h⁻¹
f_S2 = 12 # h⁻¹
Tmin = PhysOcean.rayleigh_criterion(f_M2,f_S2)
Tmin/24
# output 14.765
```

Reference:

Bruce B. Parker, [Tidal Analysis and Prediction](https://web.archive.org/web/20240626033634/https://tidesandcurrents.noaa.gov/publications/Tidal_Analysis_and_Predictions.pdf), NOAA Special Publication NOS CO-OPS 3, page 84
"""
function rayleigh_criterion(f₁,f₂)
    1/abs(1/f₁-1/f₂)
end
