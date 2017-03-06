
PhysOcean


# Sea-water properties


```@docs
density(S,T,p)
```

```@docs
secant_bulk_modulus(S,T,p)
```

```@docs
freezing_temperature(S)
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
