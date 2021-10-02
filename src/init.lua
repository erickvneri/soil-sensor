-- MIT License
-- Copyright (c) 2021 Erick Israel Vazquez Neri
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
print([[

             |||| ||   ||  |||| ||||   |||   ||     || |||||
              ||  |||  ||   ||   ||  ||   || |||   ||| ||
         |||  ||  || | ||   |||||||  ||   || || | | || ||||   |||
              ||  ||  |||   ||   ||  ||   || ||  |  || ||
             |||| ||   ||  |||| ||||   |||   ||     || |||||

    |||||   |||   |||| ||||       ||||| ||||| ||   ||  |||||   |||   ||||||
   ||     ||   ||  ||   ||       ||     ||    |||  || ||     ||   || ||   ||
     ||   ||   ||  ||   ||         ||   ||||  || | ||   ||   ||   || |||||
       || ||   ||  ||   ||  ||       || ||    ||  |||     || ||   || ||  ||
   |||||    |||   |||| |||||||   |||||  ||||| ||   || |||||    |||   ||   ||

]])
local Wifi = require 'wifi_if'
local TemperatureSensor = require 'components.temperature'

local network = Wifi:new()
network:ap_init()

local temp_component = TemperatureSensor:new(14)
local err, temp, hum = temp_component:getdata()
print(string.format('Temperature: %s, Humidity: %s, Error: %s', temp, hum, tostring(err)))
