#!/usr/bin/env bash

# -----
# Global variables
# -----

BASE_URL="https://papermc.io/api/v2/projects/paper"

URL=$BASE_URL

CURL_CMD=$(curl -s -X GET $BASE_URL -H "accept: application/json")

PAPER_INFO=$CURL_CMD

# -----
# Initial checks
# -----

exit_error() {
    echo $1
    exit 1
}

jq_help=$(jq --help)

if [ $? -ne 0 ]; then # jq not installed
    exit_error "jq not installed!"
fi

jq_help=$(curl --help)

if [ $? -ne 0 ]; then # curl not installed
    exit_error "curl not installed!"
fi

if [ -z $PAPER_INFO ]; then # if LATEST_BUILD empty
    exit_error "No Internet connection!"
fi

# -----
#  Functions
# -----

fetch_json() {
    # fetches json from url
    # $1 url

    if [ ! $1 ]; then
        echo [fetch_json ]: Not enough arguments
        exit 1
    fi

    curl -s -X GET $1 -H 'accept: application/json'
}

parse_json() {
    # returns json output for the selector in the input
    # $1 selector
    # $2 input (make f***ing sure to put quotes around it)
    if [ ! $1 ] && [ ! $2 ]; then
        echo [parse_json]: Not enough arguments
        exit 1
    fi

    echo $2 | jq -r $1
}

get_version_groups() {
    #prints every version_group
    parse_json .version_groups $PAPER_INFO
}

get_versions() {
    if [ $1 ]; then
        URL=$URL/version_group/$1

        JSON=$(fetch_json $URL)
        SOURCE=$JSON
    else
        SOURCE=$PAPER_INFO
    fi

    VERSIONS=$(parse_json .versions $SOURCE)

    if [ "$VERSIONS" = null ]; then
        parse_json .error "$JSON"
    else
        parse_json .versions "$SOURCE"
    fi
}

get_builds() {
    URL=$URL/versions/$1

    JSON=$(fetch_json $URL)

    parse_json .builds $JSON
}

download_version() {
    # downloads build of a version
    # $1 version
    # $2 build
    if [ $1 = "latest" ]; then
        VERSION=$(parse_json .versions[-1] $PAPER_INFO)
    else
        VERSION=$1
    fi

    URL=$BASE_URL/versions/$VERSION

    if [ -z $2 ]; then #If no BUILD is supplied: get latest
        JSON=$(fetch_json $URL)
        BUILD=$(parse_json .builds[-1] "$JSON")
    else
        BUILD=$2
    fi

    URL=$URL/builds/$BUILD
    JSON=$(fetch_json $URL)

    DOWNLOAD_NAME=$(parse_json .downloads.application.name "$JSON")

    if [ $DOWNLOAD_NAME = "null" ]; then
        echo "Couldn't find a download!"
        echo "Version: $VERSION"
        echo "Build: $BUILD"
        echo "Use 'versions' command to see available versions."
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

print_help() {
    echo "Usage: papermc COMMAND ARGS"
    echo
    echo "COMMANDs:"
    echo "help: this command"
    echo "version_groups: prints every version_group"
    echo "versions {version_group}: prints every available version"
    echo "builds {version}: prints every build for a specific version"
    echo "get {version/latest} {build}: downloads specific version"
    exit 0
}

case $1 in

"version_groups")
    get_version_groups
    ;;

"versions")
    get_versions $2
    ;;

"builds")
    get_builds $2
    ;;

"get")
    if [ -z $2 ]; then
        echo "No version supplied!"
        exit 1
    fi

    download_version $2 $3
    ;;

*)
    print_help
    ;;
esac
