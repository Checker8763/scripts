Filename="paper-231.jar"
Args="-Xms2G -Xmx2G"
Params="nogui"
StartCmd="java $Args -jar $Filename $Params"

echo Filename: $Filename
echo Args: $Args
echo Params: $Params
echo StartCmd: $StartCmd

echo Starting
$StartCmd
Code=$?

# Restart while no crash and no STOP file exists
while [ $Code -eq 0 ] && [ ! -f STOP ]
do
echo Code: $Code
echo Restarting
$StartCmd
Code=$?
done

[ -f STOP ] && echo STOP file exists!

[ ! $Code -eq 0 ] && echo Server crashed!