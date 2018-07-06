"""
Get the values of f which in direction dim have the hightest index where mask is true

fdeep = deepestpoint(mask,f,dim=0);


# Input:
* mask: true for points to take into account. 
* f: array in which the points are taken
* dim: along which dimension depth is found and integral is performed. If not provided last dimension is used

# Output:
* values of f which in direction dim are found at the highest index not being false in the mask
# Note:


"""
function deepestpoint(mask,f,dim::Integer=0)

if dim==0
	# assume depth is last dimension
	dim=ndims(f)
end

ind1 = [(j == dim ? (1) : (:)) for j = 1:ndims(f)]

fdeep=similar(f[ind1...])


Rpre = CartesianIndices(size(f)[1:dim-1])
Rpost = CartesianIndices(size(f)[dim+1:end])
n=size(f)[dim]

    for Ipost in Rpost
        # Initialize the first value along the dimension
        for Ipre in Rpre
            fdeep[Ipre, Ipost] = f[Ipre, 1, Ipost]
        end
        # Handle all other entries
        for i = 2:n
            for Ipre in Rpre
                if mask[Ipre, i, Ipost] 
					fdeep[Ipre, Ipost] = f[Ipre, i , Ipost]
				end
				
            end
        end
    end

return fdeep

end
    
# Adapted from https://julialang.org/blog/2016/02/iteration


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

