struct Point{T}
    x::T
    y::T
    z::Union{T, Nothing}
    name::String
end

Point(x::T, y::T, name::String) where {T} = Point(x, y, nothing, name)

function moveto(sp, point::Point; safe_height=55, wait=false)
    println("Moving to $(point.name)")
    write(sp, "G1 Z$(safe_height)\n")
    write(sp, "G1 X$(point.x) Y$(point.y)\n")
    (!isnothing(z)) && write(sp, "G1 Z$(point.z)\n")

    wait && wait_for_key("press any key to continue")
end

function create_wells(topleft; well_spacing = 9.0, well_depth = 11.0)
    well_names = map(x->"$(x[1])$(x[2])", Iterators.product('A':'H', 1:12))

    wells = Array{Point, 2}(undef, size(well_names))

    for I in CartesianIndices(well_names)
        wells[I] = Point(
            plate.x + well_spacing * (I[1] - 1),
            plate.y + well_spacing * (I[2] - 1),
            plate.z - well_depth,
            well_names[I]
        )
    end

    return wells
end

wait_for_key(prompt) = (print(stdout, prompt); read(stdin, 1); nothing)