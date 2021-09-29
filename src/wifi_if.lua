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
local Wifi = {}


function Wifi:new()
  local instance = {}

  -- Wifi module abstraction
  instance.wifi = wifi
  instance.ap = instance.wifi.ap
  instance.sta = instance.wifi.sta

  ---- Wifi interface config
  instance.MODE = instance.wifi.STATIONAP
  instance.NAME = 'soil-sensor-develop-0.0.1'
  instance.PWD = 'dummy-passphrase'
  instance.AUTHMODE = instance.wifi.AUTH_WPA_WPA2_PSK
  instance.HIDDEN = false
  instance.CHANNEL = 11
  instance.MAXCONN = 4
  instance.BEACON = 100
  instance.SAVE = true

  ---- Initial interface setup
  local _, err = pcall(
    instance.wifi.mode,
    instance.MODE,
    instance.SAVE)
  if err ~= nil then return err end

  -- Initialize Wifi module
  local _, err = pcall(instance.wifi.start)
  if err ~= nil then return err end

  setmetatable(instance, {__index = Wifi})
  return instance
end


function Wifi:ap_init()
  local config = {
    ssid=self.NAME,
    pwd=self.PWD,
    hidden=self.HIDDEN,
    auth=self.AUTHMODE,
    channel=self.CHANNEL,
    max=self.MAXCONN,
    beacon=self.BEACON,
    save=self.SAVE
  }
  local success, err = pcall(self.ap.config, config)

  config = nil
  collectgarbage()
  return true and success or err
end


function Wifi:sta_init(ssid, pwd)end


-- FIXME: settle scan service
function Wifi:scan_network(verbose)
  verbose = true and verbose or false

  return self.sta.scan({}, function (err, list)
    for k,net in pairs(list) do
      print(net.ssid)
    end
    return list
  end)
end


return Wifi
