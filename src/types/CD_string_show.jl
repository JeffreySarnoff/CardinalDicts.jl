# string, io

function Base.string(dict::CardinalDict{V,K}) where {K,V}
    n = length(dict)
    maxkey = keymax(dict)
    n == 0 && return string("CardinalDict{",V,"}(",maxkey,")")
    ks = keys(dict)
    vs = values(dict)
    kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
    str = string("CardinalDict(",kv)
    if maxkey==n
        result = string(str,")")
    else
        result = string(str,", ",maxkey,")")
    end
    return result
end

function stringtoshow(dict::CardinalDict{V,K}) where {K,V}
    n = length(dict)
    n == 0 && return string("CardinalDict{",V,"}(",keymax(dict),")")
    ks = keys(dict)
    vs = values(dict)
    ttyrows = displaysize(Base.TTY())[1] - 3
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

function Base.show(io::IO,dict::CardinalDict{V,K}) where {K,V}
    str = stringtoshow(dict)
    return print(io, str)
end

Base.show(dict::CardinalDict{V,K}) where {K,V} = Base.show(Base.STDOUT, dict)
   
Base.display(dict::CardinalDict{V,K}) where {K,V} = Base.show(dict)
