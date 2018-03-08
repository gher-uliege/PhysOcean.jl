"""
Compute vertical integral of density anomalies

rhoi = integraterhoprime(rhop,z);

Integrates density anomalies over depth. When used with gravity, assuming gravity is independant on z,
it can be used to calculate dynamic pressure up to a constant. Function can be used with 1D, 2D, ...

# Input:
* rhop: density anomaly array
* z: vertical position array. Zero at surface and positive downward, same dimensions as rhop
* dim: along which dimension depth is found and integral is performed 



# Note:


"""

function integraterhoprime(rhop,z,dim::Integer=0)

if dim==0
# assume depth is last dimension
dim=ndims(rhop)
end

rhoi=similar(rhop)
Rpre = CartesianRange(size(rhop)[1:dim-1])
Rpost = CartesianRange(size(rhop)[dim+1:end])
    
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
    rhoi
end



# From https://julialang.org/blog/2016/02/iteration
# function expfiltdim(x, dim::Integer, α)
    # s = similar(x)
    # Rpre = CartesianRange(size(x)[1:dim-1])
    # Rpost = CartesianRange(size(x)[dim+1:end])
    # _expfilt!(s, x, α, Rpre, size(x, dim), Rpost)
# end

# @noinline function _expfilt!(s, x, α, Rpre, n, Rpost)
    # for Ipost in Rpost
        # # Initialize the first value along the filtered dimension
        # for Ipre in Rpre
            # s[Ipre, 1, Ipost] = x[Ipre, 1, Ipost]
        # end
        # # Handle all other entries
        # for i = 2:n
            # for Ipre in Rpre
                # s[Ipre, i, Ipost] = α*x[Ipre, i, Ipost] + (1-α)*s[Ipre, i-1, Ipost]
            # end
        # end
    # end
    # s
# end

