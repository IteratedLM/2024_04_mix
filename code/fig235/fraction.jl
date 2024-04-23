using Gadfly,CSV,DataFrames
import Cairo, Fontconfig

# Assuming 'df' is your DataFrame loaded from the CSV file
df = CSV.read("ailm_all_10_10.csv", DataFrame)

# Filter for generation 20 and property types 'a' and 'b'
df_filtered = filter(row -> row.generation == 20 && (row.propertyType == "a" || row.propertyType == "b"), df)

threshold=0.9

# INITIALIZE A DATAFRAME TO STORE THE FRACTIONS
fractions = DataFrame(p = Float64[], fraction_a = Float64[], fraction_b = Float64[])

# Calculate fractions
for p_val in unique(df_filtered.p)
    # For 'a'
    df_a = filter(row -> row.propertyType == "a" && row.property > threshold, df_filtered)
    frac_a = nrow(filter(row -> row.p == p_val, df_a)) / nrow(filter(row -> row.p == p_val && row.propertyType == "a", df_filtered))
    
    # For 'b'
    df_b = filter(row -> row.propertyType == "b" && row.property > threshold, df_filtered)
    frac_b = nrow(filter(row -> row.p == p_val, df_b)) / nrow(filter(row -> row.p == p_val && row.propertyType == "b", df_filtered))
    
    push!(fractions, (p = p_val, fraction_a = frac_a, fraction_b = frac_b))
end



# Plotting with Gadfly
plt=plot(
    layer(fractions, x=:p, y=:fraction_a, Geom.line, Theme(default_color=colorant"red",line_width=1mm)),
    layer(fractions, x=:p, y=:fraction_b, Geom.line, Theme(default_color=colorant"red",line_width=1mm)),
    Coord.Cartesian(xmin=0.5, xmax=1.0, ymin=-0.05, ymax=1.05),
         Guide.xlabel("p"), Guide.ylabel("a / b fraction"),
                 Theme(plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white")
         )

draw(PDF("fraction.pdf", 3.25inch, 2.25inch),plt)

