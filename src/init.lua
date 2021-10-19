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
         |||  ||  || | ||   |||||||  ||   || || | | || ||||  |||
              ||  ||  |||   ||   ||  ||   || ||  |  || ||
             |||| ||   ||  |||| ||||   |||   ||     || |||||

    |||||   |||   |||| ||||       ||||| ||||| ||   ||  |||||   |||   ||||||
   ||     ||   ||  ||   ||       ||     ||    |||  || ||     ||   || ||   ||
     ||   ||   ||  ||   ||         ||   ||||  || | ||   ||   ||   || |||||
       || ||   ||  ||   ||  ||       || ||    ||  |||     || ||   || ||  ||
   |||||    |||   |||| |||||||   |||||  ||||| ||   || |||||    |||   ||   ||

                              |||        |||        ||
                            ||   ||    ||   ||     |||
                     || ||  ||   ||    ||   ||      ||
                      |||   ||   ||    ||   ||      ||
                       |      |||   ||   |||   ||  ||||
]])
local Wifi = require 'wifi_if'

local network = Wifi:new()
network:ap_init()

network:subscribe(Wifi.evt.AP_STACONNECTED, function (...)
  for k,v in pairs(({...})[1]) do print(k,v) end

  network:subscribe(Wifi.evt.AP_STADISCONNECTED, function (...)
    for k,v in pairs(({...})[1]) do print(k,v) end

  end)
end)


local Button = require 'button'
local mode_btn = Button:new(1)

mode_btn:subscribe(Button.x1, Button.SHORT_PRESS, function()
  print('>> Single press')
end)

mode_btn:subscribe(Button.x3, Button.LONG_PRESS, function()
  print('>> Triple long press')
end)

mode_btn:subscribe(Button.x2, Button.SHORT_PRESS, function()
  print('>> Double press')
end)
mode_btn:init()
