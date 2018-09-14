# Overview

Sample Kubernetes config to set up a redis cluster, using vSphere storage.

# Usage

Create the cluster with

```
kubectl apply -f redis-server.yaml
```

# Sentinel usage in pods

When using the sentinel mode in a pod, you should include a container spec similiar to the following:

```
- name: sentinel
  image: topaztechnology/redis:4.0.2
  ports:
  - name: sentinel
    containerPort: 26379
  env:
  - name: REDIS_TYPE
    value: sentinel
  - name: REDIS_MASTER
    value: redis-0.redis
  - name: SENTINEL_QUORUM
    value: "3"
  volumeMounts:
  - name: redis-data
    mountPath: /redis/data
```
