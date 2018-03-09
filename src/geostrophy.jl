"""
Calculates geostrophic velocities
works with one or two horizontal dimensions and additional (time) dimensions
Dimensions are supposed to be ordered horizontal, vertical, other dimensions


# Input:
* rhop: density anomaly array
* z: vertical position array. Zero at surface and positive downward, same dimensions as rhop
* dim: along which dimension depth is found and integral is performed 
* either provide level of no motion or ssh eta
* dimensions of ssh must be the same as rhop in which vertical dimension has been taken out


# Output:
* Velocity tuple components NORMAL and to the left of each coordinate line
* eta : sea surface height deduced
# Note:


"""

function geostrophy(rhop,;dim::Integer=0,ssh=(),znomotion=0)

if dim==0
# assume depth is last dimension
dim=ndims(rhop)
end


# Fill in density anomalies on land

rhof=deepcopy(rhop)
B=deepcopy(rhop)
A[find(.~mask)]=NaN

floodfill!(rhof,B,NaN)

# Now integrate in dimension dim

rhoi=integraterhoprime(rhof,z,dim)

# If ssh provided use it, otherwise first calculate steric height

  if znomotion>0
    ssh=stericheight(rhoi,z,znomotion,dim)
  end

# Now add barotropic pressure onto the direction dim 

poverrho=similar(rhoi)

poverrhog=addlowtoheighdimension(ssh,rhoi/1025.,dim)

# Now times g/f and gradient





return geostropicvelocity,ssh
  


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


