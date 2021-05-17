#!/usr/bin/env bash

# CONFIG
# ----------
Filename="spigot-1.16.5.jar"
Ram=3G
Flags="-Xms$Ram -Xmx$Ram"
Args="nogui"
StartCmd="java $Flags -jar $Filename $Args"
MaxRestarts=3
SleepTime=5m
# ----------

echo Filename: $Filename
echo Flags: $Flags
echo Args: $Args
echo StartCmd: $StartCmd

# VARIABLES
Stopped=false
CurrentRestart=0

echo Starting
$StartCmd
Code=$?

# Restart while no crash and no STOP file exists
while [ $Code -eq 0 ] && [ $CurrentRestart -le $MaxRestarts ]
do
    if [ -f STOP ] # If File STOP exist
    then
        [ ! Stopped ] && \
			echo Not starting due to STOP file being set.
		Stopped=true
    else
		Stopped=false
        echo Code: $Code
        echo Restarting
        $StartCmd
        Code=$?
		# https://linuxhint.com/increment-a-variable-in-bash/
        ((++CurrentRestart))
    fi
    sleep $SleepTime
done


[ -f STOP ] && echo STOP file exists!

[ $CurrentRestart -le $MaxRestarts ] && echo MaxRestarts reached!

[ ! $Code -eq 0 ] && echo Server crashed!