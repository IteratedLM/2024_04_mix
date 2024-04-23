
using Flux

mutable struct Agent
    bitN::Int64
    s2m
    m2s
    m2m
    m2sTable
        
    function Agent(bitN::Int64,s2m::Chain,m2s::Chain)
        m2m=Chain(m2s,s2m)
        new(bitN,s2m,m2s,m2m,Vector{Int64}(undef, 2^bitN))
    end

end

function makeAgent(bitN::Int,hiddenN::Int)
    Agent(bitN,Chain(Dense(bitN=>hiddenN,sigmoid),Dense(hiddenN=>bitN,sigmoid)),Chain(Dense(bitN=>hiddenN,sigmoid),Dense(hiddenN=>bitN,sigmoid)))
end

function deleteAgent(agent::Agent)
    agent.s2m=nothing
    agent.m2s=nothing
    agent.m2m=nothing
    agent.m2sTable=nothing
    GC.gc()
end

function makeTable(agent::Agent)

    for i in 1:2^agent.bitN 
        probs=agent.m2s(v2BV(agent.bitN,i-1))
        signal=bV2I(round.(Int64,agent.m2s(v2BV(agent.bitN,i-1))))+1
        agent.m2sTable[i]=signal
    end
end

function randomTable(bitN::Int64)
    table=randperm(2^bitN)
end

function randomCompositionalTable(bitN::Int64)
    table=Vector{Int64}(undef, 2^bitN)
    map=shuffle(collect(1:bitN))
    flip = rand(0:1, bitN)
    for i in 1:2^bitN 
        number=v2BV(bitN,i-1)
        newNumber=copy(number)
        for bit in 1:bitN
            newNumber[bit]=number[map[bit]]
        end
        for j in 1:bitN
            if flip[j]==1
                newNumber[j]=(newNumber[j]+1)%2
            end
        end
        table[i]=bV2I(newNumber)+1
    end
    table
end
    
function spliceTable(p::Real,tableA::Vector{Int64},tableB::Vector{Int64})
    l=length(tableA)
    table=Vector{Int64}(undef, l)
    for i in 1:l
        if (rand()<p)
            table[i]=tableA[i]
        else
            table[i]=tableB[i]
        end
    end
    table        
end


function makeAgent(n::Int)
    makeAgent(n,n)
end

function expressivity(agent::Agent)
    n=2^agent.bitN
    onto=zeros(Int64,n)
    for i in 1:n
        onto[agent.m2sTable[i]]=1
    end
    sum(onto)/n
end

function compositionality(agent::Agent)

    n=agent.bitN
    
    messageMatrix=Matrix{Int64}(undef,n,2^n)
    signalMatrix =Matrix{Int64}(undef,n,2^n)

    for messageC in 1:2^n
        message=v2BV(n,messageC-1)
        signal =v2BV(n,agent.m2sTable[messageC]-1)
        for i in 1:n
            messageMatrix[i,messageC]=message[i]
            signalMatrix[i,messageC]=signal[i]
        end
    end


    
    signalColV=collect(1:n)

    entropyV=[Vector{Float64}() for _ in 1:n]

    
    for messageCol in 1:n

        thisColEntropy=ones(Float64,n)
        
        for signalCol in 1:n
            p=0.0
            for rowC in 1:2^n
                if messageMatrix[messageCol,rowC]*signalMatrix[signalCol,rowC]==1
                    p+=1.0
                end
            end
            p/=2^(n-1)
            thisColEntropy[signalCol]=calculateEntropy(p)
        end

        minVal, minIndex = findmin(thisColEntropy)

        append!(entropyV[minIndex],minVal)
        
    end


    entropy=0.0
    
    for i in 1:n
        if length(entropyV[i])>0
            entropy+=minimum(entropyV[i])
        else
            entropy+=1
        end
    end
    
    1-entropy/n
    
end

function stability(parent::Vector,child::Vector)
    l=length(parent)
    total=0

    for i in 1:l
        if parent[i]==child[i]
            total+=1
        end
    end

    total/l

end


    
    

