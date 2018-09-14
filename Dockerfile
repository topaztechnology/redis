FROM topaztechnology/base:3.6
MAINTAINER Topaz Tech Ltd <info@topaz.technology>

ENV REDIS_VERSION 4.0.2
ENV REDIS_RELEASES http://download.redis.io/releases
ENV REDIS_CHECKSUM b1a0915dbc91b979d06df1977fe594c3fa9b189f1f3d38743a2948c9f7634813

RUN addgroup redis && \
    adduser -S -G redis redis

# Install Redis
RUN \
  apk add --update --no-cache --virtual build-dependencies coreutils build-base linux-headers && \
  curl -Lso /tmp/redis.tar.gz "${REDIS_RELEASES}/redis-${REDIS_VERSION}.tar.gz" && \
  echo "${REDIS_CHECKSUM}  /tmp/redis.tar.gz" | sha256sum -c && \
  cd /tmp && \
  tar zxvf redis.tar.gz && \
  rm redis.tar.gz && \
  cd redis-${REDIS_VERSION} && \
# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
  grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' src/server.h && \
  sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' src/server.h && \
  grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' src/server.h && \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag
# because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
# see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
  make -j "$(nproc)" && \
  make install && \
  apk del build-dependencies && \
  cd /tmp && \
  rm -rf /tmp/redis

COPY containerpilot.json5 /etc/containerpilot.json5
COPY etc/ /etc/redis/
COPY bin/ /usr/local/bin/

RUN \
  mkdir -p /redis/data && \
  chown -R redis:redis /redis/data

VOLUME ["/redis/data"]

WORKDIR /redis/data

EXPOSE 6379 26379
