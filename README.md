# Automatic fractionation using a 3D printer

Some basic Julia code for fractionating using a Creality Ender 3 3D printer, but
should work with any 3D printer with the Marlin firmware. Feel free to copy or
remix this code!

![](3d-printer-fractionator.gif)

## Why?

A 3D printer is a cheap, flexible, and accurate 3 axis robot that can be
controlled via serial commands, i.e. perfect for automating a lot of lab tasks
on the cheap. You can even use it to print the adaptor heads to use it for the
different tasks!

In my case, I have a peristaltic pump that's constantly on and use the 3D
printer to move between wells