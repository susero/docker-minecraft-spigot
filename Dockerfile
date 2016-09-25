FROM ubuntu:16.04


RUN apt-get update \
 && apt-get install -y git curl sudo openjdk-8-jre-headless tar vim
ADD assets/*.sh /usr/local/sbin/
RUN chmod +x /usr/local/sbin/* \
 && useradd -m -s /bin/bash spigot

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

VOLUME ["/home/spigot-user/data"]
