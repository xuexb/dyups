# dyups

前端小武动态化站点配置

```bash
docker run \
    --rm \
    --name xiaowu-dyups \
    -v $PWD/ca:/etc/nginx/ca \
    -v $PWD/html:/etc/nginx/html \
    -v $PWD/inc:/etc/nginx/inc \
    -v $PWD/vhost:/etc/nginx/vhost \
    -v $PWD/nginx.conf:/etc/nginx/nginx.conf \
    -p 80:80 \
    -p 443:443 \
    -e DYUPS_TOKEN=OK \
    ghcr.io/shangxianapp/nginx:latest-alpine
```