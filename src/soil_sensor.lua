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
local SoilSensor = {}
SoilSensor.MAX_MEASURE = 1024
SoilSensor.MIN_MEASURE = 560


--[[
-- SoilSensor class constructor
-- Takes:
--   adc_channel: default=0
--]]
function SoilSensor:new(adc_channel) -- SoilSensor class constructor
  local instance = {}

  instance.sensor = adc.force_init_mode(adc.INIT_ADC)
  instance.adc_channel = adc_channel or 0

  setmetatable(instance, {__index = SoilSensor})
  return instance
end

--[[
-- SoilSensor.get_raw interfaces the
-- built-in adc.read method and returns
-- the raw ADC reading.
--]]
function SoilSensor:get_raw()
  local _, raw_adc = assert(pcall(adc.read, self.adc_channel))

  return raw_adc
end

--[[
-- SoilSensor.get_level interfaces the
-- build-in adc.read method and performs
-- the calculation to return the
-- level/percentage of moisture detected.
--]]
function SoilSensor:get_level()
  local _, raw = assert(pcall(self.get_raw, self))

  local level = ((raw - self.MAX_MEASURE) * 100) / (self.MAX_MEASURE - self.MIN_MEASURE)
  return math.floor(math.abs(level))
end

return SoilSensor
