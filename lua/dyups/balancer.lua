local balancer = require("ngx.balancer")
local dyups = require("dyups.api")

local upstreams = ngx.ctx.upstreams

ngx.ctx.current = nil

local function set_current_peer(data)
    local ip = data.address
    local port = data.port
    if data.ip then
        ip = data.ip
    end
    local ok, err = balancer.set_current_peer(ip, port)
    if not ok then
        ngx.log(ngx.ERR, "set_current_peer failed: ", err)
        return ngx.exit(500)
    end
end

local function getKey(upstream)
    return upstream.address .. ":" .. upstream.port
end

if not upstreams then
    ngx.log(ngx.ERR, "upstreams not found, set 502")
    return set_current_peer({ address = "127.0.0.1", port = 502 })
end

if not ngx.ctx.retry then
    ngx.ctx.retry = true
    ngx.ctx.tried = {}

    ngx.ctx.current = upstreams.server[math.random(#upstreams.server)]

    ngx.ctx.tried[getKey(ngx.ctx.current)] = true

    local ok, err = balancer.set_more_tries(#upstreams.server - 1)
    if not ok then
        ngx.log(ngx.ERR, "set_more_tries failed: ", err)
    end

    if upstreams.timeout and upstreams.timeout ~= 0 and tostring(upstreams.timeout) ~= "userdata: NULL" then
        balancer.set_timeouts(upstreams.timeout, nil, nil)
    else
        balancer.set_timeouts(2, nil, nil)
    end
else
    for k, server in pairs(upstreams.server) do
        local key = getKey(server)
        local in_ctx = ngx.ctx.tried[key] ~= nil
        if in_ctx == false then
            ngx.ctx.tried[key] = true
            ngx.ctx.current = server
            break
        end
    end
end

if ngx.ctx.current then
    set_current_peer(ngx.ctx.current)
else
    ngx.log(ngx.ERR, "ngx.ctx.current is nil")
    ngx.exit(500)
end