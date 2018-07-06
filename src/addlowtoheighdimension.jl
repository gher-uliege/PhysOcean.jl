"""
    newhd = addlowtoheighdimension(ld,hd,dim=0);

"""
function addlowtoheighdimension(ld,hd,dim::Integer=0)

if dim==0
	# assume depth is last dimension
	dim=ndims(hd)
end



nhd=similar(hd)


Rpre = CartesianIndices(size(hd)[1:dim-1])
Rpost = CartesianIndices(size(hd)[dim+1:end])
n=size(hd)[dim]

    for Ipost in Rpost
        
        for i = 1:n
            for Ipre in Rpre
                 nhd[Ipre, i, Ipost] = hd[Ipre, i , Ipost]+ld[Ipre,Ipost]
			end
        end
    end

return nhd

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

