#!/bin/bash

docker run \
  --name redis \
  -p 6379:6379 \
  -e LOG_LEVEL=INFO \
  -e REDIS_TYPE=server \
  -v redis-data:/redis/data \
  topaztechnology/redis:4.0.2
