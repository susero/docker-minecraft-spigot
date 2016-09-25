#!/bin/bash -x

set -e

USERNAME=spigot
USER_DIR=/home/${USERNAME}
DATA_DIR=${USER_DIR}/data
BUILD_DIR=${DATA_DIR}/build
GAME_DIR=${DATA_DIR}/game
# SYSTEM SETTINGS
USERMAP_UID=${USERMAP_UID:-$(id -u spigot)}
USERMAP_GID=${USERMAP_UID:-$(id -g spigot)}
TIMEZONE=${TIMEZONE:-Asia/Tokyo}
# GAME SETTINGS
AGREE_TO_EULA=${AGREE_TO_EULA:-false}
# SERVICE SETTINGS
JVM_XMS=${JVM_XMS:-1024M}
JVM_XMX=${JVM_XMX:-1024M}

build_spigot() {
   sudo -u ${USERNAME} mkdir -p ${BUILD_DIR}
   cd ${BUILD_DIR}
   [ -e BuildTools.jar ] || sudo -u ${USERNAME} curl -O https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
   #sudo -u ${USERNAME} git config --global --unset core.autocrlf
   sudo -u ${USERNAME} java -jar BuildTools.jar
}

setup_server() {
   [ -d ${GAME_DIR} ] || sudo -u ${USERNAME} mkdir -p ${GAME_DIR}
   sudo -u ${USERNAME} cp ${BUILD_DIR}/spigot-*.jar ${GAME_DIR}/
   [ -e ${BUILD_DIR}/bukkit-*.jar ] && sudo -u ${USERNAME} cp ${BUILD_DIR}/bukkit-*.jar ${GAME_DIR}/
   echo "eula=${AGREE_TO_EULA}" > ${GAME_DIR}/eula.txt
}

[ $(id -u ${USERNAME}) -eq ${USERMAP_UID} ] || usermod -u ${USERMAP_UID} ${USERNAME}
chown -R ${USERNAME} ${USER_DIR}
[ -e ${BUILD_DIR}/BuildTools.log.txt ] || build_spigot

echo "${TIMEZONE}" > /etc/timezone
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

[ -e ${GAME_DIR}/server.properties ] || setup_server

cd ${GAME_DIR}
if [ $# -eq 0 ]; then
   EXECUTABLE=$(find . -name spigot-\*.jar | sort -r | head -n 1)
   sudo -u ${USERNAME} java -Xms${JVM_XMS} -Xmx${JVM_XMX} ${JVM_OPTS} -jar ${EXECUTABLE}
else
   $@
fi
