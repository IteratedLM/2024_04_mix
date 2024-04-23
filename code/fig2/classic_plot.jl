
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")

filename=ARGS[1]

df = CSV.File(filename*".csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filtered_df = filter(row -> row.propertyType == type, df)

    max_generation = maximum(filtered_df.generation)
    max_trial = maximum(filtered_df.trial)


    matrix = fill(NaN, max_generation, max_trial)  # or use zeros() if you prefer

    
    for row in eachrow(filtered_df)
        matrix[row.generation, row.trial] = row.property
    end

    matrix

end

expressMatrix=makeMatrix(df,"e")
composeMatrix=makeMatrix(df,"c")
stableMatrix=makeMatrix(df,"s")
aMatrix=makeMatrix(df,"a")
bMatrix=makeMatrix(df,"b")

plotPropertyLinesScaled(expressMatrix,filename*"_express.png",colorant"blue","",0.5)
plotPropertyLinesScaled(composeMatrix,filename*"_compose.png",colorant"orange","",0.5)
plotPropertyLinesScaled(stableMatrix,filename*"_stable.png" ,colorant"purple","",0.5)
plotPropertyLinesScaled(aMatrix,filename*"_a.png" ,colorant"red","",0.5)
plotPropertyLinesScaled(bMatrix,filename*"_b.png" ,colorant"red","",0.5)
