Filename="spigot-1.16.5.jar"
Folder="."
Ram=3G
Flags="-Xms$Ram -Xmx$Ram"
Args="nogui"
StartCmd="java $Flags -jar $Filename $Args"

echo Filename: $Filename
echo Folder: $Folder
echo Flags: $Flags
echo Args: $Args
echo StartCmd: $StartCmd

Code=0

cd $Folder

# Restart while no crash
while [ $Code -eq 0 ]
do
echo "(Re)starting"
$StartCmd
Code=$?
done

echo Server crashed!