using ArgParse
using LibSerialPort
using Dates


function parse_commandline()
    s = ArgParseSettings()

		s.prog = "Serial packet receiver"
		s.description = "Receives, prints and writes serial data."
		s.usage = "Usage: julia serialpacketrec.jl portname baudrate path"

    @add_arg_table! s begin
				"--path", "-p"
					help = "Path to save the data."
					arg_type = String
					required = false
					default = string(pwd(), "/", Dates.today(), "_serialdata.txt")

				"--baudrate", "-b"
					help = "Baudrate. Default = 115200."
					arg_type = Int64
					required = false
					default = 115200

        "portname"
        	help = "Portname used for serial communication."
        	arg_type = String
        	required = true
    end

    return parse_args(ARGS, s)
end


function retrieve_serial_data(portname::String, baudrate::Int64)
mcu_message = ""
LibSerialPort.open(portname, baudrate) do sp
  while true
    if bytesavailable(sp) > 0
      mcu_message *= String(read(sp))
      return(mcu_message)
    end
  sleep(0.0001)
  end
end
end


function write_data(data::String, path_to_datafile::String)
  open(path_to_datafile, "a") do f
    write(f, data)
  end
end


function main()
	parsed_args = parse_commandline()
	path_to_datafile = parsed_args["path"]
	baudrate = parsed_args["baudrate"]
	portname = parsed_args["portname"]

	header = ["rssi", "period", "temperature", "humidity"]
	while true
		datapacket = retrieve_serial_data(portname, baudrate)
		println("Got a data packet:")
		println(datapacket)
		if length(datapacket) == 24
			write_data(datapacket, path_to_datafile)
		end
	end
end


main()
