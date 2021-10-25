module SensorsController

  using CSV
  using Plots

  # Plots defaults
  default(thickness_scaling = 3,
  		size=(1294.4, 800),
  		dpi=300,
  		widen = false,
  		gridstyle = :dash,
  		framestyle = :box,
  	  foreground_color_axis = colorant"#303030",
  	  foreground_color_border = colorant"#303030",
      foreground_color_guide = colorant"#303030",
  		foreground_color_text = colorant"#303030")

  function load_data(path_to_datafile::String)
    header = ["rssi", "time", "temperature", "humidity"]
    return CSV.File(path_to_datafile, header=header, delim="\t")
  end


  function plot_data(time::Array, temperature::Array, humidity::Array)
    p = plot(xlabel = "time (h)", bottom_margin = -10mm, left_margin = -10mm, right_margin = 10mm)
		plot!(time, temperature;
		  		label = "t [ºC]",
				  legend = :topleft,
				  linewidth = 2,
				  c = colorant"#F38181")
		plot!(twinx(), time, humidity;
				  label = "rh [%]",
				  legend = :topright,
				  linewidth = 2,
				  c = colorant"#95E1D3")
		return p
  end


  function main()
    path_to_datafile = "/Users/alfredolhomme/Hacking/lorasensors/pi/2021-10-24_serialdata.txt"
    data = load_data(path_to_datafile)
    plot_data(data.time, data.temperature, data.humidity)
    return("partial success")
  end
end
