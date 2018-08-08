"""

    velocity,ssh,fluxes=geostrophy(mask::BitArray,rhop,pmnin,xiin;dim::Integer=0,ssh=(),znomotion=0,fillin=true)





# Input:
* `mask` : Boolean array with true in water and false on land.
* `rhop` : density anomaly (rho-1025) array on the same grid as the mask.
* `pmnin`: tuple of metrics as in divand, but to get velocities in m/s the metrics need to be in per meters too.
* `xiin`: tuple position of the grid points.
* `dim` : optional paramter telling which index in the arrays corresponds to the vertical direction. By default 0 uses the last index
* `ssh` : array as mask for which the vertical direction is taken out. Corresponds to sea surface height in meters. Default is no used but diagnosed
* `znomotion` : index in the vertical direction where a level of no motion is assumed
* `fillin` : Boolean telling if a filling of land points using water points at the same level is to be used. Default is yes.



# Output:
* `velocity` tuple of velocity components NORMAL and to the left of each coordinate line
* `eta` : sea surface height deduced. If a ssh was provided in input it returs ssh but filled in on land.
* `fluxes`: integrated velocities across sections in each horizontal direction. Same conventions as for velocities
# Note:

Calculates geostrophic velocities.
Works with one or two horizontal dimensions and additional (time) dimensions.
Dimensions are supposed to be ordered horizontal, vertical, other dimensions
You must either provide the index for the level of no motion or ssh eta. NOTE THAT THE LEVEL IS AN INDEX NUMBER FOR THE MOMENT
Dimensions of ssh must be the same as rhop in which vertical dimension has been taken out
If you force fillin=false, then you must have created the density array without missing values outside of this call, as well as ssh if you provide it.

"""
function geostrophy(mask::BitArray,rhop,pmnin,xiin;dim::Integer=0,ssh=(),znomotion=0,fillin=true)

if dim==0
# assume depth is last dimension
dim=ndims(rhop)
end


#############################################
function myfilter3(A::AbstractArray,fillvalue,isfixed,ntimes=1)

    #
    function dvisvalue(x)
        if isnan(fillvalue)
            return !isnan(x);
        else
            return !(x==fillvalue);
        end
    end

    nd=ndims(A)
    # central weight
    cw=3^nd-1
    cw=1
    out = similar(A)
    if ntimes>1
        B=deepcopy(A)
    else
        B=A
    end

    RI = Compat.CartesianIndices(size(A))
    I1, Iend = first(RI), last(RI)
    for nn=1:ntimes

        for I in RI
            w, s = 0.0, zero(eltype(out))
            # Define out[I] fillvalue
            out[I] = fillvalue
            if dvisvalue(B[I])
                RJ =
                    @static if VERSION >= v"0.7.0"
                        # https://github.com/JuliaLang/julia/issues/15276#issuecomment-297596373
                        # let block work-around
                        let I = I, I1 = I1, Iend = Iend
                            CartesianIndices(ntuple(
                                i-> max(I1[i], I[i]-I1[i]):min(Iend[i], I[i]+I1[i]),nd))
                        end
                    else
                        CartesianIndices(max(I1, I-I1), min(Iend, I+I1))
                    end

                for J in RJ
                    # If not a fill value
                    #                if !(B[J] == fillvalue)
                    if dvisvalue(B[J])
                        s += B[J]
                        if (I==J)
                            w += cw
                        else
                            w += 1.
                        end
                    end
                    # end if not fill value
                end
				if isfixed[I]
				    out[I]=A[I]
				  else
				    if w>0.0
                    out[I] = s/w
                    end
				end
            end
        end
        B=deepcopy(out);
    end


    return out
end
##########################################




rhof=deepcopy(rhop)

# If asked for, fill in density anomalies on land
# If not asked for the field must have already been filled in by other means
if fillin
	BBB=deepcopy(rhop)
	rhof[.!mask] .= NaN
	#maybe better to floodfill in all directions EXCEPT vertically. So loop on layers and indexing ?
	#floodfill!(rhof,B,NaN)
	for iz=1:size(BBB)[dim]
	  ind2 = [(j == dim ? (iz) : (:)) for j = 1:ndims(rhop)]
	  #@show ind2,iz,dim
	  #@show rhop[ind2...]
	  aaa=deepcopy(rhof[ind2...])
	  #@show size(BBB),size(rhof)
	  bbb=deepcopy(BBB[ind2...])
	  #@show size(aaa),size(bbb)
	  nanpos=isnan.(aaa)
	  #@show size(aaa),size(bbb)
	  aaa=floodfill!(aaa,bbb,NaN)
	  # @show size(aaa),size(bbb)
	 #  Now one also should filter in the places where originially NaN where found
	  # si using divand_filter3(,NaN,10)

	  zzzz=fill(NaN,size(aaa))
	  #@show size(zzzz)
	  zzzz[nanpos]=aaa[nanpos]
	  isfixed=fill(true,size(aaa))
	  isfixed[nanpos] .= false

	  zzzz=myfilter3(zzzz,NaN,isfixed,20)
	  aaa[nanpos]=zzzz[nanpos]
	  #@show size(aaa),size(zzzz)
     #@show size(rhof)
	 rhof[ind2...]=deepcopy(aaa)




	end

end


# Now integrate in dimension dim

#@show size(rhop),size(rhof),typeof(rhop),typeof(rhof),mean(var(rhof,2))

rhoi=integraterhoprime(rhof,xiin[dim],dim)

#@show size(rhoi),size(rhof)

#@show mean(var(rhoi,2)),mean(var(rhop,2))

# If ssh provided use it, otherwise first calculate steric height

  if znomotion>0
    ssh=stericheight(rhoi,xiin[dim],znomotion,dim)
	    else
		if fillin
		 ind2 = [(j == dim ? (1) : (:)) for j = 1:ndims(mask)]
		 # @show ind2
		  ssh[.!mask[ind2...]] .= NaN
		 # @show ssh
		 aaa=deepcopy(ssh)
		 bbb=deepcopy(ssh)

	     nanpos=isnan.(aaa)

	     aaa=floodfill!(aaa,bbb,NaN)
		 zzzz=fill(NaN,size(aaa))
	    #@show size(zzzz)
	     zzzz[nanpos]=aaa[nanpos]
	     isfixed=fill(true,size(aaa))
	     isfixed[nanpos] .= false

	    zzzz=myfilter3(zzzz,NaN,isfixed,20)
	    aaa[nanpos]=zzzz[nanpos]
		ssh=deepcopy(aaa)

		end
  end

# Now add barotropic pressure onto the direction dim

poverrho=similar(rhoi)

#@show var(rhoi),mean(rhoi)

#
poverrhog=addlowtoheighdimension(ssh,rhoi/1025.,dim)

#@show mean(var(poverrhog,2))

goverf=earthgravity.(xiin[2])./coriolisfrequency.(xiin[2])

# Need to decide how to provide latitude if 1D ...



# Loop over dimensions 1 to dim-1



velocity=()
fluxes=()

for i=1:dim-1



#VN=0*similar(poverrhog)
VN=zeros(Float64,size(poverrhog))

#@show mean(VN),mean(poverrhog),typeof(poverrhog),typeof(VN)

Rpre = CartesianIndices(size(poverrhog)[1:i-1])
Rpost = CartesianIndices(size(poverrhog)[i+1:end])
n=size(poverrhog)[i]

    for Ipost in Rpost

        for j = 1:n-1
            for Ipre in Rpre
                 VN[Ipre, j, Ipost] = (poverrhog[Ipre, j+1 , Ipost]-poverrhog[Ipre, j , Ipost])*pmnin[i][Ipre, j , Ipost]*goverf[Ipre, j , Ipost]
			end
        end
    end
VN[.!mask] .= 0.0

if isnan(mean(VN))
 @show mean(VN)
 warning("Problem in geostrophic calculation")
end

velocity=tuple(velocity...,(deepcopy(VN)))

#@show mean(VN)

# maybe add volume flux calculation using mask putting zero and integraterhoprime of VN/pnmin[i] with previous loop and then simple sum in remaining direction of # bottom value yep should work easily !!!

ind1 = [(j == dim ? (size(VN)[dim]) : (:)) for j = 1:ndims(VN)]

#@show ind1, size(VN),size(pmnin[i])

dummy=integraterhoprime(VN./pmnin[i],xiin[dim],dim)


#@show size(dummy),mean(VN),mean(dummy)

# now take deepast value for VN which is the integral

#hjm=deepestpoint(mask,dummy)

#@show size(dummy[ind1...]),size(hjm)




fluxi =
    if VERSION >= v"0.7.0-beta2"
        dropdims(sum(dummy[ind1...],dims = i),dims = i)
    else
        squeeze(sum(dummy[ind1...],i),i)
    end

#@show size(fluxi), var(fluxi),mean(VN),var(VN)

#if isnan(var(fluxi))

#@show dummy[ind1...]
#@show VN[ind1...]./pmnin[i][ind1...]
#@show xiin[dim][ind1...]

#end

fluxes=tuple(fluxes...,(deepcopy(fluxi)))

end




return velocity,ssh,fluxes

end


# Copyright (C)           2018 Alexander Barth 		<a.barth@ulg.ac.be>
#                              Jean-Marie Beckers 	<jm.beckers@ulg.ac.be>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.
