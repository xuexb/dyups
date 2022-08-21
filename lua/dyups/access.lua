local cjson = require("cjson")
local dyups = require("dyups.api")
local resolver = require("resty.dns.resolver")
local domain = ngx.var.dyups
local upstreams = dyups:get(domain)
local upstreamsDNS = dyups:getDNS(domain)

if not ngx.ctx then
    ngx.ctx = {}
end

if upstreamsDNS then
    ngx.ctx.upstreams = upstreamsDNS
elseif upstreams then
   local r, err = resolver:new{
        nameservers = {"8.8.8.8", "114.114.114.114"},
        retrans = 2,
        timeout = 1000,
        no_random = true
    }

    if r then
        for index, server in pairs(upstreams.server) do
            local answers, err, tries = r:query(server.address, {
                qtype = r.TYPE_A
            }, {})
            if not answers.errcode and answers[#answers].address then
                upstreams.server[index].ip = answers[#answers].address
            end
        end
        ngx.shared.upstream_list_dns:set(domain, cjson.encode(upstreams), 60 * 60 * 24)
    end
    ngx.ctx.upstreams = upstreams
end
