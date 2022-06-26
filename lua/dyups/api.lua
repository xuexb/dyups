local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")

local _M = {};

_M.DYUPS_CONSUL_ORIGIN = os.getenv("DYUPS_CONSUL_ORIGIN")
_M.DYUPS_CONSUL_KEY = os.getenv("DYUPS_CONSUL_KEY")


_M._VERSION = "0.1"

function _M:dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. _M:dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end


function _M:update()
    local resp = {}
    local res, code = http.request {
        url = _M.DYUPS_CONSUL_ORIGIN .. "/v1/kv/" .. _M.DYUPS_CONSUL_KEY .. "/?dc=dc1&recurse=true&raw=true",
        sink = ltn12.sink.table(resp)
    }

    if code ~= 200 then
        return false, code
    end

    local resp = table.concat(resp);
    local resp = cjson.decode(resp);
    local upstreams = {}
    for i, v in ipairs(resp) do
        local data = ngx.decode_base64(v.Value)
        local data = cjson.decode(data)
        ngx.shared.upstream_list:set(data.domain, cjson.encode(data))
    end

    return true, code
end

function _M:get(domain)
    local data = ngx.shared.upstream_list:get(domain)
    if not data then return { upstream = nil } end
    return cjson.decode(data)
end

function _M:getAll()
    local data = {}
    local keys = ngx.shared.upstream_list:get_keys()
    for i, key in ipairs(keys) do
        local item = ngx.shared.upstream_list:get(key)
        local item = cjson.decode(item)
        data[item.domain] = item
    end
    return data
end


return _M
