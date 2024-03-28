using PhysOcean

using Dates
using Test
using Statistics

@testset "PhysOcean" begin

    @test nansum([NaN,1.,2.]) ≈ 3
    @test nanmean([NaN,1.,2.]) ≈ 1.5

    @test nansum([NaN 1.; 2. 4.],1) ≈ [2. 5.]
    @test nanmean([NaN 1.; 2. 4.],1) ≈ [2. 2.5]

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

    # reference values from octave using matlab sw toolbox
    #
    # >> format long
    # >> sw_adtg(35.,20.,10)
    # ans =    1.84387209878308e-04
    # >> sw_ptmp(35.,20.,10,0)
    # ans =  19.9981570426625
    # >> sw_pdens(35.,20.,1000,0)
    # ans =  1024.81108126767

    @test adiabatic_temperature_gradient(35.,20.,10) ≈ 1.84387209878308e-04

    @test potential_temperature(35.,20.,1000,0) ≈ 19.8122912486651
    @test potential_density(35.,20.,1000,0) ≈ 1024.81108126767

    # Reference page 44 of UNESCO report
    @test adiabatic_temperature_gradient(40.,40/1.00024,10_000) ≈ 3.255976e-4 atol=1e-10

    # Reference page 43 of UNESCO report
    @test potential_temperature(40.,40. /  1.00024,10000,0) * 1.00024 ≈ 36.89073 atol=1e-5

    # Reference page 42 of UNESCO report
    @test PhysOcean.depth(10_000,30) ≈ 9712.653 atol=1e-4

    # >> format long
    # >> sw_bfrq([0.,15.,30.,35.],[15.,15,15,15],[0.,250,500,1000],30.)
    N²_ref = 1.0e-03 * [ 0.451543647810379, 0.445598092244291, 0.074099678791248]
    @test PhysOcean.N²([0.,15.,30.,35.],[15.,15,15,15],[0.,250,500,1000],30.) ≈ N²_ref

    # load CastAway file
    filename = joinpath(dirname(@__FILE__),"20160622_0747_TC100.csv")
    data,header,metadata = loadcastaway(filename)
    @test data[1,end] ≈ 1026.4925224486576


	@test earthgravity.([90 0]) ≈ [9.8321862058848 9.780327]
	@test coriolisfrequency.([90 0]) ≈ [0.0001458423 0]

	mask=trues(3,4,5)
    myval=zeros(3,4,5)
    botval=zeros(3,4)
    for i=1:3
       for j=1:4
          botval[i,j]=i+j+5
          for k=1:5
            myval[i,j,k]=i+j+k
            if k>i+j
                mask[i,j,k]=false
                botval[i,j]=2*(i+j)
            end
          end
       end
    end
    @test deepestpoint(mask,myval) ≈ botval

	mask=trues(3,4,5)
	myval=zeros(3,4,5)
	eta=zeros(3,4)
	myvals=zeros(3,4,5)
	for i=1:3
		for j=1:4
			eta[i,j]=i-j
			for k=1:5
				myval[i,j,k]=i+j+k
				myvals[i,j,k]=myval[i,j,k]+eta[i,j]
			end
		end
	end
    @test addlowtoheighdimension(eta,myval) ≈ myvals

	mask=trues(3,4,5)
	myval=zeros(3,4,5)
	myvali=zeros(3,4,5)
	zval=zeros(3,4,5)
	eta=zeros(3,4)
	myvals=zeros(3,4,5)
	for i=1:3
        for j=1:4
            for k=1:5
                myval[i,j,k]=i+j
                myvali[i,j,k]=(i+j)*k
                zval[i,j,k]=k
            end
        end
	end
	@test integraterhoprime(myval,zval) ≈ myvali

	mask=trues(3,4,5)
	myval=zeros(3,4,5)

	zval=zeros(3,4,5)
	eta=zeros(3,4)
	myvals=zeros(3,4,5)
	for i=1:3
        for j=1:4
            for k=1:5
                myval[i,j,k]=i+j+k
                zval[i,j,k]=k
            end
        end
	end

	@test stericheight(myval,zval,3)*1025.0+myval[:,:,3] ≈ zeros(3,4)


	myval=zeros(3,4,5)
	myvals=zeros(3,4,5)
	for i=1:3
		for j=1:4
             for k=1:5
				myval[i,j,k]=i+j+k
			end
		end
	end
	myval[2,2:3,3:4] .= NaN
	floodfill!(myval,myvals,NaN)
	refval=[6.826086956521739 8.0; 8.0 9.173913043478262]
	@test myval[2,2:3,3:4] ≈ refval



	xi=zeros(3,4,5)
	yi=zeros(3,4,5)
	zi=zeros(3,4,5)
	pm=zeros(3,4,5)
	pn=zeros(3,4,5)
	po=zeros(3,4,5)

	mask=trues(3,4,5)

	for i=1:3
        for j=1:4
            for k=1:5
                xi[i,j,k]=i
                yi[i,j,k]=30+j
                zi[i,j,k]=10*k
                pm[i,j,k]=1
                pn[i,j,k]=1
                po[i,j,k]=0.1
            end
        end
	end
	temp=16 .- zi/1600+cos.(1.4*xi+0*xi-zi/300)+xi/5 .* xi./(zi .+ 1)/2000 .* (zi/1000+xi)
	salt=28 .+ xi
	dens=density.(salt,temp,0) .- 1025;
	velocities,eta,Vflux=geostrophy(mask,dens,(pm,pn,po),(xi,yi,zi);znomotion=3);
	@test var(eta) ≈ 0.00045683197717526355
	velocities,eta,Vflux=geostrophy(mask,dens,(pm,pn,po),(xi,yi,zi);ssh=eta);
	@test var(eta) ≈ 0.00045683197717526355

	psi=streamfunctionvolumeflux(mask,velocities,(pm,pn,po),(xi,yi,zi))

	@test mean(psi[1]) ≈ -0.06242550029999892

	mask[2,3,:] .= false
	eta1=eta[1,1]
	psi11=psi[1][1,1]
	velocities,eta,Vflux=geostrophy(mask,dens,(pm,pn,po),(xi,yi,zi);znomotion=3);
	@test eta1 ≈ eta[1,1]
	velocities,eta,Vflux=geostrophy(mask,dens,(pm,pn,po),(xi,yi,zi);ssh=eta);
	@test eta1 ≈ eta[1,1]

	psi=streamfunctionvolumeflux(mask,velocities,(pm,pn,po),(xi,yi,zi))

	@test psi11 ≈ psi[1][1,1]



    include("test_cmems.jl")
    include("test_argo.jl")
    include("test_wod.jl")
    include("test_tides.jl")
end
