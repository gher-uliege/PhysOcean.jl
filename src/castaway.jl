

"""
   data,header,metadata = loadcastaway(filename)

Load the CastAway CTD file `filename` and return the `data`, `header` and a dictionary with the `meatadata`.
"""
function loadcastaway(filename::String)
    open(filename) do f
        return loadcastaway(f)
    end
end

function loadcastaway(stream::IOStream)
    # load all lines of file
    lines = readlines(stream)

    # all metadata as key value dictionary
    #metadata = OrderedDict{String,Any}()
    metadata = Dict{String,Any}()

    headerfound = false
    j = 1
    data = Array{Float64,2}(undef,0,0)
    header = ""

    for i = 1:length(lines)
        line = chomp(lines[i])

        if startswith(line,"% ")
            keyvalue =
                if VERSION >= v"0.7.0-beta.0"
                    replace(line,r"^% " => "")
                else
                    replace(line,r"^% ","")
                end

            if occursin(",",keyvalue)
                key,value = split(keyvalue,",",limit = 2)

                if key == "Cast time (UTC)" || key == "Cast time (local)"
                    # parse time
                    metadata[key] = DateTime(value,"y-m-d H:M:S")
                else
                    metadata[key] = value
                end
            end
        else
            if !headerfound
                header = split(line,",")
                headerfound = true
                data = zeros(length(lines)-i,length(header))
            else
                records = split(line,",")

                for k = 1:length(records)
                    data[j,k] = parse(Float64,records[k])
                end
                j = j+1
            end
        end
    end

    return data,header,metadata
end
