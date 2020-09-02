using Dates
using LibSerialPort

include("utils.jl")

portname = LibSerialPort.get_port_list()[1]
baudrate = 115_200

origin = Point(0, 0, 55, "origin")
plate = Point(125, 152, 29, "plate top left")
waste = Point(65, plate.y, 55, "waste container")

well_spacing = 9.0 # in microns

# let 3D printer initialize, it reboots when we setup the serial connection 
sp = LibSerialPort.open(portname, baudrate)
sleep(7) 

write(sp, "G1 Z55\n")
write(sp, "G28\n")

moveto(sp, origin; wait=true)

for row in 1:3:8

    y_loc = plate.y - (row - 1) * well_spacing

    write(sp, "G1 X$(plate.x) Y$(y_loc)\n")
    write(sp, "G1 Z$(plate.z)\n")

    wait_for_key("start flow now, press any key")

    waste_start = now()
    moveto(sp, waste; wait = true)
    waste_stop = now()
    println("$(waste_stop - waste_start)")
    
    write(sp, "G1 X$(plate.x) Y$(plate.y)\n")
    sleep(3)

    for subrow in 0:2

        cols = 1:12
        if subrow == 1
            println("Flipping... row #$(row+subrow)")
            cols = 12:-1:1
        end

        y_loc = plate.y - (row - 1 + subrow) * well_spacing

        write(sp, "G1 Z$(plate.z)\n")
        write(sp, "G1 Y$(y_loc)\n")

        for column in cols

            loc = (
                x = plate.x + (column - 1) * well_spacing, 
                y = y_loc,
                z = 18
            )
            println(loc)
            write(sp, "G1 Z$(plate.z)\n")
            write(sp, "G1 X$(loc.x)\n")
            write(sp, "G1 Z$(loc.z)\n")
            readline(sp)
            write(sp, "M400\n")
            readline(sp)
            sleep(7.5)
        end
    end

    moveto(sp, waste)
    sleep(100)
end