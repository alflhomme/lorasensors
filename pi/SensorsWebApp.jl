module SensorsWebApp

using Stipple
using StippleUI
using StipplePlotly

using CSV
using DataFrames

export load_data, update_data!
export SensModel, init_model, set_model
export ui
export route, html, up


function load_data(path_to_datafile::Union{String, IOBuffer})
   header = ["rssi", "time", "temperature", "humidity"]
   #data = CSV.read(path_to_datafile, header=header, delim="\t", DataFrame)
   data = CSV.File(path_to_datafile, header=header, delim="\t") |> DataFrame
 end


function sensor_plot_data(x::Array, y::Array,
                          label::String,
                          color::String,
                          hovertext::String)
  PlotData(x = x,
           y = y,
           plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
           aspectratio = 1.6180,
           color = color,
           hoverinfo = "y+text",
           hoverlabel = Dict("namelength" => 0),
           hovertext = hovertext,
           line = PlotlyLine(color = color),
           name = label
  )
end


function sensor_plot_layout()
  PlotLayout(
    title = PlotLayoutTitle(text="Adafruit's Si7021 sensor data",
                            font=Font(size=18)
            ),
    xaxis = [PlotLayoutAxis(xy="x",
      showline = true,
      linecolor = "#333333",
      title = "time (h)",
      mirror = true,
      showgrid = false
    )],
    yaxis = [PlotLayoutAxis(xy="y",
      showline = true,
      zeroline = false,
      linecolor = "#333333",
      mirror = true,
      showgrid = false
    )],
    legend = PlotLayoutLegend(font=Font(size=16)
             ),
    showlegend = true,
    font = Font(color="#333333"),
    hovermode = "closest",
    hoverdistance = 10
  )
end


function sensor_plot_config()
  PlotConfig(
    responsive = true,
    displaymodebar = false,
    displaylogo = false
  )
end


# Definition of the reactive model
Base.@kwdef mutable struct SensModel <: ReactiveModel
  data::R{Vector{PlotData}} = []
  layout::R{PlotLayout} = sensor_plot_layout()
  config::R{PlotConfig} = sensor_plot_config()
end


function init_model(data::DataFrame)
  sensors_model = set_model(data, SensModel()) |> Stipple.init
end


function set_model(data::DataFrame, model::M) where {M<:Stipple.ReactiveModel}
  model.data = [sensor_plot_data(data.time, data.temperature,
                                   "temperature [ºC]",
                                   "#F38181",
                                   "ºC"),
                  sensor_plot_data(data.time, data.humidity,
                                   "relative humidity [%]",
                                   "95E1D3",
                                   "%")
    ]
  return model
end


function update_data!(data::DataFrame,
                      datapacket::String,
                      model::M) where {M<:Stipple.ReactiveModel}
  #newdata = Tuple(parse.(Float64, split(datapacket[1:end-1], "\t")))
  newdata = load_data(IOBuffer(datapacket))
  append!(data, newdata)

  #model = set_model(data, model)
  return nothing
end


function ui(model::SensModel)
  [
  style("""
    body {
      font-family: "Roboto";
      color: #333333;
    }
  """)

  page(
    vm(model),
    class="container",
    title="YunyisRaspi • Si7021",
    head_content=Genie.Assets.favicon_support(),
    [
      heading("YunyisRaspi's monitoring station")

      plot(:data; layout = :layout, config = :config)

      footer("")

    ])
  ]
end


# Handler
#on(sensors_model.data_loading) do
#end

end
