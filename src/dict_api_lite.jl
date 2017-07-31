# core
Base.length(dict::CardinalDict{K, V}) where K where V = length(dict.values)

Base.eltype(dict::CardinalDict{K, V}) where K where V = Pair{K,V}

Base.:(==)(a_dict::D, b_dict::D) where D<:CardinalDict{K,V} where K where V =
    a_dict.values == b_dict.values
Base.:(==)(a_dict::CardinalDict{K,V}, b_dict::CardinalDict{J,W}) where K where J where V where W =
    false

Base.keys(dict::CardinalDict{K,V}) where K where V = one(K):length(dict)%K

function Base.values(dict::CardinalDict{K,V}) where K where V 
    result = Vector{V}()
    for i in keys(dict)
        if haskey(dict, i)
            push(result, getindex(dict, i))
        end
    end
    return result
end

# iteration

function Base.start(dict::CardinalDict{K,V}) where K where V
    (1, keys(dict)) 
end

function Base.next(dict::CardinalDict{K,V}, state) where K where V
    index, ks = state
    (ks[index], dict.values.values[index]), (index+1, ks)
end

function Base.done(dict::CardinalDict{K,V}, state) where K where V
    state[1] > length(dict)
end

# string, io

function Base.string(dict::CardinalDict{K,V}, state) where K where V
    return string("CardinalDict{",K,",",V,"}(",string(dict.values),")")
end

function Base.show(io::IO, dict::CardinalDict{K,V}, state) where K where V
    print(io, strin(dict))
end
