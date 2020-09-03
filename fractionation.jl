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

groups = [wells[:, 1:3]]

moveto(sp, plate)
wait_for_key("start flow now, press any key")

waste_start = now()
moveto(sp, waste; wait = true)
waste_stop = now()
println("$(waste_stop - waste_start)")

start_pos = first(groups[1])
start_pos = Point(start_pos.x, start_pos.y, "Start pos")
moveto(sp, start_pos)
sleep(3)

# visit each well in a group in a snaking pattern
for well in snake(groups[1])
    println(well.name)
    moveto(sp, well; safe_height=plate.z)
    sleep(7.5)
end

moveto(sp, waste)
sleep(100)