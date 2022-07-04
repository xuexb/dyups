# dyups

前端小武动态化站点配置

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
```

### Remove

```bash
curl -H 'x-dyups-token: token' \
    -X DELETE \
    dyups/api/test.xuexb.com
```

### Update

```bash
curl -H 'x-dyups-token: token' dyups/api/update
```

## SQL

```sql
SET NAMES utf8mb4;

CREATE TABLE `upstream` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `domain` char(100) NOT NULL DEFAULT '',
  `server` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;
```
