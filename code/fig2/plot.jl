
using CSV, DataFrames,Gadfly, Statistics, Random
import Cairo, Fontconfig

#filename="ailm_50"
#filename="ailm_100"
#filename="ailm_100_100"
#filename="ailm_all"
filename="ailm_all_20_30"

function addPJitter(df::DataFrame, jitterMagnitudeX::Float64, jitterMagnitudeY::Float64)
    Random.seed!(123) 
    jitterValuesX = jitterMagnitudeX .* (rand(size(df, 1)) .- 0.5)
    jitterValuesY = jitterMagnitudeY .* (rand(size(df, 1)) .- 0.5)
    df[!, :pJitter] = df[!, :p] .+ jitterValuesX
    df[!, :propertyJitter] = df[!, :property] .+ jitterValuesY
    return df
end


df = CSV.File(filename*".csv") |> DataFrame

gen20Df = filter(row -> row.generation == 20 && (row.propertyType == "a" || row.propertyType == "b"), df)

df = filter(row -> !(row.propertyType == "b" && row.p == 0.5), gen20Df)
df.p[df.propertyType .== "b"] .= 1 .- df.p[df.propertyType .== "b"]


gen20Df=df
        
avgProperty = combine(groupby(gen20Df, :p), :property => mean => :propertyAvg)

gen20Df=addPJitter(gen20Df, 0.05,0.01)

# Merge average back into original dataframe for plotting
mergedDf = leftjoin(gen20Df, avgProperty, on = :p)



# Plotting with Gadfly
plt=plot(
layer(mergedDf, x=:p, y=:propertyAvg, Geom.line, Theme(default_color=colorant"red",line_width=1mm)),
    layer(mergedDf, x=:pJitter, y=:propertyJitter, Geom.point, Theme(default_color=colorant"black",point_size=0.3mm,highlight_width=0pt)),
    Coord.Cartesian(xmin=-0.05, xmax=1.05, ymin=-0.05, ymax=1.05),
         Guide.xlabel("p"), Guide.ylabel("a"),
                 Theme(plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white")
         )

draw(PDF(filename*".pdf", 3.25inch, 2.25inch),plt)
