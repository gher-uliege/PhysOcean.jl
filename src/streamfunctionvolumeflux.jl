"""

    psifluxes=streamfunctionvolumeflux(mask::BitArray,velocities,pmnin,xiin;dim::Integer=0)
	
	



# Input:
* `mask` : Boolean array with true in water and false on land. 
* `velocities` : tuple of arrays on the same grid as the mask. Each tuple element is a velocity field normal to the corresponding direction in space
* `pmnin`: tuple of metrics as in divand, but to get velocities in m/s the metrics need to be in per meters too.
* `xiin`: tuple position of the grid points.
* `dim` : optional paramter telling which index in the arrays corresponds to the vertical direction. By default 0 uses the last index



# Output:
* `psifluxes` tuple of volume fluxes at each depth and direction NORMAL and to the left of each coordinate line


Calculates volume flux streamfunction calculated from the surface. The value of this field provides the total flow (in Sverdrup) across the section above the depth of the zlevel looked at. 

"""
function streamfunctionvolumeflux(mask::BitArray,velocities,pmnin,xiin;dim::Integer=0)

if dim==0
# assume depth is last dimension
dim=ndims(mask)
end


# snippets from https://julialang.org/blog/2016/02/iteration
# function sumalongdims(A, dims)
    # sz = [size(A)...]
    # sz[[dims...]] = 1
    # #B = Array(eltype(A), sz...)
	# B = Array{eltype(A)}(sz...)
    # sumalongdims!(B, A)
# end
# @noinline function sumalongdims!(B, A)
    # # It's assumed that B has size 1 along any dimension that we're summing
    # fill!(B, 0)
    # Bmax = CartesianIndex(size(B))
    # for I in CartesianIndices(size(A))
        # B[min(Bmax,I)] += A[I]
    # end
    # B
# end






# Loop over dimensions 1 to dim-1



velocity=()
psifluxes=()

for i=1:dim-1

# normal velocities to direction i

VN=velocities[i]

VN[findall(.!mask)] .= 0.0

# Now transports

dummy=integraterhoprime(VN./pmnin[i],xiin[dim],dim)

#@show VN[:,:,1]

#@show dummy[:,:,1]

# Put zero on land
dummy[.!mask] .= 0.0

# And now simply do the reduction


#Volumeflux=squeeze(sumalongdims(dummy, i),i)/10^6
Volumeflux =
    if VERSION >= v"0.7.0-beta2"
        dropdims(sum(dummy, dims = i),dims = i)/10^6
    else
        squeeze(sum(dummy, i),i)/10^6
    end
#@show size(Volumeflux)
#
# Apply mask based on mask 

if VERSION >= v"0.7.0-beta2"
    Volumeflux[dropdims(sum(mask,dims=i),dims=i) .== 0] .= NaN
else
    Volumeflux[find(sum(mask,i) .== 0)] .= NaN
end
#

psifluxes=tuple(psifluxes...,(deepcopy(Volumeflux)))

end




return psifluxes
 
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


