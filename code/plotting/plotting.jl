using Colors,Gadfly,Compose
import Cairo, Fontconfig
using Statistics,DataFrames,ProgressMeter

function plotProperty(propertyMatrix,xAxis,filename,color,yLabel)
    mu=vec(mean(propertyMatrix, dims=2))
    stdDev = vec(std(propertyMatrix, dims=2))
    
    min = mu .- stdDev
    max = mu .+ stdDev

    df = DataFrame(x=xAxis, y=mu, yMin=min,yMax=max)
       
    #alphaValue=0.3
    #lightColor = RGBA(color, alphaValue)
    
    plt=plot(
        layer(df,x=:x,y=:y, Geom.line,style(line_width=3pt,default_color=color)),
        layer(df,x=:x,ymin=:yMin,ymax=:yMax,Geom.ribbon,style(default_color=color)),
        Theme(background_color=colorant"white"),
        Guide.xlabel("bottleneck"),
        Guide.ylabel(yLabel),
        Coord.Cartesian(ymin=0.0,ymax=1.0)

    )

    draw(PNG(filename, 2.5inch, 2inch),plt)

end

function plotProperty(propertyMatrix0,propertyMatrix1,xAxis,filename,color,yLabel)
    plotProperty(propertyMatrix0,propertyMatrix1,xAxis,filename,color,yLabel,"bottleneck")
end

function plotProperty(propertyMatrix0,propertyMatrix1,xAxis,filename,color,yLabel,xLabel)


    function muMinMax(propertyMatrix)
    
        mu=vec(mean(propertyMatrix, dims=2))
        stdDev = vec(std(propertyMatrix, dims=2))
    
        (mu,mu .- stdDev,mu .+ stdDev)
    end

    (mu0,min0,max0)=muMinMax(propertyMatrix0)
    (mu1,min1,max1)=muMinMax(propertyMatrix1)
    
    df0 = DataFrame(x=xAxis, y=mu0, yMin=min0,yMax=max0)
    df1 = DataFrame(x=xAxis, y=mu1, yMin=min1,yMax=max1)
       
    #alphaValue=0.3
    #lightColor = RGBA(color, alphaValue)
    
    plt=plot(
        layer(df1,x=:x,y=:y, Geom.line,style(line_width=3pt,default_color=color,line_style=[:dash])),
        layer(df1,x=:x,y=:y, Geom.line,style(line_width=1pt,default_color=colorant"black",line_style=[:dash])),
        layer(df0,x=:x,y=:y, Geom.line,style(line_width=3pt,default_color=color)),
        layer(df0,x=:x,ymin=:yMin,ymax=:yMax,Geom.ribbon,style(default_color=color)),
        Theme(plot_padding=[0mm,2mm,0mm,0mm],background_color=colorant"white"),
        Guide.xlabel(xLabel),
        Guide.ylabel(yLabel,orientation=:vertical),
        Coord.Cartesian(ymin=0.0,ymax=1.0,xmax=maximum(df1.x))

    )

    draw(PNG(filename, 2.5inch, 2inch),plt)
    draw(PNG("big_"*filename, 5inch, 4inch),plt)

end
        
function plotPropertyLines(propertyMatrix,color,xLabel,yLabel)

    
    numTimePoints = size(propertyMatrix, 1)
    numTrials = size(propertyMatrix, 2)

    df = DataFrame()
    df.time = repeat(1:numTimePoints, outer=numTrials)
    df.trial = repeat(1:numTrials, inner=numTimePoints)
    df.performance = vec(propertyMatrix)

    avgPerformance = mean(propertyMatrix, dims=2)[2:end] |> vec
    avgDf = DataFrame(time=2:numTimePoints, avgPerformance=avgPerformance)

       
    alphaValue=0.3
    lightColor = RGBA(color, alphaValue)
    
    plt=plot(
        layer(avgDf, x=:time, y=:avgPerformance, Geom.line,style(line_width=3pt,default_color=color)),
        layer(df, x=:time, y=:performance, group=:trial, Geom.line,style(line_width=0.5pt,default_color=lightColor)),
        Theme(plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white"),
        Theme(background_color=colorant"white"),
        Guide.xlabel(xLabel),
        Guide.ylabel(yLabel),
        Coord.Cartesian(ymin=0.0,ymax=1.0)
     )


    plt
    
end
        
function plotPropertyLines(propertyMatrix,filename,color,yLabel,xRange)

    numTimePoints = size(propertyMatrix, 1)
    numTrials = size(propertyMatrix, 2)

    df = DataFrame()
    df.time = repeat(1:numTimePoints, outer=numTrials)
    df.trial = repeat(1:numTrials, inner=numTimePoints)
    df.performance = vec(propertyMatrix)

    avgPerformance = mean(propertyMatrix, dims=2)[2:end] |> vec
    avgDf = DataFrame(time=2:numTimePoints, avgPerformance=avgPerformance)



    alphaValue=0.3
    lightColor = RGBA(color, alphaValue)



    plt=plot(
        layer(avgDf, x=:time, y=:avgPerformance, Geom.line,style(line_width=1pt,default_color=colorant"black")),
        layer(avgDf, x=:time, y=:avgPerformance, Geom.line,style(line_width=3pt,default_color=color)),
        layer(df, x=:time, y=:performance, group=:trial, Geom.line,style(line_width=0.5pt,default_color=lightColor)),
        Theme(plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white"),
        Guide.xlabel("generations"),
        Guide.ylabel(yLabel,orientation=:vertical),
        Coord.Cartesian(ymin=0.0,ymax=1.0,xmin=0,xmax=xRange)
     )

    draw(PNG(filename, 2.5inch, 2inch),plt)
    #draw(PNG("big_"*filename, 5inch, 4inch),plt)
end


