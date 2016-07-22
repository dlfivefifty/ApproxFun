

export SavedFunctional,SavedBandedOperator





## SavedFunctional

type SavedFunctional{T<:Number,M<:Operator} <: Operator{T}
    op::M
    data::Vector{T}
    datalength::Int
end

@functional SavedFunctional

SavedFunctional(op::Operator,data)=SavedFunctional(op,data,length(data))
SavedFunctional{T<:Number}(op::Operator{T})=SavedFunctional(op,Array(T,0),0)

@eval Base.convert{T}(::Type{Operator{T}},S::SavedFunctional)=SavedFunctional(convert(Operator{T},S.op))



domainspace(F::SavedFunctional)=domainspace(F.op)
bandwidth(S::SavedFunctional)=bandwidth(S.op)

function Base.getindex(B::SavedFunctional,k::Integer)
    resizedata!(B,k)
    B.data[k]
end

function Base.getindex(B::SavedFunctional,k::Range)
    resizedata!(B,k[end]+50)
    B.data[k]
end



function resizedata!(B::SavedFunctional,n::Integer)
    if n > B.datalength
        resize!(B.data,2n)

        B.data[B.datalength+1:n]=B.op[B.datalength+1:n]

        B.datalength = n
    end

    B
end



## SavedBandedOperator


type SavedBandedOperator{T<:Number,M<:Operator} <: Operator{T}
    op::M
    data::BandedMatrix{T}   #Shifted to encapsolate bandedness
    datalength::Int
    bandinds::Tuple{Int,Int}
end



# convert needs to throw away calculated data
function Base.convert{BT<:Operator}(::Type{BT},S::SavedBandedOperator)
    T=eltype(BT)
    if isa(S,BT)
        S
    else
        SavedBandedOperator(convert(Operator{T},S.op),
                            convert(BandedMatrix{T},S.data),
                            S.datalength,S.bandinds)
    end
end


#TODO: index(op) + 1 -> length(bc) + index(op)
function SavedBandedOperator{T<:Number}(op::Operator{T})
    data = bzeros(T,0,:,bandinds(op))  # bzeros is needed to allocate top of array
    SavedBandedOperator(op,data,0,bandinds(op))
end



for OP in (:domain,:domainspace,:rangespace,:(Base.stride))
    @eval $OP(S::SavedBandedOperator)=$OP(S.op)
end

bandinds(B::SavedBandedOperator)=B.bandinds




function Base.getindex(B::SavedBandedOperator,k::Integer,j::Integer)
    resizedata!(B,k)
    B.data[k,j]
end

function resizedata!(B::SavedBandedOperator,n::Integer)
    if n > B.datalength
        pad!(B.data,2n,:)

        kr=B.datalength+1:n
        jr=max(B.datalength+1-B.data.l,1):n+B.data.u
        BLAS.axpy!(1.0,view(B.op,kr,jr),view(B.data,kr,jr))

        B.datalength = n
    end

    B
end
