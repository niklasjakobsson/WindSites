module WindSites

using Proj4, XLSX, CSV, DataFrames, Dates

export openmap, readusa, readdk, readuk, df_dk, df_usa, df_uk

function openmap(df::DataFrame, turbinenumber::Int)
    lon, lat = df[turbinenumber, :lon], df[turbinenumber, :lat]
    url = "http://maps.google.com/maps?t=k\"&\"q=loc:$lat+$lon"
    c = Cmd(`cmd /c start \"\" $url`, windows_verbatim=true)
    run(c)
    return df[turbinenumber, :]
end

function openmap(lon::Real, lat::Real)
    url = "http://maps.google.com/maps?t=k\"&\"q=loc:$lat+$lon"
    # Extra quotes to avoid errors with special chars ? and &:
    # https://superuser.com/questions/36728/can-i-launch-urls-from-command-line-in-windows
    # https://discourse.julialang.org/t/quoting-special-characters-of-a-url-in-cmd-objects-on-windows/44324
    c = Cmd(`cmd /c start \"\" $url`, windows_verbatim=true)
    run(c)
end

function openmapchrome(lon::Real, lat::Real)
    command = "C:/Program Files (x86)/Google/Chrome/Application/chrome"
    url = "http://maps.google.com/maps?t=k&q=loc:$lat+$lon"
    println("Opening $url...")
    run(`$command $url`)
end

function readusa()
    datadir = joinpath(@__DIR__, "..", "data")
    df = DataFrame!(CSV.File("$datadir/USA_uswtdb_v3_1_20200717.csv"))
    select!(df, [:t_cap, :xlong, :ylat, :p_year, :t_model, :t_hh, :t_rd])
    rename!(df, [:capac, :lon, :lat, :year, :model, :hubheight, :rotordiam])
    delete!(df, ismissing.(df[:, :capac]))
    delete!(df, ismissing.(df[:, :year]))
    df[!, :capac] = convert.(Int, df[!, :capac])
    return df
end

parse_not_missing(T, x) = ismissing(x) ? missing : parse(T, x)

function readuk()
    datadir = joinpath(@__DIR__, "..", "data")
    cols = [6,9,14,15,16,19,25,26,47]
    df = DataFrame!(CSV.File("$datadir/UK_REPD-June-2020-update.csv"))[!, cols]
    rename!(df, [:type, :capac_park, :capac, :nturbines, :height, :status, :lon, :lat, :year])
    delete!(df, .!startswith.(df[!, :type], "Wind"))
    delete!(df, df[:, :status] .!= "Operational")
    select!(df, Not(:status))
    df[!, :type] = replace.(df[!, :type], "Wind " => "")
    df[!, :nturbines] = parse.(Int, df[!, :nturbines])
    df[!, :height] = parse_not_missing.(Int, df[!, :height])
    df[!, :capac] = parse.(Float64, df[!, :capac])
    df[!, :capac_park] = parse.(Float64, replace.(df[!, :capac_park], "," => ""))
    df[!, :lon] = parse.(Int, replace.(df[!, :lon], "," => ""))
    df[!, :lat] = parse.(Int, replace.(df[!, :lat], "," => ""))
    df[!, :year] = Date.(df[!, :year], dateformat"d/m/y")

    x = df[!, :lon] # BNG: British National Grid = EPSG:27700
    y = df[!, :lat] # https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid#General
    source = Projection("+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs")
    dest = Projection("+proj=longlat +datum=WGS84 +no_defs")
    len = size(df,1)
    lon, lat = zeros(len), zeros(len)
    for i = 1:len
        lon[i], lat[i], _ = Proj4.transform(source, dest, [x[i] y[i] 0])
    end
    df[!, :lon] = lon
    df[!, :lat] = lat
    return df
end

function readdk()
    datadir = joinpath(@__DIR__, "..", "data")
    cols = [3,13,14,2,7,5,4,10]
    df = DataFrame!(XLSX.readtable("$datadir/DK_anlaegprodtilnettet_0.xlsx", "IkkeAfmeldte-Existing turbines",
        "A:P", first_row=19, header=false, infer_eltypes=false)...)[!, cols]
    rename!(df, [:capac, :lon, :lat, :year, :model, :hubheight, :rotordiam, :onshore])
    df[!, :capac] = convert.(Int, round.(df[!, :capac]))
    df[!, :model] = string.(df[:, :model])
    df[!, :hubheight] = convert.(Float64, df[!, :hubheight])
    df[!, :rotordiam] = convert.(Float64, df[!, :rotordiam])
    df[!, :year] = Dates.year.(df[!, :year])
    df[!, :onshore] = uppercase.(df[!, :onshore]) .== "LAND"    # no missings here, no need to check
    delete!(df, ismissing.(df[:, :lon]))

    x = df[!, :lon] # European Terrestrial Reference System 1989: ETRS89/UTM zone 32N = EPSG:25832
    y = df[!, :lat] # https://en.wikipedia.org/wiki/European_Terrestrial_Reference_System_1989
    source = Projection("+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs")
    dest = Projection("+proj=longlat +datum=WGS84 +no_defs")
    len = size(df,1)
    lon, lat = zeros(len), zeros(len)
    for i = 1:len
        lon[i], lat[i], _ = Proj4.transform(source, dest, [x[i] y[i] 0])
    end
    df[!, :lon] = lon
    df[!, :lat] = lat
    return df
end



# df_dk = readdk()
# df_usa = readusa()
# df_uk = readuk()

# CSV.write("turbines_DK.csv", df_dk)
# CSV.write("turbines_USA.csv", df_usa)


# println("\nProjecting coordinates (Mollweide)...")
# res = 0.01
# res2 = res/2
# lons = (-180+res2:res:180-res2)[lonrange]         # longitude values (pixel center)
# lats = (90-res2:-res:-90+res2)[latrange]          # latitude values (pixel center)
# source = LonLat()
# dest = Projection("+proj=moll +lon_0=$(mean(lons))")
# xs, ys = xygrid(lons, lats)
# Proj4.transform!(source, dest, vec(xs), vec(ys))

end # module
