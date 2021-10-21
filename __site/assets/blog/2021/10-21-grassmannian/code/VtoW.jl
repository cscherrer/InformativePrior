# This file was generated, do not modify it. # hide
function VtoW(V)
    # Makes ones on the diagonal
    W = V / Diagonal(diag(V))

    # Gaussian elimination to clear the top
    for editcol in 1:k
        for refcol in (editcol + 1):k
            m = -W[refcol, editcol]
            for i in refcol:n
                W[i, editcol] += m * W[i, refcol]
            end
        end
    end
    return W
end