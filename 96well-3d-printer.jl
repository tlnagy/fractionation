using Dates
using LibSerialPort

portname = LibSerialPort.get_port_list()[1]
baudrate = 115_200

wait_for_key(prompt) = (print(stdout, prompt); read(stdin, 1); nothing)

function origin(sp)
    println("Returning machine to origin...")
    write(sp, "G1 Z40\n")
    write(sp, "G1 X0 Y0\n")
    wait_for_key("press any key to continue")
end

home = (x = 92, y = 175, z = 29)
well_spacing = 9.0 # in microns

sp = LibSerialPort.open(portname, baudrate)

sleep(5) # let 3D printer initialize

try
    write(sp, "G1 Z$(home.z)\n")
    write(sp, "G28\n")

    origin(sp)

    for row in 4:3:8

        y_loc = home.y - (row - 1) * well_spacing

        write(sp, "G1 X$(home.x) Y$(y_loc)\n")

        wait_for_key("press any key to continue")

        for subrow in 0:2

            cols = 1:12
            if subrow == 1
                println("Flipping... row #$(row+subrow)")
                cols = 12:-1:1
            end

            y_loc = home.y - (row - 1 + subrow) * well_spacing

            write(sp, "G1 Z$(home.z)\n")
            write(sp, "G1 Y$(y_loc)\n")

            for column in cols

                loc = (
                    x = home.x + (column - 1) * well_spacing, 
                    y = y_loc,
                    z = 18
                )
                println(loc)
                write(sp, "G1 Z$(home.z)\n")
                write(sp, "G1 X$(loc.x)\n")
                write(sp, "G1 Z$(loc.z)\n")
                readline(sp)
                write(sp, "M400\n")
                readline(sp)
                sleep(15)
            end
        end

        origin(sp)
    end
finally
    println("Cleaning up")
    sleep(1)
    write(sp, "G1 Z$(home.z)\n")
    write(sp, "G1 X0 Y0\n")
    sleep(20)
end