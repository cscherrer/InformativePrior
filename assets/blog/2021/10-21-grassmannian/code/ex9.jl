# This file was generated, do not modify it. # hide
for editcol in 1:k
    for refcol in (editcol+1):k
        m = -y[refcol, editcol]
        for i in refcol:n
            y[i,editcol] += m * y[i,refcol]
        end
    end
end