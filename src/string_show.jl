
# string, io

function Base.string(dict::CardinalDict{K,V}) where {K,V}
    length(dict) == 0 && return string("CardinalDict{",V,"}(",keymax(dict),")")
    ks = keys(dict)
    vs = values(dict)
    kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
    return string("CardinalDict(",kv,")")
end

function stringtoshow(dict::CardinalDict{K,V}) where {K,V}
    n = length(dict)
    n == 0 && return string("CardinalDict{",V,"}(",keymax(dict),")")
    ks = keys(dict)
    vs = values(dict)
    ttyrows = displaysize(Base.TTY())[1] - 2
    if ttyrows >= n  
        kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
        str = string("CardinalDict(",kv,")")
    else
        ttyrows = fld(ttyrows-2, 2)
        kvfront = [Pair(k,v) for (k,v) in zip(ks[1:ttyrows], vs[1:ttyrows])]
        kvback  = [Pair(k,v) for (k,v) in zip(ks[end-ttyrows:end], vs[end-ttyrows:end])]
        sfront = string(kvfront)
        sback  = string(kvback)
        str = string(sfront[findfirst(sfront,'}')+1:end-1],", ...\n  ", sback[findfirst(sback,'}')+2:end])
        str = string("CardinalDict(", str, ")")
        str = join(split(str,", "),",\n  ")
    end
    return str
end

function Base.show(io::IO,dict::CardinalDict{K,V}) where {K,V}
    str = stringtoshow(dict)
    return print(io, str)
end

Base.show(dict::CardinalDict{K,V}) where {K,V} = Base.show(Base.STDOUT, dict)
   
Base.display(dict::CardinalDict{K,V}) where {K,V} = Base.show(dict)
