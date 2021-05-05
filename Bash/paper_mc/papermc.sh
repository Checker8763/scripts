#!/usr/bin/env bash

# -----
# Global variables
# -----

BASE_URL="https://papermc.io/api/v2/projects/paper"

URL=$BASE_URL

CURL_CMD=`curl -s -X GET $URL -H  "accept: application/json"`

PAPER_INFO=$CURL_CMD

# -----
# Initial checks
# -----

# TODO: check if curl and jq are installed

if [ -z $PAPER_INFO  ]    # if LATEST_BUILD empty
then
    echo "No Internet connection!"
    exit 1
fi



# -----
#  Functions
# -----

get_versions() {
    echo $PAPER_INFO | jq  .versions
    echo "latest for latest version"
    exit 0
}

print_help () {
    echo "Usage: papermc COMMAND ARGS"
    echo "COMMANDs:"
    echo "help: this command"
    echo "versions: gets every available version"
    echo "get {version} {build}: downloads specific version"
    echo "  version can be latest"
    exit 0
}

download_version() {
    # $1 version
    # $2 build
    if [ $1 = "latest" ]
    then
        VERSION=$(curl -s -X GET $BASE_URL -H  "accept: application/json" | jq --raw-output .versions[-1])
    else
        VERSION=$1
    fi
    
    URL=$BASE_URL/versions/$VERSION

    
    if [ -z $2 ] #If no BUILD is supplied: get latest
    then
        BUILD=$(curl -s -X GET $URL -H  "accept: application/json" | jq --raw-output .builds[-1])
    else
        BUILD=$2
    fi
    
    URL=$URL/builds/$BUILD

    
    DOWNLOAD_NAME=$(curl -s -X GET $URL -H  "accept: application/json" | jq --raw-output .downloads.application.name)

    if [ $DOWNLOAD_NAME = "null"  ]
    then
        echo "Couldn't find a download for the specified version ($VERSION) and build ($BUILD)."
        echo "Run 'versions' command to see available versions."
        exit 1
    fi

    URL=$URL/downloads/$DOWNLOAD_NAME


    echo VERSION: $VERSION
    echo BUILD: $BUILD
    echo DOWNLOAD_NAME: $DOWNLOAD_NAME
    echo DOWNLOAD_URL: $URL

    echo Downloading...
    curl -s -o $DOWNLOAD_NAME $URL
    echo DONE!

}

case $1 in
    "versions" )
        get_versions
    ;;
    
    "help" )
        print_help
    ;;

    "get" )
        
        if [ -z $2 ]
        then
            echo "No version supplied!"
            exit 1
        fi

        download_version $2 $3
        
    ;;

    *) # This catches all cases that weren't previously listed. That's why it has the wildcard "*" operator.
        print_help
    ;;
esac
