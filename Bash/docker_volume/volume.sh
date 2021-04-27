#!/usr/bin/env bash

backup () {
    # $1 volume_name
    docker run --rm \
    -v $1:/volume \
    -v $(pwd):/backup \
    busybox:stable \
    tar cf /backup/$1_backup.tar -C /volume .
}

backup_compressed () {
    # $1 volume_name
    docker run --rm \
    -v $1:/volume \
    -v $(pwd):/backup busybox:stable \
    --name backup_$1 \
    tar czf /backup/$1_backup.tar.gz -C /volume .
}

populate () {
    # $1 volume_name
    # $2 tar_ball_name
    docker run --rm \
    -v $1:/volume \
    -v $(pwd):/backup \
    --name populate_$1 \
    busybox:stable tar xaf /backup/$2 -C /volume
}

check_volume () {
    if [ ! $(docker volume ls | grep -o $1) -eq $1 ]   # ← see 'man test' for available unary and binary operators.
    then
        echo No Volume found matching: $1
        exit 1
    fi
}

case $1 in
        # ← put one or more switches here. Use snippet "switch" or snippet "switch multi"
    "backup" )
        check_volume $2
        backup_compressed $2    # ← put your command here
    ;;

    "populate" )
        populate $2 $3    # ← put your command here
    ;;
    
    *) # This catches all cases that weren't previously listed. That's why it has the wildcard "*" operator.
        echo Usage:   
        echo script.sh backup VOLUME_NAME
        echo script.sh populate VOLUME_NAME TAR_BALL
    ;;
esac