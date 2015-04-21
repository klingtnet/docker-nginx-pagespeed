# docker-nginx-pagespeed

A debian based docker image that runs an nginx with google's pagespeed module.

## build the container

```sh
docker build -t nginx-pagespeed .
```

## run the container

```sh
[ENV=VALUE [ENV=VALUE]] ./run.sh
```

You can specify the following options via environment variables:

- `NAME` the container name
- `HTTP_PORT`
- `SSL_PORT`
- `CONFIG_PATH` must be absolute
- `SITES` absolute path to website content
