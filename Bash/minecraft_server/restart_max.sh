#!/usr/bin/env bash

# CONFIG
# ----------
Filename="spigot-1.16.5.jar"
Ram=3G
Args="-Xms$Ram -Xmx$Ram"
Params="nogui"
StartCmd="java $Args -jar $Filename $Params"
MaxRestarts=3
# ----------

echo Filename: $Filename
echo Args: $Args
echo Params: $Params
echo StartCmd: $StartCmd

# VARIABLES
EchoedStop=false
CurrentRestart=0

echo Starting
$StartCmd
Code=$?

# Restart while no crash and no STOP file exists
while [ $Code -eq 0 ] && [ $CurrentRestart -le $MaxRestarts ]
do
    if [ -f STOP ] # If File STOP exist
    then
        [ ! EchoedStop ] && \
			echo Not starting due to STOP file being set.
		EchoedStop=true
    else
		EchoedStop=false
        echo Code: $Code
        echo Restarting
        $StartCmd
        Code=$?
		# https://linuxhint.com/increment-a-variable-in-bash/
        ((++CurrentRestart))
    fi
    sleep 5
done


[ -f STOP ] && echo STOP file exists!

[ $CurrentRestart -le $MaxRestarts ] && echo MaxRestarts reached!

[ ! $Code -eq 0 ] && echo Server crashed!