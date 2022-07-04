local dyups = require "dyups.api";
local server = dyups:get(ngx.var.dyups);

if not ngx.ctx then
    ngx.ctx = {}
end

ngx.ctx.upstreams = server