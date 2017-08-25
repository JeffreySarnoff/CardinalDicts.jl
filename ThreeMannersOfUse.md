## The Shared API

Associative{ *KeyType* , *ValueType* }
--------------------------------------
             determined  given at each
             internally  construction

Each new CardinalDict specifies    
    - ValueType: the `type` of value to be held
    - ItemStore: the count of entries, at most [for each dim]
    
All CardinalDicts (cd) support

size(cd): the shape; max entry count for each dim
   *Note: this is **not** the number of values present.*
   *(this answers) At most, how many values may be kept?*     

length(cd): the maximum number of slots for values


### CardinalDict (a dictionary with cardinal indices)

The dictionary may be empty.  CardinalDicts are empty when first constructed.  
A CardinalDict that is not empty may be emptied.

