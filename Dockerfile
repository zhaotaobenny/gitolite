# Create gitolite image based on ubuntu

FROM ubuntu:14.04

MAINTAINER Benny.Zhao zhaotao1985@163.com

RUN set -ex \
 && \
 { \
   echo "en_US.UTF-8 UTF-8"; \
   echo "zh_CN.UTF-8 UTF-8"; \
   echo "zh_CN.GBK GBK"; \
   echo "zh_CN GB2312"; \
 } > /var/lib/locales/supported.d/local \
 && \
 { \
   echo "LANG=\"en_US.UTF-8\""; \
   echo "LANGUAGE=\"en_US:en\""; \
   echo "LC_ALL=\"C\""; \
 } > /etc/default/locale \
 && cd /etc && unlink localtime && ln -s /usr/share/zoneinfo/PRC localtime \
 && echo "PRC" > /etc/timezone \
 && locale-gen

RUN set -ex \
 && apt-get update \
 && apt-get install -y git-core openssh-server \
 && apt-get clean && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/*

ENV WORKDIR /home/git
ENV SETUPDIR /opt/gitolite
ENV group git
ENV user git
ENV VERSION v3.6.7
 
RUN set -ex \
 && addgroup ${group} \
 && useradd ${user} -d ${WORKDIR} -m -g $group \
 && mkdir -p ${SETUPDIR} /var/run/sshd \
 && chown -R ${user}:${group} ${SETUPDIR}

WORKDIR "${WORKDIR}"

USER ${user}

RUN set -ex \
 && git clone git://github.com/sitaramc/gitolite \
 && cd "${WORKDIR}/gitolite" \
 && git reset --hard ${VERSION} \
 && ${WORKDIR}/gitolite/install -to=${SETUPDIR} \
 && rm -rf ${WORKDIR}/gitolite

USER root
RUN set -ex \
 && rm -rf /tmp/* /var/cache/* /var/log/* 

VOLUME ["${WORKDIR}", "${SETUPDIR}"]

ADD gitolite-enterpoint.sh /
ENTRYPOINT ["/gitolite-enterpoint.sh"]

EXPOSE 22
CMD ["sshd"]