FROM ubuntu:18.04

MAINTAINER Yuki Watanabe <watanabe@future-needs.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /monacoin

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} monacoin \
	&& useradd -u ${USER_ID} -g monacoin -s /bin/bash -m -d /monacoin monacoin

ARG MONACOIN_VERSION=${MONACOIN_VERSION:-0.17.1}
ENV MONACOIN_PREFIX=/opt/monacoin-${MONACOIN_VERSION}
ENV MONACOIN_DATA=/monacoin/.monacoin
ENV PATH=/monacoin/monacoin-${MONACOIN_VERSION}/bin:$PATH

RUN set -xe \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        unzip \
        curl \
        && curl -SLO https://github.com/monacoinproject/monacoin/releases/download/monacoin-${MONACOIN_VERSION}/monacoin-${MONACOIN_VERSION}-x86_64-linux-gnu.tar.gz \
        && tar -xzf *.tar.gz -C /monacoin \
        && rm *.tar.gz \
        && apt-get purge -y \
        ca-certificates \
        curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# grab gosu for easy step-down from root
ARG GOSU_VERSION=${GOSU_VERSION:-1.11}
RUN set -xe \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y \
		ca-certificates \
		wget \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin

VOLUME ["/monacoin"]

EXPOSE 9401 9402 19401 19402

WORKDIR /monacoin

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mona_oneshot"]
