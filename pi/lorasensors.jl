using Pkg
using ArgParse
using Dates

include("DataPacket.jl")
using .DataPacket

include("SensorsWebApp.jl")
using .SensorsWebApp


function parse_commandline()
    s = ArgParseSettings()

		s.prog = "Serial packet receiver"
		s.description = "Receives, prints and writes serial data."
		s.usage = "Usage: julia lorasensors.jl portname baudrate path"

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


function main()
	Pkg.activate(pwd())
	Pkg.instantiate()

	parsed_args = parse_commandline()
	path_to_datafile = parsed_args["path"]
	baudrate = parsed_args["baudrate"]
	portname = parsed_args["portname"]

	# Open a serial connection to the microcontroller
	mcu = open(portname, baudrate)

	# Retrieve a first data packet to populate the datafile
	datapacket = retrieve_data(mcu)
	write_data(datapacket, path_to_datafile)
	############################################################################
	# Reference data written in datafile
	data = load_data(path_to_datafile)

	# Instantiate a Stipple's ReactiveModel:
	sensors_model = init_model(data)

	# Route to localhost:
	route("/") do
	  ui(sensors_model) |> html
	end

	# Launch the webserver and open a browser window:
	up(open_browser = true)
	############################################################################


	while true
		# Get a new datapacket!
		datapacket = retrieve_data(mcu)
		# Feed the ReactiveModel
		update_data!(data, datapacket, sensors_model)
		# Save the data
		write_data(datapacket, path_to_datafile)
	end
end


main()
