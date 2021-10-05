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


-- Shortwand Wifi Events
Wifi.evt = {}
Wifi.evt.STA_CONNECTED = wifi.eventmon.STA_CONNECTED
Wifi.evt.STA_DISCONNECTED = wifi.eventmon.STA_DISCONNECTED
Wifi.evt.STA_AUTHMODE_CHANGE = wifi.eventmon.STA_AUTHMODE_CHANGE
Wifi.evt.STA_GOT_IP = wifi.eventmon.STA_GOT_IP
Wifi.evt.STA_DHCP_TIMEOUT = wifi.eventmon.STA_DHCP_TIMEOUT
Wifi.evt.AP_STACONNECTED = wifi.eventmon.AP_STACONNECTED
Wifi.evt.AP_STADISCONNECTED = wifi.eventmon.AP_STADISCONNECTED
Wifi.evt.AP_PROBEREQRECVED = wifi.eventmon.AP_PROBEREQRECVED

--[[
-- Wifi class constructor
--
-- The wifi initializer abstracts the
-- wifi intefaces (ap and sta) directly
-- from the instance.
--]]
function Wifi:new() -- Wifi class constructor
  local instance = {}

  -- Wifi module abstraction
  instance.wifi = assert(wifi)
  instance.ap = instance.wifi.ap
  instance.sta = instance.wifi.sta

  -- Wifi interface config
  instance._MODE = instance.wifi.STATIONAP
  instance._NAME = 'soil-sensor-develop-v001'
  instance._PWD = 'dummy-passphrase'
  instance._AUTHMODE = instance.wifi.WPA_WPA2_PSK
  instance._HIDDEN = false
  instance._CHANNEL = 6
  instance._MAXCONN = 4
  instance._BEACON = 100
  instance._SAVE_CONFIG = true
  instance._STA_AUTO_CONNECT = false

  -- Wifi mode setup
  assert(instance.wifi.setmode(instance._MODE))

  setmetatable(instance, {__index = Wifi})
  return instance
end

--[[
-- Configure the Wifi Access Point
-- which will enable the 192.168.4.1
-- address for Station configuration.
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
    save = self._SAVE_CONFIG
  }

  ---- Enable access point
  assert(self.ap.config(config))

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
--   @calback: function
--
--  Returns:
--    nil or err
--]]
function Wifi:sta_init(ssid, pwd, callback)
  -- Station config params
  local sta_config = {
    ssid = ssid,
    pwd = pwd,
    auto = self._STA_AUTO_CONNECT,
    save = self._SAVE_CONFIG
  }

  -- Config Wifi Station
  assert(self.sta.config(sta_config))

  -- Set Wifi station hostname
  assert(self.sta.sethostname(self._NAME))

  -- Connect to access point
  pcall(self.sta.connect, callback)

  sta_config = nil
  collectgarbage()
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
  return pcall(self.sta.getap, 1, scan_callback)
end

--[[
-- Wifi Station - Soft Disconnect
--
-- Only disconnects from configured
-- Access Point but doesn't erase
-- credentials from flash.
--]]
function Wifi:soft_disconnect(callback)
  return pcall(self.sta.disconnect, callback)
end

--[[
-- Wifi Station Hard Disconnect
--
-- Disconnects from configured Access
-- Point and delete credentials from
-- flash.
--]]
function Wifi:hard_disconnect(callback)
  assert(self.sta.clearconfig())
end

--[[
-- Register callback for Wifi-specific
-- event (AP and STA events).
--
-- Supported event enums under Wifi.evt:
--
-- STA_CONNECTED        0
-- STA_DISCONNECTED     1
-- STA_AUTHMODE_CHANGE  2
-- STA_GOT_IP           3
-- STA_DHCP_TIMEOUT     4
-- AP_STADISCONNECTED   5
-- AP_STACONNECTED      6
-- AP_PROBEREQRECVED    7
--
-- doc ref:
-- https://nodemcu.readthedocs.io/en/release/modules/wifi/#wifieventmonregister
--]]
function Wifi:subscribe(evt, callback)
  pcall(self.wifi.eventmon.register, evt, callback)
end

function Wifi:unsubscribe(evt)
  pcall(self.wifi.eventmon.unregister(evt))
end


return Wifi
