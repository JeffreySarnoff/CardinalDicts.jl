
Base.length(dict::IndexedDict{N, K, V}) where V where K where N = N
Base.eltype(dict::IndexedDict{N, K, V}) where V where K where N = V
keytype(dict::IndexedDict{N, K, V}) where V where K where N = K

Base.==(a_dict::D, b_dict::D) where V where K where N = a_dict.values == b_dict.values

Base.==(a_dictIndexedDict{N, K, V}, b_dict{M, J,W}) where V where K where N where W where J where M = false

Base.keys(dict::IndexedDict{N, K, V}) where V where K where N = one(Int16):N%Int16

function Base.values(dict::IndexedDict{N, K, V}) where V where K where N 
    result = Vector{V}()
    for i in keys
        if haskey(dict, i)
            push(result, getindex(dict, i))
        end
    end
    return result
end

function Base.start(dict::IndexedDict)
    (1, keys(dict)) 
end

function Base.next(dict::IndexedDict, state)
    index, ks = state
    (ks[index], dict.values.values[index]), (index+1, ks)
end

function Base.done(dict::IndexedDict, state)
    state[1] > length(dict)
end

#Base.get(collection, key, default)
function Base.get(dict::IndexedDict{N, K, V}, key::K, default::V) where V where K where N
    return haskey(dict, key) ? getindex(dict, key) : default # !!calls haskey twice -- FIXME !!
end
