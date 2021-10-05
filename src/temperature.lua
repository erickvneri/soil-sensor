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
-- DHT models-based enums
TemperatureSensor.DHT11 = 0x01
TemperatureSensor.DHT12 = 0x02
TemperatureSensor.DHTxx = 0x03

-- Status enums
TemperatureSensor.OK = dht.OK
TemperatureSensor.ERROR_CHECKSUM = dht.ERROR_CHECKSUM
TemperatureSensor.ERROR_CHECKSUM = dht.ERROR_TIMEOUT


--[[
-- TemperatureSensor constructor
--
-- Takes:
--
-- Returns:
--   {
--     temperature: number,
--     temp_decimal: number,
--     humidity: number,
--     hum_decimal: number,
--     status: []
--   }
--
--]]
function TemperatureSensor:new(gpio, model) -- class constructor
  local instance = {}
  -- model mapper
  instance.models = {
    [0x01] = dht.read11,
    [0x02] = dht.read12,
    [0x03] = dht.readxx,
  }
  -- status mapper
  instance.status = {
    [dht.OK] = 'OK',
    [dht.ERROR_CHECKSUM] = 'CHECKSUM ERROR',
    [dht.ERROR_TIMEOUT] = 'TIMEOUT ERROR'
  }

  -- DHT module abrstracion
  instance.gpio = gpio
  instance.read = instance.models[model or 0x01]

  setmetatable(instance, {__index = TemperatureSensor})
  return instance
end


function TemperatureSensor:getdata()
  local stat, temp, hum, temp_dec, hum_dec = assert(self.read(self.gpio))
  return {
    status = self.status[stat],
    temperature = temp,
    temp_dec = temp_dec,
    humidity = hum,
    hum_decimal = hum_dec
  }

end

return TemperatureSensor
