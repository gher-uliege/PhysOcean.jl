using PhysOcean
using Base.Test


@testset "PhysOcean" begin

    @test nansum([NaN,1.,2.]) ≈ 3
    @test nanmean([NaN,1.,2.]) ≈ 1.5

    @test datetime_matlab(730486) == DateTime(2000,1,1)

    @test freezing_temperature(35) ≈ -1.9 atol=0.1

    Ts = 10
    Ta = 20
    r = 0.9
    e = r * vaporpressure(Ta)
    tcc = 0.5
    w = 10
    pa = 1000

    # reference value from original matlab code
    @test latentflux(Ts,Ta,r,w,pa)   ≈ -265 atol=1
    @test longwaveflux(Ts,Ta,e,tcc)  ≈ -2.980503192476682  atol=0.01
    @test sensibleflux(Ts,Ta,w)      ≈ -188.5 atol=1

    Q = 1000.
    al = 1.
    @test solarflux(Q,al) ≈ 0


    # reference value from https://en.wikipedia.org/w/index.php?title=Vapour_pressure_of_water&oldid=767455276
    @test vaporpressure(10) ≈ 12.281 atol=0.01

    # gausswin should be symmetric
    gw = gausswin(3)
    @test gw[2] ≈ 1
    @test gw[1] ≈ gw[3]

    # gaussfilter should reduce a peak
    @test all(gaussfilter([0,0,0,1,0,0,0],2) .< 1)

    # pure water
    @test density(0,10,0) ≈ 9.997018700984376e+02

    @test density(35,10,0) ≈ 1.026952000476324e+03
    @test density(35,10,1000) ≈ 1.031430065478789e+03

    @test secant_bulk_modulus(35,10,0) ≈ 2.269535808268893e+04
    @test secant_bulk_modulus(35,10,1000) ≈ 2.303294089994505e+04

    # load CastAway file
    filename = joinpath(dirname(@__FILE__),"20160622_0747_TC100.csv")
    data,header,metadata = loadcastaway(filename)
    @test data[1,end] ≈ 1026.4925224486576
end
