#!/usr/bin/env bash

# CONFIG
# ----------
Filename="spigot-1.16.5.jar"
Folder="."
Ram=3G
Flags="-Xms$Ram -Xmx$Ram"
Args="nogui"
StartCmd="java $Flags -jar $Filename $Args"
MaxRestarts=3
StopFilePath=STOP
SleepTime=5m
# ----------

echo Filename: $Filename
echo Folder: $Folder
echo Flags: $Flags
echo Args: $Args
echo StartCmd: $StartCmd
echo StopFile: $Folder/$StopFilePath

# VARIABLES
EchoedStop=false
CurrentRestart=0

# Change to folder
cd $Folder

# Restart while no crash and no STOP file exists
while [ $CurrentRestart -le $MaxRestarts ]
do
    if [ -f $StopFilePath ] 
    then
        [ ! $EchoedStop = true ] && \
			echo Not starting due to STOP file being set. && \
            EchoedStop=true
    else
		EchoedStop=false
        echo "(Re)starting"
        echo "(Re)start: $CurrentRestart"
        $StartCmd
        Code=$?
		# https://linuxhint.com/increment-a-variable-in-bash/
        ((++CurrentRestart));
        # Straight restart when crashed
        [ ! $Code -eq 0 ] && \
            echo "Server crashed!" && \
            continue
    fi
    sleep $SleepTime
done

[ ! $CurrentRestart -le $MaxRestarts ] && echo MaxRestarts reached! 
