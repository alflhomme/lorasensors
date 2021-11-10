module DataPacket

using LibSerialPort

export open, write_data, retrieve_data
export SP_MODE_READ


function write_data(data::String, path_to_datafile::String)
	open(path_to_datafile, "a") do f
		write(f, data)
	end
end


function retrieve_data(sp::SerialPort)
	datapacket = ""
	while true
		datapacket *= String(nonblocking_read(sp))
		if length(datapacket) >= 26
			println("Got a data packet:")
			print(datapacket)
			break
		end
		sleep(0.001)
	end
	return datapacket
end


end
