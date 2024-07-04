
PhysOcean


# Sea-water properties


```@docs
density(S,T,p)
secant_bulk_modulus(S,T,p)
freezing_temperature(S)
potential_temperature
potential_density
PhysOcean.N²
```

# Heat fluxes

```@docs
latentflux(Ts,Ta,r,w,pa)
```

```@docs
longwaveflux(Ts,Ta,e,tcc)
```

```@docs
sensibleflux(Ts,Ta,w)
```

```@docs
solarflux(Q,al)
```

```@docs
vaporpressure(T)
```


# Filtering

```@docs
gausswin(N, α = 2.5)
```

```@docs
gaussfilter(x,N)
```

# Earth

```@docs
coriolisfrequency(latitude)
```

```@docs
earthgravity(latitude)
```

# GFD

```@docs
integraterhoprime(rhop,z)
```

```@docs
stericheight(rhoi,z,zlevel,dim::Integer=0)
```

```@docs
geostrophy(mask::BitArray,rhop,pmnin,xiin;dim::Integer=0,ssh=(),znomotion=0,fillin=true)
```

```@docs
streamfunctionvolumeflux(mask::BitArray,velocities,pmnin,xiin;dim::Integer=0)
```

# Tides

```@docs
ap2ep
ep2ap
PhysOcean.rayleigh_criterion
```

# Data download

## CMEMS

```@docs
CMEMS.download
CMEMS.load
```

## World Ocean Database (US NODC)

```@docs
WorldOceanDatabase.download
WorldOceanDatabase.load
```

## ARGO

```@docs
ARGO.load
```
