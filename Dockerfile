FROM debian

RUN apt-get update \
 && apt-get install -y git curl sudo openjdk-7-jre-headless tar vim
ADD assets/*.sh /usr/local/sbin/
RUN chmod +x /usr/local/sbin/* \
 && useradd spigot-user

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

VOLUME ["/home/spigot-user/data"]
