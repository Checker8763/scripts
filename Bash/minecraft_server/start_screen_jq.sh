#!/bin/bash

CONFIG_PATH=~/mc_config/config.json

SCREEN_NAME=$(cat $CONFIG_PATH | jq -r .screen.name)
FILENAME=$(cat $CONFIG_PATH | jq -r .start.filename)
FOLDER=$(cat $CONFIG_PATH | jq -r .start.folder)
RAM=$(cat $CONFIG_PATH | jq -r .start.ram)

echo Starting $FILENAME
echo inside $FOLDER
echo with $RAM of ram
echo;

cd $FOLDER

echo starting...
# https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/
screen -d -m -S $SCREEN_NAME java -Xms$RAM -Xmx$RAM -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
    -jar $FILENAME nogui

sleep 3

IS_THERE=$(screen -ls | grep $SCREEN_NAME)

if  [ ! IS_THERE ]
then
    echo Server did not start properly!
    exit 1
fi

echo done!
