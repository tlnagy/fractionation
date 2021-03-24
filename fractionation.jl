using Dates
using LibSerialPort
using SnakeIterator

include("utils.jl")

portname = LibSerialPort.get_port_list()[1]
baudrate = 115_200 # Creality Ender 3D uses a non standard baud rate

origin = Point(0, 0, 55, "origin")
plate = Point(125, 152, 29, "plate top left")
waste = Point(65, plate.y, 55, "waste container")

# let 3D printer initialize, it reboots when we setup the serial connection 
sp = LibSerialPort.open(portname, baudrate)
sleep(7) 

# move head up and calibrate the origin

write(sp, "G1 Z55\n")
write(sp, "G28\n")

# raise head and wait, this is useful for priming the lines
moveto(sp, origin; wait=true)

wells = create_wells(plate, well_spacing = 9.0, well_depth = 11.0)

groups = [
    wells[:, 1:6], 
    wells[:, 7:12]
    ]

for group in groups
    println("Fractionating first tube")

    moveto(sp, plate)
    wait_for_key("start flow now, press any key")

    waste_start = now()
    moveto(sp, waste; wait = true)
    waste_stop = now()
    println("$(waste_stop - waste_start)")

    start_pos = first(group)
    start_pos = Point(start_pos.x, start_pos.y, "Start pos")
    moveto(sp, start_pos)
    sleep(2)

    prev_pos = start_pos

    # visit each well in a group in a snaking pattern
    for well in snake(group)
        println(well.name)
        moveto(sp, well; safe_height=plate.z)
        sleep(13)
        prev_pos = well
    end

    moveto(sp, Point(prev_pos.x, prev_pos.y + 9, waste.z*1.0, "outside"))
    moveto(sp, waste; wait=true)
end