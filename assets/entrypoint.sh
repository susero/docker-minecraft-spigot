#!/bin/bash

set -e

USERNAME=spigot-user
USER_DIR=/home/${USERNAME}
DATA_DIR=${USER_DIR}/data
BUILD_DIR=${DATA_DIR}/build
GAME_DIR=${DATA_DIR}/game
# SYSTEM SETTINGS
USERMAP_UID=${USERMAP_UID:-$(id -u spigot-user)}
USERMAP_GID=${USERMAP_UID:-$(id -g spigot-user)}
TIMEZONE=${TIMEZONE:-Asia/Tokyo}
# GAME SETTINGS
AGREE_TO_EULA=${AGREE_TO_EULA:-false}
# SERVICE SETTINGS
JVM_OPTS=${JVM_OPTS:-}
JVM_XMS=${JVM_XMS:-512M}
JVM_XMX=${JVM_XMX:-1400M}
JVM_XXMPS=${JVM_XXMPS:-128M}

build_spigot() {
   sudo -u ${USERNAME} mkdir -p ${BUILD_DIR}
   cd ${BUILD_DIR}
   [ -e BuildTools.jar ] || sudo -u ${USERNAME} curl -O https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
   sudo -u ${USERNAME} git config --global --unset core.autocrlf || echo "git returned $?"
   sudo -u ${USERNAME} java -jar BuildTools.jar
}

setup_server() {
   [ -d ${GAME_DIR} ] || sudo -u ${USERNAME} mkdir -p ${GAME_DIR}
   sudo -u ${USERNAME} cp ${BUILD_DIR}/spigot-*.jar ${GAME_DIR}/
   sudo -u ${USERNAME} cp ${BUILD_DIR}/craftbukkit-*.jar ${GAME_DIR}/
   echo "eula=${AGREE_TO_EULA}" > ${GAME_DIR}/eula.txt
}

[ $(id -u ${USERNAME}) -eq ${USERMAP_UID} ] || usermod -u ${USERMAP_UID} ${USERNAME}
chown -R ${USERNAME} ${USER_DIR}
[ -d ${BUILD_DIR} ] || build_spigot

echo "${TIMEZONE}" > /etc/timezone
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

[ -d ${GAME_DIR} ] || setup_server

cd ${GAME_DIR}

# build up options
[ ! -z ${JVM_XMS} ] && JVM_OPTS="${JVM_OPTS} -Xms${JVM_XMS}"
[ ! -z ${JVM_XMX} ] && JVM_OPTS="${JVM_OPTS} -Xmx${JVM_XMX}"
[ ! -z ${JVM_XXMPS} ] && JVM_OPTS="${JVM_OPTS} -XX:MaxPermSize=${JVM_XXMPS}"
export JVM_OPTS

if [ $# -eq 0 ]; then
   EXECUTABLE=$(find . -name spigot-\*.jar | sort -r | head -n 1)
   sudo -u ${USERNAME} java ${JVM_OPTS} -jar ${EXECUTABLE} nogui
else
   $@
fi
