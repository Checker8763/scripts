#!/bin/bash

CONFIG_PATH=~/mc_config/config.json

SCREEN_NAME=$(cat $CONFIG_PATH | jq -r .screen.name)

screen -S $SCREEN_NAME -X stuff 'save-all\n'
screen -S $SCREEN_NAME -X stuff 'say Server will be shutting down in 30sec!\n'
sleep 30
screen -S $SCREEN_NAME -X stuff 'kick @a Shutting down the servers!\n'
screen -S $SCREEN_NAME -X stuff 'stop\n'