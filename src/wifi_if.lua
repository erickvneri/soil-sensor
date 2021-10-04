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
  instance.wifi = assert(wifi)
  instance.ap = instance.wifi.ap
  instance.sta = instance.wifi.sta

  -- Wifi interface config
  instance._MODE = instance.wifi.STATIONAP
  instance._NAME = 'soil-sensor-develop-0.0.1'
  instance._PWD = 'dummy-passphrase'
  instance._AUTHMODE = instance.wifi.WPA_WPA2_PSK
  instance._HIDDEN = false
  instance._CHANNEL = 6
  instance._MAXCONN = 4
  instance._BEACON = 100
  instance._SAVE = true
  instance._STA_AUTO_CONNECT = false

  -- Wifi mode setup
  assert(
    instance.wifi.setmode(instance._MODE),
    'cannot init STATIONAP mode')

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
    ssid = self._NAME,
    pwd = self._PWD,
    hidden = self._HIDDEN,
    auth = self._AUTHMODE,
    channel = self._CHANNEL,
    max = self._MAXCONN,
    beacon = self._BEACON,
    save = self._SAVE
  }

  ---- Enable access point
  assert(
    self.ap.config(config),
    'cannot init wifi.ap')

  config = nil
  collectgarbage()
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
-- As Wifi.sta.clearconfig() isn't
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
