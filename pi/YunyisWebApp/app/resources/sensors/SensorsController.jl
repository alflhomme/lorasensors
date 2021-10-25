module SensorsController

  using CSV
  using Plots

  function load_data(path_to_datafile::String)
  end


  function plot_data(temperature_data::Array, humidity_data::Array)

  end


  function main()

    header = ["signal", "period", "temperature", "humidity"]

    datapacket = retrieve_serial_data(portname, baudrate)

    write_data(datapacket, path_to_datafile)
    data = CSV.File(path_to_datafile, delim="\t", header=header)
    #plot_data(time, temperature, humidity)
    return("partial success")
  end
end
