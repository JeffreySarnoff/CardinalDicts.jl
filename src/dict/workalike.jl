
Base.length(dict::IndexedDict{K, V}) where K where V = length(dict.values)
Base.eltype(dict::IndexedDict{K, V}) where K where V = V
keytype(dict::IndexedDict{K, V}) where K where V = K

Base.:(==)(a_dict::D, b_dict::D) where D<:IndexedDict{K,V} where K where V =
    a_dict.values == b_dict.values

Base.:(==)(a_dict::IndexedDict{K,V}, b_dict::IndexedDict{J,W}) where K where J where V where W =
    false

Base.keys(dict::IndexedDict{K,V}) where K where V = one(K):length(dict)%K

function Base.values(dict::IndexedDict{K,V}) where K where V 
    result = Vector{V}()
    for i in keys
        if haskey(dict, i)
            push(result, getindex(dict, i))
        end
    end
    return result
end

function Base.start(dict::IndexedDict{K,V}) where K where V
    (1, keys(dict)) 
end

function Base.next(dict::IndexedDict{K,V}, state) where K where V
    index, ks = state
    (ks[index], dict.values.values[index]), (index+1, ks)
end

function Base.done(dict::IndexedDict{K,V}, state) where K where V
    state[1] > length(dict)
end

#Base.get(collection, key, default)
function Base.get(dict::IndexedDict{K,V}, key::K, default::V) where K where V
    return haskey(dict, key) ? getindex(dict, key) : default # !!calls haskey twice -- FIXME !!
end
