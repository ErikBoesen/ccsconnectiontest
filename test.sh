#!/bin/bash

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export CYAN='\033[0;36m'
export NC='\033[0m'

export PRE="[${CYAN}CT${NC}] "

function log(){
    case $2 in
        "warning")
            message="${PRE}${YELLOW}WARNING${NC}: $1\n";
            ;;
        "error")
            message="${PRE}${RED}ERROR${NC}: $1\n"
            ;;
        "success")
            message="${PRE}${GREEN}SUCCESS${NC}: $1\n"
            ;;
        *)
            message="${PRE}${BCYAN}LOG${NC}: $1\n"
            ;;
    esac
    printf "$message"
}

# Test connection
ping -c 1 -t 1 google.com
if [ $? = 0 ]; then
	log "Reached Google successfully." "success"
else
    log "Couldn't reach Google." "error"


# Test CCS servers
servers=($(< uri_1.txt) $(< uri_2.txt) $(< uri_3.txt))

for i in $servers; do
    log "Contacting server $((i+1))..."
    resp=$(timeout 2 curl $servers[$i])
    if [ $? = 0 ]; then
        if
        log "success!" "success"
    fi

    # TODO: Complete checks
