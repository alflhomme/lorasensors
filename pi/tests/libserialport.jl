using LibSerialPort

# Modify these as needed
portname = "/dev/cu.usbmodem146201"
baudrate = 115200

# Snippet from examples/mwe.jl
LibSerialPort.open(portname, baudrate) do sp
	sleep(2)

	if bytesavailable(sp) > 0
    	println(String(read(sp)))
	end

    write(sp, "hello\n")
    sleep(0.1)
    println(readline(sp))
end
