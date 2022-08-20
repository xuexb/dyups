local dyups = require("dyups.api");
local upstreams = dyups:get(ngx.var.dyups);

if not ngx.ctx then
    ngx.ctx = {}
end

ngx.ctx.upstreams = upstreams
