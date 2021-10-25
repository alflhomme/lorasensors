module SensorsController

  using LibSerialPort
  using CSV
  using Plots


  function retrieve_serial_data(portname::String, baudrate::Int64)
    mcu_message = ""
    LibSerialPort.open(portname, baudrate) do sp
      while true
        if bytesavailable(sp) > 0
          mcu_message *= String(read(sp))
          #println(mcu_message)
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


  function plot_data(temperature_data::Array, humidity_data::Array)

  end


  function main()
    portname = "/dev/cu.usbmodem1442301"
    baudrate = 115200
    path_to_datafile = pwd()*"datapacket.txt"
    header = ["signal", "period", "temperature", "humidity"]

    datapacket = retrieve_serial_data(portname, baudrate)

    write_data(datapacket, path_to_datafile)
    data = CSV.File(path_to_datafile, delim="\t", header=header)
    #plot_data(time, temperature, humidity)
    return("partial success")
  end
end
