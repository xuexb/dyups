# dyups

OpenResty Dynamic Upstream

前端小武动态化转发服务，配合泛域名可轻松部署一个独立域名服务。

## Features

- [x] MySQL 数据持久化
- [x] Agent 同步
- [x] 多机部署
- [x] Upstream 动态加载
- [x] Upstream 负载均衡
- [x] Upstream 支持域名解析（解析缓存1天）
- [x] Token 鉴权
    - Cookie - `x_dyups_token=value`
    - GET param - `token=value`
    - Request Header - `x-dyups-token=value`
- [x] 响应 Headers
    - `x-dyups-target` - 当前响应服务的目标地址（IP/域名+端口）
- [x] 向上游应用服务透传 Headers
    - `host` - `127.0.0.1` ，用于破解备案限制
    - `x-dyups` - `true`
    - `x-dyups-host` - 用户真实 Host
    - `x-dyups-scheme` - 用户访问的协议
    - `x-dyups-ip` - 用户真实 IP

## API

### Get data

```bash
curl -H 'x-dyups-token: token' dyups/api/all
curl -H 'x-dyups-token: token' dyups/api/test.xuexb.com
```

### Add

```bash
curl -H 'x-dyups-token: token' \
    -X POST \
    -d '[{"address":"127.0.0.1","port":8080}]' \
    dyups/api/test.xuexb.com

# proxy timeout
curl -H 'x-dyups-token: token' \
    -X POST \
    -d '{"server":[{"address":"127.0.0.1","port":8080}],"timeout":5}' \
    dyups/api/test.xuexb.com
```

### Remove

```bash
curl -H 'x-dyups-token: token' \
    -X DELETE \
    dyups/api/test.xuexb.com
```

### Reload single agent

```bash
curl -H 'x-dyups-token: token' dyups/api/reload
```

### Sync all agent

```bash
curl -H 'x-dyups-token: token' dyups/api/sync
```

## SQL

```sql
SET NAMES utf8mb4;

DROP TABLE IF EXISTS `upstream`;
CREATE TABLE `upstream` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `domain` char(100) NOT NULL DEFAULT '',
  `server` text NOT NULL,
  `timeout` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DROP TABLE IF EXISTS `agent`;
CREATE TABLE `agent` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `address` char(255) NOT NULL DEFAULT '',
  `remark` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
