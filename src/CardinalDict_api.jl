include("dict_api_lite.jl")


keymax(dict::CardinalDict{K, V}) where {K,V} = length(dict.valued)
isfull(dict::CardinalDict{K, V}) where {K,V} = all(dict.valued)

function clearindex!(dict::CardinalDict{K,V}, key::K) where K where V
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    @inbounds setindex!(dict.valued, false, key)
    return dict
end
@inline clearindex!(dict::CardinalDict{K,V}, key::J) where J where K where V =
    clearindex!(dict, key%K)
