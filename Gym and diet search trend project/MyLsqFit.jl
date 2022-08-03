module MyLsqFit

using IJulia, Plots
using LinearAlgebra

# these are the functions that will be immediately accessible after `using MyLsqFit`
export lsqfit_poly, polynomial, lsqfit_poly_periodic, poly_periodic


function lsqfit_poly(t::AbstractVector, y::AbstractVector, d::Integer)
    m = length(y)
    @assert length(t) == m "length of t and y vectors must be the same"
    
    A = zeros(m, d+1)
    for t_idx in 1:m
        for i in 0:d
            A[t_idx, i + 1] =t[t_idx]^i
        end
    end
    
    c_ls = pinv(A)*y
    return A, c_ls 
end

function lsqfit_poly_periodic(
        t::AbstractVector,
        y::AbstractVector,
        d_poly::Integer,
        d_periodic::Integer,
        T::Number=1.0
    )
    
	  m = length(t)
    
    # Construct the A matrix for the polynomial part
    Apoly = zeros(m, d_poly+1)
    for i in 0:d_poly
        Apoly[:, i+1] = t.^(i)
    end
    
    # Construct the A matrix for the periodic part
    Aperiodic = zeros(m, 2*d_periodic)
    
    for i in 1:d_periodic
       Aperiodic[:, 2 * i - 1] = cos.(2*pi*i/T*t)
       Aperiodic[:, 2 * i] = sin.(2*pi*i/T*t)
    end
    
    # Concatenate them 
    A = [Apoly Aperiodic]
    
    # Step 4: Solve the least squares problem
    c_ls = pinv(A)*y
    
    return A, c_ls
	
end


function polynomial(t::AbstractVector, c::AbstractVector) 
    y = zeros(length(t))
    d = length(c)-1
    for j in 1:length(t)
        for i in 0:d
           y[j]+= c[i+1]*t[j]^i
        end
    end
    return y
end
function poly_periodic(
        t::AbstractVector,
        c::AbstractVector,
        d_poly::Integer,
        d_periodic::Integer,
        T::Number
        ) 
    

     m = length(t)
    y = zeros(m)
    
    # Step 1: Extact polynomial and periodic coefficients
    c_poly = c[1:(d_poly+1)]
    c_periodic = c[(d_poly+2):end]
    @assert length(c_periodic) == 2 * d_periodic "Number of periodic coeffs does not match 2 * d_periodic"
    
    # Step 2: Compute the polynomial part 
    for i in 0:d_poly
       y += c[i+1]*t.^i
    end
    
    # Step 3: Compute the periodic part
    for i in 1:d_periodic
        y += c_periodic[2i-1]*cos.(2*pi*i/T*t) # cosine term
        y += c_periodic[2i]*sin.(2*pi*i/T*t) # sine term
    end
    
    return y
    
end

end # module
