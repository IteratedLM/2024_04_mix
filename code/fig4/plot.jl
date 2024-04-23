
using CSV, DataFrames,Gadfly, Statistics, Random, Compose
import Cairo, Fontconfig

filename1="ailm_all_10_10"
filename2="ailm_all_10_12"
filename3="ailm_all_10_11_12"
filename4="ailm_all_10_15_20"

df1 = CSV.File(filename1*".csv") |> DataFrame
df2 = CSV.File(filename2*".csv") |> DataFrame
df3 = CSV.File(filename3*".csv") |> DataFrame
df4 = CSV.File(filename4*".csv") |> DataFrame

df=[df1,df2,df3,df4]

for i in 1:4

    gen20Df = filter(row -> row.generation == 20 && (row.propertyType == "a" || row.propertyType == "b"), df[i])

    df[i] = filter(row -> !(row.propertyType == "b" && row.p == 0.5), gen20Df)
    df[i].p[df[i].propertyType .== "b"] .= 1 .- df[i].p[df[i].propertyType .== "b"]

end

function getAv(df)

    gen20Df=df
        
    avgProperty = combine(groupby(gen20Df, :p), :property => mean => :propertyAvg)

    leftjoin(gen20Df, avgProperty, on = :p)

end

mergedDF= [getAv(df[i]) for i in 1:4]

filename="ailm_all"

mergedDF[1][!,:size] .= "10X10X10"
mergedDF[2][!,:size] .= "10X12X10"
mergedDF[3][!,:size] .= "09X11X12"
mergedDF[4][!,:size] .= "10X15X20"

mergedDf = vcat(mergedDF[1], mergedDF[2], mergedDF[3], mergedDF[4])

plt = plot(mergedDf, x=:p, y=:propertyAvg, color=:size, Geom.line,
           Scale.color_discrete_manual("red", "darkred", "lightcoral","crimson"),
           Coord.Cartesian(xmin=-0.05, xmax=1.05, ymin=-0.05, ymax=1.05),
           Guide.xlabel("p"), Guide.ylabel("a"), Guide.colorkey(pos=[0.10w,-0.10h]),         
           Theme(plot_padding=[0mm,0mm,0mm,0mm], background_color=colorant"white"))

draw(PDF(filename*".pdf", 3.25inch, 2.25inch), plt)
