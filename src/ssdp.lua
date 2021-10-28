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
local SSDP = {}

-- SSDP Object constants
SSDP.LOCAL_ADDR = '0.0.0.0'
SSDP.MULTICAST_ADDRESS = '239.255.255.250'
SSDP.MULTICAST_PORT = 1900


--[[
-- SSDP class constructor which
-- intends to encapsulate SSDP
-- config and implementation.
--]]
function SSDP:new()
  -- Initialize instance
  local instance = {}

  setmetatable(instance, {__index = SSDP})
  return instance
end

--[[
-- SSDP.parse_req is a simple
-- utility to parse the string
-- payload into a table.
--]]
function SSDP:parse_req(request)
  local req = {
    headers = {},
    body = nil,
    method = nil,
    proto = nil,
    status = nil
  }

  -- HTTP Request Status
  req.status = request:sub(
    0, request:find('\r\n'))

  -- SSDP Method
  req.method = req.status:sub(
    0, status:find(' '))

  -- SSDP HTTP Protocol
  req.proto = req.status:sub(
    req.status:find('HTTP/1.1'), #req.status)

  -- HTTP Headers & body
  local key_pattern = '(%w+[%w+-]+): '
  local val_pattern = '([%w+-: ()/=;%"%-]+)'
  for k, v in request:gmatch(key_pattern..val_pattern) do
    req.headers[k] = v
  end

  return req
end

--[[
-- SSDP.on_msearch interfaces a
-- UDP server to address MSEARCH
-- requests from multicast group
-- 239.255.255.250
--]]
function SSDP:on_msearch(callback)
  assert(pcall(net.multicastJoin, '', self.MULTICAST_ADDRESS))
  local ssdp = assert(net.createUDPSocket(), 'failed to initialize UDP socket')

  -- Handle Multicast Streams
  ssdp:on('receive', function (conn, req, port, ip)
    local _, req_parsed = pcall(self.parse_req, self, req)

    -- Process through callback
    local _, res = pcall(callback, req_parsed)
    local sent, err = pcall(conn.send, conn, port, ip, res)

    -- Sanity check
    if not sent then
      error(err)
    end
  end)

  -- Disable socket when
  -- SSDP Response has been
  -- sent.
  ssdp:on('sent', function (conn)
    assert(pcall(conn.close, conn))
    assert(pcall(net.multicastLeave, '', self.MULTICAST_ADDRESS))
    ssdp = nil
    collectgarbage()
  end)

  -- Initialize event listener
  ssdp:listen(self.MULTICAST_PORT, self.LOCAL_ADDR)
end


return SSDP
