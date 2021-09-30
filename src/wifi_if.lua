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


function Wifi:new() -- Wifi class constructor
  local instance = {}

  -- Wifi module abstraction
  instance.wifi = wifi
  instance.ap = instance.wifi.ap
  instance.sta = instance.wifi.sta

  -- Wifi interface config
  instance.MODE = instance.wifi.STATIONAP
  instance.NAME = 'soil-sensor-develop-0.0.1'
  instance.PWD = 'dummy-passphrase'
  instance.AUTHMODE = instance.wifi.AUTH_WPA_WPA2_PSK
  instance.HIDDEN = false
  instance.CHANNEL = 11
  instance.MAXCONN = 4
  instance.BEACON = 100
  instance.SAVE = true
  instance.STA_AUTO_CONNECT = false

  -- Wifi mode setup
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


--[[
-- Wifi Access Point Interface
--
-- Returns:
--   err or nil
--]]
function Wifi:ap_init()
  -- AP config params
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

  -- Enable access point
  local _, err = pcall(self.ap.config, config, self.SAVE)

  config = nil
  collectgarbage()
  return nil or err
end


--[[
-- Configure the Wifi Station
-- Inteface and connect it to
-- the Access Point reference
-- received.
--
-- Takes:
--   @ssid: string
--   @pwd: string
--   @bssid: string
--
--  Returns:
--    nil or err
--]]
function Wifi:sta_init(ssid, pwd)
  -- Station config params
  local sta_config = {
    ssid = ssid,
    pwd = pwd,
    auto = self.STA_AUTO_CONNECT
  }

  -- Config Wifi Station
  local _, err = pcall(self.sta.config, sta_config, self.SAVE)
  if err ~= nil then return err end

  -- Wifi station hostname
  local _, err pcall(self.sta.sethostname, self.NAME)
  if err ~= nil then return err end

  -- Connect to access point
  local _, err = pcall(self.sta.connect)

  sta_config = nil
  collectgarbage()
  return nil or err
end


--[[
-- Wifi Access Point Scanner.
--
-- Takes:
--   @scan_callback: function
--   (callback will be called
--   as soon as scanning has
--   table of Wifi APs ready.)
--
-- Returns:
--   err or nil
--]]
function Wifi:scan_network(scan_callback)
  local _, err = pcall(self.sta.scan, {}, scan_callback)
  return nil or err
end


--[[
-- Wifi Station clearconfig
--
-- As wifi.sta.clearconfig() isn't
-- natively supported by dev-esp32
-- firmware, this resouce intends to
-- monkey patch adisconnection and reset
-- configs redefining it with empty
-- strings.
--]]
function Wifi:force_disconnect()
  local nil_config = {
    ssid = '',
    pwd = '',
    auto = self.STA_AUTO_CONNECT
  }

  -- Redefine station config
  local _, err = pcall(self.sta.config, nil_config, self.SAVE)
  return err
end

return Wifi
