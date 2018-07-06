"""

    ssh=stericheight(rhoi,z,zlevel,dim::Integer=0)



# Input:
* `rhoi`: integrated density anomalies (from a call to integraterhoprime)
* `z`: array of vertical positions
* `zlevel`: integer for the zlevel on which no motion is assumed
* `dim`: along which dimension depth is found . If not provided last dimension is used

# Output:
* `ssh`: steric height. space dimensions as for rhoi in which direction dim is taken out


Compute steric height with respect to given depth level presently provided as index , not depth

"""
function stericheight(rhoi,z,zlevel,dim::Integer=0);



if dim==0
# assume depth is last dimension
   dim=ndims(rhoi)
end

# Here simple index provided for zlevel, not depth

ind1 = [(j == dim ? (zlevel) : (:)) for j = 1:ndims(rhoi)]

# If someone wants to interpolate to arbitrary z values, look at deepestpoint
# to know how to deal with searching along the direction specified for the adequate levels

return -rhoi[ind1...]/1025.

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



