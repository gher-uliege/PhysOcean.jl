# Adapted from
# from http://julialang.org/blog/2016/02/iteration
# to  fill values in a regular grid array.

function floodfill!(A::AbstractArray,B::AbstractArray,fillvalue;MAXITER=())

    #
    function dvisvalue(x)
        if isnan(fillvalue)
            return !isnan(x);
        else
            return !(x==fillvalue);
        end
    end
	if MAXITER==()
	  MAXITER=sum(size(B))
	  #@show MAXITER
	end


    ntimes=1
    nd=ndims(A)
    # central weight
    cw=3^nd-1
    cw=1
    iter=0

    RI = Compat.CartesianIndices(size(A))
    I1, Iend = first(RI), last(RI)
	needtocontinue=true
    while needtocontinue
	    iter=iter+1
        needtocontinue=false
        for I in RI
            w, s = 0.0, zero(eltype(A))

            B[I] = A[I]
            if !dvisvalue(A[I])
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
                    if dvisvalue(A[J])
                        s += A[J]
                        if (I==J)
                            w += cw
                        else
                            w += 1.
                        end
						else
						needtocontinue=true
                    end
                    # end if not fill value
                end
                if w>0.0
                    B[I] = s/w
                end
            end
        end

	if iter > MAXITER
	needtocontinue=false
    end
	A[:]=B[:]

    end


    return A
end
