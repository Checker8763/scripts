#!/bin/bash

CONFIG_PATH=~/mc_config/config.json

SCREEN_NAME=$(cat $CONFIG_PATH | jq -r .screen.name)

# STOPPING
./stop_screen_jq.sh

# Wait for STOP
NotStopped=$(screen -ls | grep $SCREEN_NAME)
while [ NotStopped ]
do
	sleep 1
	NotStopped=$(screen -ls | grep $SCREEN_NAME)
done

while [ $Code -eq 0 ] && [ ! -f STOP ]
do
echo Code: $Code
echo Restarting
$StartCmd
Code=$?
done

# STARTING
