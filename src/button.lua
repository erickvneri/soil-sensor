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

-- Button constants
Button.x1 = 1
Button.x2 = 2
Button.x3 = 3
Button.x4 = 4
Button.LONG_PRESS = -1
Button.LONG_PRESS_MS = 4000
Button.SHORT_PRESS = -2
Button.SHORT_PRESS_MS = 500
Button.DEBOUNCE_TIME = (200 * 1000)
Button.TIMEOUT_MS = 400
Button.PRESSED = 0
Button.RELEASED = 1
Button.RESTART_TO = true

--[[
-- Button class constructor
--]]
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
function Button:subscribe(press_count, press_lenght, callback)
  self.evt_handlers[press_count] = {
    func = callback,
    press_lenght = press_lenght
  }
end

--[[
-- Initialize the task that will
-- keep listening the gpio events.
--]]
function Button:init()
  pcall(gpio.trig, self.pin, 'both', function(io, ...)
    --[[
    -- Handle Button Press
    -- On Pulled Up GPIO, io = 0
    --]]
    if io == self.PRESSED then
      -- Initialize counting press events
      self.pcount = self.pcount + 1

      -- Initialize timeout timer based on
      -- a long_press ms reference
      -- which will trigger if button is
      -- held.
      self.timeout:register(4000, tmr.ALARM_SINGLE, function()
        local handler = self.evt_handlers[self.pcount]

        -- Validate press subscription
        -- configuration
        if handler and handler.press_lenght == self.LONG_PRESS then
          pcall(handler.func)
        end
        self.pcount = 0
      end)
      -- restart timer
      self.timeout:start(self.RESTART_TO)

      ---[[
      -- Handle Button Release
      -- On Pulled Up GPIO, io = 1
      --]]
    elseif io == self.RELEASED and self.pcount > 0 then
      -- Reinitialize timeout timer based on
      -- a short_press ms reference that will
      -- trigger once button is released (io = 1)
      self.timeout:register(500, tmr.ALARM_SINGLE, function ()
        local handler = self.evt_handlers[self.pcount]

        -- Validate press subscription
        -- configuration
        if handler and handler.press_lenght == self.SHORT_PRESS then
          pcall(handler.func)
        end
        self.pcount = 0
      end)
      -- restart timer
      self.timeout:start(self.RESTART_TO)
    end
  end)
end


return Button
