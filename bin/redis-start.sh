#!/bin/bash

if [ -z "${LOG_LEVEL}" ]; then
  LOG_LEVEL=INFO
fi

function startServer {
  # Either we are:
  # 1) in a Kubernetes StatefulSet, and the first pod ends in -0 for the master
  # 2) in docker-compose, and the hostname is redis
  # 3) in a test container with a random name
  # We will only create a slave when we are a) in Kubernetes and b) not the master

  if [[ $HOSTNAME =~ redis-\d* && ${HOSTNAME: -2} != "-0" ]]; then
    exec /usr/local/bin/redis-server /etc/redis/redis-slave.conf
  else
    exec /usr/local/bin/redis-server /etc/redis/redis-master.conf
  fi
}

function startSentinel {
  if [ -z "${REDIS_MASTER}" ]; then
    # Default for testing in docker-compose stack
    REDIS_MASTER=redis
    SENTINEL_QUORUM=1
  fi

  cat >> /etc/redis/sentinel.conf <<-EOF
sentinel monitor master ${REDIS_MASTER} 6379 ${SENTINEL_QUORUM}
sentinel down-after-milliseconds master 10000
sentinel failover-timeout master 30000
sentinel parallel-syncs master 1
EOF

  exec /usr/local/bin/redis-server /etc/redis/sentinel.conf --sentinel
}

case ${REDIS_TYPE} in
  server)
    startServer
    ;;

  sentinel)
    startSentinel
    ;;

  *)
    echo "Invalid redis type: ${REDIS_TYPE}"; exit 1
    ;;
esac
