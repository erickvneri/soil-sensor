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

--[[
-- DHT-based Temperature & Humidity
-- driver.
--
-- By default, the temperature provided
-- is based in Celcius (°C) degree scale
-- and does not support floating point.
--]]
local TemperatureSensor = {}
TemperatureSensor.DHT11 = 0x01
TemperatureSensor.DHT2x = 0x02


function TemperatureSensor:new(gpio, component) -- class constructor
  local instance = {
    [0x01] = dht.read11,
    [0x02] = dht.read2x
  }

  -- DHT module abrstracion
  instance.gpio = gpio
  instance.read = instance[component]

  -- Shorthand enums
  instance.OK = dht.OK
  -- Error enum & msg
  instance.ERROR_CHECKSUM = dht.ERROR_CHECKSUM
  instance.CHECKSUM_MSG = 'Checksum failed'
  instance.ERROR_TIMEOUT = dht.ERROR_TIMEOUT
  instance.TIMEOUT_MSG = 'GPIO did timout'

  setmetatable(instance, {__index = TemperatureSensor})
  return instance
end


function TemperatureSensor:getdata()
  local stat, temp, hum = assert(self.read(self.gpio))
  local err = nil

  if stat == self.ERROR_CHECKSUM then
    err = self.CHECKSUM_MSG
  elseif stat == self.ERROR_TIMEOUT then
    err = self.TIMEOUT_MSG
  end
  return temp, hum, err
end

return TemperatureSensor
