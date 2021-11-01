# lorasensors
Raspi-AdaFeather (32u4 RFM95)-based sensor system for home that uses the
amazing [Stipple julia package](https://github.com/GenieFramework/Stipple.jl)
to display data on a webserver!

The whole setup requires a monitoring computer (e.g. **Raspberry Pi**) connected
through serial to a **Adafruit Feather 32u4 RFM95** that is used as a radio receiver.

On the other hand, another 32u4 RFM95 hooked with a **temperature & humidity
Si7021 sensor** and a LiPo battery is used as a sensor-radio transmitter module.

### Dependencies
###### Microcontrollers (Arduino IDE)

Go through [this link](https://learn.adafruit.com/adafruit-feather-32u4-radio-with-lora-radio-module/setup) for setting up the feathers.

To get the sensor's I2C API, install the [Adafruit_Si7021 library](https://github.com/adafruit/Adafruit_Si7021).

###### Computer (Julia)

The [Julia codes in this repository](https://github.com/alflhomme/lorasensors/tree/main/pi) use a bunch of packages that should be installed beforehand using Julia's
package manager. To do so run Julia's REPL and type:

`]add ArgParse LibSerialPort CSV DataFrames Stipple StippleUI StipplePlotly`


### How to use

Once the arduino codes have been successfully uploaded to the LoRa feathers
(32u4_rx.ino and 32u4_tx.ino to the receiver and transmitter respectively), the
transmitter is powered up and the receiver is connected to a computer, simply
run the Julia code in the computer by doing:

```bash
julia lorasensors.jl "portname"
```

which will start listening to the `portname` serial port to gather data and
setup a webserver to display this data in a plot. The data will be also written
on a generated text file (named something like 2021-11-01_serialdata.txt)
located at the current directory. If another path is preferred use the optional
argument `--path`.

e.g.
```bash
julia lorasensors.jl "/dev/cu.usbmodem1442401" -p "/Users/alfre/data/sensor_data.txt"
```
