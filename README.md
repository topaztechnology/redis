# Supported tags and respective `Dockerfile` links
* `latest` [(Dockerfile)](https://github.com/topaztechnology/redis/blob/master/Dockerfile) - the latest release
* `4.0.2` [(Dockerfile)](https://github.com/topaztechnology/redis/blob/master/Dockerfile) - release based on Redis 4.0.2

# Overview

A Redis image built on the Alpine base image, using Joyent's [Containerpilot](https://www.joyent.com/containerpilot) to manage job scheduling. Inspired by the offical Redis [image](https://hub.docker.com/_/redis/).

It is designed to be used either standalone, in a docker-compose stack, or in a Kubernetes StatefulSet.

It can also run in server mode, or sentinel mode.

# How to use this image

```
docker run --name redis -e 'REDIS_TYPE=server' -p 6379:6379 -d topaztechnology/redis:latest
```

# Environment variables

* **REDIS_TYPE** : either `server` or `sentinel`
* **REDIS_MASTER** : used if run in `sentinel` mode, defaults to `redis` to be used in a docker-compose stack. If using Kubernetes this would point to the Kubernetes service (e.g. `redis-0.redis`).
* **SENTINEL_QUORUM** : used if run in `sentinel` mode, defaults to 1 for a docker-compose stack. If used in Kubernetes, this will depend on the number of replicas in your StatefulSet.
