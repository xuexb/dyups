if type(ngx.ctx.current) == "table" then
    local address = ngx.ctx.current.address
    local port = ngx.ctx.current.port
    local target = address .. ":" .. port
    ngx.header["x-dyups-target"] = ngx.encode_base64(target)
end