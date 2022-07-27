local balancer = require("ngx.balancer")
local dyups = require("dyups.api")

local upstreams = ngx.ctx.upstreams

ngx.ctx.current = nil

local function getKey(upstream)
    return upstream.address .. ":" .. upstream.port
end

if not upstreams then
    ngx.log(ngx.ERR, "upstreams not found")
    return ngx.exit(502)
end

if not ngx.ctx.retry then
    ngx.ctx.retry = true
    ngx.ctx.tried = {}

    ngx.ctx.current = upstreams[math.random(#upstreams)]

    ngx.ctx.tried[getKey(ngx.ctx.current)] = true

    local ok, err = balancer.set_more_tries(#upstreams - 1)
    if not ok then
        ngx.log(ngx.ERR, "set_more_tries failed: ", err)
    end
else
    for k, upstream in pairs(upstreams) do
        local key = getKey(upstream)
        local in_ctx = ngx.ctx.tried[key] ~= nil
        if in_ctx == false then
            ngx.ctx.tried[key] = true
            ngx.ctx.current = upstream
            break
        end
    end
end

balancer.set_timeouts(2, nil, nil)

local ok, err = balancer.set_current_peer(ngx.ctx.current.address, ngx.ctx.current.port)
if not ok then
    ngx.log(ngx.ERR, "set_current_peer failed: ", err)
    return ngx.exit(502)
end