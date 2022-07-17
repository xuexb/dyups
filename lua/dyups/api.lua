local mysql = require("resty.mysql")
local ltn12 = require("ltn12")
local cjson = require("cjson")
local httpc = require("resty.http").new()

local _M = {};

_M.DYUPS_DB_HOST = os.getenv("DYUPS_DB_HOST")
_M.DYUPS_DB_PORT = os.getenv("DYUPS_DB_PORT")
_M.DYUPS_DB_DATABASE = os.getenv("DYUPS_DB_DATABASE")
_M.DYUPS_DB_USER = os.getenv("DYUPS_DB_USER")
_M.DYUPS_DB_PASSWORD = os.getenv("DYUPS_DB_PASSWORD")
_M.DYUPS_DB_CHARSET = os.getenv("DYUPS_DB_CHARSET")

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

function _M:connect()
    local db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return nil
    end

    db:set_timeout(3000) -- 3 sec

    local ok, err, errcode, sqlstate = db:connect{
        host = _M.DYUPS_DB_HOST,
        port = _M.DYUPS_DB_PORT,
        database = _M.DYUPS_DB_DATABASE,
        user = _M.DYUPS_DB_USER,
        password = _M.DYUPS_DB_PASSWORD,
        charset = _M.DYUPS_DB_CHARSET
    }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return nil
    end

    return db
end

function _M:close(db)
    if not db then return nil end
    db:close()
    return nil
end

function _M:parseServer(data)
    if not data or #data == 0 then return {} end
    for i, v in ipairs(data) do
        data[i].server = cjson.decode(data[i].server)
    end
    return data
end

function _M:getAll()
    local db = _M:connect();
    if not db then return nil end
    local sql = "select domain, server from upstream"
    local res, err, errno, sqlstate = db:query(sql)
    _M:close(db)

    if res then
        return _M:parseServer(res)
    else
        return nil
    end
end

function _M:getByDomain(domain)
    local db = _M:connect();
    if not db then
        return nil
    end
    local sql = "select domain, server from upstream where domain = " .. ngx.quote_sql_str(domain) .. " limit 1"
    local res, err, errno, sqlstate = db:query(sql)
    _M:close(db)

    if res then
        return _M:parseServer(res)[1]
    else
        return nil
    end
end

function _M:removeDomain(domain)
    local db = _M:connect();
    if not db then return nil end
    local sql = "delete from upstream where domain = " .. ngx.quote_sql_str(domain)
    local res, err, errno, sqlstate = db:query(sql)
    _M:close(db)
    return res
end

function _M:addDomain(domain, server)
    local db = _M:connect();
    if not db then
        return nil
    end
    local sql = "INSERT INTO upstream (domain, server) VALUES (\'" .. domain .. "\', \'" .. server .. "\') ON DUPLICATE KEY UPDATE server=VALUES(server)"
    local res, err, errno, sqlstate = db:query(sql)
    _M:close(db)
    return res
end

function _M:reload()
    local data = _M:getAll()
    if not data then
        return nil
    end
    local upstreams = {}
    for i, v in ipairs(data) do
        ngx.shared.upstream_list:set(v.domain, cjson.encode(v.server))
    end
    return true
end

function _M:sync()
    local db = _M:connect();
    if not db then
        return nil
    end
    local sql = "select address, remark from agent"
    local res, err, errno, sqlstate = db:query(sql)
    _M:close(db)

    if not res then
        return nil
    end

    local result = {}
    for k, v in ipairs(res) do
        local data, err = httpc:request_uri('http://' .. v.address .. "/api/reload", {
            method = "GET",
            headers = {
                ["x-dyups-token"] = os.getenv("DYUPS_TOKEN"),
                ["host"] = "dyups"
            }
        })
        if not data or data.status ~= 200 then
            result[v.remark] = data and data.status or err
        else
            result[v.remark] = "OK"
        end
    end
    return result
end

function _M:get(domain)
    local data = ngx.shared.upstream_list:get(domain)
    if not data then return nill end
    return cjson.decode(data)
end

return _M
