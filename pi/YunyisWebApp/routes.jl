using Genie.Router
using SensorsController

route("/") do
  serve_static_file("welcome.html")
end

route("/sensors", SensorsController.main)
