"""
Calculates geostrophic velocities
works with one or two horizontal dimensions and additional (time) dimensions
Dimensions are supposed to be ordered horizontal, vertical, other dimensions


# Input:
* rhop: density anomaly array
* pmnin: tuple of metrics as in divand, but should be in m 
* xiin: tuple position of the grid points.
* either provide level of no motion or ssh eta LEVEL IS INDEX NUMBER FOR THE MOMENT
* dimensions of ssh must be the same as rhop in which vertical dimension has been taken out


# Output:
* Velocity tuple components NORMAL and to the left of each coordinate line
* eta : sea surface height deduced
* fluxes: integrated velocities across sections.
# Note:


"""

function geostrophy(mask::BitArray,rhop,pmnin,xiin;dim::Integer=0,ssh=(),znomotion=0)

if dim==0
# assume depth is last dimension
dim=ndims(rhop)
end


# Fill in density anomalies on land

rhof=deepcopy(rhop)
B=deepcopy(rhop)
rhof[find(.~mask)]=NaN

floodfill!(rhof,B,NaN)

# Now integrate in dimension dim

rhoi=integraterhoprime(rhof,xiin[dim],dim)

# If ssh provided use it, otherwise first calculate steric height

  if znomotion>0
    ssh=stericheight(rhoi,xiin[dim],znomotion,dim)
  end

# Now add barotropic pressure onto the direction dim 

poverrho=similar(rhoi)
# 
poverrhog=addlowtoheighdimension(ssh,rhoi/1025.,dim)

goverf=earthgravity.(xiin[2])./coriolisfrequency.(xiin[2])
 
# Need to decide how to provide latitude if 1D ...



# Loop over dimensions 1 to dim-1



velocity=()
fluxes=()

for i=1:dim-1

VN=0*similar(poverrhog)
Rpre = CartesianRange(size(poverrhog)[1:i-1])
Rpost = CartesianRange(size(poverrhog)[i+1:end])
n=size(poverrhog)[i]

    for Ipost in Rpost
        
        for j = 1:n-1
            for Ipre in Rpre
                 VN[Ipre, j, Ipost] = (poverrhog[Ipre, j+1 , Ipost]-poverrhog[Ipre, j , Ipost])*pmnin[i][Ipre, j , Ipost]*goverf[Ipre, j , Ipost]
			end
        end
    end
VN[find(.~mask)]=0

velocity=tuple(velocity...,(deepcopy(VN)))

# maybe add volume flux calculation using mask putting zero and integraterhoprime of VN/pnmin[i] with previous loop and then simple sum in remaining direction of # bottom value yep should work easily !!!

ind1 = [(j == dim ? (size(VN)[dim]) : (:)) for j = 1:ndims(VN)]

@show ind1
dummy=integraterhoprime(VN./pmnin[i],xiin[dim],dim)
@show size(dummy)

@show size(dummy[ind1...])

fluxi=squeeze(sum(dummy[ind1...],i),i)

@show size(fluxi), var(fluxi),mean(VN),var(VN)

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


