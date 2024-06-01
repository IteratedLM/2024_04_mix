# figures 2 and 4
# takes the filename without the ".csv" as a command line argument 



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

matrices=[makeMatrix(df,"e"),makeMatrix(df,"c"),makeMatrix(df,"s"),makeMatrix(df,"a"),makeMatrix(df,"b")]
names=["_express","_compose","_stable","_a","_b"]
colors=[colorant"blue",colorant"orange",colorant"purple",colorant"red",colorant"red"]
scale=0.5

for i in 1:5
    plt=plotPropertyLines(matrices[i],colors[i],"","")
    draw(PDF(filename*names[i]*".png",scale*2.5inch, scale*2inch),pdf)
end
