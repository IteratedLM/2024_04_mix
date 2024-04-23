#makes two perfect languages for n=8
#splices them with different mixing parameters
#uses this as a tutor-0
#trains and measures stability relative to the original parents
#prints out the results


using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/m2m_agent_big.jl")
include("../utilities/utilities.jl")
    
bitNM=9
bitNS=12
hiddenN=10

reflectionE=15

bottleN=80
reflectionN=3*bottleN
p=parse(Float64, ARGS[1])

filenameRoot="./results/ailm"
filenameBase=filenameRoot*".csv"
filename=filenameRoot*"_"*string(p)*".csv"

loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=20

generationN=20
trialsN=10

header = "generation,trial,p,propertyType,property\n"
open(filenameBase, "w") do file
    write(file, header)
end

#bgCompose=0.0::Float64
#bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20


for backgroundC in 1:backgroundN

    #global(bgCompose,bgExpress,bgStable)
    global(bgStable)
    child=makeAgent(bitNM,bitNS,hiddenN)
    anotherChild=makeAgent(bitNM,bitNS,hiddenN)
    makeTable(child)
    makeTable(anotherChild)
    #bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
    #bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
    bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
    
end

file=open(filename, "a")                   


for trialC in 1:trialsN

    tableA=randomCompositionalTable(bitNM,bitNS)
    tableB=randomCompositionalTable(bitNM,bitNS)
    
    #global(bgCompose,bgExpress,bgStable,file,bitN)
    global(bgStable,file,bitN)
    
    child=makeAgent(bitNM,bitNS,hiddenN)
    
    parentTable=spliceTable(p,tableA,tableB)
    
    for generation in 1:generationN
        
        shuffledMeanings = randperm(2^bitNM)
        shuffledAutos = randperm(2^bitNM)
        

        exemplars1 = shuffledMeanings[1:bottleN]
        exemplars2 = copy(exemplars1)

        autos =   shuffledAutos[1:reflectionN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        if generation>1
            parentTable=child.m2sTable
        end
        
        #express=rebased(expressivity(child),bgExpress)
        #compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)
        stableA=rebased(stability(parentTable,tableA),bgStable)
        stableB=rebased(stability(parentTable,tableB),bgStable)
        
        #write(file,"$generation,$trialC,$p,e,$express\n")
        #write(file,"$generation,$trialC,$p,c,$compose\n")
        write(file,"$generation,$trialC,$p,s,$stable\n")
        write(file,"$generation,$trialC,$p,a,$stableA\n")
        write(file,"$generation,$trialC,$p,b,$stableB\n")
        flush(file)

        child=makeAgent(bitNM,bitNS,hiddenN)

        for epoch in 1:numEpochs
            
            shuffle!(exemplars1)
            shuffle!(exemplars2)

            for meaningC in 1:bottleN

                meaning1=exemplars1[meaningC]
                meaning2=exemplars2[meaningC]
                
                dataI=[(v2BV(bitNS,parentTable[meaning1]-1),v2BV(bitNM,meaning1-1))]
                Flux.train!(loss, child.s2m, dataI, optimizer)
                
                dataI=[(v2BV(bitNM,meaning2-1),v2BV(bitNS,parentTable[meaning2]-1))]
                Flux.train!(loss, child.m2s, dataI, optimizer)
                
                for _ in 1:reflectionE
                    auto=rand(autos)-1
                    dataI=[(v2BV(bitNM,auto),v2BV(bitNM,auto))]
                    Flux.train!(loss, child.m2m, dataI, optimizer)
                end
            end

        end
    end

end 
