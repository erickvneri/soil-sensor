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
local Button = {}

-- Button event constants
Button.x1 = 0x01
Button.x2 = 0x02
Button.x3 = 0x03
Button.DEBOUNCE_TIME = (300 * 1000)
Button.TIMEOUT_MS = (500)

function Button:new(pin)
  local instance = {}

  -- Instance params
  instance.evt_handlers = {}
  instance.pin = pin
  instance.pcount = 0
  instance.timeout = tmr:create()

  -- Configure GPIO mode
  assert(pcall(gpio.mode, instance.pin, gpio.INPUT, gpio.PULLUP))

  setmetatable(instance, {__index=Button})
  return instance
end


--[[
-- Subscribe a callback to button
-- press counts and duration of
-- the press.
--
-- None argument will be passed
-- to the invoked callback.
--]]
function Button:subscribe(press_count, callback)
  self.evt_handlers[press_count] = callback
end


--[[
-- Initialize the task that will
-- keep listening the gpio events.
--]]
function Button:init()

  pcall(gpio.trig, self.pin, 'down', function (...)
    -- timeout callback
    local function timeout_btn()
      local evt_handler = self.evt_handlers[self.pcount]

      -- invoke callback
      pcall(evt_handler)
      self.pcount = 0
    end

    -- debounce press event
    tmr.delay(self.DEBOUNCE_TIME)
    self.pcount = self.pcount + 1

    -- reset timer
    self.timeout:register(self.TIMEOUT_MS, tmr.ALARM_SINGLE, timeout_btn)
    self.timeout:start(true)
  end)
end


return Button
