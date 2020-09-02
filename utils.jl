struct Point{T}
    x::T
    y::T
    z::T
    name::String
end

function moveto(sp, point::Point; safe_height=40, wait=false)
    println("Moving to $(point.name)")
    write(sp, "G1 Z$(safe_height)\n")
    write(sp, "G1 X$(point.x) Y$(point.y) Z$(point.z)\n")
    if wait
        wait_for_key("press any key to continue")
    end
end

wait_for_key(prompt) = (print(stdout, prompt); read(stdin, 1); nothing)