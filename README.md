# dyups

前端小武动态化站点配置

## API

### Get data

```bash
curl -H 'x-dyups-token: token' dyups/api/list
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