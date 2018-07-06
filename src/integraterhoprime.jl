"""


    rhoi = integraterhoprime(rhop,z);

Integrates density anomalies over depth. When used with gravity, assuming gravity is independant on z,
it can be used to calculate dynamic pressure up to a constant. Function can be used with 1D, 2D, ...

# Input:
* `rhop`: density anomaly array
* `z`: vertical position array. Zero at surface and positive downward, same dimensions as rhop
* `dim`: along which dimension depth is found and integral is performed. If not provided, last dimension is taken

# Output:
* `rhoi` : Integrated value to the same levels as on which rhop where given. So basically total density anomaly ABOVE the current depth

# Note:

Compute vertical integral of density anomalies

"""
function integraterhoprime(rhop,z,dim::Integer=0)

if dim==0
# assume depth is last dimension
dim=ndims(rhop)
end

rhoi=similar(rhop)
Rpre = CartesianIndices(size(rhop)[1:dim-1])
Rpost = CartesianIndices(size(rhop)[dim+1:end])
    
_integraterhoprime!(rhoi, rhop, z, Rpre, size(rhop, dim), Rpost)
end


@noinline function _integraterhoprime!(rhoi, rhop, z, Rpre, n , Rpost)


    for Ipost in Rpost
        # Initialize the first value along the dimension
        for Ipre in Rpre
            rhoi[Ipre, 1, Ipost] = rhop[Ipre, 1, Ipost]*z[Ipre, 1, Ipost]
        end
        # Handle all other entries
        for i = 2:n
            for Ipre in Rpre
                rhoi[Ipre, i, Ipost] =  rhoi[Ipre, i-1, Ipost] + 
				  0.5*(rhop[Ipre, i, Ipost]+rhop[Ipre, i-1, Ipost])*
				  (z[Ipre, i, Ipost]-z[Ipre, i-1, Ipost])
				
            end
        end
    end
#    @show size(rhoi),mean(var(rhoi,2)),mean(var(rhop,2)),mean(var(z,2))
#	if isnan(mean(rhoi))
#	@ show find(isnan.(rhoi))
#	end

	rhoi
	
	
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
